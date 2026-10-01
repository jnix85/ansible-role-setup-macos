# Project Context: ansible-role-setup-macos

**Type:** Ansible Role / Infrastructure Automation  
**Target:** macOS (Darwin 14+ / Sonoma, Sequoia, Apple Silicon & Intel)  
**Service:** Provisioning and configuring macOS workstations: initial zsh bootstrap (`bootstrap.sh`), Homebrew bundle (Brewfile), macOS system preferences (`osx_defaults`), Dock configuration (`dockutil`), Git global defaults, and dotfiles synchronization (`chezmoi`).

---

## Layout

Standard standalone Ansible project structure wiring shared-inventory:
- `bootstrap.sh` (Zero-dependency zsh bootstrap script: installs Xcode CLI tools, Homebrew, uv, Ansible)
- `ansible.cfg` (wires `../shared-inventory/inventory/hosts.yml` and `inventory/hosts.yml`)
- `requirements.yml` (`community.general`, `ansible.posix`)
- `inventory/`
  - `hosts.yml` (Pre-configured `macos` group targeting `localhost` with `ansible_connection: local`)
  - `group_vars/macos/main.yml`
- `playbooks/`
  - `site.yml` (Complete workstation provisioning: developer paths, Git, Homebrew bundle, system preferences, Dock, chezmoi)
  - `defaults.yml` (Rapid macOS system preferences application: Finder, Dock, Global, Trackpad, Screensaver)
  - `packages.yml` (Rapid Homebrew bundle synchronization)
  - `dotfiles.yml` (Rapid chezmoi dotfiles apply)
  - `dock.yml` (Rapid Dock pinned applications sync)
- `roles/setup_macos/` (Core role tasks, handlers, defaults, vars, meta, and Brewfile.j2 template)

---

## Common Commands

```bash
# 1. Fresh Mac Initial Bootstrap (Installs Xcode CLI, Homebrew, uv, Ansible without launching playbooks)
./bootstrap.sh

# 2. Syntax check
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/site.yml --syntax-check
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/defaults.yml --syntax-check
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/packages.yml --syntax-check
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dotfiles.yml --syntax-check
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dock.yml --syntax-check

# 3. Dry-run / Check mode
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check --diff

# 4. Full deployment on local machine
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/site.yml

# 5. Targeted rapid updates
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/defaults.yml
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/packages.yml
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dotfiles.yml
ANSIBLE_CONFIG=ansible.cfg uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/dock.yml
```

---

## comP MCP Tool Usage

At the start of every coding or documentation task, ALWAYS call `run_pipeline` FIRST.
Do NOT read files, run grep/find/Bash searches, or explore the codebase manually before calling run_pipeline.
run_pipeline indexes the entire codebase and returns exactly the relevant files — use it every time.

---

## Session Continuity (daemon restarts / session resets)

Sessions persist across daemon restarts.
When resuming work or restarting the agent, call `session_recall` first to restore prior context.

**When resuming work**:

1. Call `session_recall()` to view past interactions
   - `session_recall({ "query": "keyword" })` — filter by task keywords
   - `session_recall({ "limit": 5 })` — show last N interactions
2. Review what was done previously and continue in that context

**Note**: The hook system also auto-injects recent history into each prompt (`<system-reminder>`),
but explicit `session_recall` is useful to manually review past work or search specific tasks.
