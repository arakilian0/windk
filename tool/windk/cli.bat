@echo off
setlocal EnableDelayedExpansion

:: Define utility and config paths
set "PATH_MGR=%~dp0..\..\lib\path_resolver.bat"
set "COLOR_MGR=%~dp0..\..\lib\ansi_codes.bat"
set "CONFIG_MGR=%~dp0..\..\lib\config_manager.bat"
set "CONFIG_FILE=%~dp0.cfg"

:: Canonicalize paths relative to the current script directory (%~dp0)
call "%PATH_MGR%" resolve "%CONFIG_MGR%" CONFIG_MGR
call "%PATH_MGR%" resolve "%CONFIG_FILE%" CONFIG_FILE

if not exist "%COLOR_MGR%" (
    echo [ERROR] Core colors.bat file missing at: "%COLOR_MGR%"
    exit /b 1
)
call "%COLOR_MGR%"

if not exist "%CONFIG_MGR%" (
    echo %RED%[ERROR]%RESET% Config manager missing at: "%CONFIG_MGR%"
    exit /b 1
)

if not exist "%CONFIG_FILE%" (
    echo %RED%[ERROR]%RESET% Configuration file missing at: "%CONFIG_FILE%"
    exit /b 1
)

set "TARGET_CMD="
set "STATELESS_FLAGS="
set "CMD_ARGS="

:parse_args
if "%~1"=="" goto run_command

set "ARG=%~1"
set "FIRST_CHAR=!ARG:~0,1!"

:: Check if argument is a flag (starts with - or /)
if "!FIRST_CHAR!"=="-" goto handle_flag
if "!FIRST_CHAR!"=="/" goto handle_flag
goto handle_positional


:handle_flag
:: Strip leading dashes and slashes (e.g. "--help" -> "help", "/h" -> "h")
set "FLAG_KEY=%~1"
set "FLAG_KEY=!FLAG_KEY:-=!"
set "FLAG_KEY=!FLAG_KEY:/=!"

:: ON-DEMAND LOOKUP: Query [flag] -> FLAG_KEY
set "FLAG_SCRIPT="
call "%CONFIG_MGR%" GET "%CONFIG_FILE%" "flag" "!FLAG_KEY!" "FLAG_SCRIPT"

:: Immediate execution if flag script is found AND no subcommand is set yet
if defined FLAG_SCRIPT (
    if not defined TARGET_CMD (
        if exist "!FLAG_SCRIPT!" (
            call "!FLAG_SCRIPT!"
            exit /b !ERRORLEVEL!
        ) else (
            echo [ERROR] Flag script configured but missing: "!FLAG_SCRIPT!"
            exit /b 1
        )
    )
)

:: Collect general/stateless flags to pass down to target subcommand
set "STATELESS_FLAGS=!STATELESS_FLAGS! %~1"

shift
goto parse_args


:handle_positional
:: Match subcommand or collect as subcommand positional arguments
if not defined TARGET_CMD (
    set "CMD_KEY=%~1"

    :: ON-DEMAND LOOKUP: Query [command] -> CMD_KEY
    set "TEMP_CMD="
    call "%CONFIG_MGR%" GET "%CONFIG_FILE%" "command" "!CMD_KEY!" "TEMP_CMD"

    if defined TEMP_CMD (
        set "TARGET_CMD=!TEMP_CMD!"
    ) else (
        echo [ERROR] Unknown command: %~1

        :: Fallback: Fetch help path on demand
        set "HELP_SCRIPT="
        call "%CONFIG_MGR%" GET "%CONFIG_FILE%" "flag" "help" "HELP_SCRIPT"
        if defined HELP_SCRIPT if exist "!HELP_SCRIPT!" call "!HELP_SCRIPT!"

        exit /b 1
    )
) else (
    set "CMD_ARGS=!CMD_ARGS! %~1"
)

shift
goto parse_args


:run_command
if not defined TARGET_CMD (
    echo [ERROR] No command specified.

    :: ON-DEMAND FALLBACK: Look up default "help" flag
    set "FALLBACK_SCRIPT="
    call "%CONFIG_MGR%" GET "%CONFIG_FILE%" "flag" "help" "FALLBACK_SCRIPT"

    if defined FALLBACK_SCRIPT (
        if exist "!FALLBACK_SCRIPT!" call "!FALLBACK_SCRIPT!"
    ) else (
        echo [ERROR] No default help flag registered in configuration.
    )
    exit /b 1
)

if not exist "!TARGET_CMD!" (
    echo [ERROR] Command script not found: "!TARGET_CMD!"
    exit /b 1
)

:: Execute resolved command script with forwarded flags and arguments
call "!TARGET_CMD!" !STATELESS_FLAGS! !CMD_ARGS!

endlocal
exit /b %ERRORLEVEL%
