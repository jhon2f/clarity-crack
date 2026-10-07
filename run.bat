@echo off

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:: Detect Python 3.10
set "PY="
set "PIP="
:: Check the installed interpreter directly, even when PATH is stale.
if exist "C:\Users\Vblak\AppData\Local\Programs\Python\Python310\python.exe" (
    "C:\Users\Vblak\AppData\Local\Programs\Python\Python310\python.exe" -c "import sys; exit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
    if not errorlevel 1 (
        set "PY=C:\Users\Vblak\AppData\Local\Programs\Python\Python310\python.exe"
        goto found_python
    )
)
for /f "delims=" %%i in ('where python 2^>nul') do (
    "%%i" -c "import sys; exit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
    if not errorlevel 1 (
        set "PY=%%i"
        for /f "delims=" %%j in ('where pip 2^>nul') do (
            if not defined PIP set "PIP=%%j"
        )
        goto found_python
    )
)

echo [ERROR] Python 3.10 not found. Run installs.bat first.
pause
exit /b 1

:found_python

:: Verify onnxruntime-directml actually imports (pip show alone is not enough)
"%PY%" -c "import onnxruntime" >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] onnxruntime is broken or missing - reinstalling onnxruntime-directml...
    "%PY%" -m pip uninstall onnxruntime onnxruntime-gpu onnxruntime-directml -y >nul 2>&1
    :: Remove stale gpu stub if present
    "%PY%" -c "import site; print(site.getsitepackages()[0])" > "%TEMP%\_clarity_sp.txt" 2>nul
    set /p _SPKG=<"%TEMP%\_clarity_sp.txt"
    del "%TEMP%\_clarity_sp.txt" >nul 2>&1
    if defined _SPKG (
        if exist "%_SPKG%\onnxruntime\capi\_pybind_state.py" (
            del /f /q "%_SPKG%\onnxruntime\capi\_pybind_state.py" >nul 2>&1
        )
    )
    "%PY%" -m pip install onnxruntime-directml --quiet
    echo Done. Relaunching...
    timeout /t 2 >nul
    start "" "%~f0"
    exit /b
)

"%PY%" "%~dp0extra\launcher.py"
pause
