# AwesomeWM Pacman Updater Widget

A self-contained AwesomeWM widget that checks for Arch Linux package updates,
displays a popup with live `pacman -Syu` output, and exposes its state
system-wide via `awesome-client`.

---

## Installation

1. Copy the `helpers/updater/` directory into your AwesomeWM config:

   ```
   ~/.config/awesome/helpers/updater/
   ```

2. Make the Python wrapper executable:

   ```bash
   chmod +x ~/.config/awesome/helpers/updater/pacman_pty_wrapper.py
   ```

3. Require the widget from your `rc.lua`:

   ```lua
   local updater = require("helpers.updater")
   ```

   The widget starts its periodic update check immediately on load.
   `updater.toggle()` can be bound to a key or a widget click.

4. Integrate the widget to your system bar (see next section)

---

## System-wide control via `awesome-client`

### Functions

| Command | Effect |
|---|---|
| `awesome-client 'show_update_popup()'` | Open the updater popup |
| `awesome-client 'close_update_popup()'` | Close the updater popup |

### Global variables

These are kept in sync with the widget's internal state and can be read at any time:

| Command | Returns |
|---|---|
| `awesome-client 'return update_count'` | Number of pending updates |
| `awesome-client 'return update_percent'` | Current download progress (0–100) |
| `awesome-client 'return update_running'` | `true` while an update is in progress |

These are useful for driving external status bars or scripted checks.

---

## Configuration

All tuneable constants live in `config.lua`. You can override them by setting
the corresponding globals in `rc.lua` **before** requiring the updater:

```lua
-- rc.lua (set any of these before require("helpers.updater"))
updater_timeout       = 600    -- update check interval in seconds (default: 600)

updater_forced_width  = 600    -- popup width
updater_maximum_width = 600
updater_minimum_width = 600
updater_forced_height = 180    -- popup height
updater_popup_x       = 5550   -- popup position (pixels from left, please set this first in case your screen width is less than 5550)
updater_popup_y       = 60     -- popup position (pixels from top)

updater_polkit_x      = 5700   -- lxpolkit auth dialog position
updater_polkit_y      = 170
```

Any variable left unset falls back to the default in `config.lua`.

---

## Runtime dependencies

```bash
sudo pacman -S polkit pacman-contrib psmisc lxpolkit
```
