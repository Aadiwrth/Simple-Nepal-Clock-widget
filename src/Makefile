# Nepal Clock Widget - Makefile
# Cross-platform build automation

.PHONY: help build clean dev install test run all

# Default variables
PYTHON := $(shell which python3 || which python)
PIP := $(shell which pip3 || which pip)
APP_NAME := nepal_clock_widget.py
VENV_DIR := venv
DIST_DIR := dist
BUILD_DIR := build

# Platform detection
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    PLATFORM := linux
    EXECUTABLE := nepal_clock
endif
ifeq ($(UNAME_S),Darwin)
    PLATFORM := macos
    EXECUTABLE := nepal_clock
endif
ifneq (,$(findstring CYGWIN,$(UNAME_S)))
    PLATFORM := windows
    EXECUTABLE := nepal_clock.exe
endif
ifneq (,$(findstring MINGW,$(UNAME_S)))
    PLATFORM := windows
    EXECUTABLE := nepal_clock.exe
endif

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
help: ## Show this help message
	@echo "Nepal Clock Widget - Build System"
	@echo "================================="
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Platform detected: $(PLATFORM)"
	@echo "Python: $(PYTHON)"
	@echo ""

all: clean build test ## Clean, build, and test the application

# Virtual environment setup
$(VENV_DIR)/bin/activate: requirements.txt
	@echo "$(BLUE)[INFO]$(NC) Setting up virtual environment..."
	@$(PYTHON) -m venv $(VENV_DIR)
	@$(VENV_DIR)/bin/pip install -r requirements.txt
	@echo "$(GREEN)[SUCCESS]$(NC) Virtual environment ready"

venv: $(VENV_DIR)/bin/activate ## Create virtual environment

install: venv ## Install dependencies
	@echo "$(BLUE)[INFO]$(NC) Installing dependencies..."
	@$(VENV_DIR)/bin/pip install -r requirements.txt
	@echo "$(GREEN)[SUCCESS]$(NC) Dependencies installed"

dev: venv ## Setup development environment
	@echo "$(BLUE)[INFO]$(NC) Setting up development environment..."
	@$(VENV_DIR)/bin/pip install -r requirements.txt
	@$(VENV_DIR)/bin/pip install pylint black flake8
	@echo "$(GREEN)[SUCCESS]$(NC) Development environment ready"

run: venv ## Run the application in development mode
	@echo "$(BLUE)[INFO]$(NC) Starting Nepal Clock Widget..."
	@$(VENV_DIR)/bin/python $(APP_NAME)

test: venv ## Test the application
	@echo "$(BLUE)[INFO]$(NC) Testing application..."
	@$(VENV_DIR)/bin/python -c "import $(APP_NAME:%.py=%); print('Import test passed')"
	@echo "$(GREEN)[SUCCESS]$(NC) Application test completed"

lint: dev ## Run code linting
	@echo "$(BLUE)[INFO]$(NC) Running code linting..."
	@$(VENV_DIR)/bin/flake8 $(APP_NAME) || true
	@$(VENV_DIR)/bin/pylint $(APP_NAME) || true
	@echo "$(GREEN)[SUCCESS]$(NC) Linting completed"

format: dev ## Format code with black
	@echo "$(BLUE)[INFO]$(NC) Formatting code..."
	@$(VENV_DIR)/bin/black $(APP_NAME)
	@echo "$(GREEN)[SUCCESS]$(NC) Code formatted"

build: venv ## Build executable for current platform
	@echo "$(BLUE)[INFO]$(NC) Building for $(PLATFORM)..."
	@chmod +x build.sh
	@./build.sh
	@echo "$(GREEN)[SUCCESS]$(NC) Build completed"

build-windows: venv ## Build for Windows (cross-platform)
	@echo "$(BLUE)[INFO]$(NC) Building for Windows..."
	@$(VENV_DIR)/bin/pyinstaller --onefile --windowed --name nepal_clock $(APP_NAME)
	@echo "$(GREEN)[SUCCESS]$(NC) Windows build completed"

build-linux: venv ## Build for Linux (cross-platform)
	@echo "$(BLUE)[INFO]$(NC) Building for Linux..."
	@$(VENV_DIR)/bin/pyinstaller --onefile --name nepal_clock $(APP_NAME)
	@echo "$(GREEN)[SUCCESS]$(NC) Linux build completed"

build-macos: venv ## Build for macOS (cross-platform)
	@echo "$(BLUE)[INFO]$(NC) Building for macOS..."
	@$(VENV_DIR)/bin/pyinstaller --onefile --windowed --name nepal_clock $(APP_NAME)
	@echo "$(GREEN)[SUCCESS]$(NC) macOS build completed"

build-all: build-windows build-linux build-macos ## Build for all platforms

package: build ## Create distribution package
	@echo "$(BLUE)[INFO]$(NC) Creating distribution package..."
	@mkdir -p releases
	@cd $(DIST_DIR) && tar -czf ../releases/nepal-clock-$(PLATFORM)-$$(date +%Y%m%d).tar.gz *
	@echo "$(GREEN)[SUCCESS]$(NC) Package created in releases/"

clean: ## Clean build artifacts
	@echo "$(BLUE)[INFO]$(NC) Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) $(DIST_DIR) releases
	@rm -f nepal_clock.spec *.pyc
	@rm -rf __pycache__ *.egg-info
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -delete
	@echo "$(GREEN)[SUCCESS]$(NC) Cleanup completed"

clean-all: clean ## Clean everything including virtual environment
	@echo "$(BLUE)[INFO]$(NC) Cleaning everything..."
	@rm -rf $(VENV_DIR)
	@rm -f nepal_clock_settings.json
	@echo "$(GREEN)[SUCCESS]$(NC) Complete cleanup finished"

# Platform-specific quick builds
quick-build: ## Quick build without virtual environment
	@echo "$(BLUE)[INFO]$(NC) Quick build for $(PLATFORM)..."
	@pyinstaller --onefile --windowed --name nepal_clock $(APP_NAME)

# Development helpers
deps: ## Show dependency tree
	@echo "$(BLUE)[INFO]$(NC) Dependency information:"
	@$(PYTHON) -c "import pkg_resources; [print(f'{pkg.project_name}=={pkg.version}') for pkg in pkg_resources.working_set]" | sort

info: ## Show build environment information
	@echo "Nepal Clock Widget - Build Information"
	@echo "====================================="
	@echo "Platform: $(PLATFORM)"
	@echo "Python: $(PYTHON)"
	@echo "PIP: $(PIP)"
	@echo "Virtual Env: $(VENV_DIR)"
	@echo "App Name: $(APP_NAME)"
	@echo ""
	@echo "Python Version:"
	@$(PYTHON) --version
	@echo ""
	@echo "Available Make Targets:"
	@make help

# Quick commands for common tasks
.PHONY: start stop status

start: run ## Alias for run

stop: ## Stop any running instances (Linux/macOS)
	@echo "$(BLUE)[INFO]$(NC) Stopping Nepal Clock Widget..."
	@pkill -f "$(APP_NAME)" || echo "No running instances found"

status: ## Check if application is running
	@echo "$(BLUE)[INFO]$(NC) Checking application status..."
	@pgrep -fl "$(APP_NAME)" || echo "Application not running"

# Install system-wide (Linux/macOS)
install-system: build ## Install system-wide (requires sudo)
	@echo "$(BLUE)[INFO]$(NC) Installing system-wide..."
ifeq ($(PLATFORM),linux)
	@sudo cp $(DIST_DIR)/nepal_clock /usr/local/bin/
	@echo "$(GREEN)[SUCCESS]$(NC) Installed to /usr/local/bin/nepal_clock"
endif
ifeq ($(PLATFORM),macos)
	@sudo cp $(DIST_DIR)/nepal_clock /usr/local/bin/
	@echo "$(GREEN)[SUCCESS]$(NC) Installed to /usr/local/bin/nepal_clock"
endif

uninstall-system: ## Uninstall from system (requires sudo)
	@echo "$(BLUE)[INFO]$(NC) Uninstalling from system..."
	@sudo rm -f /usr/local/bin/nepal_clock
	@echo "$(GREEN)[SUCCESS]$(NC) Uninstalled from system"