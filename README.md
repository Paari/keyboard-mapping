# keybinding

Cross-platform keyboard remapping with [Kanata](https://github.com/jtroo/kanata), ported from my Windows PowerToys Keyboard Manager setup (screenshots in [current-mapping/](./current-mapping/)).

## Mapping

`CapsLock` is the **layer trigger**: tap it for `Esc`, hold it to activate the `nav` layer (arrows on `h j k l`, tab switching, editing keys). Left `Alt` and Left `Ctrl` are swapped, and Right `Alt` acts as `Ctrl`.

See **[MAPPINGS.md](./MAPPINGS.md)** for the full list, a layout diagram, and the PowerToys rule each one replaces. The config itself is [kanata.kbd](./kanata.kbd).

Emergency exit while kanata is running: physical `Left Ctrl` + `Space` + `Esc`.

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
