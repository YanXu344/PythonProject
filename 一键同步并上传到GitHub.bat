@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ========================================================
echo       李沐深度学习代码 一键同步并上传到 GitHub
echo ========================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync_to_github.ps1"
echo.
pause
