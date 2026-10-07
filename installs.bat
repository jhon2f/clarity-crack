@echo off
title Clarity V2.7 - Dependency Installer

set "original_path=%~dp0"

reg query "HKU\S-1-5-19" >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Running as administrator...
echo(
cd /d "%original_path%"

:: Detect Python 3.10
set "PY="
for /f "delims=" %%i in ('where python 2^>nul') do (
    "%%i" -c "import sys; exit(0 if sys.version_info[:2]==(3,10) else 1)" >nul 2>&1
    if not errorlevel 1 (
        set "PY=%%i"
        goto found_python
    )
)

echo Python 3.10 not found on this system.
if not exist "%original_path%extra\python-3.10.5-amd64.exe" (
    echo Python installer not found in extra folder. Downloading from python.org...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe' -OutFile '%original_path%extra\python-3.10.5-amd64.exe' -UseBasicParsing" >nul 2>&1
    if not exist "%original_path%extra\python-3.10.5-amd64.exe" (
        echo ERROR: Failed to download Python 3.10.5 installer. Check your internet connection.
        echo You can also download it manually from:
        echo   https://www.python.org/ftp/python/3.10.5/python-3.10.5-amd64.exe
        echo Place it in the extra folder and run this script again.
        pause
        exit /b 1
    )
    echo Download complete.
)
echo Running Python 3.10.5 installer...
echo IMPORTANT: Check "Add Python to PATH" and "Install for all users" on the first screen.
echo Then click Install Now.
echo(
start "" /wait "%original_path%extra\python-3.10.5-amd64.exe"
echo(
echo Please close and reopen this script after Python installation completes.
pause
exit /b

:found_python
echo Python 3.10 detected: %PY%
"%PY%" --version
echo(

:: Upgrade pip
echo Upgrading pip...
"%PY%" -m pip install --upgrade pip --quiet
if %errorlevel% neq 0 (
    echo ERROR: Failed to upgrade pip.
    pause
    exit /b 1
)
echo Done.
echo(

:: Microsoft Visual C++ Redistributable (x64) - required so the compiled core
:: module and the native wheels (numpy/onnxruntime/pyqt5/torch) can load. Most
:: machines already have it; quick no-op if so. Non-fatal on failure.
echo Ensuring Microsoft Visual C++ Redistributable (x64)...
if not exist "%original_path%extra\vc_redist.x64.exe" (
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe' -OutFile '%original_path%extra\vc_redist.x64.exe' -UseBasicParsing"
)
if exist "%original_path%extra\vc_redist.x64.exe" (
    start "" /wait "%original_path%extra\vc_redist.x64.exe" /install /quiet /norestart
    echo Visual C++ Redistributable OK.
) else (
    echo NOTE: Could not download the VC++ Redistributable ^(check your connection^). Get it manually from:
    echo   https://aka.ms/vs/17/release/vc_redist.x64.exe
)
echo(

:: Install core packages
echo Installing dependencies (this may take several minutes)...
echo Note: ultralytics will download PyTorch which can be 3-5 GB. This is normal.
echo(
"%PY%" -m pip install pycryptodome termcolor pyqt5 pywin32 requests ultralytics bettercam "dearpygui==2.3.1" opencv-python pyserial keyboard psutil wmi numpy cryptography pygetwindow mss hidapi vgamepad
if %errorlevel% neq 0 (
    echo(
    echo ERROR: One or more packages failed to install.
    echo Check the output above for details.
    pause
    exit /b 1
)
echo(

:: Install MAKCU packages separately - non-fatal if they fail
echo Installing MAKCU packages...
"%PY%" -m pip install makcu pymakcu
if %errorlevel% neq 0 (
    echo WARNING: MAKCU packages could not be installed. This is fine if you are not using a MAKCU device.
    echo If you plan to use a MAKCU, check your internet connection and re-run this script.
) else (
    echo MAKCU packages installed OK.
)
echo(

:: GamePadEmu: vgamepad (installed above) also installs the ViGEmBus driver. HidHide hides your
:: real controller so the game sees only the virtual one (needed for passthrough on a real pad).
:: NOTE: force TLS 1.2 or the GitHub download fails SILENTLY on older Windows PowerShell (defaults
:: to TLS 1.0/1.1, which GitHub refuses) - that's why HidHide wasn't installing.
echo Downloading HidHide (for GamePadEmu)...
if not exist "%original_path%extra\HidHide_Install.exe" (
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/nefarius/HidHide/releases/download/v1.5.230.0/HidHide_1.5.230_x64.exe' -OutFile '%original_path%extra\HidHide_Install.exe' -UseBasicParsing"
)
if exist "%original_path%extra\HidHide_Install.exe" (
    echo Launching the HidHide installer - click through it to finish...
    start "" /wait "%original_path%extra\HidHide_Install.exe"
    echo HidHide install finished.
) else (
    echo NOTE: HidHide download failed ^(check your connection^). Get it manually from:
    echo   https://github.com/nefarius/HidHide/releases  ^(HidHide_1.5.230_x64.exe^)
)
echo(

:: Fix onnxruntime: ultralytics installs onnxruntime-gpu which conflicts with directml.
:: Uninstall all onnxruntime variants, remove any leftover gpu stubs, then install directml.
echo Fixing onnxruntime-directml (replacing onnxruntime-gpu if present)...
"%PY%" -m pip uninstall onnxruntime onnxruntime-gpu onnxruntime-directml -y >nul 2>&1
"%PY%" -c "import site; print(site.getsitepackages()[0])" > "%TEMP%\_clarity_sp.txt" 2>nul
set /p _SPKG=<"%TEMP%\_clarity_sp.txt"
del "%TEMP%\_clarity_sp.txt" >nul 2>&1
if defined _SPKG (
    if exist "%_SPKG%\onnxruntime\capi\_pybind_state.py" (
        del /f /q "%_SPKG%\onnxruntime\capi\_pybind_state.py"
    )
)
"%PY%" -m pip install onnxruntime-directml --quiet
if %errorlevel% neq 0 (
    echo ERROR: Failed to install onnxruntime-directml.
    pause
    exit /b 1
)
echo Done.
echo(

:: Verify the install actually works
"%PY%" -c "import onnxruntime" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: onnxruntime failed to import after install. Check output above.
    pause
    exit /b 1
)
echo onnxruntime verified OK.
echo(

:: Run pywin32 post-install
echo Running pywin32 post-install step...
"%PY%" -c "import os, sys; print(os.path.join(os.path.dirname(sys.executable), 'Scripts', 'pywin32_postinstall.py'))" > "%TEMP%\_clarity_pw32.txt" 2>nul
set /p _PW32=<"%TEMP%\_clarity_pw32.txt"
del "%TEMP%\_clarity_pw32.txt" >nul 2>&1
if defined _PW32 (
    "%PY%" "%_PW32%" -install >nul 2>&1
)
echo Done.
echo(

echo ========================================
echo Installation completed successfully!
echo You can now launch Clarity using RUN.bat
echo ========================================
timeout /t 3 >nul
exit /b 0
