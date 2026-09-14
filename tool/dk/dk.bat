@echo off
setlocal EnableDelayedExpansion

:: HARD CODED VARIABLES
set "_VERSION_NUMBER=0.2"
set "_SCRIPT=%~n0"

:: DYNAMIC VARIABLES
set "_COMMAND="
set "_TARGET="
set "_HELP="
set "_FORCE="
set "_VERSION="
set "_VERBOSE="
set "_TEMPLATE="

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
    :: Value consuming long flags
    if "%~1"=="--template"  goto parse_flag_template

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

:: THE MAIN PROCESS
:: AFTER ALL ARGUMENT PARSING IS COMPLETE, WE ENTER THE MAIN PROCESS.
:: FROM HERE WE DELEGATE TASKS TO SUBCOMMANDS AND FLAGS.
:: ==================================================================
:main
if not defined _COMMAND (
    if defined _HELP call "%~dp0tool\%_SCRIPT%\command\help.bat" & goto end
    if defined _VERSION goto command_version
    :: ERROR - NO COMMAND
    echo %_SCRIPT%: no command provided. See '%_SCRIPT% --help'.
    goto end
)

if "!_COMMAND!" == "create" call "%~dp0tool\%_SCRIPT%\command\!_COMMAND!.bat" & goto end
if "!_COMMAND!" == "delete" call "%~dp0tool\%_SCRIPT%\command\!_COMMAND!.bat" & goto end

:: ERROR - NOT A COMMAND
echo %_SCRIPT%: '!_COMMAND!' is not a %_SCRIPT% command. See '%_SCRIPT% --help'.
goto end

:: COMMAND (VERSION)
:: ===============================================================
:command_version
echo %_SCRIPT% version %_VERSION_NUMBER%
goto end

:: THE END
:: ===============================================================
:end
endlocal
exit /b 0
