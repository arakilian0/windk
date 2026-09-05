@echo off
setlocal EnableDelayedExpansion

set "PATH_MGR=%~dp0..\..\lib\path_resolver.bat"
set "CONFIG_MGR=%~dp0..\..\lib\config_manager.bat"
set "CONFIG_FILE=%~dp0..\..\tool\windk\.cfg"

:: Canonicalize paths relative to the current script directory (%~dp0)
call "%PATH_MGR%" resolve "%CONFIG_MGR%" CONFIG_MGR
call "%PATH_MGR%" resolve "%CONFIG_FILE%" CONFIG_FILE

if not exist "!CONFIG_MGR!" (
    echo [ERROR] Config manager missing at: "!CONFIG_MGR!"
    endlocal & exit /b 1
)

if not exist "!CONFIG_FILE!" (
    echo [ERROR] Configuration file missing at: "!CONFIG_FILE!"
    endlocal & exit /b 1
)

ECHO [CONFIG MANAGER]: "!CONFIG_MGR!"
ECHO [CONFIG FILE]: "!CONFIG_FILE!"

endlocal & exit /b 1
