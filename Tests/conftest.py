from pathlib import Path
import pytest
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "ForeverNameplates"

@pytest.fixture
def runtime():
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / "Tests/wow_mock.lua").read_text())
    lua.execute("NS={}")
    loader = lua.eval("function(code,name,ns) local f,e=loadstring(code); assert(f,e); return f(name,ns) end")
    for line in (ADDON / "ForeverNameplates.toc").read_text().splitlines():
        if line and not line.startswith("#"):
            loader((ADDON / line).read_text(), "ForeverNameplates", lua.globals().NS)
    lua.execute('Mock.Fire(NS.events,"ADDON_LOADED","ForeverNameplates")')
    return lua
