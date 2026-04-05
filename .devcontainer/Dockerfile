# ─────────────────────────────────────────────────────────────────────────────
# Legion DevBox Base Image
# ─────────────────────────────────────────────────────────────────────────────
FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USERNAME=vscode
ARG HOME=/home/${USERNAME}

USER ${USERNAME}

# ─────────────────────────────────────────────
# 1. Core CLI Tools
# ─────────────────────────────────────────────
RUN sudo apt-get update && sudo apt-get install -y \
    git \
    zsh \
    tmux \
    curl \
    unzip \
    wget \
    ripgrep \
    bat \
    fd-find \
    fzf \
    gcc \
    make \
    cmake \
    g++ \
    python3 \
    python3-pip \
    xclip \
    xsel \
    fontconfig \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────────
# 2. eza
# ─────────────────────────────────────────────
RUN curl -Lo /tmp/eza.tar.gz \
        "https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz" \
    && tar -xzf /tmp/eza.tar.gz -C /tmp \
    && sudo mv /tmp/eza /usr/local/bin/eza \
    && rm -f /tmp/eza.tar.gz

# ─────────────────────────────────────────────
# 3. zoxide
# ─────────────────────────────────────────────
RUN curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# ─────────────────────────────────────────────
# 4. Starship
# ─────────────────────────────────────────────
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# ─────────────────────────────────────────────
# 5. Mise
# ─────────────────────────────────────────────
RUN curl https://mise.run | sh

# ─────────────────────────────────────────────
# 6. Oh My Zsh Plugins (OMZ pre-installed in base image)
# ─────────────────────────────────────────────
RUN git clone --depth=1 \
        https://github.com/zsh-users/zsh-autosuggestions \
        ${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting \
        ${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && git clone --depth=1 \
        https://github.com/zsh-users/zsh-completions \
        ${HOME}/.oh-my-zsh/custom/plugins/zsh-completions

# ─────────────────────────────────────────────
# 7. Neovim (tarball — AppImage requires FUSE, unavailable in Docker)
# ─────────────────────────────────────────────
RUN NVIM_VERSION=$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest" \
        | grep '"tag_name"' | cut -d'"' -f4) \
    && echo "Installing Neovim ${NVIM_VERSION}..." \
    && curl -fLo /tmp/nvim.tar.gz \
        "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz" \
    && tar -xzf /tmp/nvim.tar.gz -C /tmp \
    && sudo mv /tmp/nvim-linux-x86_64 /opt/nvim \
    && sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && rm -f /tmp/nvim.tar.gz \
    && nvim --version

# ─────────────────────────────────────────────
# 8. Neovim Config (from your chezmoi repo)
# ─────────────────────────────────────────────
RUN git clone --depth=1 \
        https://github.com/Legion-ke/chezmoi.git /tmp/chezmoi-src \
    && mkdir -p ${HOME}/.config/nvim \
    && cp -r /tmp/chezmoi-src/dot_config/nvim/. ${HOME}/.config/nvim/ \
    && rm -rf /tmp/chezmoi-src

# ─────────────────────────────────────────────
# 9. Bootstrap lazy.nvim
# ─────────────────────────────────────────────
RUN git clone --filter=blob:none --depth=1 \
    https://github.com/folke/lazy.nvim.git \
    ${HOME}/.local/share/nvim/lazy/lazy.nvim

# ─────────────────────────────────────────────
# 10. Pre-install Neovim plugins (headless)
# ─────────────────────────────────────────────
RUN nvim --headless "+Lazy! sync" +qa 2>&1 || true

# ─────────────────────────────────────────────
# 11. Pre-compile base Treesitter parsers
# ─────────────────────────────────────────────
RUN nvim --headless \
    "+TSInstall lua vim vimdoc bash markdown markdown_inline json yaml toml dockerfile" \
    +qa 2>&1 || true

# ─────────────────────────────────────────────
# 12. JetBrainsMono Nerd Font (individual TTFs ~3MB vs zip ~250MB)
# ─────────────────────────────────────────────
RUN mkdir -p ${HOME}/.local/share/fonts \
    && FONT_BASE="https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures" \
    && for variant in Regular Bold Italic BoldItalic; do \
        curl -fLo "${HOME}/.local/share/fonts/JetBrainsMonoNerdFont-${variant}.ttf" \
            "${FONT_BASE}/${variant}/JetBrainsMonoNerdFont-${variant}.ttf" || true; \
    done \
    && fc-cache -fv 2>/dev/null || true

# ─────────────────────────────────────────────
# 13. Shell Configuration (.zshrc)
# ─────────────────────────────────────────────
RUN cat >> ${HOME}/.zshrc << 'EOF'

# ── Path ──────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ── Mise ──────────────────────────────────────
eval "$($HOME/.local/bin/mise activate zsh)"

# ── Starship ──────────────────────────────────
eval "$(starship init zsh)"

# ── Zoxide ────────────────────────────────────
eval "$(zoxide init zsh --cmd cd)"

# ── Oh My Zsh plugins ─────────────────────────
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf
)

# ── Aliases ───────────────────────────────────
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat --style=auto"
alias vim="nvim"
alias vi="nvim"
alias find="fd"
alias grep="rg"
alias cd="z"

# ── FZF ───────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

EOF

# ─────────────────────────────────────────────
# 14. Tmux Configuration
# ─────────────────────────────────────────────
RUN cat >> ${HOME}/.tmux.conf << 'EOF'

set -g default-terminal "screen-256color"
set -ga terminal-overrides ",*256col*:Tc"
set -g mouse on
set -g base-index 1
set -g pane-base-index 1
set -g history-limit 10000
set -g escape-time 0

unbind C-b
set -g prefix C-Space
bind C-Space send-prefix

bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

bind r source-file ~/.tmux.conf \; display "Config reloaded!"

EOF

# ─────────────────────────────────────────────
# 15. Fix ownership
# ─────────────────────────────────────────────
RUN sudo chown -R ${USERNAME}:${USERNAME} ${HOME}

# ─────────────────────────────────────────────
# METADATA
# ─────────────────────────────────────────────
LABEL org.opencontainers.image.source="https://github.com/Legion-ke/my-dev-env"
LABEL org.opencontainers.image.description="Legion DevBox base image"
LABEL org.opencontainers.image.licenses="MIT"

CMD ["zsh"]
