# Legion DevBox 🚀

A fully automated, OS-agnostic dev environment built on [DevPod](https://devpod.sh) and [chezmoi](https://chezmoi.io).
Spin up a fully-equipped dev container for any project in ~30 seconds with Neovim, Zsh, Tmux, LSPs, and your language runtime — all pre-baked.

---

## How It Works

```
ghcr.io/legion-ke/devbox-base  ← pre-baked base image (built once)
├── neovim + your config + lazy.nvim plugins
├── zsh + oh-my-zsh + starship + plugins
├── tmux, ripgrep, fzf, bat, eza, zoxide
└── mise (no runtimes yet)

postCreateCommand              ← runs once per new project (~30-60s)
├── mise install go / node / python / rust
├── language LSPs (gopls, pyright, ts-server, rust-analyzer)
└── project-specific Treesitter parsers
```

The base image is rebuilt weekly via GitHub Actions whenever the Dockerfile changes.

---

## Repo Structure

```
my-dev-env/
├── .devcontainer/
│   ├── devcontainer.json       # base devcontainer config (referenced by devup)
│   └── Dockerfile              # base image definition
├── .github/
│   └── workflows/
│       └── build-devbox.yml    # auto-build + push to GHCR
└── README.md
```

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [DevPod CLI](https://devpod.sh/docs/getting-started/install)
- [fzf](https://github.com/junegunn/fzf) (for interactive workspace picker)
- [tmux](https://github.com/tmux/tmux) (for `devtmux`)

---

## Shell Functions (devup suite)

Add these to your `~/.zshrc` or source them from a file.

### `devup [name] [lang]`

Creates and launches a DevBox. With no arguments, fuzzy-picks an existing workspace to resume.

```bash
devup payments-api go       # new Go project
devup storefront node       # new Node project
devup data-pipeline python  # new Python project
devup system-cli rust       # new Rust project
devup scratch               # base env, no language
devup                       # fuzzy resume existing workspace
```

### `devdown [name]`

Stops a running DevBox. Fuzzy-picks if no name given.

```bash
devdown payments-api
devdown   # interactive picker
```

### `devdel [name]`

Deletes a DevBox and removes its host folder from `~/projects/`. Fuzzy-picks if no name given.

```bash
devdel old-project
devdel   # interactive picker
```

### `devssh [name]`

SSH into a DevBox via `devpod ssh`. Fuzzy-picks if no name given.

```bash
devssh payments-api
```

### `devtmux [name]`

Opens a DevBox in a new tmux window. Fuzzy-picks if no name given.

```bash
devtmux payments-api
```

### `devls`

Lists all DevPod workspaces.

```bash
devls
```

---

## What's Baked Into the Base Image

| Tool | Purpose |
|---|---|
| Neovim (latest stable) | Editor — installed via tarball, not AppImage |
| lazy.nvim | Plugin manager — pre-installed headlessly |
| Treesitter parsers | lua, vim, vimdoc, bash, markdown, json, yaml, toml, dockerfile |
| Zsh + Oh My Zsh | Shell — OMZ pre-installed in base devcontainer image |
| zsh-autosuggestions | ZSH plugin |
| zsh-syntax-highlighting | ZSH plugin |
| zsh-completions | ZSH plugin |
| Starship | Prompt |
| Tmux | Terminal multiplexer |
| Mise | Runtime version manager (no languages pre-installed) |
| ripgrep | Fast grep |
| fzf | Fuzzy finder |
| bat | cat with syntax highlighting |
| eza | Modern ls |
| zoxide | Smart cd |
| fd | Fast find |
| JetBrainsMono Nerd Font | Font (individual TTFs, not the full zip) |

---

## What's Installed Per-Project

Language runtimes and LSPs are intentionally **not** baked into the base image. They are installed via `postCreateCommand` when the container is first created.

| Language | Runtime | LSP | Formatter |
|---|---|---|---|
| Go | `mise use --global go@latest` | gopls, dlv | gofumpt |
| Node | `mise use --global node@lts` | typescript-language-server | prettier, eslint_d |
| Python | `mise use --global python@latest` | pyright | ruff, black, isort |
| Rust | `mise use --global rust@latest` | rust-analyzer | rustfmt, clippy |

---

## devcontainer.json

The base config at `.devcontainer/devcontainer.json` is used as the template for all projects:

```json
{
  "name": "Legion-DevBox",
  "image": "ghcr.io/legion-ke/devbox-base:latest",
  "remoteUser": "vscode",
  "containerEnv": {
    "DEVPOD": "true",
    "EDITOR": "nvim",
    "VISUAL": "nvim",
    "TERM": "xterm-256color",
    "COLORTERM": "truecolor"
  },
  "mounts": [
    "source=${localEnv:HOME}/.ssh,target=/home/vscode/.ssh,type=bind,consistency=cached,readonly",
    "source=devbox-mise-cache,target=/home/vscode/.local/share/mise,type=volume",
    "source=devbox-nvim-state,target=/home/vscode/.local/state/nvim,type=volume"
  ],
  "postCreateCommand": "echo '✅ DevBox ready'"
}
```

### Volume mounts explained

| Mount | Purpose |
|---|---|
| `~/.ssh` (bind, readonly) | Git/GitHub SSH access — keys never copied into image |
| `devbox-mise-cache` (volume) | Mise runtimes persist across rebuilds — no re-downloading Go/Node |
| `devbox-nvim-state` (volume) | Neovim undo history and sessions persist across rebuilds |

---

## Building the Base Image

### Manual build

```bash
# Set your GitHub token (needs write:packages, read:packages, repo scopes)
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"

# Login
echo $GITHUB_TOKEN | docker login ghcr.io -u legion-ke --password-stdin

# Build and push
docker build \
  --platform linux/amd64 \
  --push \
  -t ghcr.io/legion-ke/devbox-base:latest \
  -f .devcontainer/Dockerfile .
```

### Automatic builds (GitHub Actions)

The image rebuilds automatically on:
- Any push that modifies `.devcontainer/Dockerfile`
- Weekly on Sunday at midnight (to pull in updated tool versions)

See `.github/workflows/build-devbox.yml`.

---

## Chezmoi Integration

This repo works alongside [Legion-ke/chezmoi](https://github.com/Legion-ke/chezmoi) for dotfile management.

The `postCreateCommand` in `devcontainer.json` initialises chezmoi on first boot:

```bash
mkdir -p ~/.ssh \
  && printf 'Host github.com\n  Hostname ssh.github.com\n  Port 443\n  User git\n  StrictHostKeyChecking no\n' > ~/.ssh/config \
  && chmod 600 ~/.ssh/config \
  && sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply --force --branch main git@github.com:Legion-ke/chezmoi.git
```

### Chezmoi install script behaviour

The chezmoi `install-packages.sh` script is OS-agnostic — it detects the package manager and adapts:

| OS | Package manager |
|---|---|
| Ubuntu / Debian | apt-get |
| Fedora / RHEL | dnf |
| Arch | pacman |
| macOS | brew |

All network-heavy installs (Mise, Starship, Oh My Zsh, language runtimes, fonts) run in isolated subshells so a single timeout never aborts the entire setup.

---

## Neovim Notes

- Installed via **tarball**, not AppImage — AppImages require FUSE which is unavailable in Docker build containers
- Config is pulled from the chezmoi repo at `dot_config/nvim/`
- Plugins are pre-installed headlessly via `lazy.nvim` during image build
- Base Treesitter parsers (lua, bash, json, yaml, etc.) are pre-compiled during image build
- Language-specific parsers (go, tsx, python, rust) are installed via `postCreateCommand`
- If you use `mason.nvim`, disable auto-install inside containers — LSPs are managed by `postCreateCommand` instead:

```lua
require("mason").setup({
  automatic_installation = not (
    vim.env.DEVPOD ~= nil or
    vim.env.REMOTE_CONTAINERS ~= nil
  ),
})
```

---

## Startup Time

| Step | Time |
|---|---|
| Pull base image (cached) | ~2s |
| Container start | ~5s |
| `postCreateCommand` (language + LSPs) | ~30-60s |
| **Total (first create)** | **~1 min** |
| **Total (resume existing)** | **~5-10s** |

Compare this to the original setup (provisioning everything at runtime): **7+ minutes**, with frequent timeouts.

---

## Troubleshooting

**Mise language install timed out**
```bash
# Inside the container
mise use --global go@latest
# or with explicit timeout
MISE_FETCH_TIMEOUT_SECS=120 mise use --global go@latest
```

**Neovim plugins not loaded**
```bash
# Inside the container
nvim --headless "+Lazy! sync" +qa
```

**Treesitter parsers missing**
```bash
# Inside nvim
:TSInstall go python rust
```

**SSH / GitHub auth not working**
```bash
# Verify SSH mount
ls ~/.ssh
ssh -T git@github.com
```

**GHCR push returns 403**

Regenerate your GitHub token with scopes: `write:packages`, `read:packages`, `repo`.

---

## License

MIT
