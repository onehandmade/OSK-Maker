# OSK Maker

Design your own on-screen keyboard (OSK), then export it as a standalone AutoHotkey script or a compiled `.exe`. Built with accessibility in mind, for example one-handed use, mouse-only input, or dwell (hover) clicking.

The keyboards it generates never take focus from the program you are typing into, so keys go straight to your game, art program, or document.

## Requirements

- Windows
- [AutoHotkey v2](https://www.autohotkey.com/) (v2.0 or newer)
- Optional: the Ahk2Exe compiler (install AutoHotkey with the compiler option) if you want `.exe` output

## Quick start

1. Double-click `OSK_Maker.ahk`.
2. Pick a preset (Math keyboard or Krita / drawing) and click **Load Preset**, or start from Blank and add your own keys.
3. Click **Preview** to try the keyboard right away.
4. Click **Generate .ahk...** or **Generate .exe...** to save the finished keyboard.

## The editor

### Key list

Each key has:

| Field | Meaning |
|-------|---------|
| Row | Keys with the same row number share a row. Rows are shown top to bottom in ascending order. |
| Label | The text shown on the button. |
| Type | `Text`, `Send`, or `Hold` (see below). |
| Action | What the key does. For Text keys, leave it empty to type the label itself. |

Buttons: **Add Key**, **Update Selected** (overwrites the selected key with the fields below the list), **Delete**, **Up** and **Down** (change order within the list).

Note: edits in the Row/Label/Type/Action fields are only applied when you click **Add Key** or **Update Selected**.

### Key types

- **Text** types the action text exactly as written. Good for symbols and words, such as `π`, `≤`, or `hello`.
- **Send** uses AutoHotkey Send syntax: `z`, `^c`, `{BackSpace}`, `{Esc}`, `^{NumpadAdd}`. The sticky Ctrl, Shift and Alt buttons (if enabled) are added in front of Send keys.
- **Hold** is a press-and-hold toggle, for example `Space` or `Ctrl+Space`. Click once to hold, click again to release. Held keys are always released when the keyboard closes. Use `+` to combine keys, such as `Shift+Space`.

### Keyboard settings

| Setting | Meaning |
|---------|---------|
| Title | Window title of the generated keyboard. |
| Background | 6-digit hex color, for example `1E1E1E`. |
| Font size | Button text size (6 to 48). |
| Opacity | Window transparency (30 to 255). |
| Width % | Keyboard width as a percentage of the screen (10 to 100). |
| Height (px) | Keyboard height (80 to 1200). |
| Hover delay (ms) | How long the pointer must rest on a key in hover mode before it clicks (100 to 5000). |
| Sticky Ctrl/Shift/Alt | Adds toggle buttons whose state applies to the next Send key. |
| Hover button | Adds a **Hover: On/Off** button for dwell clicking. |

## Saving and loading layouts

- **Save Layout...** writes a `.osk` file (plain tab-separated text, UTF-8). Settings and all keys are saved.
- **Open Layout...** loads a `.osk` file back into the editor.
- Presets can be loaded, edited, and then saved as your own layout.

Layout file format, if you want to edit by hand:

```
OSKLAYOUT<TAB>1
SET<TAB>name<TAB>value
KEY<TAB>row<TAB>type<TAB>label<TAB>action
```

## What the generated keyboard does

- Always on top and resizable; does not steal focus.
- **Snap Bottom** and **Snap Top** buttons move it to the screen edge.
- **Hover** mode clicks a key after the pointer rests on it for the hover delay.
- **Ctrl / Shift / Alt** sticky buttons apply to the next Send key, then reset.
- **Release Held** appears when the layout has Hold keys, and releases everything currently held.
- Maximizing the window restores it to the configured size and position instead.

## Command line

```
OSK_Maker.ahk /build layout.osk out.ahk
OSK_Maker.ahk /preset math out.ahk
OSK_Maker.ahk /preset krita out.ahk
```

- `/build` turns a saved `.osk` layout into a keyboard script without opening the editor.
- `/preset` generates a keyboard script from the built-in `math` or `krita` preset.

## Troubleshooting

- **Preview does nothing:** AutoHotkey v2 was not found. Install it, or run OSK Maker through the v2 interpreter.
- **Generate .exe fails:** Ahk2Exe was not found. Use **Generate .ahk...** and compile it yourself.
- **Background color error:** use exactly six hex digits, such as `2B2B2B`.
- **Cannot save or open a file:** the message now shows the underlying Windows error. Try saving to a folder you have write access to, such as Documents.
- **A key types the wrong thing:** check its Type. Text sends literal characters, while Send interprets `^`, `+`, `!` and `{braces}` as AutoHotkey syntax.
