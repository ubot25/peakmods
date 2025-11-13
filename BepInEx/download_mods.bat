@echo off
rmdir /s /q "plugins"
setlocal enabledelayedexpansion
set "REPO_URL=https://github.com/ubot25/peakmods"  
set "BRANCH=main"                              
for /f "delims=" %%A in ('powershell -NoProfile -Command "($env:REPO_URL -replace '^https?://(www\.)?github\.com/','') -replace '\.git$','' -replace '/$',''"') do set "OWNERREPO=%%A"
set "ZIPURL=https://github.com/%OWNERREPO%/archive/refs/heads/%BRANCH%.zip"
set "TMPZIP=%TEMP%\repo_%RANDOM%.zip"
set "TMPDIR=%TEMP%\repo_extract_%RANDOM%"
if exist "%TMPDIR%" rd /s /q "%TMPDIR%"
mkdir "%TMPDIR%" >nul 2>&1
powershell -NoProfile -Command ^
  "try { Invoke-WebRequest -Uri '%ZIPURL%' -OutFile '%TMPZIP%' -UseBasicParsing; exit 0 } catch { exit 1 }"

if errorlevel 1 (
    rd /s /q "%TMPDIR%" >nul 2>&1
    exit /b 1
)

powershell -NoProfile -Command "Expand-Archive -Path '%TMPZIP%' -DestinationPath '%TMPDIR%' -Force"
set "FOUND="
for /f "delims=" %%D in ('dir /b /ad "%TMPDIR%"') do (
    if not defined FOUND set "FOUND=%%D"
)
if not defined FOUND (
    echo ❌ Nie znaleziono rozpakowanego folderu.
    rd /s /q "%TMPDIR%"
    del "%TMPZIP%" >nul 2>&1
    exit /b 2
)
set "SRC=%TMPDIR%\%FOUND%"
set "DEST=%CD%"

where robocopy >nul 2>&1
if %errorlevel%==0 (
    robocopy "%SRC%" "%DEST%" /E /COPY:DAT /R:2 /W:2 >nul
) else (
    xcopy "%SRC%\*" "%DEST%\" /E /I /Y >nul
)
rd /s /q "%TMPDIR%" >nul 2>&1
del /f /q "%TMPZIP%" >nul 2>&1

echo   %DEST%
pause
exit /b 0
