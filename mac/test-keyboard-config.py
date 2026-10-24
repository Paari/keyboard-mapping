import importlib.util
import unittest
from pathlib import Path


spec = importlib.util.spec_from_file_location(
    "keyboard_config", Path(__file__).with_name("keyboard-config.py")
)
config = importlib.util.module_from_spec(spec)
spec.loader.exec_module(config)


def device(name, primary=6, pairs=()):
    return {
        "Product": name,
        "PrimaryUsagePage": 1,
        "PrimaryUsage": primary,
        "DeviceUsagePairs": [
            {"DeviceUsagePage": 1, "DeviceUsage": usage} for usage in pairs
        ],
    }


class KeyboardConfigTests(unittest.TestCase):
    def test_multiple_keyboards_and_duplicates(self):
        devices = [device("Keyboard B"), device("Keyboard A"), device("Keyboard A")]
        self.assertEqual(config.keyboard_names(devices), ["Keyboard A", "Keyboard B"])

    def test_mouse_with_keyboard_controls_is_not_selected(self):
        self.assertEqual(config.keyboard_names([
            device("Keyboard"), device("Pointer", primary=2, pairs=(2, 6))
        ]), ["Keyboard"])

    def test_shared_or_combined_pointer_interfaces_are_not_selected(self):
        self.assertEqual(config.keyboard_names([
            device("Shared"), device("Shared", primary=2),
            device("Combined", pairs=(6, 2)),
        ]), [])

    def test_virtual_or_unnamed_devices_are_not_selected(self):
        self.assertEqual(config.keyboard_names([
            device("Karabiner Virtual"), device("Sidecar"), device(""), device(None)
        ]), [])

    def test_missing_usage_does_not_guess(self):
        self.assertEqual(config.keyboard_names([{"Product": "Unknown"}]), [])

    def test_no_keyboard_or_invalid_template_fails(self):
        with self.assertRaises(ValueError):
            config.render(config.PLACEHOLDER, [])
        with self.assertRaises(ValueError):
            config.render("no placeholder", ["Keyboard"])

    def test_render_only_replaces_placeholder(self):
        template = "(defcfg (names (" + config.PLACEHOLDER + ")))"
        self.assertEqual(
            config.render(template, ["Keyboard A", "Keyboard B"]),
            '(defcfg (names ("Keyboard A" "Keyboard B")))',
        )

    def test_unsafe_device_names_fail(self):
        for name in ('bad"name', "bad\\name", "bad\nname"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                config.render(config.PLACEHOLDER, [name])


if __name__ == "__main__":
    unittest.main()
