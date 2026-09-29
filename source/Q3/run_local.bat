@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0" || exit /b 1
python q3_local_simulator.py %*
set "RC=%ERRORLEVEL%"
popd
pause
exit /b %RC%
