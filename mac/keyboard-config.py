#!/usr/bin/env python3
"""Render a local Kanata config using macOS HID keyboard classification."""

import json
import plistlib
import subprocess
import sys
from pathlib import Path


PLACEHOLDER = '"__KANATA_LOCAL_KEYBOARDS__"'


def keyboard_names(devices):
    def usages(device):
        return {
            (pair.get("DeviceUsagePage"), pair.get("DeviceUsage"))
            for pair in device.get("DeviceUsagePairs", [])
        } | {(device.get("PrimaryUsagePage"), device.get("PrimaryUsage"))}

    # A shared name could register both keyboard and pointer interfaces.
    pointer_names = {
        device.get("Product")
        for device in devices
        if usages(device) & {(1, 1), (1, 2)}
    }
    return sorted({
        device["Product"]
        for device in devices
        if isinstance(device.get("Product"), str)
        and device["Product"].strip()
        and (device.get("PrimaryUsagePage"), device.get("PrimaryUsage")) == (1, 6)
        and device["Product"] not in pointer_names
        and not any(
            virtual in device["Product"].lower()
            for virtual in ("karabiner", "sidecar")
        )
    })


def render(template, names):
    if not names:
        raise ValueError("No safe physical keyboards detected; existing config was not changed.")
    if template.count(PLACEHOLDER) != 1:
        raise ValueError("Expected exactly one local keyboard placeholder in the Mac template.")
    if any('"' in name or "\\" in name or any(ord(c) < 32 for c in name) for name in names):
        raise ValueError("Unsupported characters in a keyboard name; refusing unsafe config output.")
    return template.replace(PLACEHOLDER, " ".join(json.dumps(name, ensure_ascii=False) for name in names))


def main():
    devices = plistlib.loads(subprocess.check_output(
        ["/usr/sbin/ioreg", "-a", "-r", "-c", "IOHIDDevice"]
    ))
    template = Path(__file__).with_name("kanata.kbd").read_text()
    try:
        config = render(template, keyboard_names(devices))
    except ValueError as error:
        sys.exit(f"Error: {error}")
    sys.stdout.write(config)


if __name__ == "__main__":
    main()
