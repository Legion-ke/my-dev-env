# 🌌 Legion-Ke Polyglot Dev Environment

This repository contains my "Portable Development Identity." It is a highly adaptable, lightweight DevContainer setup powered by **DevPod**, **Mise**, and **Chezmoi**.



## 🚀 Features
- **OS:** Ubuntu-based (with a Smart Shim for Fedora `dnf` compatibility).
- **Dotfiles:** Automatically pulls and applies configs from `Legion-ke/chezmoi`.
- **Languages:** Managed by **Mise** (Node.js, Python, Go, Rust, etc.).
- **Tools:** Neovim (stable), Zsh, Tmux, Ripgrep, Fzf, Bat, and more.
- **Dynamic:** Inject any language or tool at runtime using environment variables.

---

## 🛠️ Quick Start

### 1. The Bootstrap Command
To spin up a new environment from any machine with DevPod installed:

```bash
devpod up [https://github.com/Legion-ke/my-dev-env](https://github.com/Legion-ke/my-dev-env) --ide none
