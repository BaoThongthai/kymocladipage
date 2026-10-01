@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "tools\update-products.ps1"
if errorlevel 1 (
  echo.
  echo Khong the cap nhat danh sach san pham.
  pause
  exit /b 1
)
echo.
echo Da xong. Dang mo website...
start "" "%~dp0index.html"
