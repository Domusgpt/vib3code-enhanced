# Jules' Development Environment Setup Script for Paul Phillips Projects

## Purpose

This script automates the setup of a consistent development environment across macOS and various Linux distributions. It installs and configures a suite of essential tools typically used in Paul Phillips' projects.

## Features

The script installs and configures the following:

*   **Core Tools:**
    *   Git (version control)
    *   GitHub CLI (`gh`)
    *   Node.js (version 20 LTS) and npm
    *   Python 3 and pip
    *   Visual Studio Code (VS Code)
    *   ImageMagick (image processing)
*   **npm Global Packages:**
    *   Firebase CLI (`firebase-tools`)
    *   `serve` (static file server)
*   **Configurations:**
    *   npm configured for user-level global package installation (`~/.npm-global`) to avoid permission issues.
    *   `~/.npm-global/bin` added to the system PATH (and attempts to persist this in shell configuration files like `~/.bashrc`, `~/.zshrc`, or `~/.profile`).
    *   Git global settings optimized for common workflows (`init.defaultBranch=main`, `pull.rebase=false`, `core.autocrlf=input`).
    *   A projects directory created at `~/paul-phillips-projects`.
*   **User Experience:**
    *   Color-coded output for better readability.
    *   Checks for existing installations to avoid redundant operations.
    *   Attempts to automatically update shell configuration for PATH changes.
    *   Provides a summary of actions at the end.
    *   Includes advice on Python virtual environments.

## Supported Operating Systems

*   **macOS:** Latest and recent versions (tested on Apple Silicon and Intel).
*   **Linux:**
    *   Ubuntu (latest LTS and recent versions)
    *   Fedora (latest and recent versions)
    *   Arch Linux (rolling release)
    *   Other Debian/RHEL based distributions should generally work.

## Prerequisites

Before running the script, ensure you have:

*   **`curl` or `wget`:** To download the script itself if you are not cloning the repository via Git. Most systems have `curl` pre-installed.
    *   Example: `sudo apt install curl` (Ubuntu), `sudo yum install curl` (Fedora).
*   **`sudo` access:** The script uses `sudo` for system-wide installations of package managers (like Homebrew on Mac if not present) and tools (like Git, Node.js from package managers on Linux). You will be prompted for your password where necessary.

## How to Run

1.  **Download or Clone the Script:**
    *   **Using Git (Recommended if you want to track updates):**
        ```bash
        git clone <repository_url> # Replace <repository_url> with the actual URL
        cd <repository_directory>
        ```
    *   **Using curl:**
        ```bash
        curl -O <raw_script_url>/jules_env_setup.sh # Replace <raw_script_url>
        ```
2.  **Navigate to Script Directory:**
    If you cloned the repository, `cd` into it. If you downloaded the script, ensure your terminal is in the directory where `jules_env_setup.sh` is located.
3.  **Make it Executable:**
    ```bash
    chmod +x jules_env_setup.sh
    ```
4.  **Run the Script:**
    ```bash
    ./jules_env_setup.sh
    ```
    The script will print information about the actions it's taking. Review the output for any errors or warnings.

## What the Script Does (Overview)

1.  **Detects OS:** Identifies if running on macOS or Linux and adapts commands accordingly.
2.  **Updates Package Managers:** Runs `brew update` on macOS or `apt update`, `yum update`, etc., on Linux.
3.  **Installs Core Development Tools:** Installs Git, GitHub CLI, Node.js 20 LTS (with npm), Python 3 (with pip), VS Code, and ImageMagick using the appropriate package manager for the detected OS. It checks if tools are already installed.
4.  **Configures npm:**
    *   Sets the npm prefix to `~/.npm-global` to allow global package installation without requiring `sudo` for `npm install -g`.
    *   Installs `firebase-tools` and `serve` globally.
    *   Adds `~/.npm-global/bin` to the PATH for the current session.
    *   Attempts to add this PATH to your shell configuration file (e.g., `~/.bashrc`, `~/.zshrc`, `~/.profile`) for persistence across terminal sessions.
5.  **Installs Python Packages:** Installs a list of common Python packages (`markdown`, `beautifulsoup4`, `pillow`, `requests`, `pyyaml`, `flask`, `fastapi`) using `pip3 install --user` (or with `--break-system-packages` if necessary on newer Linux systems when installing user-wide). It also advises using virtual environments for projects.
6.  **Configures Git:** Sets global Git configurations: `init.defaultBranch` to `main`, `pull.rebase` to `false`, and `core.autocrlf` to `input`.
7.  **Creates Projects Directory:** Ensures the directory `~/paul-phillips-projects` exists.
8.  **Provides Summary:** At the end, the script prints a summary of tools installed/configured and any actions required from the user (like restarting the terminal).

## Post-Installation

*   **New Terminal Session:** For PATH changes (especially for npm global packages) to take full effect, **open a new terminal session** after the script completes. Alternatively, you can "source" your shell's configuration file (e.g., `source ~/.bashrc` or `source ~/.zshrc`). The script will guide you on this.
*   **Verify Setup:** You can use the `verify_setup.sh` script (if available in the same repository) to perform basic checks on the installed tools and configurations:
    ```bash
    chmod +x verify_setup.sh
    ./verify_setup.sh
    ```
*   **Manual Checks:** Refer to the `TESTING_STRATEGY.md` for manual verification steps.

## Idempotency

The script is designed to be idempotent. This means you can run it multiple times on the same system. It will check for existing installations and configurations and skip them if they are already correctly set up, or attempt to bring them to the desired state.

## Customization (Optional)

If you need to modify the list of packages installed, versions, or specific configurations, you can:
1.  Fork the repository (if applicable).
2.  Edit `jules_env_setup.sh` directly to suit your needs.
Be mindful of the script's logic if making significant changes.

## Troubleshooting (Basic Tips)

*   **Read the Output:** Carefully review the script's output for any error messages (usually in red or yellow). These messages often provide clues about what went wrong.
*   **Prerequisites:** Ensure `curl` and `sudo` access are available as mentioned in the prerequisites.
*   **Internet Connection:** The script downloads packages and tools, so a stable internet connection is required.
*   **Permissions:** If you encounter permission errors not handled by `sudo` within the script, ensure the script itself is executable and that you have the necessary rights in your home directory for creating configuration files and directories.
*   **Conflicting Installations:** If you have manually installed versions of tools (e.g., Node.js via `nvm` in a way that conflicts with system installs), there might be complexities. The script tries to use system package managers primarily.

---
This README provides a guide to using the `jules_env_setup.sh` script. For detailed manual testing procedures, see `TESTING_STRATEGY.md`.
