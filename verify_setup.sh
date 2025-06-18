#!/bin/bash
echo "🔍 Running verification script..."
echo ""

# Ensure HOME is set; fallback if not (though unlikely in typical execution)
HOME="${HOME:-$(getent passwd $USER | cut -d: -f6)}"

check_command() {
    local cmd_name="$1"
    local cmd_to_run="$2"
    local version_arg="$3"

    # Default cmd_to_run to cmd_name if not specified
    if [ -z "$cmd_to_run" ]; then
        cmd_to_run="$cmd_name"
    fi

    echo "------------------------------------"
    echo "Checking for: $cmd_name"
    if command -v "$cmd_to_run" >/dev/null 2>&1; then
        echo -e "✅ $cmd_name: Found in PATH"
        if [ -n "$version_arg" ]; then
            # Handle commands that might have multi-line version output or error output
            # Capture stdout and stderr, then process
            local version_output
            version_output=$($cmd_to_run $version_arg 2>&1)
            local exit_code=$?

            if [ $exit_code -eq 0 ]; then
                # Display first line of version output, or full if short
                echo "   Version: $(echo "$version_output" | head -n 1)"
            else
                echo -e "   ⚠️ $cmd_name $version_arg returned non-zero exit code ($exit_code)."
                echo "      Output: $(echo "$version_output" | head -n 1)"
            fi
        fi
    else
        echo -e "❌ $cmd_name: Not found in PATH"
    fi
    echo ""
}

check_command "Git" "git" "--version"
check_command "GitHub CLI" "gh" "--version"
check_command "Node.js" "node" "--version"
check_command "npm" "npm" "--version"
check_command "Python 3" "python3" "--version"
check_command "pip3" "pip3" "--version"

# VS Code's 'code --version' can be problematic in non-GUI/headless environments or if not fully set up.
# We'll check for the command and note if version check is problematic.
echo "------------------------------------"
echo "Checking for: Visual Studio Code (code)"
if command -v "code" >/dev/null 2>&1; then
    echo -e "✅ Visual Studio Code (code): Found in PATH"
    # Attempt version, but be mindful of potential issues.
    # Some environments might not have 'code --version' work as expected (e.g. if it tries to connect to a display server)
    code_version_output=$(code --version 2>&1)
    if [ $? -eq 0 ]; then
         echo "   Version: $(echo "$code_version_output" | head -n 2)" # Often 2 lines for VSCode
    else
         echo "   ⚠️ Could not determine VS Code version via 'code --version'. This is sometimes normal in headless environments."
    fi
else
    echo -e "❌ Visual Studio Code (code): Not found in PATH"
fi
echo ""

check_command "ImageMagick (magick)" "magick" "--version"
# If magick not found, try convert (for older ImageMagick)
if ! command -v magick >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
    echo "   'magick' not found, trying 'convert' for older ImageMagick..."
    check_command "ImageMagick (convert)" "convert" "--version"
elif ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    # Neither found, this will be caught by the initial magick check failing if convert also fails
    echo -e "   Neither 'magick' nor 'convert' found for ImageMagick."
fi


# For npm global packages, ensure $HOME/.npm-global/bin is in PATH for these commands to be found
# The PATH check below is more indicative for these.
echo "------------------------------------"
echo "Checking for npm global packages (Firebase CLI, serve):"
echo "Note: These rely on '$HOME/.npm-global/bin' being in your PATH for the current session."
echo ""
check_command "Firebase CLI" "firebase" "--version"
check_command "Serve" "serve" "--version" # Serve's version is tricky, `serve --version` doesn't work. `serve -v` or `npm list -g serve`
# For serve, a better check might be if `serve --help` works
echo "------------------------------------"
echo "Checking for: Serve (alternative check)"
if command -v "serve" >/dev/null 2>&1; then
    echo -e "✅ Serve: Found in PATH"
    serve_help_output=$(serve --help 2>&1)
    if [ $? -eq 0 ]; then
        echo "   'serve --help' executed successfully."
    else
        echo "   ⚠️ 'serve --help' returned non-zero exit code."
    fi
else
    echo -e "❌ Serve: Not found in PATH"
fi
echo ""


echo "------------------------------------"
echo "🔧 Checking configurations..."
echo ""

NPM_GLOBAL_PATH_EXPECTED="$HOME/.npm-global/bin"
echo "Checking for NPM global path in current PATH: $NPM_GLOBAL_PATH_EXPECTED"
if [[ ":$PATH:" == *":$NPM_GLOBAL_PATH_EXPECTED:"* ]]; then
    echo -e "✅ NPM global path ($NPM_GLOBAL_PATH_EXPECTED) is in the current PATH."
else
    echo -e "⚠️ NPM global path ($NPM_GLOBAL_PATH_EXPECTED) does NOT seem to be in the current PATH."
    echo "   Current PATH: $PATH"
    echo "   Note: This script checks the current session's PATH. If jules_env_setup.sh modified a shell config file (e.g., .bashrc), you might need to open a new terminal or source that file."
fi
echo ""

echo "Checking Git global default branch..."
GIT_DEFAULT_BRANCH=$(git config --global init.defaultBranch 2>/dev/null || echo "Error reading git config")
if [ "$GIT_DEFAULT_BRANCH" == "main" ]; then
    echo -e "✅ Git defaultBranch (init.defaultBranch) is 'main'."
elif [ "$GIT_DEFAULT_BRANCH" == "Error reading git config" ]; then
    echo -e "❌ Could not read Git global config. Is Git installed and configured?"
else
    echo -e "❌ Git defaultBranch (init.defaultBranch) is '$GIT_DEFAULT_BRANCH', expected 'main'."
fi
echo ""

PROJECTS_DIR_EXPECTED="$HOME/paul-phillips-projects"
echo "Checking for Projects directory: $PROJECTS_DIR_EXPECTED"
if [ -d "$PROJECTS_DIR_EXPECTED" ]; then
    echo -e "✅ Projects directory ($PROJECTS_DIR_EXPECTED) exists."
else
    echo -e "❌ Projects directory ($PROJECTS_DIR_EXPECTED) does not exist."
fi
echo ""

echo "------------------------------------"
echo "🔍 Verification finished. Review results above."
echo "Reminder: For checks like PATH configuration, a new terminal session might be needed after running jules_env_setup.sh."
