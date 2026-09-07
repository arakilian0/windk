@echo off
setlocal EnableDelayedExpansion

set "TARGET_NAME="
set "FLAGS="
set "EXTRA_ARGS="

: ==========
: PARSE ARGS
: ==========
:parse_args
if "%~1"=="" goto :main

:: Check Help Flags
if /i "%~1"=="-h"     goto :show_help
if /i "%~1"=="--help" goto :show_help
if /i "%~1"=="help"   goto :show_help

:: Extract 1st character to identify flags
set "ARG=%~1"
set "FIRST_CHAR=!ARG:~0,1!"

if "!FIRST_CHAR!"=="-" goto :save_flag
if "!FIRST_CHAR!"=="/" goto :save_flag

:: --- POSITIONAL ARGUMENT HANDLING ---
:: FIRST non-flag becomes TARGET_NAME
if not defined TARGET_NAME (
    set "TARGET_NAME=%~1"
    shift
    goto :parse_args
)

:: Subsequent non-flags go into EXTRA_ARGS
if defined EXTRA_ARGS (
    set "EXTRA_ARGS=!EXTRA_ARGS! "%~1""
) else (
    set "EXTRA_ARGS="%~1""
)
shift
goto :parse_args

: =========
: SAVE FLAG
: =========
:save_flag
if defined FLAGS (
    set "FLAGS=!FLAGS! "%~1""
) else (
    set "FLAGS="%~1""
)
shift
goto :parse_args

: ====
: MAIN
: ====
:main
if "!TARGET_NAME!"=="" (
    echo [ERROR] No target name provided.
    goto :show_help
)

:: Process flags to set state variables
if defined FLAGS call :process_flags !FLAGS!

:: --- LOG RESULTS ---
echo ==========================================
echo Target Name    : !TARGET_NAME!
echo Verbose Mode   : !VERBOSE!
echo Captured Flags : !FLAGS!
if defined EXTRA_ARGS (
    echo Extra Positionals: !EXTRA_ARGS!
)
echo ==========================================

exit /b 0

: =============
: PROCESS FLAGS
: =============
:process_flags
if "%~1"=="" exit /b 0

if /i "%~1"=="-v"        set "VERBOSE=1"
if /i "%~1"=="--verbose" set "VERBOSE=1"

shift
goto :process_flags

: =========
: SHOW HELP
: =========
:show_help
echo Usage: %~nx0 ^<target_name^> [flags]
echo.
echo Example:
echo   %~nx0 my_project -v
echo   %~nx0 -v my_project
exit /b 0
