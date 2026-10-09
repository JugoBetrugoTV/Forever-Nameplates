local _, NS = ...
local Share = {}
NS.Share = Share
local Deflate = LibStub("LibDeflate")
local fields = {"id","kind","source","text","x","y","width","height","alpha","layer","fontSize","enabled","locked","vertical","reverse","shape","asset"}
local bools = {enabled=true,locked=true,vertical=true,reverse=true}
local numbers = {x=true,y=true,width=true,height=true,alpha=true,layer=true,fontSize=true}
local function hex(value)
    return (value:gsub(".", function(c) return string.format("%02x", string.byte(c)) end))
end
local function unhex(value)
    if #value%2~=0 or value:find("[^0-9a-f]") then error("Invalid encoded string") end
    return (value:gsub("..", function(pair) return string.char(tonumber(pair,16)) end))
end
local function split(value, delimiter)
    local result,offset={},1
    while true do
        local first,last=value:find(delimiter,offset,true)
        if not first then result[#result+1]=value:sub(offset); break end
        result[#result+1]=value:sub(offset,first-1); offset=last+1
    end
    return result
end
local extensions={
    {key="anchor",fields={{"ref","s"},{"point","s"},{"relativePoint","s"}}},
    {key="aura",fields={{"filter","s"},{"sort","s"},{"direction","s"},{"limit","n"},{"columns","n"},{"size","n"},{"gap","n"},
        {"own","b"},{"cooldown","b"},{"listMode","s"},{"spells","s"}}},
    {key="castStyle",fields={{"enabled","b"},{"normal","c"},{"channel","c"},{"shield","c"},{"spark","b"},
        {"sparkColor","c"},{"sparkWidth","n"},{"sparkAlpha","n"}}},
}
local function encodeExtensions(e)
    local groups={}
    for _,extension in ipairs(extensions) do
        local values={}; local config=e[extension.key]
        if config then
            for _,field in ipairs(extension.fields) do
                local value=config[field[1]]; local kind=field[2]
                if kind=="c" then for j=1,4 do values[#values+1]=string.format("%.6f",value[j]) end
                elseif kind=="s" then values[#values+1]=hex(value)
                elseif kind=="b" then values[#values+1]=value and "1" or "0"
                else values[#values+1]=string.format("%.6f",value) end
            end
        end
        groups[#groups+1]=table.concat(values,",")
    end
    return hex(table.concat(groups,"\t"))
end
local function decodeExtensions(value,e)
    local groups=split(unhex(value),"\t")
    if #groups~=#extensions then error("Invalid extension groups") end
    for i,extension in ipairs(extensions) do
        if groups[i]~="" then
            local values=split(groups[i],","); local config,offset={},1
            for _,field in ipairs(extension.fields) do
                local kind=field[2]; local value=values[offset]
                if not value then error("Missing extension value") end
                if kind=="c" then
                    value={}; for j=1,4 do value[j]=tonumber(values[offset+j-1]) end; offset=offset+3
                elseif kind=="s" then value=unhex(value)
                elseif kind=="b" then
                    if value~="0" and value~="1" then error("Invalid extension boolean") end
                    value=value=="1"
                else value=tonumber(value) end
                config[field[1]]=value; offset=offset+1
            end
            if offset~=#values+1 then error("Invalid extension field count") end
            e[extension.key]=config
        end
    end
end
function Share.Export(layout)
    local valid, err=NS.Model.Validate(layout)
    if not valid then return nil,err end
    local version=2
    for _,e in ipairs(valid.elements) do if e.anchor or e.aura or e.castStyle then version=3 end end
    local lines={tostring(version),hex(valid.name)}
    local row={hex(valid.rules.healthColor)}
    for _,key in ipairs({"friendlyColor","hostileColor","neutralColor"}) do
        for i=1,4 do row[#row+1]=string.format("%.6f",valid.rules[key][i]) end
    end
    lines[#lines+1]=table.concat(row,";")
    for _,category in ipairs(NS.Rules.categories) do
        local rule=valid.rules.overrides[category.id]
        row={rule.enabled and "1" or "0",rule.visible and "1" or "0",string.format("%.6f",rule.alpha),string.format("%.6f",rule.scale),hex(rule.colorMode)}
        for i=1,4 do row[#row+1]=string.format("%.6f",rule.color[i]) end
        lines[#lines+1]=table.concat(row,";")
    end
    for _, e in ipairs(valid.elements) do
        local row={}
        for _, key in ipairs(fields) do
            local value=e[key]
            if bools[key] then value=value and "1" or "0"
            elseif numbers[key] then value=string.format("%.6f",value)
            else value=hex(value) end
            row[#row+1]=value
        end
        for i=1,4 do row[#row+1]=string.format("%.6f",e.color[i]) end
        if version==3 then row[#row+1]=encodeExtensions(e) end
        lines[#lines+1]=table.concat(row,";")
    end
    local raw=table.concat(lines,"\n")
    if #raw>32768 then return nil,"Layout exceeds share limit" end
    -- Independently compressed small blocks bound the work per decompression call.
    local blocks={}
    for i=1,#raw,160 do
        local compressed=Deflate:CompressDeflate(raw:sub(i,i+159),{level=5})
        blocks[#blocks+1]=Deflate:EncodeForPrint(compressed)
    end
    local code="FN"..version..":"..table.concat(blocks,".")
    if #code>48000 then return nil,"Share code too large" end
    return code
end
local function decode(code)
    if type(code)~="string" or #code>48000 or not code:match("^FN[123]:") then error("Invalid share header or size") end
    local blocks=split(code:sub(5),".")
    local raw,total={},0
    if #blocks>205 then error("Too many compressed blocks") end
    for _, block in ipairs(blocks) do
        if #block==0 or #block>240 or block:find("[^a-zA-Z0-9%(%) ]") then error("Invalid compressed block") end
        local compressed=Deflate:DecodeForPrint(block)
        if not compressed or #compressed>180 then error("Invalid compressed data") end
        local text,left=Deflate:DecompressDeflate(compressed)
        if not text or #text>160 or left~=0 then error("Invalid block output") end
        total=total+#text; if total>32768 then error("Decoded layout too large") end
        raw[#raw+1]=text
    end
    local lines=split(table.concat(raw),"\n")
    local version=tonumber(code:sub(3,3))
    local first=version==1 and 3 or 16
    if lines[1]~=tostring(version) or #lines<first or #lines>first+63 then error("Invalid layout envelope") end
    local layout={version=version==1 and 1 or 2,name=unhex(lines[2]),elements={}}
    if version>=2 then
        local row=split(lines[3],";")
        if #row~=13 then error("Invalid color configuration") end
        layout.rules=NS.Rules.Defaults(); layout.rules.healthColor=unhex(row[1])
        for c,key in ipairs({"friendlyColor","hostileColor","neutralColor"}) do
            for j=1,4 do layout.rules[key][j]=tonumber(row[1+(c-1)*4+j]) end
        end
        for c,category in ipairs(NS.Rules.categories) do
            row=split(lines[3+c],";")
            if #row~=9 or (row[1]~="0" and row[1]~="1") or (row[2]~="0" and row[2]~="1") then error("Invalid rule configuration") end
            local rule={enabled=row[1]=="1",visible=row[2]=="1",alpha=tonumber(row[3]),scale=tonumber(row[4]),colorMode=unhex(row[5]),color={}}
            for j=1,4 do rule.color[j]=tonumber(row[5+j]) end
            layout.rules.overrides[category.id]=rule
        end
    end
    for i=first,#lines do
        local row=split(lines[i],";")
        if #row~=#fields+4+(version==3 and 1 or 0) then error("Invalid field count") end
        local e={color={}}
        for j,key in ipairs(fields) do
            if bools[key] then
                if row[j]~="0" and row[j]~="1" then error("Invalid boolean") end
                e[key]=row[j]=="1"
            elseif numbers[key] then e[key]=tonumber(row[j])
            else e[key]=unhex(row[j]) end
        end
        for j=1,4 do e.color[j]=tonumber(row[#fields+j]) end
        if version==3 then decodeExtensions(row[#row],e) end
        layout.elements[#layout.elements+1]=e
    end
    local valid,err=NS.Model.Validate(layout)
    if not valid then error(err) end
    return valid
end
function Share.Import(code)
    local ok,result=pcall(decode,code)
    if ok then return result end
    return nil,"Import rejected: "..tostring(result)
end
