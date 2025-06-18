# Testing Strategy for jules_env_setup.sh

This document outlines the manual testing process for the `jules_env_setup.sh` script.

## Prerequisites for Testers

*   Access to virtual machines (VMs) or physical machines with the target operating systems.
*   Familiarity with using the terminal/command line.
*   Ability to create a clean/minimal OS installation for testing.

## Target Operating Systems

The script should be tested on the latest available versions of:

*   **macOS** (e.g., latest Sonoma, Ventura)
*   **Ubuntu** (latest LTS version, e.g., 22.04 LTS)
*   **Fedora** (latest version)
*   **Arch Linux** (rolling release, test on a recent snapshot)

## Testing Steps for Each OS

For each target operating system:

1.  **Clean Installation:** Start with a fresh, minimal installation of the OS to ensure no pre-existing conflicting software.
2.  **Prerequisites:**
    *   Ensure `curl` is available. Most minimal installations include it. If not, install it using the OS package manager (e.g., `sudo apt install curl` on Ubuntu).
    *   `git` is installed by the script itself, but if you were to fetch the script via `git clone`, you'd need `git` first. For this testing, assume `curl` is used to fetch the script or it's otherwise made available.
3.  **Download/Clone Script:**
    *   Download `jules_env_setup.sh` to the test machine (e.g., using `curl -O <URL_to_script>`).
    *   Alternatively, if `git` is pre-installed for testing setup, clone the repository containing the script.
4.  **Make Executable:**
    *   Open a terminal and navigate to the directory where the script was downloaded.
    *   Run `chmod +x jules_env_setup.sh`.
5.  **Run the Script:**
    *   Execute the script: `./jules_env_setup.sh`.
6.  **Observe Output:**
    *   Carefully monitor the script's output during execution.
    *   Note any error messages, warnings, or unexpected behavior.
7.  **Post-Completion Verification:**
    After the script finishes, verify the installation and configuration of tools:
    *   **Tool Versions:** Check versions of key tools.
        *   `git --version`
        *   `gh --version`
        *   `node --version`
        *   `npm --version`
        *   `python3 --version`
        *   `pip3 --version`
        *   `code --version` (May require VS Code to be launched or have specific CLI setup for this command to work reliably from terminal immediately).
        *   `magick --version` or `convert --version` (for ImageMagick)
        *   `firebase --version` (Requires new terminal/sourced config)
        *   `serve --version` (May also require new terminal/sourced config; version can be tricky to get directly)
    *   **npm Global Path:**
        *   Open a **new terminal session** or re-source your shell configuration file (e.g., `source ~/.bashrc`, `source ~/.zshrc`).
        *   Try running `firebase --version` and `serve --help` (or other serve commands).
        *   Inspect your shell configuration file (e.g., `cat ~/.bashrc`) to see if the `$HOME/.npm-global/bin` path was added.
    *   **Git Global Configuration:**
        *   Run `git config --global --list`.
        *   Verify `init.defaultbranch=main`, `pull.rebase=false`, and `core.autocrlf=input`.
    *   **Projects Directory:**
        *   Check if the directory `$HOME/paul-phillips-projects` was created (`ls -d $HOME/paul-phillips-projects`).
8.  **Note Deviations:** Document any tools that failed to install, configurations not applied, or versions that seem incorrect.

## Idempotency Test

This test ensures that running the script multiple times does not cause issues or unwanted changes.

1.  **First Run:** Perform a full run of the script on a clean OS as per the steps above.
2.  **Second Run:** After the first successful run and verification, run the script again: `./jules_env_setup.sh` on the **same machine without cleaning it**.
3.  **Verify Script Behavior:**
    *   Observe the output. The script should recognize that tools are already installed and configurations are already applied.
    *   Messages like "Git already installed", "npm global bin already configured in ~/.bashrc", etc., are expected.
4.  **Ensure No Errors:** Verify that no new errors or warnings are introduced during the second run.
5.  **System State:** Confirm that the system state remains consistent and that tools are still correctly configured. No settings should be negatively altered by a subsequent run.

## Reporting Issues

*   If any bugs, errors, or unexpected behaviors are found, please report them.
*   Include the following information in your report:
    *   Operating System and version.
    *   Steps to reproduce the issue.
    *   Relevant output from the script (especially error messages).
    *   Expected behavior vs. actual behavior.
    *   Any manual troubleshooting steps taken.
*   (Specify where to report issues, e.g., GitHub Issues for the project).
