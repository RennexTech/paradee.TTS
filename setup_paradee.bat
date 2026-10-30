@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "APP=Paradee Studio Pro"
set "PY=venv\Scripts\python.exe"
set "STAMP=venv\.paradee_ready"
set "PIP_PKGS=git+https://github.com/sahilmahendrakar/paradee soundfile numpy pygame"

echo ============================================
echo   %APP%
echo ============================================
echo.

REM ---------- 1. Create venv only if missing ----------
if not exist "%PY%" (
    echo [*] First run - creating virtual environment...
    where py >nul 2>nul
    if not errorlevel 1 (
        py -3.12 -m venv venv 2>nul
        if not exist "%PY%" py -3 -m venv venv 2>nul
    )
    if not exist "%PY%" (
        where python >nul 2>nul
        if errorlevel 1 (
            echo [X] Python not found. Install Python 3.10-3.12 and add it to PATH.
            pause & exit /b 1
        )
        python -m venv venv
    )
    if not exist "%PY%" (
        echo [X] Could not create the virtual environment.
        pause & exit /b 1
    )
)

REM ---------- 2. Install deps ONLY the first time ----------
if not exist "%STAMP%" (
    echo [*] Installing Paradee + player dependencies. This runs once only...
    "%PY%" -m pip install --upgrade pip setuptools wheel
    "%PY%" -m pip install %PIP_PKGS%
    if errorlevel 1 (
        echo [X] Dependency install failed. Scroll up for details.
        pause & exit /b 1
    )
    > "%STAMP%" echo ready
    echo [*] Setup complete.
) else (
    REM Cheap sanity check; only repair if something is really broken
    "%PY%" -c "import paradee, soundfile, numpy, pygame" >nul 2>&1
    if errorlevel 1 (
        echo [!] A package is missing/broken - repairing (one time)...
        "%PY%" -m pip install %PIP_PKGS%
        if errorlevel 1 (
            echo [X] Repair failed. Delete the "venv" folder and run again.
            pause & exit /b 1
        )
    )
)

REM ---------- 3. Sanity checks ----------
if not exist "paradee_studio.py" (
    echo [X] paradee_studio.py is missing next to this .bat
    pause & exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    if exist "ffmpeg.exe" (echo [*] Using local ffmpeg.exe) else (echo [!] No ffmpeg - WAV only, MP3 disabled)
) else (
    echo [*] ffmpeg found on PATH
)

REM ---------- 4. Launch ----------
echo.
echo [*] Launching %APP%...
"%PY%" paradee_studio.py
if errorlevel 1 (
    echo.
    echo [X] The app exited with an error. Scroll up.
    pause
)
endlocal
