@echo off
chcp 65001 >nul 2>&1
title U-Claw - Extract and Launch

echo.
echo   ========================================
echo     U-Claw v1.1
echo     Extract and Launch (Windows)
echo   ========================================
echo.

set "SCRIPT_DIR=%~dp0"
set "ARCHIVE=%SCRIPT_DIR%U-Claw.tar.gz"
set "INSTALL_DIR=%SCRIPT_DIR%U-Claw"

REM Check archive
if not exist "%ARCHIVE%" (
    echo   [ERROR] U-Claw.tar.gz not found
    echo   Please ensure this script and the archive are in the same directory
    echo.
    pause
    exit /b 1
)

REM Check if already extracted
if exist "%INSTALL_DIR%\app\core\node_modules" (
    echo   U-Claw already extracted at: %INSTALL_DIR%
    echo.
    echo   [1] Launch directly (skip extract)
    echo   [2] Re-extract (overwrite)
    echo.
    set /p choice="  Choose [1/2, default 1]: "
    if "%choice%"=="2" (
        echo.
        echo   Re-extracting...
        rmdir /s /q "%INSTALL_DIR%" >nul 2>&1
    ) else (
        echo.
        echo   Launching...
        goto :start
    )
)

REM Extract
echo.
echo   Extracting U-Claw to: %INSTALL_DIR%
echo   This may take a few minutes...
echo.

where tar >nul 2>&1
if %errorlevel%==0 (
    cd /d "%SCRIPT_DIR%"
    tar xzf "%ARCHIVE%"
    if %errorlevel% neq 0 (
        echo   Extract failed! Please extract U-Claw.tar.gz manually
        pause
        exit /b 1
    )
) else (
    echo   tar not available. Please extract U-Claw.tar.gz manually
    echo   using 7-Zip or WinRAR to this directory.
    pause
    exit /b 1
)

echo   Extract complete!
echo.

:start
echo   Starting OpenClaw...
echo.

cd /d "%INSTALL_DIR%"
call "%INSTALL_DIR%\Windows-Start.bat"