@echo off

set "arg=%~1"
set "LEVELS=..\..\..\"
set "PATH_MGR=%~dp0%LEVELS%lib\path_resolver.bat"
set "COLOR_MGR=%~dp0%LEVELS%lib\ansi_codes.bat"
set "TEMPLATE_DIR=%~dp0%LEVELS%lib\__template"

call "%PATH_MGR%" resolve "%TEMPLATE_DIR%" TEMPLATE_DIR
call "%COLOR_MGR%"

if "%~1"=="" (
    ECHO %RED%Error:%RESET% please provide the name of the script to %~n0.
    GOTO end
)

where "$PATH:%~1" >nul 2>nul

if errorlevel 1 ( goto notfound ) else ( goto found )

:found
echo Error: Command ' %~1' already exists on system PATH. Please choose another name for your command.
goto end

:notfound
:: Check if arg contains only letters and numbers
echo !arg!| findstr /r "^[A-Za-z0-9]*$" >nul
if errorlevel 1 (
    echo Error: "%arg%" must contain only letters and numbers
    exit /b 1
)

if not exist !TEMPLATE_DIR! (
    echo Error: the template directory is missing.
    exit /b 0
)

:: Main Process
xcopy "%TEMPLATE_DIR%" "%~dp0%LEVELS%tool\!arg!" /E /I /H /R /Y /Q >nul 2>&1
copy "%~dp0%LEVELS%bin\windk.bat" "%~dp0%LEVELS%bin\!arg!.bat" >nul
move "%~dp0..\..\!arg!\main.bat" "%~dp0..\..\!arg!\!arg!.bat" >nul

goto end

:end
endlocal
