@echo off
:: Clarity Makcu v2.8 - cracked launcher
:: Starts the local license mock, then runs the app. Any key now verifies.
cd /d "%~dp0"

set "PY="
if exist "%LOCALAPPDATA%\Programs\Python\Python310\python.exe" set "PY=%LOCALAPPDATA%\Programs\Python\Python310\python.exe"
if not defined PY if exist "C:\Program Files\Python310\python.exe" set "PY=C:\Program Files\Python310\python.exe"
if not defined PY set "PY=python"

echo [1/2] starting license mock server...
start "clarity-crack-server" /min "%PY%" "%~dp0extra\crack_server.py"
timeout /t 2 /nobreak >nul

echo [2/2] launching Clarity...
call "%~dp0run.bat"
