#!/usr/bin/env zsh
# ==============================================================================
# macOS Workstation Bootstrap Script
# Installs: Xcode CLI Tools, Homebrew, uv, and Ansible
# Does NOT launch the Ansible playbook automatically.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
ARCH="$(uname -m)"

echo "==> Starting macOS Bootstrap..."
echo "    Architecture: $ARCH"
echo "    Workspace:    $SCRIPT_DIR"

# 1. Xcode Command Line Tools
echo "==> Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  echo "==> Triggering Xcode Command Line Tools installation..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD=$(softwareupdate -l | grep -B 1 "Command Line Tools" | awk -F"*" '/^ *\*/ {print $2}' | sed -e 's/^ *//' | tr -d '\n' || true)
  if [[ -n "$PROD" ]]; then
    softwareupdate -i "$PROD" --verbose
  else
    xcode-select --install || true
    echo "==> Please complete the Xcode Command Line Tools dialog, then re-run bootstrap.sh."
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    exit 0
  fi
  rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
else
  echo "    Xcode Command Line Tools already installed."
fi

# 2. Homebrew
echo "==> Checking Homebrew..."
BREW_PREFIX="/usr/local"
if [[ "$ARCH" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
fi

if ! command -v brew &>/dev/null; then
  if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
    echo "    Found existing Homebrew at $BREW_PREFIX/bin/brew, activating in current shell..."
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  else
    echo "==> Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$("$BREW_PREFIX/bin/brew" shellenv)"
  fi
else
  echo "    Homebrew already present at $(command -v brew)."
fi

# 3. uv and ansible
echo "==> Ensuring uv and ansible are installed..."
brew install uv ansible

# 4. Xpra (X11 Forwarding)
echo "==> Checking for Xpra..."
if [[ ! -d "/Applications/Xpra.app" ]]; then
  echo "==> Installing Xpra..."
  if [[ "$ARCH" == "arm64" ]]; then
    curl -L -o /tmp/Xpra.pkg "https://xpra.org/dists/osx/arm64/Xpra-arm64-6.5.3-r0.pkg"
  else
    curl -L -o /tmp/Xpra.pkg "https://xpra.org/dists/osx/x86_64/Xpra-x86_64-6.5.3-r0.pkg"
  fi
  sudo installer -pkg /tmp/Xpra.pkg -target /
  rm -f /tmp/Xpra.pkg
else
  echo "    Xpra already installed."
fi

echo ""
echo "=============================================================================="
echo " macOS Bootstrap Complete!"
echo " Installed: Xcode CLI Tools, Homebrew ($BREW_PREFIX), uv, Ansible, Xpra"
echo ""
echo " Next steps (run manually when ready):"
echo "   cd $SCRIPT_DIR"
echo "   uv run --with ansible-core ansible-galaxy collection install -r requirements.yml"
echo "   uv run --with ansible-core ansible-playbook -i inventory/hosts.yml playbooks/site.yml"
echo "=============================================================================="

