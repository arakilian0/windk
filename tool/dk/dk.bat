@echo off
setlocal EnableDelayedExpansion

:: HARD CODED VARIABLES
set "_VERSION_=0.2"
set "_SCRIPT=%~n0"

:: DYNAMIC VARIABLES
set "_COMMAND="
set "_TARGET="
set "_HELP="
set "_FORCE="
set "_VERBOSE="
set "_TEMPLATE="
set "_OUTPUT="

:: LOOP THROUGH ALL ARGUMENTS PASSED
:: ===============================================================
:parse_loop
if "%~1"=="" goto main

set "_ARG=%~1"
set "_FIRST=%_ARG:~0,1%"
set "_SECOND=%_ARG:~1,1%"

:: Handle short/long flags starting with - or /
if "%_FIRST%"=="-" goto parse_flag
if "%_FIRST%"=="/" goto parse_flag

:: Positional Arguments
if not defined _COMMAND (
    set "_COMMAND=%~1"
) else if not defined _TARGET (
    set "_TARGET=%~1"
)
shift
goto parse_loop

:: LOOP THROUGH ALL FLAGS PASSED
:: ===============================================================
:parse_flag
:: Handle Long Flags (starting with --)
if "%_SECOND%"=="-" (
    if "%~1"=="--force"     set "_FORCE=true"
    if "%~1"=="--verbose"   set "_VERBOSE=true"
    if "%~1"=="--version"   set "_VERSION=true"
    if "%~1"=="--help"      set "_HELP=true"

    if "%~1"=="--template"  goto parse_flag_template
    if "%~1"=="--output"    goto parse_flag_output

    shift
    goto parse_loop
)

:: Handle Short Flags (-fv or -t template)
set "_FLAGS=%_ARG:~1%"

:: LOOP THROUGH ALL SHORT FLAGS PASSED
:: ===============================================================
:parse_short_chars
if "%_FLAGS%"=="" (
    shift
    goto parse_loop
)

set "_CHAR=%_FLAGS:~0,1%"
set "_FLAGS=%_FLAGS:~1%"

:: Binary short flags
if "%_CHAR%"=="f"  set "_FORCE=true" & goto parse_short_chars
if "%_CHAR%"=="v"  set "_VERSION=true" & goto parse_short_chars
if "%_CHAR%"=="V"  set "_VERBOSE=true" & goto parse_short_chars
if "%_CHAR%"=="h"  set "_HELP=true" & goto parse_short_chars

:: Short flags that consume the next argument
if "%_CHAR%"=="t"  goto parse_flag_template
if "%_CHAR%"=="o"  goto parse_flag_output

goto parse_short_chars

:: FLAG (TEMPLATE)
:: ===============================================================
:parse_flag_template
if not "%_FLAGS%"=="" (
    :: Value attached to flag (e.g., -ttemplate.txt)
    set "_TEMPLATE=%_FLAGS%"
    set "_FLAGS="
    shift
    goto parse_loop
)
shift
set "_TEMPLATE=%~1"
shift
goto parse_loop

:: FLAG (OUTPUT)
:: ===============================================================
:parse_flag_output
if not "%_FLAGS%"=="" (
    :: Value attached to flag (e.g., -oout.txt)
    set "_OUTPUT=%_FLAGS%"
    set "_FLAGS="
    shift
    goto parse_loop
)
shift
set "_OUTPUT=%~1"
shift
goto parse_loop

:: MAIN PROCESS
:: ===============================================================
:main
if not defined _COMMAND (
    if defined _HELP goto command_help
    if defined _VERSION goto command_version
    echo %_SCRIPT%: no command provided. See '%_SCRIPT% --help'.
    goto end
)

if "!_COMMAND!" == "create" goto command_create
if "!_COMMAND!" == "delete" goto command_delete

echo %_SCRIPT%: '!_COMMAND!' is not a %_SCRIPT% command. See '%_SCRIPT% --help'.
goto end

:: COMMAND (HELP)
:: ===============================================================
:command_help
echo in the help command
goto end

:: COMMAND (VERSION)
:: ===============================================================
:command_version
echo %_SCRIPT% version %_VERSION_%
goto end

:: COMMAND (CREATE)
:: ===============================================================
:command_create
echo in the create command
echo "!_TARGET!"
echo "!_OUTPUT!"
echo "!_VERBOSE!"
echo "!_FORCE!"
goto end

:: COMMAND (DELETE)
:: ===============================================================
:command_delete
echo in the delete command
echo "!_TARGET!"
goto end

:: THE END
:: ===============================================================
:end
endlocal
exit /b 0
