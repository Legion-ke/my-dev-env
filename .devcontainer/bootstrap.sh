#!/bin/bash
set -e

echo "🚀 Starting Adaptable Bootstrap..."

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

# 2. Install Mise Manually (Bypass Registry Errors)
if ! command -v mise &>/dev/null; then
  echo "🛠️ Installing Mise..."
  curl https://mise.jdx.dev/install.sh | sh
fi
export PATH="$HOME/.local/bin:$PATH"

# 3. Dynamic Tool Installation
FINAL_TOOLS="${EXTRA_TOOLS:-tmux ripgrep fzf bat zoxide eza}"
echo "📦 Installing: $FINAL_TOOLS"
sudo apt-get update && sudo apt-get install -y $FINAL_TOOLS

# 4. Mise Language Setup
FINAL_LANGS="${MISE_LANGS:-node@latest python@3.12 go@latest}"
echo "🛠️ Mise installing: $FINAL_LANGS"
# Activate mise for this session
eval "$($HOME/.local/bin/mise activate bash)"
mise use --global $FINAL_LANGS

# 5. Apply Chezmoi Dotfiles
echo "✨ Applying dotfiles..."
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
chezmoi init --apply --force Legion-ke

echo "✅ Environment Ready!"
