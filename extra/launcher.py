import os
import sys
import importlib.util

_extra = os.path.dirname(os.path.abspath(sys.argv[0]))
_root  = os.path.dirname(_extra)
sys.path.insert(0, _extra)
os.chdir(_root)

_stale = os.path.join(_extra, "main.py")
if os.path.exists(_stale):
    os.remove(_stale)

_pyd  = os.path.join(_extra, "main.cp310-win_amd64.pyd")
_spec = importlib.util.spec_from_file_location("main", _pyd)
_mod  = importlib.util.module_from_spec(_spec)
sys.modules["main"] = _mod
_spec.loader.exec_module(_mod)
