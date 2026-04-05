#!/bin/bash
set -e

echo "🚀 Starting Polyglot Bootstrap..."

# 1. Fedora-to-Ubuntu Compatibility
if ! command -v dnf &>/dev/null; then
  sudo ln -s /usr/bin/apt-get /usr/local/bin/dnf || true
fi

# 2. Install Core CLI Tools
sudo apt-get update
sudo apt-get install -y \
  curl git tmux ripgrep fzf bat zoxide eza \
  build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev

# 3. Setup Mise & Languages
# If you have a .mise.toml or .tool-versions in your project,
# Mise will pick it up automatically.
echo "🛠️ Installing languages via Mise..."
# Ensure Mise is in the path for this sub-shell
export PATH="$HOME/.local/share/mise/bin:$PATH"

# Install your core stack (Change versions as needed)
mise use --global node@latest
mise use --global python@3.12
mise use --global go@latest
mise use --global rust@stable

# 4. Install Chezmoi & Apply Dotfiles
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
export PATH="$HOME/.local/bin:$PATH"

echo "✨ Applying dotfiles..."
# Use --force if you want to overwrite default Ubuntu configs
chezmoi init --apply --force Legion-ke

echo "✅ Environment Ready! Your polyglot tools are live."
