@echo off

if defined _HELP goto show_help

goto main

:main
echo in main process(delete)
goto end

:show_help
echo showing delete command help page.
goto end

:end
endlocal
exit /b 0
