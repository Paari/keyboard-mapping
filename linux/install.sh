#!/usr/bin/env bash
# Installs kanata on Linux and runs it as a systemd user service using this repo's kanata.kbd.
set -euo pipefail

KANATA_VERSION="${KANATA_VERSION:-v1.12.0}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$HOME/.local/bin/kanata"
CFG_DIR="$HOME/.config/kanata"
UNIT_DIR="$HOME/.config/systemd/user"

install_binary() {
  if [[ -x "$BIN" ]] && "$BIN" --version | grep -q "${KANATA_VERSION#v}"; then
    echo "kanata ${KANATA_VERSION} already installed at $BIN"
    return
  fi
  local tmp url
  tmp="$(mktemp -d)"
  url="https://github.com/jtroo/kanata/releases/download/${KANATA_VERSION}"
  echo "Downloading kanata ${KANATA_VERSION}..."
  curl -fsSL -o "$tmp/linux-binaries-x64.zip" "$url/linux-binaries-x64.zip"
  curl -fsSL -o "$tmp/sha256sums" "$url/sha256sums"
  (cd "$tmp" && grep ' linux-binaries-x64.zip$' sha256sums | sha256sum -c -)
  unzip -o -q "$tmp/linux-binaries-x64.zip" -d "$tmp"
  mkdir -p "$(dirname "$BIN")"
  install -m 755 "$tmp/kanata_linux_x64" "$BIN"
  rm -rf "$tmp"
}

setup_permissions() {
  if id -nG "$USER" | grep -qw input && id -nG "$USER" | grep -qw uinput \
     && [[ -f /etc/udev/rules.d/99-input.rules ]]; then
    echo "Input permissions already configured"
    return
  fi
  echo "Configuring uinput/input permissions (needs sudo)..."
  sudo groupadd -f uinput
  sudo usermod -aG input,uinput "$USER"
  echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' \
    | sudo tee /etc/udev/rules.d/99-input.rules >/dev/null
  echo uinput | sudo tee /etc/modules-load.d/uinput.conf >/dev/null
  sudo modprobe uinput
  sudo udevadm control --reload-rules
  sudo udevadm trigger
  NEEDS_RELOGIN=1
}

link_config() {
  mkdir -p "$CFG_DIR" "$UNIT_DIR"
  ln -sfn "$REPO_DIR/kanata.kbd" "$CFG_DIR/kanata.kbd"
  ln -sfn "$REPO_DIR/linux/kanata.service" "$UNIT_DIR/kanata.service"
  "$BIN" --check --cfg "$CFG_DIR/kanata.kbd" >/dev/null
}

start_service() {
  systemctl --user daemon-reload
  systemctl --user enable kanata.service
  if [[ "${NEEDS_RELOGIN:-0}" == 1 ]]; then
    echo "Log out and back in (or reboot) so the new group membership applies; kanata will then start automatically."
  else
    systemctl --user restart kanata.service
    systemctl --user --no-pager status kanata.service | head -n 5
  fi
}

NEEDS_RELOGIN=0
install_binary
link_config
setup_permissions
start_service
