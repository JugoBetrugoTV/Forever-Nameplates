"""Render the actual Lua studio in the widget simulator, never an in-game screenshot.

Pillow draws recorded widget geometry and colors. Client fonts/textures are unavailable:
native textures are visibly hatched, bars use a solid fill, and fonts use DejaVu Sans.
The demo modifies an isolated Lua runtime only, not the addon or user's saved profiles.
"""
import argparse
import json
from functools import lru_cache
from pathlib import Path

from lupa.lua51 import LuaRuntime
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
FONT = Path('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf')
POINTS = {'CENTER': (.5, .5), 'LEFT': (0, .5), 'RIGHT': (1, .5),
          'TOP': (.5, 0), 'BOTTOM': (.5, 1), 'TOPLEFT': (0, 0),
          'TOPRIGHT': (1, 0), 'BOTTOMLEFT': (0, 1), 'BOTTOMRIGHT': (1, 1)}


def snapshot(page):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / 'Tests/wow_mock.lua').read_text())
    lua.execute('''
        function GetLocale() return "deDE" end
        local F=getmetatable(UIParent).__index
        local texture,font=F.CreateTexture,F.CreateFontString
        function F:CreateTexture(name,layer)
            local f=texture(self,name,layer); f.drawLayer=layer; return f
        end
        function F:CreateFontString(name,layer)
            local f=font(self,name,layer); f.drawLayer=layer; return f
        end
        function F:SetAllPoints(parent) self.allPoints=parent or self.parent end
        function F:GetFrameLevel() return self.frameLevel or (self.parent and self.parent:GetFrameLevel()+1 or 0) end
        local fill=F.GetStatusBarTexture
        function F:GetStatusBarTexture()
            local f=fill(self); f.previewFill=true; return f
        end
        NS={}
    ''')
    loader = lua.eval('function(code,ns) return assert(loadstring(code))("ForeverNameplates",ns) end')
    for line in (ROOT / 'ForeverNameplates/ForeverNameplates.toc').read_text().splitlines():
        if line and not line.startswith('#'):
            loader((ROOT / 'ForeverNameplates' / line).read_text(), lua.globals().NS)
    lua.execute('''
        Mock.Fire(NS.events,"ADDON_LOADED","ForeverNameplates")
        local s=NS.Studio; s.Open(); s.session.snap=0
        assert(s.session:Add("cast")); local cast=s.session.selected
        assert(s.session:Update(cast,{width=103,y=-16}))
        assert(s.session:UpdateFeature("castStyle",{enabled=true,spark=true}))
        assert(s.session:Add("auras")); local aura=s.session.selected
        assert(s.session:UpdateFeature("aura",{sort="ExpirationOnly",limit=6,columns=6}))
        assert(s.session:SetAnchor("health","BOTTOM","TOP",true))
        assert(s.session:Update(aura,{y=22}))
        assert(s.session:Add("castIcon")); assert(s.session:SetAnchor(cast,"RIGHT","LEFT",true))
        s.zoom=2; s.scenario=7; s.Select("health"); s.Refresh()
        s.previewPicker:SetValue(s.scenario)
        previewAura=aura
    ''')
    if page == 'components':
        lua.execute('NS.Studio.Select(previewAura); assert(NS.Studio.ShowPage("components"))')
    lua.execute('for i,f in ipairs(Mock.frames) do f.previewId=i end')
    records = []
    fields = ('kind', 'text', 'width', 'height', 'alpha', 'scale', 'shown', 'enabled',
              'justify', 'rotation', 'texture', 'atlas', 'drawLayer', 'frameLevel',
              'clipsChildren', 'min', 'max', 'value', 'reverse', 'orientation', 'previewFill')
    arrays = ('font', 'color', 'vertexColor', 'textColor', 'statusColor', 'insets')
    frames = lua.globals().Mock.frames
    for i in range(1, len(frames) + 1):
        f = frames[i]
        record = {'id': i}
        for key in fields:
            if f[key] is not None:
                record[key] = f[key]
        for key in arrays:
            if f[key] is not None:
                record[key] = [f[key][j] for j in range(1, len(f[key]) + 1)]
        for key in ('parent', 'allPoints', 'thumb'):
            if f[key] is not None:
                record[key] = f[key]['previewId']
        if f.point is not None:
            record['point'] = [v['previewId'] if hasattr(v, 'items') else v
                               for v in [f.point[j] for j in range(1, len(f.point) + 1)]]
        records.append(record)
    return records, lua.globals().NS.Studio.root.previewId, lua.globals().NS.version


class Renderer:
    def __init__(self, records, root, factor, font):
        self.nodes = {r['id']: r for r in records}
        self.root = root
        self.factor = factor
        self.font_path = font
        self.origin = self.rect(root)[:2]
        self.size = (round(1080 * factor), round(680 * factor))
        self.image = Image.new('RGBA', self.size, (11, 13, 17, 255))
        self.missing = set()

    @lru_cache(None)
    def font(self, size):
        return ImageFont.truetype(str(self.font_path), max(1, round(size * self.factor)))

    @lru_cache(None)
    def scale(self, i):
        n = self.nodes[i]
        return n.get('scale', 1) * (self.scale(n['parent']) if n.get('parent') else 1)

    @lru_cache(None)
    def visible(self, i):
        n = self.nodes[i]
        return n.get('shown', True) and (self.visible(n['parent']) if n.get('parent') else True)

    @lru_cache(None)
    def alpha(self, i):
        n = self.nodes[i]
        return n.get('alpha', 1) * (self.alpha(n['parent']) if n.get('parent') else 1)

    @lru_cache(None)
    def level(self, i):
        n = self.nodes[i]
        return n.get('frameLevel', self.level(n['parent']) + 1 if n.get('parent') else 0)

    @lru_cache(None)
    def belongs(self, i):
        n = self.nodes[i]
        return i == self.root or bool(n.get('parent') and self.belongs(n['parent']))

    @lru_cache(None)
    def rect(self, i):
        n = self.nodes[i]
        if n.get('previewFill'):
            p=self.nodes[n['parent']]
            x,y,w,h=self.rect(n['parent'])
            ratio=max(0,min(1,(p.get('value',0)-p.get('min',0))/max(.001,p.get('max',100)-p.get('min',0))))
            if p.get('orientation')=='VERTICAL':
                return x,y if p.get('reverse') else y+h*(1-ratio),w,h*ratio
            return x+w*(1-ratio) if p.get('reverse') else x,y,w*ratio,h
        if n.get('allPoints'):
            return self.rect(n['allPoints'])
        size = n.get('font', ['', 11])[1]
        text = n.get('text', '')
        w = n.get('width', max((len(s) for s in text.split('\n')), default=0) * size * .58 if text else 1)
        h = n.get('height', (text.count('\n') + 1) * size * 1.22 if text else 1)
        scale = self.scale(i)
        w, h = w * scale, h * scale
        if not n.get('parent'):
            return 0, 0, w, h
        p = n.get('point', ['CENTER'])
        own = POINTS[p[0]]
        if len(p) > 1 and isinstance(p[1], int) and len(p) > 2 and isinstance(p[2], str):
            ref = p[1]
            relative = POINTS[p[2]]
            dx, dy = p[3:5] if len(p) > 4 else (0, 0)
        else:
            ref = n['parent']
            relative = own
            dx, dy = p[1:3] if len(p) > 2 else (0, 0)
        x, y, rw, rh = self.rect(ref)
        return x + rw * relative[0] + dx * scale - w * own[0], y + rh * relative[1] - dy * scale - h * own[1], w, h

    def box(self, i):
        x, y, w, h = self.rect(i)
        return tuple(round(v * self.factor) for v in (x-self.origin[0], y-self.origin[1], x-self.origin[0]+w, y-self.origin[1]+h))

    def color(self, value, i):
        v = list(value or [1, 1, 1, 1])
        return tuple(round(max(0, min(1, c)) * 255) for c in v[:3]) + (round((v[3] if len(v) > 3 else 1) * self.alpha(i) * 255),)

    def label(self, draw, n, box):
        size = n.get('font', ['', 11])[1] * self.scale(n['id'])
        font = self.font(size)
        x, y, r, b = box
        text = n.get('text', '')
        if not text:
            return
        lines = []
        width = max(1, r - x)
        for paragraph in text.split('\n'):
            if 'width' not in n and not n.get('allPoints'):
                lines.append(paragraph)
                continue
            words = paragraph.split(' ')
            line = ''
            for word in words:
                trial = (line + ' ' + word).strip()
                if line and draw.textlength(trial, font=font) > width:
                    lines.append(line); line = word
                else:
                    line = trial
            lines.append(line)
        line_height = size * self.factor * 1.22
        if n.get('allPoints') or n['kind'] == 'EditBox':
            y += max(0, ((b-y) - line_height*len(lines))/2)
        if n['kind'] == 'EditBox':
            x += n.get('insets', [7])[0] * self.scale(n['id']) * self.factor
        for line in lines:
            offset = 0
            if n.get('justify') == 'CENTER':
                offset = (width-draw.textlength(line, font=font))/2
            draw.text((x+offset, y), line, font=font, fill=self.color(n.get('textColor'), n['id']), anchor='lt')
            y += line_height

    def render(self):
        layers = {'BACKGROUND': 0, 'BORDER': 1, 'ARTWORK': 2, 'OVERLAY': 3, 'HIGHLIGHT': 4}
        items = [n for n in self.nodes.values() if self.belongs(n['id']) and self.visible(n['id'])]
        items.sort(key=lambda n: (self.level(n.get('parent', n['id'])) if n['kind'] in ('Texture','FontString') else self.level(n['id']),
                                 layers.get(n.get('drawLayer'), 2), n['id']))
        for n in items:
            i = n['id']; box = self.box(i)
            layer = Image.new('RGBA', self.size)
            draw = ImageDraw.Draw(layer)
            if n.get('drawLayer') == 'HIGHLIGHT':
                continue
            if n['kind'] == 'Texture':
                if n.get('thumb'):
                    continue
                parent = self.nodes.get(n.get('parent'), {})
                if parent.get('kind') == 'Slider' and parent.get('thumb') == i:
                    continue
                if n.get('color') or n.get('texture') == 'Interface\\Buttons\\WHITE8X8':
                    draw.rectangle(box, fill=self.color(n.get('color') or n.get('vertexColor'), i))
                elif n.get('texture') or n.get('atlas'):
                    self.missing.add(str(n.get('texture') or n.get('atlas')))
                    if n.get('texture') == 'Interface\\Tooltips\\Nameplate-Border':
                        draw.rectangle(box,outline=(131,142,158,200),width=max(1,round(self.factor)))
                        self.image=Image.alpha_composite(self.image,layer)
                        continue
                    draw.rectangle(box, fill=(56, 63, 73, 230), outline=(131, 142, 158, 240))
                    x,y,r,b=box
                    for offset in range(-int(b-y), int(r-x)+1, max(4, round(4*self.factor))):
                        draw.line((x+offset,y,x+offset+(b-y),b),fill=(106,119,140,150),width=1)
                    mask=Image.new('L',self.size); ImageDraw.Draw(mask).rectangle(box,fill=255)
                    layer.putalpha(Image.composite(layer.getchannel('A'),Image.new('L',self.size),mask))
            elif n['kind'] == 'StatusBar':
                x,y,r,b=box
                ratio=(n.get('value',0)-n.get('min',0))/max(.001,n.get('max',100)-n.get('min',0))
                ratio=max(0,min(1,ratio))
                if n.get('orientation') == 'VERTICAL':
                    if n.get('reverse'): b=y+(b-y)*ratio
                    else: y=b-(b-y)*ratio
                else:
                    if n.get('reverse'): x=r-(r-x)*ratio
                    else: r=x+(r-x)*ratio
                draw.rectangle((x,y,r,b),fill=self.color(n.get('statusColor'),i))
            elif n['kind'] in ('FontString','EditBox'):
                self.label(draw,n,box)
            elif n['kind'] == 'Slider':
                x,y,r,b=box
                ratio=(n.get('value',0)-n.get('min',0))/max(.001,n.get('max',100)-n.get('min',0))
                cx=x+(r-x)*max(0,min(1,ratio))
                draw.rectangle((cx-4*self.factor,y-2*self.factor,cx+4*self.factor,b+2*self.factor),fill=self.color([.78,.63,.37,1],i))
            parent = n.get('parent')
            while parent:
                if self.nodes[parent].get('clipsChildren'):
                    mask = Image.new('L',self.size)
                    ImageDraw.Draw(mask).rectangle(self.box(parent), fill=255)
                    layer.putalpha(Image.composite(layer.getchannel('A'),Image.new('L',self.size),mask))
                parent = self.nodes[parent].get('parent')
            self.image = Image.alpha_composite(self.image, layer)
        return self.image


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=ROOT/'docs/previews')
    parser.add_argument('--font',type=Path,default=FONT)
    args=parser.parse_args()
    if not args.font.is_file():
        parser.error('Provide a TrueType font using --font; original WoW fonts are unavailable here.')
    args.output.mkdir(parents=True,exist_ok=True)
    for page,title in [('studio','Layout-Editor'),('components','Anker, Auren und Casts')]:
        records,root,version=snapshot(page)
        renderer=Renderer(records,root,1.5,args.font)
        image=renderer.render()
        result=Image.new('RGB',(image.width+64,image.height+152),(20,23,30))
        result.paste(image,(32,88),image)
        d=ImageDraw.Draw(result)
        d.text((32,22),f'Forever Nameplates {version}  |  {title}',font=ImageFont.truetype(str(args.font),25),fill=(230,225,215))
        d.text((32,58),'LOKALE LUA-GUI-VORSCHAU · Demo-Profil · kein Ingame-Screenshot',font=ImageFont.truetype(str(args.font),15),fill=(199,161,94))
        d.text((32,image.height+110),'Clientgrafiken: Platzhalterkontur / Schraffur. Balkenfüllung vereinfacht. Ersatzschrift: DejaVu Sans.',
               font=ImageFont.truetype(str(args.font),15),fill=(172,181,194))
        path=args.output/f'forever-nameplates-{version}-{page}.png'
        result.save(path)
        print(path)
        metadata={'version':version,'page':page,'demo_profile':True,'in_game':False,
                  'client_textures_available':False,'font':args.font.name,'missing_textures':sorted(renderer.missing),
                  'limitations':['Simplified rendering of recorded Lua widgets','Approximate text metrics and draw ordering',
                                 'Solid statusbar fills; missing client images outlined or hatched','No native game client or game-world background']}
        path.with_suffix('.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2)+'\n')


if __name__ == '__main__':
    main()
