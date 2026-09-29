@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0" || exit /b 1
python q1_generator.py --output q1_input.json
if errorlevel 1 goto finish
python q1_solver.py --input q1_input.json --output q1_result.json
:finish
set "RC=%ERRORLEVEL%"
popd
pause
exit /b %RC%
