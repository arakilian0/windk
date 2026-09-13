@echo off

if defined _HELP goto show_help

goto main

:main
echo in main process
goto end

:show_help
echo showing create command help page.
goto end

:end
endlocal
exit /b 0
