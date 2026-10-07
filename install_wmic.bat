@echo off
title Clarity - Install WMIC (Windows 11 fix)



reg query "HKU\S-1-5-19" >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo Checking whether wmic is already available...
where wmic >nul 2>&1
if %errorlevel% equ 0 (
    echo wmic is already installed. Nothing to do.
    echo(
    pause
    exit /b 0
)

echo wmic not found. Installing the WMIC capability via DISM (this can take a minute)...
echo(
dism /online /add-capability /capabilityname:WMIC~~~~
if %errorlevel% neq 0 (
    echo(
    echo First attempt failed - trying the short capability name...
    dism /online /add-capability /capabilityname:WMIC
)
echo(

where wmic >nul 2>&1
if %errorlevel% equ 0 (
    echo ========================================
    echo SUCCESS - wmic is now available.
    echo You can now launch Clarity with RUN.bat
    echo ========================================
) else (
    echo ========================================
    echo wmic could NOT be installed on this system.
    echo A newer Clarity build does not need it - it falls back to PowerShell.
    echo If you still get a UUID error, ask for an updated build.
    echo ========================================
)
echo(
pause
exit /b 0
