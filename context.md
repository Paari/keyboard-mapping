# Agent Handoff Notes: Cross-Platform Keyboard Remapping (Kanata)

## 1. Goal & Context

* **Objective:** Replace Windows PowerToys Keyboard Manager with a unified, cross-platform solution sharing the exact same keymap configuration across **macOS** and **Linux**.
* **Core Desired Behavior:**
* Use **CapsLock** as the primary modifier / layer toggle (tap for `Esc`, hold for navigation layer).
* Hold **CapsLock** + `h / j / k / l` $\rightarrow$ Arrow keys (`Left / Down / Up / Right`).
* Hold **CapsLock** + `b / n` $\rightarrow$ `Backspace / Delete`.
* Keep remaining keys transparent (`_`) when held.



---

## 2. Tool Evaluation & Decision

* **Tools Evaluated:** Kanata vs. Keymapper (`houmain/keymapper`) vs. OS-native pairs (Karabiner + keyd).
* **Selection: [Kanata**](https://github.com/jtroo/kanata)
* **Why Kanata wins:** Substantially larger adoption (8k+ GitHub stars), rapid maintenance in Rust, low-latency low-level interception (`uinput`/`evdev` on Linux, Karabiner DriverKit VirtualHID on macOS), and identical `.kbd` syntax across OSes.
* **Past Friction Addressed:** User previously experienced friction running Kanata as an interactive terminal process. Solution is to decouple from shell sessions and run strictly as headless background services or via a tray app (`kanata-tray`).



---

## 3. Shared Configuration File

**Path:** `~/.config/kanata/kanata.kbd` (synced via dotfiles)

```lisp
(defcfg
  process-unmapped-keys yes
)

(defsrc
  caps
  h    j    k    l
  b    n
)

(defalias
  nav (tap-hold 200 200 esc (layer-toggle nav-layer))
)

(deflayer base
  @nav
  h    j    k    l
  b    n
)

(deflayer nav-layer
  _
  left down up   rght
  bspc del
)

```

---

## 4. Platform-Specific Daemon & Headless Execution

### macOS Setup

* **Package:** Installed via Homebrew (`brew install kanata` or `brew install kanata-tray` for menu bar control).
* **Driver Prerequisite:** Requires Karabiner DriverKit VirtualHID permissions enabled in macOS *Privacy & Security* (Input Monitoring + Accessibility).
* **Daemon (LaunchDaemon/Service):**
* Auto-managed via Homebrew:
```bash
sudo brew services start kanata

```


* Or custom LaunchDaemon at `/Library/LaunchDaemons/com.kanata.daemon.plist` targeting the shared config.



### Linux Setup

* **Binary:** Stored at `~/.local/bin/kanata`.
* **Hardware Permissions (`udev` / `uinput`):**
```bash
sudo usermod -aG input,uinput $USER
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules
sudo udevadm control --reload && sudo udevadm trigger
sudo modprobe uinput

```


* **Systemd User Unit (`~/.config/systemd/user/kanata.service`):**
```ini
[Unit]
Description=Kanata Keyboard Remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
ExecStart=%h/.local/bin/kanata --cfg %h/.config/kanata/kanata.kbd
Restart=on-failure
RestartSec=3

[Install]
WantedBy=default.target

```


* Enable and start: `systemctl --user enable --now kanata.service`



---

## 5. Potential Next Steps for Incoming Agent

1. **Dotfiles Automation:** Scaffold a symlinking or setup script (e.g., GNU Stow, dotbot, or shell installer) that places `kanata.kbd` into `~/.config/kanata/` and links the appropriate daemon configuration on each OS.
2. **Layer Extensions:** Add secondary utility layers (e.g., number row shortcuts, media controls, or home-row mods if desired).
3. **Troubleshooting Support:** If permission errors appear on macOS upgrades or Linux kernel updates, check DriverKit approval in macOS Security settings or `/dev/uinput` group permissions on Linux.