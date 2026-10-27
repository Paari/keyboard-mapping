# keybinding

[Kanata](https://github.com/jtroo/kanata) keyboard remapping config for Linux and macOS.

- Linux config: [kanata.kbd](./kanata.kbd)
- macOS config: [mac/kanata.kbd](./mac/kanata.kbd)
- Mappings: [MAPPINGS.md](./MAPPINGS.md)

## Linux

```bash
./linux/install.sh
```

Log out and back in after the first run. Apply config edits with `systemctl --user restart kanata`.

## macOS

From this repository, run as your normal user (requires [Homebrew](https://brew.sh), Python 3, and asks for sudo):

```bash
bash mac/install.sh
```

The installer installs Kanata if missing, generates and validates a local Mac config, links it at `~/.config/kanata/kanata.kbd`, and installs two system LaunchDaemons so the VirtualHID driver daemon and Kanata start at boot without a Terminal window. It supports Intel and Apple Silicon Macs. It uses **Kanata 1.12.x + VirtualHID 6.2.0**, verifies the driver's download checksum, and refuses to replace a different installed driver. Do not upgrade either independently; see the matching [upstream setup guide](https://github.com/jtroo/kanata/blob/v1.12.0/docs/setup-macos.md).

### Keyboard selection and privacy

[keyboard-config.py](./mac/keyboard-config.py) reads macOS HID usage information locally and selects devices whose primary usage is **keyboard**, not mouse/pointer. Secondary mouse controls on a primary keyboard (for example, firmware mouse keys) do not disqualify it. It rejects names shared with separate primary mouse/pointer interfaces and known Karabiner/Sidecar virtual keyboards. No mouse-name exclusion is needed, and no device names, IDs, or serial numbers are stored in the repository. Selected keyboard names exist only in the generated local config at `/Library/Application Support/kanata/kanata.kbd`; do not commit or share that file or device-list output.

Connect any additional keyboards, then rerun `bash mac/install.sh` to detect them and restart the services. A restart alone does not refresh the generated keyboard list. Already-selected keyboard models remain configured across reboots. If no safe keyboard is connected, generation fails without replacing the existing system config.

The checked-in [mac/kanata.kbd](./mac/kanata.kbd) is a template with a placeholder, not a runnable device configuration. Kanata 1.12 has no built-in reliable keyboard-only HID filter, so this local generation step is necessary. Unusually classified keyboards or combined keyboard/pointer receivers may be skipped deliberately; this avoids seizing their pointer interface.

### One-time macOS approvals

1. Request activation of the driver:

   ```bash
   sudo /Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager forceActivate
   ```

   While this command waits, enable the pqrs.org driver under **System Settings > General > Login Items & Extensions > Driver Extensions** (or approve it under **Privacy & Security**, depending on macOS). Restart if prompted.
2. Add the Kanata binary to both **Privacy & Security > Input Monitoring** and **Accessibility**. In the file picker, press `Command+Shift+G` and enter the path printed by:

   ```bash
   echo "$(brew --prefix kanata)/bin/kanata"
   ```

3. After granting permissions, restart Kanata and check both services:

   ```bash
   sudo launchctl kickstart -k system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
   sudo launchctl kickstart -k system/dev.kanata.kanata
   sudo launchctl print system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
   sudo launchctl print system/dev.kanata.kanata
   tail -n 30 /var/log/kanata.log /var/log/kanata-vhid.log
   ```

   If Karabiner-Elements already manages the driver daemon, use its label `org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon` instead.

Check that each service has `state = running` and a PID, and that Kanata's log shows it entering the processing loop without permission or connection errors. Then physically test CapsLock tap = Esc, CapsLock+H/J/K/L = arrows, and CapsLock+Space = Return. Ctrl, Option, and Command should retain their native behavior. Reboot and repeat these checks to confirm startup.

### Applying config edits

The boot service reads a root-owned generated config at `/Library/Application Support/kanata/kanata.kbd`; the user symlink points there too. Edit the template, connect the keyboards you want to use, and regenerate/reinstall from the repository:

```bash
bash mac/install.sh
```

### Stopping and removing startup

Emergency exit: physical Left Ctrl + Space + Esc. The service restarts on failures, but not this clean exit; use `sudo launchctl kickstart -k system/dev.kanata.kanata` to resume. To disable startup and stop it persistently:

```bash
sudo launchctl disable system/dev.kanata.kanata
sudo launchctl bootout system/dev.kanata.kanata
```

Run the installer again to re-enable it. To remove these startup services entirely:

```bash
sudo rm /Library/LaunchDaemons/dev.kanata.kanata.plist
sudo launchctl bootout system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon
sudo rm /Library/LaunchDaemons/org.pqrs.Karabiner-VirtualHIDDevice-Daemon.plist
```

Only remove the standalone driver daemon if no other application uses it. Do not also run `sudo brew services start kanata`: this setup uses its own LaunchDaemon with an explicit config path to avoid duplicate remappers and root-home config lookup problems.