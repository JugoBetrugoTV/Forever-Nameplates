"""Measure simulated event updates. This is not an in-game FPS benchmark."""
import time
from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute((root / "Tests/wow_mock.lua").read_text())
lua.execute("NS={}")
loader = lua.eval("function(code,ns) local f,e=loadstring(code); assert(f,e); f('ForeverNameplates',ns) end")
for line in (root / "ForeverNameplates/ForeverNameplates.toc").read_text().splitlines():
    if line and not line.startswith("#"):
        loader((root / "ForeverNameplates" / line).read_text(), lua.globals().NS)
lua.execute('Mock.Fire(NS.events,"ADDON_LOADED","ForeverNameplates"); NS.DB.data.live=true; for i=1,40 do Mock.AddUnit("nameplate"..i); NS.Engine.Add("nameplate"..i) end')
before = len(lua.globals().Mock.frames)
start = time.perf_counter()
lua.execute('for j=1,100 do for i=1,40 do NS.Engine.Update("nameplate"..i) end end')
elapsed = time.perf_counter() - start
assert len(lua.globals().Mock.frames) == before
print(f"40 simulated plates, 4,000 event updates: {elapsed:.4f}s; 0 new widget objects")
print("Lua 5.1 widget simulation only. Does not establish in-game CPU, FPS or memory usage.")
