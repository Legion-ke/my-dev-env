#!/bin/bash

# --- PERMISSIONS FIX ---
# Recursively give the 'vscode' user ownership of the workspace
sudo chown -R vscode:vscode /workspaces/go-api || true
sudo chmod -R 755 /workspaces/go-api || true
# ---

set -e

echo "🚀 Starting Manual Bootstrap (Registry Bypass)..."

# 1. Smart Fedora-to-Ubuntu Shim
if ! command -v dnf &>/dev/null; then
  echo "🔗 Creating smart dnf-to-apt shim..."
  cat <<'EOF' | sudo tee /usr/local/bin/dnf >/dev/null
#!/bin/bash
case "$1" in
    install|remove|update)
        shift
        exec apt-get update && exec apt-get install -y "$@"
        ;;
    *)
        exec apt-get "$@"
        ;;
esac
EOF
  sudo chmod +x /usr/local/bin/dnf
fi

# 2. Install Neovim & Build Tools
echo "📦 Installing Neovim and Core Dependencies..."
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install -y neovim git curl build-essential

# 3. Install Mise Manually
if ! command -v mise &>/dev/null; then
  echo "🛠️ Installing Mise..."
  curl https://mise.jdx.dev/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 4. Dynamic Tool Installation (htop, jq, etc.)
FINAL_TOOLS="${EXTRA_TOOLS:-tmux ripgrep fzf bat zoxide eza}"
echo "📦 Installing Extra Tools: $FINAL_TOOLS"
sudo apt-get install -y $FINAL_TOOLS

# 5. Mise Language Setup (Go, Node, etc.)
FINAL_LANGS="${MISE_LANGS:-node@latest python@3.12 go@latest}"
echo "🛠️ Mise installing: $FINAL_LANGS"
eval "$($HOME/.local/bin/mise activate bash)"
mise use --global $FINAL_LANGS

# 6. Apply Chezmoi Dotfiles
echo "✨ Applying dotfiles..."
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
export PATH="$HOME/.local/bin:$PATH"
chezmoi init --apply --force Legion-ke

echo "✅ Environment Ready! Neovim is live."
