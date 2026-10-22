# keybinding

Cross-platform keyboard remapping with [Kanata](https://github.com/jtroo/kanata), ported from my Windows PowerToys Keyboard Manager setup (screenshots in [current-mapping/](./current-mapping/)).

## Mapping ([kanata.kbd](./kanata.kbd))

| Key | Action |
| --- | --- |
| Tap `CapsLock` | `Esc` |
| Hold `CapsLock` | Activates the `nav` layer (replaces the old Ctrl+Alt+Shift "Hyper" combos) |
| Left `Alt` ↔ Left `Ctrl` | Swapped |
| Right `Alt` | Right `Ctrl` |

While holding `CapsLock`:

| Key | Action | Key | Action |
| --- | --- | --- | --- |
| `h` `j` `k` `l` | ← ↓ ↑ → | `w` / `s` | ↑ / ↓ |
| `a` / `[` | Previous tab (`Ctrl+Shift+Tab`) | `d` / `]` | Next tab (`Ctrl+Tab`) |
| `i` | `Backspace` | `o` | Delete word (`Ctrl+Backspace`) |
| `n` | `Esc` | `q` | Close window (`Alt+F4`) |
| `Space` | `Enter` | | |

Emergency exit while kanata is running: physical `Left Ctrl` + `Space` + `Esc`.

The PowerToys `F23 → Browser Search` rule (Copilot key) is not ported.

## Linux setup

```bash
./linux/install.sh
```

This installs kanata to `~/.local/bin`, symlinks `kanata.kbd` into `~/.config/kanata/`, grants `input`/`uinput` access (sudo, one time), and enables the `kanata` systemd user service. Log out and back in after the first run.

Edits to `kanata.kbd` apply after `systemctl --user restart kanata`. Logs: `journalctl --user -u kanata -f`.

## macOS setup

1. `brew install kanata` and install the [Karabiner DriverKit VirtualHID](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice) driver.
2. Grant Input Monitoring + Accessibility to kanata in *Privacy & Security*.
3. `mkdir -p ~/.config/kanata && ln -sfn "$PWD/kanata.kbd" ~/.config/kanata/kanata.kbd`
4. `sudo brew services start kanata` (or run `sudo kanata --cfg ~/.config/kanata/kanata.kbd`).

On macOS you may not want the Ctrl/Alt swap — change `lalt lctl` back to `lctl lalt` in `deflayer base`.
