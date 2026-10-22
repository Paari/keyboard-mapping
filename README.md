# keybinding

[Kanata](https://github.com/jtroo/kanata) keyboard remapping config for Linux and macOS.

- Config: [kanata.kbd](./kanata.kbd)
- Mappings: [MAPPINGS.md](./MAPPINGS.md)

## Linux

```bash
./linux/install.sh
```

Log out and back in after the first run. Apply config edits with `systemctl --user restart kanata`.

## macOS

1. `brew install kanata` and install the [Karabiner DriverKit VirtualHID](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice) driver.
2. Allow kanata under Input Monitoring and Accessibility.
3. `mkdir -p ~/.config/kanata && ln -sfn "$PWD/kanata.kbd" ~/.config/kanata/kanata.kbd`
4. `sudo brew services start kanata`
