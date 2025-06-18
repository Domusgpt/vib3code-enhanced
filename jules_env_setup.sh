#!/bin/bash
# Jules Environment Setup Script for Paul Phillips Projects
# Bash script for macOS/Linux setup

set -e

echo "🚀 Setting up Jules' development environment for Paul Phillips projects..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# --- OS Detection ---
# Detects if the script is running on macOS or Linux.
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
    print_info "Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    print_info "Detected Linux"
else
    print_error "Unsupported OS: $OSTYPE"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for sudo privileges if on Linux
if [[ "$OS" == "linux" ]]; then
    if ! sudo -n true 2>/dev/null; then
        print_warning "Sudo privileges may be required for some installations."
        print_info "You might be prompted for your password."
        # Forcing a sudo prompt here can ensure subsequent sudo commands don't fail if tty is lost
        # However, it's better to let individual commands prompt as needed.
        # sudo true
    fi
fi

# Install Homebrew on macOS
if [[ "$OS" == "mac" ]] && ! command_exists brew; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the current script execution to ensure 'brew' command is available immediately.
    if [[ -x "/opt/homebrew/bin/brew" ]]; then # Standard for Apple Silicon Macs
        export PATH="/opt/homebrew/bin:$PATH"
        print_status "Homebrew (Apple Silicon path) added to PATH for this session."
    elif [[ -x "/usr/local/bin/brew" ]]; then # Standard for Intel Macs
         export PATH="/usr/local/bin:$PATH"
         print_status "Homebrew (Intel path) added to PATH for this session."
    fi
fi

# Update package managers
print_header "📦 Updating package managers..."
if [[ "$OS" == "mac" ]]; then
    if command_exists brew; then
        brew update
        print_status "Homebrew updated."
    else
        print_warning "Homebrew not found. Skipping update."
    fi
elif [[ "$OS" == "linux" ]]; then
    if command_exists apt; then
        sudo apt update
        print_status "APT updated."
    elif command_exists yum; then
        sudo yum update -y
        print_status "YUM updated."
    elif command_exists pacman; then
        sudo pacman -Sy
        print_status "Pacman updated."
    else
        print_warning "No common Linux package manager (apt, yum, pacman) found. Skipping update."
    fi
fi

# Install core development tools
print_header "🔧 Installing core development tools..."

# Git
if ! command_exists git; then
    print_info "Installing Git..."
    if [[ "$OS" == "mac" ]]; then
        brew install git
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            sudo apt install -y git
        elif command_exists yum; then
            sudo yum install -y git
        elif command_exists pacman; then
            sudo pacman -S git --noconfirm
        else
            print_error "Cannot install Git: No known package manager for Linux."
        fi
    fi
    if command_exists git; then
        print_status "Git installed successfully. Version: $(git --version)"
    else
        print_error "Git installation failed."
    fi
else
    print_status "Git already installed. Version: $(git --version)"
fi

# GitHub CLI
if ! command_exists gh; then
    print_info "Installing GitHub CLI..."
    if [[ "$OS" == "mac" ]]; then
        brew install gh
    elif [[ "$OS" == "linux" ]]; then
        # GitHub CLI installation steps for Debian/Ubuntu based on official documentation.
        if command_exists apt; then
            type -p curl >/dev/null || sudo apt install curl -y # Ensure curl is available
            # Download and install GPG key
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            # Add GitHub CLI repository
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y
        elif command_exists yum; then # For Fedora, RHEL, etc.
            # Using dnf as yum is often a symlink to dnf
            if command_exists dnf; then
                sudo dnf install -y 'dnf-command(config-manager)'
                sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo dnf install -y gh
            else # Fallback for older systems with only yum
                sudo yum install -y 'yum-utils'
                sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
                sudo yum install -y gh
            fi
        elif command_exists pacman; then
            sudo pacman -S --noconfirm github-cli
        else
            print_error "Cannot install GitHub CLI: No known package manager for Linux (apt/yum/dnf/pacman)."
        fi
    fi
    if command_exists gh; then
        print_status "GitHub CLI installed successfully. Version: $(gh --version)"
    else
        print_error "GitHub CLI installation failed."
    fi
else
    print_status "GitHub CLI already installed. Version: $(gh --version)"
fi

# Node.js and npm (version 20 LTS for compatibility)
# Installs Node.js version 20 (LTS) and its corresponding npm.
NODE_MAJOR_WANTED=20
if ! command_exists node; then
    print_info "Installing Node.js ${NODE_MAJOR_WANTED} LTS..."
    if [[ "$OS" == "mac" ]]; then
        brew install node@${NODE_MAJOR_WANTED}
        brew link node@${NODE_MAJOR_WANTED} --force
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command_exists dnf; then # Prefer DNF
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo bash -
            sudo dnf install -y nodejs
        elif command_exists yum; then # Fallback to YUM
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo bash -
            sudo yum install -y nodejs
        elif command_exists pacman; then
            sudo pacman -S --noconfirm nodejs npm
        else
            print_error "Cannot install Node.js: No known package manager for Linux (apt/yum/dnf/pacman)."
        fi
    fi
    if command_exists node && command_exists npm; then
        print_status "Node.js $(node --version) and npm $(npm --version) installed."
    else
        print_error "Node.js/npm installation failed."
    fi
else
    node_version_major=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_version_major" -lt ${NODE_MAJOR_WANTED} ]; then
        print_warning "Node.js version v${node_version_major} detected. Upgrading to Node.js ${NODE_MAJOR_WANTED} LTS..."
        if [[ "$OS" == "mac" ]]; then
            brew install node@${NODE_MAJOR_WANTED}
            brew link node@${NODE_MAJOR_WANTED} --force
        elif [[ "$OS" == "linux" ]]; then
            if command_exists apt; then
                curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo -E bash -
                sudo apt-get install -y nodejs
            elif command_exists dnf; then # Prefer DNF
                curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo bash -
                sudo dnf install -y nodejs
            elif command_exists yum; then # Fallback to YUM
                curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR_WANTED}.x | sudo bash -
                sudo yum install -y nodejs
            elif command_exists pacman; then
                sudo pacman -S --noconfirm nodejs npm
            else
                print_error "Cannot upgrade Node.js: No known package manager for Linux (apt/yum/dnf/pacman)."
            fi
        fi
        if command_exists node && [[ "$(node --version | cut -d'v' -f2 | cut -d'.' -f1)" -ge ${NODE_MAJOR_WANTED} ]]; then
            print_status "Node.js upgraded to $(node --version)."
        else
            print_error "Node.js upgrade failed or did not reach version ${NODE_MAJOR_WANTED}."
        fi
    else
        print_status "Node.js already installed (version $(node --version), npm $(npm --version) - compatible)."
    fi
fi

# Python 3
if ! command_exists python3; then
    print_info "Installing Python 3..."
    if [[ "$OS" == "mac" ]]; then
        brew install python@3.11 # Or simply python3 if specific version isn't critical
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            sudo apt install -y python3 python3-pip python3-venv
        elif command_exists yum || command_exists dnf; then
            sudo dnf install -y python3 python3-pip # dnf is preferred
        elif command_exists pacman; then
            sudo pacman -S python python-pip --noconfirm
        else
            print_error "Cannot install Python 3: No known package manager for Linux."
        fi
    fi
    if command_exists python3 && command_exists pip3; then
        print_status "Python 3 ($(python3 --version)) and pip3 installed."
    else
        print_error "Python 3 installation failed."
    fi
else
    print_status "Python 3 already installed ($(python3 --version)). Pip3: $(pip3 --version || echo 'not found')"
fi

# VS Code
if ! command_exists code; then
    print_info "Installing Visual Studio Code..."
    if [[ "$OS" == "mac" ]]; then
        brew install --cask visual-studio-code
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            # VS Code installation for Debian/Ubuntu based systems.
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
            # install -D ensures directory path exists; then remove the temporary gpg file.
            sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/packages.microsoft.gpg
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
            rm -f packages.microsoft.gpg # Clean up temporary GPG key file
            sudo apt update
            sudo apt install -y code
        elif command_exists yum || command_exists dnf; then # Handles yum and dnf
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo dnf check-update # Use dnf
            sudo dnf install -y code # Use dnf
        elif command_exists pacman; then
            sudo pacman -S --noconfirm code
        else
            print_error "Cannot install VS Code: No known package manager for Linux (apt/yum/dnf/pacman)."
        fi
    fi
    if command_exists code; then
        print_status "VS Code installed." # VS Code version check can be tricky due to how it's launched.
    else
        print_error "VS Code installation failed."
    fi
else
    print_status "VS Code already installed."
fi

# ImageMagick
# Checks for 'magick' (v7+) or 'convert' (legacy v6) to determine if ImageMagick is installed.
if ! command_exists magick && ! command_exists convert; then
    print_info "Installing ImageMagick..."
    if [[ "$OS" == "mac" ]]; then
        brew install imagemagick
    elif [[ "$OS" == "linux" ]]; then
        if command_exists apt; then
            sudo apt install -y imagemagick
        elif command_exists yum || command_exists dnf; then
            sudo dnf install -y ImageMagick # dnf is preferred
        elif command_exists pacman; then
            sudo pacman -S imagemagick --noconfirm
        else
            print_error "Cannot install ImageMagick: No known package manager for Linux."
        fi
    fi
    if command_exists magick || command_exists convert; then
        print_status "ImageMagick installed. Version: $(magick --version || convert --version)"
    else
        print_error "ImageMagick installation failed."
    fi
else
    print_status "ImageMagick already installed. Version: $(magick --version || convert --version)"
fi

# Configure npm for user-level global packages (avoid permission issues)
print_header "📦 Configuring npm and installing global packages..."

NPM_GLOBAL_DIR="$HOME/.npm-global"
# Set npm to use user directory for global packages only if not already set to this path
CURRENT_NPM_PREFIX=$(npm config get prefix)
if [ "$CURRENT_NPM_PREFIX" != "$NPM_GLOBAL_DIR" ]; then
    npm config set prefix "$NPM_GLOBAL_DIR"
    print_info "npm prefix set to $NPM_GLOBAL_DIR"
else
    print_info "npm prefix already set to $NPM_GLOBAL_DIR"
fi

# Add npm global bin to PATH for current session
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

# Install essential global packages
# --force flag is intentionally omitted from npm install -g for safer installs.
# If specific version conflicts or permission issues arise that genuinely need --force,
# it should be a documented, conscious decision rather than a default.
print_info "Installing Firebase CLI and serve globally..."
npm install -g firebase-tools serve # Removed --force

# Verify installations
if command_exists firebase; then
    print_status "Firebase CLI installed successfully. Version: $(firebase --version)"
else
    print_warning "Firebase CLI installation may have failed or is not in PATH immediately. Check $NPM_GLOBAL_DIR/bin."
fi

if command_exists serve; then
    print_status "Serve package installed successfully. Version: $(serve --version || echo '(version not easily available)')"
else
    print_warning "Serve package installation may have failed or is not in PATH immediately. Check $NPM_GLOBAL_DIR/bin."
fi

# Attempt to add npm global bin to shell configuration files for future sessions
NPM_PATH_LINE="export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\"" # Use the variable defined earlier
CONFIG_FILES_CHECKED=0
CONFIG_FILES_MODIFIED=0

# Function to add path if not already present
add_to_shell_config() {
    local config_file="$1"
    local line_to_add="$2"
    local friendly_name="$3" # e.g., ~/.bashrc

    if [ -f "$config_file" ]; then
        CONFIG_FILES_CHECKED=$((CONFIG_FILES_CHECKED + 1))
        # Use grep -qF -- "$line_to_add" to ensure fixed string search and handle potential special characters
        if ! grep -qF -- "$line_to_add" "$config_file"; then
            print_info "Attempting to add npm global bin to PATH in $friendly_name..."
            # Backup line commented out as per prompt
            # cp "$config_file" "${config_file}.bak_jules_setup_$(date +%Y%m%d_%H%M%S)"
            # print_info "Backup of $friendly_name created at ${config_file}.bak_jules_setup_..."
            if echo "$line_to_add" >> "$config_file"; then
                print_status "Successfully added npm global bin to PATH in $friendly_name."
                # Message about sourcing/restarting terminal moved to the end summary
                CONFIG_FILES_MODIFIED=$((CONFIG_FILES_MODIFIED + 1))
            else
                print_warning "Failed to add PATH to $friendly_name. Please add it manually."
            fi
        else
            print_status "npm global bin already configured in $friendly_name."
            # Consider it "modified" for success messaging if already present
            CONFIG_FILES_MODIFIED=$((CONFIG_FILES_MODIFIED + 1))
        fi
    # else
        # print_info "$friendly_name not found, skipping." # Optional: for debugging
    fi
}

# Determine default shell and config file
user_shell_path="$SHELL" # Store the full path for safety, e.g. /bin/bash
user_shell=$(basename "$user_shell_path")

BASH_CONFIG="$HOME/.bashrc"
ZSH_CONFIG="$HOME/.zshrc"
PROFILE_CONFIG="$HOME/.profile" # General fallback

# Add to specific config files
if [ "$user_shell" = "bash" ]; then
    add_to_shell_config "$BASH_CONFIG" "$NPM_PATH_LINE" "~/.bashrc"
elif [ "$user_shell" = "zsh" ]; then
    add_to_shell_config "$ZSH_CONFIG" "$NPM_PATH_LINE" "~/.zshrc"
fi

# Fallback to .profile logic:
# If no shell-specific file was successfully updated (or found to be already correct), then consider .profile.
if [ "$CONFIG_FILES_MODIFIED" -eq 0 ]; then # Only if no primary config was updated/found correct
    if [ -f "$PROFILE_CONFIG" ]; then
        # This condition is now simpler: if primary wasn't handled, try .profile if it exists.
        add_to_shell_config "$PROFILE_CONFIG" "$NPM_PATH_LINE" "~/.profile"
    fi
fi
# End of new code block for PATH persistence

# Install Python packages
print_header "🐍 Installing Python packages..."

print_info "The following Python packages will be installed globally (or for the current user via --user)."
print_info "For individual Python projects, it is highly recommended to use virtual environments"
print_info "(e.g., using 'python3 -m venv myproject_env') to manage dependencies and avoid conflicts."
print_info "Learn more: https://docs.python.org/3/library/venv.html"

# Using --break-system-packages is often needed on newer Linux distros (Python 3.11+)
# when installing packages globally with pip if not in a virtual environment.
# This script defaults to --user installs to avoid modifying system Python packages directly where possible.
PIP_INSTALL_OPTS="--user"
if [[ "$OS" == "linux" ]] && [[ $(python3 -V 2>&1 | awk '{print $2}' | cut -d. -f2) -ge 11 ]]; then
     # PEP 668, Python 3.11+ on Linux often requires this for global pip installs outside venv
     # Check if pip supports it, some older pips might not.
     if pip3 install --help | grep -q 'break-system-packages'; then
        PIP_INSTALL_OPTS="$PIP_INSTALL_OPTS --break-system-packages"
     fi
fi

if pip3 install $PIP_INSTALL_OPTS markdown beautifulsoup4 pillow requests pyyaml flask fastapi; then
    print_status "Core Python packages installed for the current user."
    print_info "Installed packages: markdown, beautifulsoup4, pillow, requests, pyyaml, flask, fastapi"
else
    print_error "Failed to install some Python packages."
fi


# Configure Git
print_header "⚙️ Configuring Git..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input # Good for cross-platform projects
print_status "Git configured with Paul Phillips project standards"

# Create projects directory
PROJECTS_DIR="$HOME/paul-phillips-projects"
if [ ! -d "$PROJECTS_DIR" ]; then
    mkdir -p "$PROJECTS_DIR"
    print_status "Created projects directory: $PROJECTS_DIR"
else
    print_status "Projects directory already exists: $PROJECTS_DIR"
fi


print_header "📋 Installation Summary & Next Steps"
echo "" # Add a newline for spacing

print_info "The setup script has attempted to install and configure the following tools:"
echo "- Git (version checked during installation)"
echo "- GitHub CLI (version checked during installation)"
echo "- Node.js & npm (versions checked during installation)"
echo "- Python 3 & pip (versions checked during installation)"
echo "- Visual Studio Code (installation attempted)"
echo "- ImageMagick (version checked during installation)"
echo "- Firebase CLI & Serve (versions checked after npm install)"
echo "" # Add a newline for spacing

print_info "Key configurations attempted:"
echo "- npm global package path set to $NPM_GLOBAL_DIR"
# The NPM_GLOBAL_DIR variable is defined earlier in the script.
# The PROJECTS_DIR variable is also defined earlier.
echo "- Git global settings (defaultBranch main, pull.rebase false, core.autocrlf input)"
echo "- Projects directory created/verified at $PROJECTS_DIR"
echo "" # Add a newline for spacing

# Conditional messaging for npm PATH persistence
if [ "$CONFIG_FILES_MODIFIED" -gt 0 ]; then
    print_status "npm global binary directory PATH ($NPM_GLOBAL_DIR/bin) was configured in your shell profile(s)."
    print_info "ACTION REQUIRED: Please open a new terminal or source your shell config (e.g., 'source ~/.bashrc') for these PATH changes to take full effect."
elif [ "$CONFIG_FILES_CHECKED" -gt 0 ] && [ "$CONFIG_FILES_MODIFIED" -eq 0 ]; then
    print_status "npm global binary directory PATH ($NPM_GLOBAL_DIR/bin) was already configured in your shell profile(s)."
else
    # This case means no common config files were found/checked by the add_to_shell_config logic, or writing failed.
    print_warning "Could not automatically update your shell configuration for npm global packages."
    print_info "ACTION REQUIRED: To make npm global packages (like Firebase CLI, serve) available in new terminals, please manually add the following line to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc, or ~/.profile):"
    print_info "  export PATH=\"$NPM_GLOBAL_DIR/bin:\$PATH\""
    print_info "After adding, restart your terminal or source the configuration file."
fi
echo "" # Add a newline for spacing

print_info "Python packages (markdown, beautifulsoup4, etc.) were installed using 'pip3 install $PIP_INSTALL_OPTS'." # Using variable here
print_info "Remember the advice to use Python virtual environments for your projects to manage dependencies effectively!"
echo "" # Add a newline for spacing

print_status "🚀 Jules' development environment setup script finished."
print_warning "Please review the entire script output above for any specific errors or warnings related to individual steps."
