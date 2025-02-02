FROM archlinux:latest

# Base system setup (static packages)
RUN --mount=type=cache,target=/var/cache/pacman/pkg \
  pacman-key --init && \
  pacman-key --populate archlinux && \
  pacman -Syu --noconfirm && \
  pacman -S --needed --noconfirm \
  base-devel git \
  7zip bat carapace-bin difftastic \
  diff-so-fancy fd fzf gh lazygit \
  ripgrep rustup starship \
  yazi zig zoxide

# Install yay (AUR helper)
RUN git clone https://aur.archlinux.org/yay.git && \
  cd yay && \
  makepkg -si --noconfirm --noprogressbar && \
  cd .. && \
  rm -rf yay

WORKDIR /

# Install semi-static AUR packages
RUN --mount=type=cache,target=/root/.cache/yay \
  yay -S --noconfirm \
  git-delta \
  quarto-cli \
  px

# Configure system components
RUN rustup default stable && \
  rustup component add rust-analyzer

# Install frequently updated components (separate layer)
RUN yay -S --noconfirm \
  neovim-nightly-bin \
  wezterm-nightly-bin \
  nushell-git \
  python-uv \
  neovide-bin

# Configure system components
ENV PATH="/root/.cargo/bin:${PATH}"

# Cleanup
RUN pacman -Scc --noconfirm && \
  rm -rf /var/cache/pacman/pkg/* /tmp/* ~/.cache/yay/*
