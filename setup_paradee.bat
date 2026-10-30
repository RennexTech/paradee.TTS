@echo off
REM setup_paradee.bat - Creates venv and installs Paradee cleanly on Windows

echo ============================================
echo  Setting up Paradee TTS Environment 💀🔥
echo ============================================

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Please install Python 3.10-3.12 and add it to PATH.
    pause
    exit /b 1
)

REM Clear broken venv if it exists
if exist "venv" (
    echo Cleaning up old venv...
    rmdir /s /q venv
)

echo Creating fresh virtual environment...
python -m venv venv

REM Activate the venv
call venv\Scripts\activate.bat

REM Upgrade pip & setuptools
echo Upgrading pip...
python -m pip install --upgrade pip setuptools wheel

REM Install Paradee directly from GitHub
echo Installing Paradee and dependencies...
pip install git+https://github.com/sahilmahendrakar/paradee

echo.
echo ============================================
echo  Setup complete! Let's test it out! 🚀
echo ============================================
pause