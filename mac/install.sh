#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRIVER_VERSION="6.2.0"
DRIVER_SHA256="9e8c46239f0748161241e42444857901224e5c82f5b58a1731df4c70bf0736a8"
MANAGER="/Applications/.Karabiner-VirtualHIDDevice-Manager.app"
SYSTEM_CONFIG="/Library/Application Support/kanata"
LABEL="dev.kanata.kanata"
DRIVER_LABEL="org.pqrs.Karabiner-VirtualHIDDevice-Daemon"

fail() {
  echo "Error: $*" >&2
  exit 1
}

[[ "$(uname -s)" == Darwin ]] || fail "This installer is for macOS only."

install_service() {
  local label="$1" destination="/Library/LaunchDaemons/$1.plist"
  if launchctl print "system/$label" >/dev/null 2>&1; then
    launchctl bootout "system/$label"
  fi
  install -o root -g wheel -m 644 "$REPO_DIR/mac/$label.plist" "$destination"
  if [[ "$label" == "$LABEL" ]]; then
    /usr/libexec/PlistBuddy -c "Set :ProgramArguments:0 $BIN" "$destination"
  fi
  plutil -lint "$destination"
  launchctl enable "system/$label"
  launchctl bootstrap system "$destination"
}

# The privileged phase can also be invoked through macOS's administrator dialog.
if [[ "${1:-}" == --system ]]; then
  [[ "$EUID" == 0 && "$#" == 3 ]] || fail "The system phase requires root, a binary path, and a package path."
  BIN="$2"
  PACKAGE="$3"
  if launchctl print system/homebrew.mxcl.kanata >/dev/null 2>&1; then
    fail "Stop the existing Homebrew service first: sudo brew services stop kanata"
  fi
  command -v python3 >/dev/null || fail "Python 3 is required for safe HID keyboard detection."
  GENERATED_CONFIG="$(mktemp)"
  trap 'rm -f "$GENERATED_CONFIG"' EXIT
  python3 "$REPO_DIR/mac/keyboard-config.py" > "$GENERATED_CONFIG"
  "$BIN" --check --cfg "$GENERATED_CONFIG"
  if [[ -d "$MANAGER" ]]; then
    installed_version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$MANAGER/Contents/Info.plist")"
    [[ "$installed_version" == "$DRIVER_VERSION" ]] \
      || fail "Existing VirtualHID driver is $installed_version; Kanata 1.12 needs $DRIVER_VERSION. Refusing to replace it."
  else
    printf '%s  %s\n' "$DRIVER_SHA256" "$PACKAGE" | shasum -a 256 -c -
    /usr/sbin/installer -pkg "$PACKAGE" -target /
  fi
  install -d -o root -g wheel -m 755 "$SYSTEM_CONFIG"
  install -o root -g wheel -m 644 "$GENERATED_CONFIG" "$SYSTEM_CONFIG/kanata.kbd"

  # Karabiner-Elements already manages this daemon if installed.
  if launchctl print system/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon >/dev/null 2>&1; then
    echo "Using the VirtualHID daemon managed by Karabiner-Elements."
  else
    install_service "$DRIVER_LABEL"
  fi
  install_service "$LABEL"
  sleep 3
  launchctl print "system/$LABEL"
  echo "Startup services installed, but keyboard remapping requires macOS approvals."
  echo "Activate the driver, then approve it in System Settings:"
  printf 'sudo "%s/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" forceActivate\n' "$MANAGER"
  echo "Grant Kanata Input Monitoring and Accessibility, then restart it and verify the logs."
  exit 0
fi

[[ "$#" == 0 ]] || fail "Usage: bash mac/install.sh"
[[ "$EUID" != 0 ]] || fail "Run as your normal user; sudo is requested for system installation."
command -v brew >/dev/null || fail "Install Homebrew first: https://brew.sh"
if ! brew list --versions kanata >/dev/null 2>&1; then
  brew install kanata
fi
BIN="$(brew --prefix kanata)/bin/kanata"
case "$("$BIN" --version)" in
  "kanata 1.12."*) ;;
  *) fail "This installer pairs Kanata 1.12.x with VirtualHID $DRIVER_VERSION. Check the upstream macOS guide before using another version." ;;
esac
"$BIN" --check --cfg "$REPO_DIR/mac/kanata.kbd"

CFG_DIR="$HOME/.config/kanata"
mkdir -p "$CFG_DIR"
if [[ -e "$CFG_DIR/kanata.kbd" && ! -L "$CFG_DIR/kanata.kbd" ]]; then
  fail "$CFG_DIR/kanata.kbd is an existing regular file; move it aside before installing."
fi
ln -sfn "$SYSTEM_CONFIG/kanata.kbd" "$CFG_DIR/kanata.kbd"

CACHE_DIR="$HOME/Library/Caches/kanata"
PACKAGE="$CACHE_DIR/Karabiner-DriverKit-VirtualHIDDevice-$DRIVER_VERSION.pkg"
if [[ ! -d "$MANAGER" ]]; then
  mkdir -p "$CACHE_DIR"
  curl -fL --retry 3 -o "$PACKAGE" \
    "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v$DRIVER_VERSION/Karabiner-DriverKit-VirtualHIDDevice-$DRIVER_VERSION.pkg"
  printf '%s  %s\n' "$DRIVER_SHA256" "$PACKAGE" | shasum -a 256 -c -
fi

echo "Installing the driver and boot-time services (administrator access required)..."
sudo /bin/bash "$REPO_DIR/mac/install.sh" --system "$BIN" "$PACKAGE"
