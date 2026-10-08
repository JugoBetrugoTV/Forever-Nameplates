from pathlib import Path
import pytest
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "ForeverNameplates"

def load_runtime(existing_profile):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / "Tests/wow_mock.lua").read_text())
    lua.execute("NS={}")
    loader = lua.eval("function(code,name,ns) local f,e=loadstring(code); assert(f,e); return f(name,ns) end")
    for line in (ADDON / "ForeverNameplates.toc").read_text().splitlines():
        if line and not line.startswith("#"):
            loader((ADDON / line).read_text(), "ForeverNameplates", lua.globals().NS)
    if existing_profile:
        # Regression coverage for accounts created before original-nameplate layouts existed.
        lua.execute('ForeverNameplatesDB={version=2,profiles={Default=NS.Copy(NS.Presets[1].layout)},characters={},active="Default",live=false}')
    lua.execute('Mock.Fire(NS.events,"ADDON_LOADED","ForeverNameplates")')
    return lua


@pytest.fixture
def runtime():
    return load_runtime(existing_profile=True)

@pytest.fixture
def fresh_runtime():
    return load_runtime(existing_profile=False)
