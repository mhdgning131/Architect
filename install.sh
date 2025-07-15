#!/bin/bash
# Architect Installation Script

set -e

# Configuration
SCRIPT_NAME="architect"
SCRIPT_FILE="architect.py"
INSTALL_DIR="/usr/local/bin"
LOCAL_INSTALL_DIR="$HOME/.local/bin"
REPO_URL="https://github.com/mhdgning131/architect"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_requirements() {
    print_info "Checking requirements..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is required but not installed"
        exit 1
    fi
    
    python_version=$(python3 --version 2>&1 | cut -d' ' -f2)
    print_info "Found Python $python_version"
    
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        print_error "Either wget or curl is required for downloading"
        exit 1
    fi
    
    print_success "Requirements check passed"
}

download_script() {
    print_info "Downloading architect.py..."
    
    local temp_file="/tmp/architect.py"
    
    if command -v wget &> /dev/null; then
        wget -q -O "$temp_file" "$REPO_URL/main/architect.py"
    elif command -v curl &> /dev/null; then
        curl -s -o "$temp_file" "$REPO_URL/main/architect.py"
    fi
    
    if [ ! -f "$temp_file" ]; then
        print_error "Failed to download architect.py"
        exit 1
    fi
    
    # Verify it's a valid Python script
    if ! head -n 1 "$temp_file" | grep -q "python"; then
        print_error "Downloaded file doesn't appear to be a valid Python script"
        exit 1
    fi
    
    echo "$temp_file"
}

install_system_wide() {
    local temp_file="$1"
    
    print_info "Installing system-wide to $INSTALL_DIR..."
    
    if [ ! -w "$INSTALL_DIR" ]; then
        print_warning "Need sudo privileges to install to $INSTALL_DIR"
        sudo cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
        sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    else
        cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME"
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    print_success "Installed to $INSTALL_DIR/$SCRIPT_NAME"
}

install_user_local() {
    local temp_file="$1"
    
    print_info "Installing to user directory $LOCAL_INSTALL_DIR..."
    
    mkdir -p "$LOCAL_INSTALL_DIR"
    
    cp "$temp_file" "$LOCAL_INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$LOCAL_INSTALL_DIR/$SCRIPT_NAME"
    
    print_success "Installed to $LOCAL_INSTALL_DIR/$SCRIPT_NAME"
    
    if [[ ":$PATH:" != *":$LOCAL_INSTALL_DIR:"* ]]; then
        print_warning "$LOCAL_INSTALL_DIR is not in your PATH"
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "export PATH=\"\$PATH:$LOCAL_INSTALL_DIR\""
    fi
}

install_local_copy() {
    if [ -f "$SCRIPT_FILE" ]; then
        print_info "Found local $SCRIPT_FILE, using it..."
        
        chmod +x "$SCRIPT_FILE"
        
        if [ "$INSTALL_TYPE" = "system" ]; then
            if [ ! -w "$INSTALL_DIR" ]; then
                sudo cp "$SCRIPT_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
                sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
            else
                cp "$SCRIPT_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
                chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
            fi
            print_success "Installed to $INSTALL_DIR/$SCRIPT_NAME"
        else
            mkdir -p "$LOCAL_INSTALL_DIR"
            cp "$SCRIPT_FILE" "$LOCAL_INSTALL_DIR/$SCRIPT_NAME"
            chmod +x "$LOCAL_INSTALL_DIR/$SCRIPT_NAME"
            print_success "Installed to $LOCAL_INSTALL_DIR/$SCRIPT_NAME"
        fi
        
        return 0
    fi
    
    return 1
}

verify_installation() {
    print_info "Verifying installation..."
    
    if command -v "$SCRIPT_NAME" &> /dev/null; then
        print_success "✓ $SCRIPT_NAME command is available"
        
        if $SCRIPT_NAME --help &> /dev/null; then
            print_success "✓ $SCRIPT_NAME is working correctly"
        else
            print_warning "⚠ $SCRIPT_NAME installed but may not be working properly"
        fi
    else
        print_error "✗ $SCRIPT_NAME command not found in PATH"
        return 1
    fi
}

install_dependencies() {
    print_info "Checking optional dependencies..."
    
    if ! python3 -c "import yaml" &> /dev/null; then
        print_warning "PyYAML not found (optional, needed for YAML output)"
        read -p "Install PyYAML? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installing PyYAML..."
            pip3 install --user PyYAML
            print_success "PyYAML installed"
        fi
    else
        print_success "PyYAML is available"
    fi
}

show_usage() {
    cat << EOF
Architect CLI Installation Script

Usage: $0 [OPTIONS]

Options:
    -h, --help     Show this help message
    -l, --local    Install to ~/.local/bin (default)
    -s, --system   Install to /usr/local/bin (requires sudo)
    -u, --uninstall Remove architect from system
    --deps         Install optional dependencies
    --no-deps      Skip dependency installation

Examples:
    $0                 # Install to ~/.local/bin
    $0 --system        # Install to /usr/local/bin
    $0 --uninstall     # Remove from system
    
EOF
}

uninstall() {
    print_info "Uninstalling architect..."
    
    for dir in "$INSTALL_DIR" "$LOCAL_INSTALL_DIR"; do
        if [ -f "$dir/$SCRIPT_NAME" ]; then
            if [ "$dir" = "$INSTALL_DIR" ] && [ ! -w "$dir" ]; then
                sudo rm -f "$dir/$SCRIPT_NAME"
            else
                rm -f "$dir/$SCRIPT_NAME"
            fi
            print_success "Removed $dir/$SCRIPT_NAME"
        fi
    done
    
    print_success "Uninstallation complete"
}

main() {
    INSTALL_TYPE="local"
    SKIP_DEPS=false
    INSTALL_DEPS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -l|--local)
                INSTALL_TYPE="local"
                shift
                ;;
            -s|--system)
                INSTALL_TYPE="system"
                shift
                ;;
            -u|--uninstall)
                uninstall
                exit 0
                ;;
            --deps)
                INSTALL_DEPS=true
                shift
                ;;
            --no-deps)
                SKIP_DEPS=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    echo "ArchitectInstallation Script"
    echo "======================================"
    
    check_requirements
    
    if ! install_local_copy; then
        temp_file=$(download_script)
        
        if [ "$INSTALL_TYPE" = "system" ]; then
            install_system_wide "$temp_file"
        else
            install_user_local "$temp_file"
        fi
        
        # Clean up
        rm -f "$temp_file"
    fi
    
    if [ "$INSTALL_DEPS" = true ] || ([ "$SKIP_DEPS" = false ] && [ -t 0 ]); then
        install_dependencies
    fi
    
    verify_installation
    
    echo
    print_success "Installation complete!"
    echo
    echo "Usage examples:"
    echo "  $SCRIPT_NAME --help"
    echo "  $SCRIPT_NAME scan ."
    echo "  $SCRIPT_NAME create -f structure.txt"
    echo "  $SCRIPT_NAME --interactive"
    echo
    
    if [ "$INSTALL_TYPE" = "local" ]; then
        echo "Note: If 'architect' command is not found, add this to your shell profile:"
        echo "export PATH=\"\$PATH:$LOCAL_INSTALL_DIR\""
    fi
}

main "$@"