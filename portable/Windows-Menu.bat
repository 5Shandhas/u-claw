@echo off
chcp 65001 >nul 2>&1
title U-Claw Menu

set "UCLAW_DIR=%~dp0"
set "CORE_DIR=%UCLAW_DIR%app\core-win"
set "DATA_DIR=%UCLAW_DIR%data"
set "STATE_DIR=%DATA_DIR%\.openclaw"
set "NODE_DIR=%UCLAW_DIR%app\runtime\node-win-x64"
set "NODE_BIN=%NODE_DIR%\node.exe"

set "OPENCLAW_HOME=%DATA_DIR%"
set "OPENCLAW_STATE_DIR=%STATE_DIR%"
set "OPENCLAW_CONFIG_PATH=%STATE_DIR%\openclaw.json"
set "PATH=%NODE_DIR%;%PATH%"

set "OPENCLAW_MJS=%CORE_DIR%\node_modules\openclaw\openclaw.mjs"

if not exist "%STATE_DIR%" mkdir "%STATE_DIR%"
if not exist "%DATA_DIR%\memory" mkdir "%DATA_DIR%\memory"
if not exist "%DATA_DIR%\backups" mkdir "%DATA_DIR%\backups"
if not exist "%DATA_DIR%\logs" mkdir "%DATA_DIR%\logs"

:menu
cls
echo.
echo   ========================================
echo     U-Claw v1.1 - Menu
echo     Portable AI Agent
echo   ========================================
echo.

if exist "%NODE_BIN%" (
    for /f "tokens=*" %%v in ('"%%NODE_BIN%%" --version') do echo   Node: %%v
) else (
    echo   [!] Node.js not found
)
if exist "%STATE_DIR%\openclaw.json" (echo   Config: OK) else (echo   Config: NOT SET)
echo.
echo   -- Config --
echo   [1] Setup wizard (model, API key)
echo   [2] Open web dashboard
echo.
echo   -- Chat Platforms --
echo   [3] QQ Bot (pre-installed, enter ID only)
echo   [4] Other platforms (Feishu/Telegram/WeChat)
echo.
echo   -- Maintenance --
echo   [5] Diagnostics
echo   [6] Backup config
echo   [7] Restore backup
echo   [8] System info
echo.
echo   -- Advanced --
echo   [9]  Kill residual processes
echo   [10] View logs
echo   [11] Factory reset
echo   [12] Uninstall
echo   [13] Check for updates
echo   [14] Disk cleanup
echo   [15] Plugin management
echo.
echo   [0] Exit
echo.
set /p choice="  Choose [0-15]: "

if "%choice%"=="1" goto :onboard
if "%choice%"=="2" goto :dashboard
if "%choice%"=="3" goto :qqbot
if "%choice%"=="4" goto :channels
if "%choice%"=="5" goto :doctor
if "%choice%"=="6" goto :backup
if "%choice%"=="7" goto :restore
if "%choice%"=="8" goto :sysinfo
if "%choice%"=="9" goto :killproc
if "%choice%"=="10" goto :viewlogs
if "%choice%"=="11" goto :factoryreset
if "%choice%"=="12" goto :uninstall
if "%choice%"=="13" goto :checkupdate
if "%choice%"=="14" goto :diskcleanup
if "%choice%"=="15" goto :plugins
if "%choice%"=="0" exit /b 0
echo   Invalid choice
pause
goto :menu

:onboard
echo.
echo   === Setup Wizard ===
echo.
echo   DeepSeek  - Custom Provider, URL: https://api.deepseek.com/v1
echo   Kimi      - Moonshot AI
echo   Qwen      - Qwen
echo   Doubao    - Volcano Engine
echo.
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" onboard
pause
goto :menu

:dashboard
echo.
echo   Starting gateway...
set PORT=18789
:find_port
netstat -an | findstr ":%PORT% " | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 (
    set /a PORT+=1
    if %PORT% gtr 18799 (echo No available port & pause & goto :menu)
    goto :find_port
)
cd /d "%CORE_DIR%"
if not exist "%STATE_DIR%\openclaw.json" (
    echo {"gateway":{"mode":"local","auth":{"token":"uclaw"}}} > "%STATE_DIR%\openclaw.json"
)
start "" http://127.0.0.1:%PORT%/#token=uclaw
"%NODE_BIN%" "%OPENCLAW_MJS%" gateway run --allow-unconfigured --force --port %PORT%
pause
goto :menu

:qqbot
echo.
echo   === QQ Bot Setup ===
echo.
echo   QQ plugin is pre-installed!
echo   You only need your AppID and AppSecret.
echo.
echo   Get them at: q.qq.com (create a bot)
echo.
set /p qqid="  AppID: "
set /p qqsecret="  AppSecret: "
if "%qqid%"=="" goto :qq_cancel
if "%qqsecret%"=="" goto :qq_cancel
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" channels add --channel qqbot --token "%qqid%:%qqsecret%"
echo.
set /p qqallow="  Your QQ number (allowlist, empty to skip): "
if not "%qqallow%"=="" "%NODE_BIN%" "%OPENCLAW_MJS%" config set channels.qqbot.allowFrom "%qqallow%"
echo.
echo   QQ Bot configured! Restart gateway to apply.
pause
goto :menu
:qq_cancel
echo   Cancelled.
pause
goto :menu

:channels
echo.
echo   === Other Platforms ===
echo.
echo   Feishu:   Built-in. Use [1] Setup wizard.
echo   Telegram: Built-in. Use [1] Setup wizard.
echo   Discord:  Built-in. Use [1] Setup wizard.
echo   WeChat:   Community plugin.
echo.
echo   Use Setup wizard [1] to configure these.
pause
goto :menu

:doctor
cd /d "%CORE_DIR%"
"%NODE_BIN%" "%OPENCLAW_MJS%" doctor --repair
pause
goto :menu

:backup
echo.
set "TS=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
set "TS=%TS: =0%"
set "BK=%DATA_DIR%\backups\backup_%TS%"
mkdir "%BK%" 2>nul
if exist "%STATE_DIR%\openclaw.json" copy "%STATE_DIR%\openclaw.json" "%BK%\" >nul
if exist "%DATA_DIR%\memory" xcopy /s /q "%DATA_DIR%\memory" "%BK%\memory\" >nul 2>nul
echo   Backup saved: %BK%
pause
goto :menu

:restore
echo.
echo   Available backups:
dir /b "%DATA_DIR%\backups\" 2>nul
echo.
set /p rname="  Backup folder name: "
if exist "%DATA_DIR%\backups\%rname%\openclaw.json" (
    copy "%DATA_DIR%\backups\%rname%\openclaw.json" "%STATE_DIR%\" >nul
    echo   Config restored!
)
pause
goto :menu

:sysinfo
echo.
echo   OS: Windows
"%NODE_BIN%" --version
echo   Path: %UCLAW_DIR%
echo   Data: %DATA_DIR%
pause
goto :menu

:killproc
echo.
echo   === Kill Residual Processes ===
echo.
echo   Checking ports 18789-18799...
set FOUND=0
for /l %%p in (18789,1,18799) do (
    netstat -ano | findstr ":%%p " | findstr "LISTENING" >nul 2>&1
    if not errorlevel 1 (
        echo   Port %%p: process found
        set FOUND=1
        for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%%p " ^| findstr "LISTENING"') do (
            echo   Killing PID %%a...
            taskkill /PID %%a /F >nul 2>&1
        )
    )
)
if "%FOUND%"=="0" echo   No residual processes found.
if "%FOUND%"=="1" echo   Processes killed.
pause
goto :menu

:viewlogs
echo.
echo   === View Logs ===
echo.
set "LOG_FILE=%DATA_DIR%\logs\gateway.log"
if not exist "%LOG_FILE%" (
    echo   No log file found. Start the gateway first.
    pause
    goto :menu
)
echo   [a] View last 50 lines
echo   [b] Open log file
echo.
set /p logchoice="  Choose (a-b): "
if "%logchoice%"=="a" (
    echo.
    powershell -command "Get-Content '%LOG_FILE%' -Tail 50"
)
if "%logchoice%"=="b" (
    start notepad "%LOG_FILE%"
)
pause
goto :menu

:factoryreset
echo.
echo   === Factory Reset ===
echo.
echo   WARNING: This will delete all config and memory data!
echo.
echo   Type RESET to confirm:
set /p resetconfirm="  > "
if not "%resetconfirm%"=="RESET" (
    echo   Cancelled.
    pause
    goto :menu
)
echo.
echo   [1/4] Backing up...
set "TS=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%"
set "TS=%TS: =0%"
set "BK=%DATA_DIR%\backups\pre-reset_%TS%"
mkdir "%BK%" 2>nul
if exist "%STATE_DIR%\openclaw.json" copy "%STATE_DIR%\openclaw.json" "%BK%\" >nul 2>nul
if exist "%DATA_DIR%\memory" xcopy /s /q "%DATA_DIR%\memory" "%BK%\memory\" >nul 2>nul
echo   Backup saved: %BK%
echo   [2/4] Deleting config...
del "%STATE_DIR%\openclaw.json" 2>nul
del "%DATA_DIR%\config.json" 2>nul
echo   [3/4] Clearing memory...
rmdir /s /q "%DATA_DIR%\memory" 2>nul
mkdir "%DATA_DIR%\memory" 2>nul
echo   [4/4] Restoring default config...
if exist "%UCLAW_DIR%default-config.json" (
    copy "%UCLAW_DIR%default-config.json" "%STATE_DIR%\openclaw.json" >nul
) else (
    echo {"gateway":{"mode":"local","auth":{"token":"uclaw"}}} > "%STATE_DIR%\openclaw.json"
)
echo.
echo   Factory reset complete! Run Setup wizard [1] to reconfigure.
pause
goto :menu

:uninstall
echo.
echo   === Uninstall U-Claw ===
echo.
if exist "%USERPROFILE%\.uclaw" (
    echo   Found installed data: %USERPROFILE%\.uclaw
    echo   Type UNINSTALL to delete:
    set /p unconfirm="  > "
    if "%unconfirm%"=="UNINSTALL" (
        rmdir /s /q "%USERPROFILE%\.uclaw" 2>nul
        echo   Uninstalled!
    ) else (
        echo   Cancelled.
    )
) else (
    echo   Portable version - just delete this folder to uninstall.
    echo   Path: %UCLAW_DIR%
    echo.
    echo   For Electron desktop app:
    echo     Open Settings - Apps - find U-Claw - Uninstall
)
pause
goto :menu

:checkupdate
echo.
echo   === Check for Updates ===
echo.
if not exist "%CORE_DIR%\node_modules\openclaw\package.json" (
    echo   OpenClaw not installed.
    pause
    goto :menu
)
echo   Checking latest version...
for /f "tokens=*" %%v in ('"%NODE_BIN%" -e "console.log(require('%CORE_DIR:\=/%/node_modules/openclaw/package.json').version)"') do set CUR_VER=%%v
echo   Current: %CUR_VER%
echo.
echo   To update, run in the core directory:
echo     npm install openclaw@latest --registry=https://registry.npmmirror.com
pause
goto :menu

:diskcleanup
echo.
echo   === Disk Cleanup ===
echo.
echo   Checking sizes...
for /f "tokens=*" %%s in ('powershell -command "(Get-ChildItem '%UCLAW_DIR%' -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB" 2^>nul') do echo   Total: %%s MB
echo.
echo   To clean up manually:
echo     - Delete old backups in %DATA_DIR%\backups\
echo     - Delete logs in %DATA_DIR%\logs\
pause
goto :menu

:plugins
echo.
echo   === Plugin Management ===
echo.
echo   [a] List installed plugins
echo   [b] Install a plugin
echo   [c] Remove a plugin
echo.
set /p plgchoice="  Choose (a-c): "
cd /d "%CORE_DIR%"
if "%plgchoice%"=="a" "%NODE_BIN%" "%OPENCLAW_MJS%" plugins list
if "%plgchoice%"=="b" (
    echo.
    echo   Common plugins:
    echo     @icesword760/openclaw-wechat
    echo.
    set /p plgname="  Plugin name: "
    if not "%plgname%"=="" "%NODE_BIN%" "%OPENCLAW_MJS%" plugins install "%plgname%"
)
if "%plgchoice%"=="c" (
    "%NODE_BIN%" "%OPENCLAW_MJS%" plugins list
    echo.
    set /p plgname="  Plugin to remove: "
    if not "%plgname%"=="" "%NODE_BIN%" "%OPENCLAW_MJS%" plugins remove "%plgname%"
)
pause
goto :menu