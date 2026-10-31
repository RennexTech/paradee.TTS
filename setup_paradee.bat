@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "APP=Paradee Studio Pro"
set "PY=venv\Scripts\python.exe"
set "REPO_URL=https://github.com/sahilmahendrakar/paradee.git"
set "PIP_PKGS=git+https://github.com/sahilmahendrakar/paradee soundfile numpy pygame"

echo ============================================
echo   %APP% - Full Setup & Launch
echo ============================================
echo.

REM ---------- 1. Check for Git, install if missing ----------
where git >nul 2>nul
if errorlevel 1 (
    echo [*] Git not found. Attempting to install via winget...
    where winget >nul 2>nul
    if errorlevel 1 (
        echo [X] winget is not available on this system.
        echo     Please install Git manually from https://git-scm.com/download/win
        pause & exit /b 1
    )
    winget install --id Git.Git -e --source winget --accept-source-agreements --accept-package-agreements --silent
    if errorlevel 1 (
        echo [X] Git installation via winget failed.
        echo     Please install Git manually from https://git-scm.com/download/win
        pause & exit /b 1
    )
    echo [*] Git installed. You may need to restart this script for PATH changes to take effect.
    echo     If the script fails now, close this window and run it again.
    echo.
    REM Refresh PATH for this session so git is usable immediately
    set "PATH=%PATH%;C:\Program Files\Git\cmd;C:\Program Files\Git\bin"
)

REM Verify git is now available
where git >nul 2>nul
if errorlevel 1 (
    echo [X] Git is still not on PATH. Close this window, open a new one, and run again.
    pause & exit /b 1
)
echo [*] Git found.

REM ---------- 2. Check for Python ----------
where py >nul 2>nul
if errorlevel 1 (
    where python >nul 2>nul
    if errorlevel 1 (
        echo [X] Python not found. Install Python 3.10-3.12 from https://python.org
        echo     Make sure to check "Add Python to PATH" during installation.
        pause & exit /b 1
    )
    set "PYTHON_CMD=python"
) else (
    set "PYTHON_CMD=py -3.12"
    REM Fallback to any py -3 if 3.12 isn't available
    %PYTHON_CMD% -c "import sys" >nul 2>&1
    if errorlevel 1 set "PYTHON_CMD=py -3"
)
echo [*] Python found: %PYTHON_CMD%

REM ---------- 3. Create venv if missing ----------
if not exist "%PY%" (
    echo [*] Creating virtual environment...
    %PYTHON_CMD% -m venv venv
    if not exist "%PY%" (
        echo [X] Could not create the virtual environment.
        pause & exit /b 1
    )
) else (
    echo [*] Virtual environment already exists.
)

REM ---------- 4. Clone repo if paradee_studio.py is missing ----------
if not exist "paradee_studio.py" (
    echo [*] paradee_studio.py not found in this folder.
    echo     The repo is expected at: %REPO_URL%
    echo.
    set /p "CLONE=Clone the repo now? (Y/N): "
    if /i "!CLONE!"=="Y" (
        echo [*] Cloning...
        git clone "%REPO_URL%" .
        if errorlevel 1 (
            echo [X] Clone failed. The repo may have moved or you may be offline.
            echo     Check: %REPO_URL%
            pause & exit /b 1
        )
        echo [*] Clone complete.
    ) else (
        echo [X] Cannot proceed without paradee_studio.py.
        pause & exit /b 1
    )
) else (
    echo [*] paradee_studio.py found.
)

REM ---------- 5. Install/repair dependencies ----------
echo [*] Checking dependencies...
"%PY%" -c "from paradee import Paradee, SAMPLE_RATE; import soundfile, numpy, pygame" >nul 2>&1
if errorlevel 1 (
    echo [*] Installing/repairing Paradee and player dependencies...
    "%PY%" -m pip install --upgrade pip setuptools wheel
    "%PY%" -m pip install %PIP_PKGS%
    if errorlevel 1 (
        echo [X] Dependency install failed. Scroll up for details.
        pause & exit /b 1
    )
    REM Re-verify after install
    "%PY%" -c "from paradee import Paradee, SAMPLE_RATE; import soundfile, numpy, pygame" >nul 2>&1
    if errorlevel 1 (
        echo [X] Packages installed but import still fails.
        echo     Check for a stray "paradee" folder or paradee.py in this directory.
        pause & exit /b 1
    )
    echo [*] Dependencies installed successfully.
) else (
    echo [*] All dependencies present.
)

REM ---------- 6. Check for ffmpeg (optional MP3 support) ----------
where ffmpeg >nul 2>nul
if errorlevel 1 (
    if exist "ffmpeg.exe" (echo [*] Using local ffmpeg.exe) else (echo [!] No ffmpeg - WAV only, MP3 disabled)
) else (
    echo [*] ffmpeg found on PATH
)

REM ---------- 7. Launch ----------
echo.
echo [*] Launching %APP%...
echo     (First launch may download the model from Hugging Face to %%USERPROFILE%%\.cache)
echo.
"%PY%" paradee_studio.py
if errorlevel 1 (
    echo.
    echo [X] The app exited with an error. Scroll up.
    pause
)
endlocal
