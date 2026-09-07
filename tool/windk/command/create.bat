@echo off
setlocal EnableDelayedExpansion

set "LEVELS=..\..\..\"
set "NAME=%~1"

call "%~dp0%LEVELS%lib\ansi_codes.bat"

if "!NAME!" == "" (
    echo error: please provide name of new cli.
    goto end
)

echo hello "!NAME!"
goto end

:end
exit /b 0
