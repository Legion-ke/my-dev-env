#!/bin/bash
set -e

echo "🚀 Starting Adaptable Bootstrap..."

# 1. Smart Fedora-to-Ubuntu Shim (Handles basic 'dnf install' calls)
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

# 2. Dynamic Tool Installation
# Use $EXTRA_TOOLS if provided, otherwise use these defaults
FINAL_TOOLS="${EXTRA_TOOLS:-tmux ripgrep fzf bat zoxide eza}"
echo "📦 Installing: $FINAL_TOOLS"
sudo apt-get update
sudo apt-get install -y $FINAL_TOOLS

# 3. Mise Language Setup
# Use $MISE_LANGS if provided, otherwise install these defaults
FINAL_LANGS="${MISE_LANGS:-node@latest python@3.12 go@latest}"
echo "🛠️ Mise installing: $FINAL_LANGS"
export PATH="$HOME/.local/share/mise/bin:$PATH"
# Ensure mise is initialized for this subshell
eval "$(mise activate bash)"
mise use --global $FINAL_LANGS

# 4. Apply Chezmoi Dotfiles
echo "✨ Applying dotfiles from Legion-ke..."
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi
export PATH="$HOME/.local/bin:$PATH"
chezmoi init --apply --force Legion-ke

echo "✅ Environment Ready!"
