@echo off
setlocal EnableDelayedExpansion

set "HELP="
set "FORCE="
set "VERBOSE="
set "TEMPLATE="

:parse_args
if "%~1" == "" goto main

if "%~1" == "-h" set "HELP=1"
if "%~1" == "-f" set "FORCE=1"
if "%~1" == "-v" set "VERBOSE=1"
if "%~1" == "--template" set "TEMPLATE=%~2"

shift
goto parse_args

:main
echo hello worldW

echo help: !help!
echo force: !force!
echo verbose: !verbose!
echo template: !template!
goto end

:end
exit /b 0
