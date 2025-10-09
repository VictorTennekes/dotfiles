# Dotfiles

My personal macOS configuration, managed with Make and structured for XDG compliance. This setup automates the installation of applications and symlinking of configuration files for a clean and reproducible environment.

---
## ✨ Overview

This repository contains the configuration files for my primary development tools. The main goals are:

* **Automation:** A single command should set up a new machine.
* **Cleanliness:** Adherence to the XDG Base Directory Specification to keep the home directory uncluttered.
* **Simplicity:** Using `make` to orchestrate shell scripts for straightforward and readable logic.

---
## 🔧 What's Inside?

This setup configures the following tools:

* **Shell:** Zsh with [Antidote](https://github.com/mattmc3/antidote) for fast plugin management.
* **Package Manager:** [Homebrew](https://brew.sh/) for installing system packages and applications via a `Brewfile`.
* **Terminal:** Configuration for Ghostty.
* **Window Manager:** Configuration for Aerospace.
* **Core Utils:** Settings for my core utilities.
* **Editor:** My Neovim setup is managed separately. See [Neovim Configuration](#-neovim-configuration) below.

---
## 🚀 Installation

### Prerequisites
* Git
* macOS Command Line Tools (run `xcode-select --install` to get them)

### Steps
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/victortennekes/dotfiles.git](https://github.com/your-username/dotfiles.git)
    cd dotfiles
    ```

2.  **Run the installer:**
    ```bash
    make install
    ```
    This command will automatically:
    * Install **Homebrew** if it's not already present.
    * Install all applications and tools listed in the `Brewfile`.
    * Symlink all configuration files to the correct locations (`~/.config/` and `~/`).

---
## 💡 Post-Installation

The first time you open a Zsh session after installation, Antidote will automatically clone the plugins listed in your `zsh/zsh_plugins.txt` file.

---
## 🛠️ Usage

The `Makefile` provides two main targets for managing your dotfiles:

* `make install`: Sets up everything or updates existing symlinks and packages.
* `make clean`: Safely removes all created symlinks from your home directory.

---
## 📂 Repository Structure

* `Makefile`: The main orchestrator that runs all setup and cleanup tasks.
* `Brewfile`: A list of all Homebrew packages, casks, and App Store apps to be installed.
* `config/`: Contains application-specific configurations that will be linked into `~/.config/`.
* `scripts/`: Holds the robust `install` and `clean` shell scripts responsible for symlinking.
* `zshenv`: The bootstrap file that sets the `$ZDOTDIR`, keeping the home directory clean.

---
## 🖋️ Neovim Configuration

My Neovim configuration is managed in its own repository to keep it modular. You can find it over at [github.com/victortennekes/nvim](https://github.com/victortennekes/nvim).
