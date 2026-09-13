@echo off
setlocal EnableDelayedExpansion

set "_COMMAND="
set "_TARGET="
set "_FORCE="
set "_VERBOSE="
set "_HELP="
set "_TEMPLATE="
set "_OUTPUT="

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

:parse_flag
:: Handle Long Flags (starting with --)
if "%_SECOND%"=="-" (
    if "%~1"=="--force"   set "_FORCE=1"
    if "%~1"=="--verbose" set "_VERBOSE=1"
    if "%~1"=="--help"    set "_HELP=1"
    shift
    goto parse_loop
)

:: Handle Short Flags (can be chained, e.g., -fv or -t template)
set "_FLAGS=%_ARG:~1%"

:parse_short_chars
if "%_FLAGS%"=="" (
    shift
    goto parse_loop
)

set "_CHAR=%_FLAGS:~0,1%"
set "_FLAGS=%_FLAGS:~1%"

if "%_CHAR%"=="f" set "_FORCE=1" & goto parse_short_chars
if "%_CHAR%"=="v" set "_VERBOSE=1" & goto parse_short_chars
if "%_CHAR%"=="h" set "_HELP=1" & goto parse_short_chars

:: Flags that consume the next argument
if "%_CHAR%"=="t" goto get_val_template
if "%_CHAR%"=="o" goto get_val_output

goto parse_short_chars

:get_val_template
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

:get_val_output
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

:main
echo COMMAND: !_COMMAND!
echo TARGET: !_TARGET!
echo FORCE: !_FORCE!
echo VERBOSE: !_VERBOSE!
echo TEMPLATE: !_TEMPLATE!
echo OUTPUT: !_OUTPUT!
echo HELP: !_HELP!
goto end

:end
endlocal
exit /b 0
