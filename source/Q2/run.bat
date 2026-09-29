@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0" || exit /b 1
python q2_generator.py --output q2_input.json
if errorlevel 1 goto finish
python q2_solver.py --input q2_input.json --output q2_result.json
:finish
set "RC=%ERRORLEVEL%"
popd
pause
exit /b %RC%
