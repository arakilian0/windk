@echo off
:: bin/windk.bat - Entry Proxy & Scope Guard
setlocal EnableExtensions EnableDelayedExpansion

:: Forward all arguments to the tool dispatcher
call "%~dp0..\tool\windk\windk.bat" %*

:: Store return code from dispatcher
set "EXIT_CODE=%ERRORLEVEL%"

:: Destroy all windk variables and restore user's previous environment
endlocal & exit /b %EXIT_CODE%
