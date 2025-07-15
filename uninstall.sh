#!/bin/bash

# Architect Uninstallation Script

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_NAME="architect"
INSTALL_DIR="/usr/local/bin"
LOCAL_INSTALL_DIR="$HOME/.local/bin"

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

remove_file() {
    local file_path="$1"
    local use_sudo="$2"
    
    if [ -f "$file_path" ]; then
        if [ "$use_sudo" = "true" ]; then
            sudo rm "$file_path"
        else
            rm "$file_path"
        fi
        print_success "Removed $file_path"
        return 0
    else
        print_warning "$file_path not found"
        return 1
    fi
}

uninstall_system_wide() {
    print_info "Removing system-wide installation..."
    
    local system_script="$INSTALL_DIR/$SCRIPT_NAME"
    
    if [ -f "$system_script" ]; then
        if [ -w "$INSTALL_DIR" ]; then
            remove_file "$system_script" "false"
        else
            print_warning "Need sudo privileges to remove from $INSTALL_DIR"
            if sudo -v; then
                remove_file "$system_script" "true"
            else
                print_error "Cannot remove system-wide installation without sudo"
                return 1
            fi
        fi
    else
        print_warning "System-wide installation not found"
        return 1
    fi
}

uninstall_local() {
    print_info "Removing local installation..."
    
    local local_script="$LOCAL_INSTALL_DIR/$SCRIPT_NAME"
    remove_file "$local_script" "false"
}

check_installations() {
    local found_installations=()
    
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        found_installations+=("system")
    fi
    
    # Check local
    if [ -f "$LOCAL_INSTALL_DIR/$SCRIPT_NAME" ]; then
        found_installations+=("local")
    fi
    
    echo "${found_installations[@]}"
}

main() {
    echo "    ╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "    ║                                                                                ║"
    echo "    ║       █████╗ ██████╗  ██████╗██╗  ██╗██╗████████╗███████╗ ██████╗████████╗     ║"
    echo "    ║      ██╔══██╗██╔══██╗██╔════╝██║  ██║██║╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝     ║"
    echo "    ║      ███████║██████╔╝██║     ███████║██║   ██║   █████╗  ██║        ██║        ║"
    echo "    ║      ██╔══██║██╔══██╗██║     ██╔══██║██║   ██║   ██╔══╝  ██║        ██║        ║"
    echo "    ║      ██║  ██║██║  ██║╚██████╗██║  ██║██║   ██║   ███████╗╚██████╗   ██║        ║"
    echo "    ║      ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝ ╚═════╝   ╚═╝        ║"
    echo "    ║                                                                                ║"
    echo "    ║                           CLI File structure builder                           ║"
    echo "    ║                                    v 1.0.0                                     ║"
    echo "    ╚════════════════════════════════════════════════════════════════════════════════╝"
    
    installations=($(check_installations))
    
    if [ ${#installations[@]} -eq 0 ]; then
        print_warning "No Architect CLI installations found"
        exit 0
    fi
    
    print_info "Found installations:"
    for install in "${installations[@]}"; do
        case $install in
            "system")
                echo "  - System-wide ($INSTALL_DIR/$SCRIPT_NAME)"
                ;;
            "local")
                echo "  - Local ($LOCAL_INSTALL_DIR/$SCRIPT_NAME)"
                ;;
        esac
    done
    
    echo
    print_info "What would you like to uninstall?"
    echo "  1) Remove all installations"
    echo "  2) Remove system-wide installation only"
    echo "  3) Remove local installation only"
    echo "  4) Cancel"
    echo
    
    while true; do
        read -p "Enter your choice (1-4): " choice
        case $choice in
            1)
                print_info "Removing all installations..."
                removed=false
                for install in "${installations[@]}"; do
                    case $install in
                        "system")
                            if uninstall_system_wide; then
                                removed=true
                            fi
                            ;;
                        "local")
                            if uninstall_local; then
                                removed=true
                            fi
                            ;;
                    esac
                done
                if [ "$removed" = "true" ]; then
                    print_success "Uninstallation completed!"
                else
                    print_error "No installations were removed"
                fi
                break
                ;;
            2)
                if [[ " ${installations[@]} " =~ " system " ]]; then
                    uninstall_system_wide
                    print_success "System-wide installation removed!"
                else
                    print_warning "No system-wide installation found"
                fi
                break
                ;;
            3)
                if [[ " ${installations[@]} " =~ " local " ]]; then
                    uninstall_local
                    print_success "Local installation removed!"
                else
                    print_warning "No local installation found"
                fi
                break
                ;;
            4)
                print_info "Uninstallation cancelled"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    
    echo
    print_info "Verifying removal..."
    remaining=$(check_installations)
    if [ -z "$remaining" ]; then
        print_success "All installations successfully removed"
        if [ "$(realpath "$PWD")" = "$(realpath "$HOME/.architect")" ]; then
            cd "$HOME" || {
                print_error "Failed to cd to \$HOME. Aborting deletion."
                exit 1
            }
        fi
        rm -rf "$HOME/.architect"

    else
        print_warning "Some installations may still remain"
    fi
}

main "$@"