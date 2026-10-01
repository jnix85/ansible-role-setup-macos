# Ansible Role: setup-macos

Standalone Ansible role for configuring, provisioning, and standardizing macOS workstations from a completely clean reinstall.

Part of the homelab automation suite under `~/src/infra/ansible/`.

---

## Features

- **Zero-Dependency Bootstrap (`bootstrap.sh`)**: Pure `zsh` script to install Xcode Command Line Tools, Homebrew, `uv`, and `ansible` on a clean macOS install without automatically launching playbooks.
- **Homebrew Bundle (`Brewfile.j2`)**: Declarative management of Homebrew taps, CLI packages, GUI casks, and Mac App Store apps via `community.general.homebrew_bundle`.
- **Modular macOS Preferences (`osx_defaults`)**: Organized by domain across modular task files:
  - `defaults_finder.yml`: Hidden files, filename extensions, path bar, status bar, list view, `.DS_Store` suppression.
  - `defaults_dock.yml`: Orientation, icon tile size, autohide, MRU spaces disabling.
  - `defaults_global.yml`: Forced Dark Mode, fast key repeat rate, save/print dialog expansions.
  - `defaults_trackpad.yml`: Tap-to-click on Bluetooth and built-in trackpads.
  - `defaults_screensaver.yml`: Immediate password requirement on display sleep.
- **Dotfiles Synchronization (`chezmoi`)**: Automated initialization and synchronization with `git@github.com:jnix85/chezmoi.git` (with configurable HTTPS fallback).
- **Dock Customization (`dockutil`)**: Declarative pinned application management.
- **Git Global Configuration**: Automated setup of name, email, and default branch (`main`).
- **Developer Scaffolding**: Ensures development root directories (`~/src`, `~/bin`, `~/.local/bin`) exist with proper permissions.

---

## Requirements

Collections (installed automatically via `requirements.yml`):
- `community.general >= 10.0.0`
- `ansible.posix >= 1.5.0`

---

## Quick Start (Fresh Machine)

### 1. Run Bootstrap

On a clean macOS installation, run the bootstrap script:

```zsh
./bootstrap.sh
```

This installs Xcode CLI Tools, Homebrew, `uv`, and `ansible`, then exits cleanly.

### 2. Install Collections

```bash
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-galaxy collection install -r requirements.yml
```

### 3. Run Full Provisioning Playbook

```bash
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/site.yml
```

### 4. Targeted Rapid Playbooks

```bash
# Update macOS preferences only
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/defaults.yml

# Sync Homebrew packages/casks only
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/packages.yml

# Apply dotfiles updates only
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dotfiles.yml

# Re-apply Dock pinning only
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dock.yml
```

---

## License

MIT - Jason Parks
