#!/bin/bash

# Nepal Clock Widget - Cross-Platform Build Script
# Supports Windows, Linux, and macOS

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
APP_NAME="Nepal Clock"
SCRIPT_NAME="nepal_clock_widget.py"
OUTPUT_DIR="dist"
BUILD_DIR="build"
SPEC_FILE="nepal_clock.spec"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect OS
detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS="macos"
            PLATFORM="macOS"
            EXTENSION=""
            ;;
        Linux)
            OS="linux"
            PLATFORM="Linux"
            EXTENSION=""
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            OS="windows"
            PLATFORM="Windows"
            EXTENSION=".exe"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            exit 1
            ;;
    esac
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check Python
    if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
        print_error "Python is not installed or not in PATH"
        exit 1
    fi
    
    # Determine Python command
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        PIP_CMD="pip3"
    else
        PYTHON_CMD="python"
        PIP_CMD="pip"
    fi
    
    print_success "Python found: $($PYTHON_CMD --version)"
    
    # Check pip
    if ! command -v $PIP_CMD &> /dev/null; then
        print_error "pip is not installed or not in PATH"
        exit 1
    fi
    
    print_success "pip found: $($PIP_CMD --version)"
}

# Function to setup virtual environment
setup_venv() {
    print_status "Setting up virtual environment..."
    
    if [ ! -d "venv" ]; then
        $PYTHON_CMD -m venv venv
        print_success "Virtual environment created"
    else
        print_status "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    case "$OS" in
        "windows")
            source venv/Scripts/activate
            ;;
        *)
            source venv/bin/activate
            ;;
    esac
    
    print_success "Virtual environment activated"
}

# Function to install requirements
install_requirements() {
    print_status "Installing requirements..."
    
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        print_success "Requirements installed from requirements.txt"
    else
        # Install minimal requirements
        pip install pytz pyinstaller
        print_success "Basic requirements installed"
    fi
}

# Function to create PyInstaller spec file
create_spec_file() {
    print_status "Creating PyInstaller spec file..."
    
    cat > "$SPEC_FILE" << EOF
# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['$SCRIPT_NAME'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=['pytz'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='nepal_clock$EXTENSION',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,
)

# macOS app bundle
if '$OS' == 'macos':
    app = BUNDLE(
        exe,
        name='$APP_NAME.app',
        icon=None,
        bundle_identifier='com.example.nepalclock',
    )
EOF
    
    print_success "Spec file created: $SPEC_FILE"
}

# Function to build executable
build_executable() {
    print_status "Building executable for $PLATFORM..."
    
    # Clean previous builds
    rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
    
    # Build with PyInstaller
    pyinstaller --clean "$SPEC_FILE"
    
    if [ $? -eq 0 ]; then
        print_success "Build completed successfully!"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Function to create distribution package
create_distribution() {
    print_status "Creating distribution package..."
    
    DIST_NAME="nepal-clock-${OS}-$(date +%Y%m%d)"
    DIST_DIR="releases/$DIST_NAME"
    
    mkdir -p "$DIST_DIR"
    
    case "$OS" in
        "macos")
            if [ -d "$OUTPUT_DIR/$APP_NAME.app" ]; then
                cp -R "$OUTPUT_DIR/$APP_NAME.app" "$DIST_DIR/"
                EXECUTABLE_PATH="$DIST_DIR/$APP_NAME.app"
            else
                cp "$OUTPUT_DIR/nepal_clock" "$DIST_DIR/"
                EXECUTABLE_PATH="$DIST_DIR/nepal_clock"
            fi
            ;;
        "windows")
            cp "$OUTPUT_DIR/nepal_clock.exe" "$DIST_DIR/"
            EXECUTABLE_PATH="$DIST_DIR/nepal_clock.exe"
            ;;
        "linux")
            cp "$OUTPUT_DIR/nepal_clock" "$DIST_DIR/"
            chmod +x "$DIST_DIR/nepal_clock"
            EXECUTABLE_PATH="$DIST_DIR/nepal_clock"
            ;;
    esac
    
    # Create README for distribution
    cat > "$DIST_DIR/README.txt" << EOF
Nepal Clock Widget - $PLATFORM Distribution
==========================================

Installation:
1. Extract this archive to your preferred location
2. Run the executable:
   - Windows: Double-click nepal_clock.exe
   - macOS: Double-click Nepal Clock.app
   - Linux: Run ./nepal_clock from terminal

Features:
- Live Nepal time display
- Draggable window
- Always on top option
- Right-click context menu
- Automatic position saving

Controls:
- Drag to move window
- Right-click for options menu
- ESC key to close
- Click X to close

Built on: $(date)
Platform: $PLATFORM
EOF
    
    # Create archive
    cd releases
    case "$OS" in
        "windows")
            # Use built-in Windows compression or 7zip if available
            if command -v 7z &> /dev/null; then
                7z a "${DIST_NAME}.zip" "$DIST_NAME"
            else
                # Fallback to tar (available in Windows 10+)
                tar -czf "${DIST_NAME}.tar.gz" "$DIST_NAME"
            fi
            ;;
        "macos")
            # Create DMG for macOS
            if command -v hdiutil &> /dev/null && [ -d "$DIST_NAME/$APP_NAME.app" ]; then
                hdiutil create -volname "$APP_NAME" -srcfolder "$DIST_NAME" -ov -format UDZO "${DIST_NAME}.dmg"
            else
                tar -czf "${DIST_NAME}.tar.gz" "$DIST_NAME"
            fi
            ;;
        "linux")
            tar -czf "${DIST_NAME}.tar.gz" "$DIST_NAME"
            ;;
    esac
    cd ..
    
    print_success "Distribution package created in releases/"
    print_status "Executable location: $EXECUTABLE_PATH"
}

# Function to cleanup
cleanup() {
    print_status "Cleaning up build artifacts..."
    rm -rf "$BUILD_DIR" "$SPEC_FILE"
    print_success "Cleanup completed"
}

# Function to test executable
test_executable() {
    print_status "Testing executable..."
    
    case "$OS" in
        "macos")
            if [ -d "$OUTPUT_DIR/$APP_NAME.app" ]; then
                print_success "macOS app bundle created successfully"
            elif [ -f "$OUTPUT_DIR/nepal_clock" ]; then
                print_success "Executable created successfully"
            else
                print_error "No executable found!"
                exit 1
            fi
            ;;
        "windows")
            if [ -f "$OUTPUT_DIR/nepal_clock.exe" ]; then
                print_success "Windows executable created successfully"
            else
                print_error "No executable found!"
                exit 1
            fi
            ;;
        "linux")
            if [ -f "$OUTPUT_DIR/nepal_clock" ]; then
                print_success "Linux executable created successfully"
            else
                print_error "No executable found!"
                exit 1
            fi
            ;;
    esac
}

# Main build function
main_build() {
    print_status "Starting build process for $PLATFORM..."
    
    # Check if script exists
    if [ ! -f "$SCRIPT_NAME" ]; then
        print_error "Script file '$SCRIPT_NAME' not found!"
        exit 1
    fi
    
    check_dependencies
    setup_venv
    install_requirements
    create_spec_file
    build_executable
    test_executable
    create_distribution
    
    if [ "$1" != "--keep-build" ]; then
        cleanup
    fi
    
    print_success "Build process completed for $PLATFORM!"
    print_status "Find your executable in the 'releases' directory"
}

# Function to display help
show_help() {
    echo "Nepal Clock Widget Build Script"
    echo "=============================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --help, -h          Show this help message"
    echo "  --clean, -c         Clean build artifacts and exit"
    echo "  --keep-build        Keep build artifacts after compilation"
    echo "  --dev-build         Development build (console visible)"
    echo ""
    echo "Examples:"
    echo "  $0                  Build for current platform"
    echo "  $0 --clean          Clean build artifacts"
    echo "  $0 --keep-build     Build and keep intermediate files"
    echo ""
    echo "Supported Platforms:"
    echo "  - Windows (via Git Bash, WSL, or native)"
    echo "  - macOS"
    echo "  - Linux"
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    rm -rf "$BUILD_DIR" "$OUTPUT_DIR" "$SPEC_FILE" "releases" "venv" "__pycache__"
    rm -f "*.pyc" "nepal_clock_settings.json"
    print_success "All build artifacts cleaned"
}

# Main script logic
main() {
    # Parse command line arguments
    case "$1" in
        "--help"|"-h")
            show_help
            exit 0
            ;;
        "--clean"|"-c")
            clean_build
            exit 0
            ;;
        "--keep-build")
            detect_os
            main_build "--keep-build"
            ;;
        "--dev-build")
            detect_os
            # Modify spec file for development build
            SCRIPT_NAME="nepal_clock_widget.py"
            main_build "--keep-build"
            ;;
        "")
            detect_os
            main_build
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"