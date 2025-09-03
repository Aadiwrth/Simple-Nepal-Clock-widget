@echo off
REM Nepal Clock Widget - Windows Build Script
REM This script builds the application for Windows

setlocal EnableDelayedExpansion

REM Configuration
set APP_NAME=Nepal Clock
set SCRIPT_NAME=nepal_clock_widget.py
set OUTPUT_DIR=dist
set BUILD_DIR=build
set SPEC_FILE=nepal_clock.spec

REM Colors (for Windows 10+)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

echo %BLUE%[INFO]%NC% Starting Nepal Clock Widget build for Windows...

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%[ERROR]%NC% Python is not installed or not in PATH
    echo Please install Python from https://python.org/downloads/
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Requirements installed

REM Create PyInstaller spec file
echo %BLUE%[INFO]%NC% Creating PyInstaller spec file...
(
echo # -*- mode: python ; coding: utf-8 -*-
echo.
echo block_cipher = None
echo.
echo a = Analysis^(
echo     ['%SCRIPT_NAME%'],
echo     pathex=[],
echo     binaries=[],
echo     datas=[],
echo     hiddenimports=['pytz'],
echo     hookspath=[],
echo     hooksconfig={},
echo     runtime_hooks=[],
echo     excludes=[],
echo     win_no_prefer_redirects=False,
echo     win_private_assemblies=False,
echo     cipher=block_cipher,
echo     noarchive=False,
echo ^)
echo.
echo pyz = PYZ^(a.pure, a.zipped_data, cipher=block_cipher^)
echo.
echo exe = EXE^(
echo     pyz,
echo     a.scripts,
echo     a.binaries,
echo     a.zipfiles,
echo     a.datas,
echo     [],
echo     name='nepal_clock.exe',
echo     debug=False,
echo     bootloader_ignore_signals=False,
echo     strip=False,
echo     upx=True,
echo     upx_exclude=[],
echo     runtime_tmpdir=None,
echo     console=False,
echo     disable_windowed_traceback=False,
echo     argv_emulation=False,
echo     target_arch=None,
echo     codesign_identity=None,
echo     entitlements_file=None,
echo     icon=None,
echo ^)
) > "%SPEC_FILE%"

echo %GREEN%[SUCCESS]%NC% Spec file created

REM Clean previous builds
echo %BLUE%[INFO]%NC% Cleaning previous builds...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"

REM Build with PyInstaller
echo %BLUE%[INFO]%NC% Building executable for Windows...
pyinstaller --clean "%SPEC_FILE%"

if errorlevel 1 (
    echo %RED%[ERROR]%NC% Build failed!
    pause
    exit /b 1
)

REM Check if executable was created
if not exist "%OUTPUT_DIR%\nepal_clock.exe" (
    echo %RED%[ERROR]%NC% Executable not found after build!
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]%NC% Build completed successfully!

REM Create distribution package
echo %BLUE%[INFO]%NC% Creating distribution package...

set "DIST_NAME=nepal-clock-windows-%date:~-4,4%%date:~-7,2%%date:~-10,2%"
set "DIST_DIR=releases\%DIST_NAME%"

if not exist "releases" mkdir "releases"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

REM Copy executable
copy "%OUTPUT_DIR%\nepal_clock.exe" "%DIST_DIR%\"

REM Create README
(
echo Nepal Clock Widget - Windows Distribution
echo =========================================
echo.
echo Installation:
echo 1. Extract this archive to your preferred location
echo 2. Double-click nepal_clock.exe to run
echo.
echo Features:
echo - Live Nepal time display
echo - Draggable window
echo - Always on top option
echo - Right-click context menu
echo - Automatic position saving
echo.
echo Controls:
echo - Drag to move window
echo - Right-click for options menu
echo - ESC key to close
echo - Click X to close
echo.
echo Built on: %date% %time%
echo Platform: Windows
echo.
echo Note: Windows Defender might show a warning for unsigned executables.
echo This is normal for PyInstaller-built applications.
) > "%DIST_DIR%\README.txt"

REM Create ZIP archive
echo %BLUE%[INFO]%NC% Creating ZIP archive...
cd releases
powershell -Command "Compress-Archive -Path '%DIST_NAME%' -DestinationPath '%DIST_NAME%.zip' -Force"
cd ..

if exist "releases\%DIST_NAME%.zip" (
    echo %GREEN%[SUCCESS]%NC% Distribution package created: releases\%DIST_NAME%.zip
) else (
    echo %YELLOW%[WARNING]%NC% Could not create ZIP archive, but files are in releases\%DIST_NAME%\
)

REM Cleanup
echo %BLUE%[INFO]%NC% Cleaning up build artifacts...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%SPEC_FILE%" del "%SPEC_FILE%"

echo.
echo %GREEN%[SUCCESS]%NC% Build process completed!
echo %BLUE%[INFO]%NC% Executable location: %DIST_DIR%\nepal_clock.exe
echo %BLUE%[INFO]%NC% You can now run the application or distribute the ZIP file.
echo.

pause%NC% Python found
python --version

REM Check if script exists
if not exist "%SCRIPT_NAME%" (
    echo %RED%[ERROR]%NC% Script file '%SCRIPT_NAME%' not found!
    pause
    exit /b 1
)

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo %BLUE%[INFO]%NC% Creating virtual environment...
    python -m venv venv
    echo %GREEN%[SUCCESS]%NC% Virtual environment created
) else (
    echo %BLUE%[INFO]%NC% Virtual environment already exists
)

REM Activate virtual environment
echo %BLUE%[INFO]%NC% Activating virtual environment...
call venv\Scripts\activate.bat

REM Install requirements
echo %BLUE%[INFO]%NC% Installing requirements...
if exist "requirements.txt" (
    pip install -r requirements.txt
) else (
    pip install pytz pyinstaller
)

if errorlevel 1 (
    echo %RED%[ERROR]%NC% Failed to install requirements
    pause
    exit /b 1
)

echo %GREEN%[SUCCESS]