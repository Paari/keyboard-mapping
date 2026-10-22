# Key mappings

Every remap defined in [kanata.kbd](./kanata.kbd). The **Origin** column shows the PowerToys rule each one replaces (see [current-mapping/](./current-mapping/)).

## Layer trigger: `CapsLock`

`CapsLock` is the **layer trigger**. It no longer toggles caps. It does one of two things depending on how you press it:

| Gesture | Result |
| --- | --- |
| **Tap** (press and release within 200 ms, no other key pressed) | `Esc` |
| **Hold** (keep it down and press another key, or hold longer than 200 ms) | Activates the **`nav` layer** for as long as it's held |
| Hold alone, then release | Nothing |

Notes:

- The trigger uses `tap-hold-press`. Pressing any other key while `CapsLock` is down counts as a hold right away, so fast combos like `CapsLock`+`j` never send a stray `Esc`.
- In PowerToys, `CapsLock` was remapped to `Ctrl+Alt+Shift` (a "Hyper" key) and each `Hyper`+key combo was remapped separately. Kanata uses a real layer instead, so the remapped keys never send Ctrl/Alt/Shift by accident.
- Modifiers still work in the layer. For example, `Shift`+`CapsLock`+`l` sends `Shift+→` (extend a selection), and physical Left `Alt` (which sends `Ctrl`, see the swap below)+`CapsLock`+`h` sends `Ctrl+←` (jump one word).
- Keys not listed below type normally while `CapsLock` is held.

## `nav` layer (hold `CapsLock`)

### Navigation

| `CapsLock` + | Sends | Origin (PowerToys) |
| --- | --- | --- |
| `h` | `←` | `Ctrl+Alt+Shift+H` → `←` |
| `j` | `↓` | `Ctrl+Alt+Shift+J` → `↓` |
| `k` | `↑` | `Ctrl+Alt+Shift+K` → `↑` |
| `l` | `→` | `Ctrl+Alt+Shift+L` → `→` |
| `w` | `↑` | `Ctrl+Alt+Shift+W` → `↑` |
| `s` | `↓` | `Ctrl+Alt+Shift+S` → `↓` |

### Tabs

| `CapsLock` + | Sends | Action | Origin (PowerToys) |
| --- | --- | --- | --- |
| `a` | `Ctrl+Shift+Tab` | Previous tab | `Ctrl+Alt+Shift+A` |
| `d` | `Ctrl+Tab` | Next tab | `Ctrl+Alt+Shift+D` |
| `[` | `Ctrl+Shift+Tab` | Previous tab | `Ctrl+Alt+Shift+[` |
| `]` | `Ctrl+Tab` | Next tab | `Ctrl+Alt+Shift+]` |

### Editing

| `CapsLock` + | Sends | Action | Origin (PowerToys) |
| --- | --- | --- | --- |
| `i` | `Backspace` | Delete previous character | `Ctrl+Alt+Shift+I` |
| `o` | `Ctrl+Backspace` | Delete previous word | `Ctrl+Alt+Shift+O` |
| `n` | `Esc` | Escape | `Ctrl+Alt+Shift+N` |
| `Space` | `Enter` | Enter / confirm | `Ctrl+Alt+Shift+Space` |

### Window

| `CapsLock` + | Sends | Action | Origin (PowerToys) |
| --- | --- | --- | --- |
| `q` | `Alt+F4` | Close window | `Ctrl+Alt+Shift+Q` |

### Layout

```
 CapsLock held:
 ┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┐
 │ Tab │  q  │  w  │  e  │  r  │  t  │  y  │  u  │  i  │  o  │  p  │  [  │  ]  │
 │     │AltF4│  ↑  │     │     │     │     │     │Bksp │^Bksp│     │PrvTb│NxtTb│
 └──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────┴─────┘
    │Caps │  a  │  s  │  d  │  f  │  g  │  h  │  j  │  k  │  l  │
    │ ███ │PrvTb│  ↓  │NxtTb│     │     │  ←  │  ↓  │  ↑  │  →  │
    └──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────┴─────┘
       │  z  │  x  │  c  │  v  │  b  │  n  │  m  │
       │     │     │     │     │     │ Esc │     │
       └─────┴─────┴─────┴─────┴─────┴─────┴─────┘
                   ┌─────────────────────┐
                   │        Space        │
                   │        Enter        │
                   └─────────────────────┘
```

`███` = layer trigger (held), `^Bksp` = `Ctrl+Backspace`, `PrvTb`/`NxtTb` = previous/next tab.

## Always-on remaps (base layer)

These apply all the time, not only while `CapsLock` is held.

| Physical key | Sends | Origin (PowerToys) |
| --- | --- | --- |
| `CapsLock` | Tap: `Esc` / Hold: `nav` layer | `CapsLock` → `Ctrl+Alt+Shift` |
| Left `Alt` | Left `Ctrl` | `Alt (Left)` → `Ctrl (Left)` |
| Left `Ctrl` | Left `Alt` | `Ctrl (Left)` → `Alt (Left)` |
| Right `Alt` | Right `Ctrl` | `Alt (Right)` → `Ctrl` |

Because Left `Alt` and Left `Ctrl` are swapped, the old PowerToys shortcut rules come for free:

| You press (physical) | Result | Origin (PowerToys) |
| --- | --- | --- |
| Left `Alt`+`Tab` | `Ctrl+Tab` (next tab) | `Alt+Tab` → `Ctrl+Tab` |
| Left `Ctrl`+`Tab` | `Alt+Tab` (switch window) | `Ctrl+Tab` → `Alt+Tab` |

## Special

| Combo (physical keys) | Action |
| --- | --- |
| Left `Ctrl` + `Space` + `Esc` | Emergency exit: kills kanata and restores the normal keyboard |

## Not ported

| PowerToys rule | Reason |
| --- | --- |
| `F23` → Browser Search | Copilot-key specific to Windows; add `f23` to `defsrc` if you need it |
