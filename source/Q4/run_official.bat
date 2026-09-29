@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0" || exit /b 1
python q4_official_solver.py %*
set "RC=%ERRORLEVEL%"
popd
pause
exit /b %RC%
