# Bootstrap

## Prerequisites

- Sway / Wayland
- Nushell
- `swaymsg`
- Fuzzel
- Foot
- GLib/GIO (`gio`)
- `swaylock`

Optional: Goose for agent recipes and a Nerd Font for widget icons.

## System requirements

AutoSway is intentionally lightweight:

- Linux running Sway
- 64-bit userspace recommended
- 2 GB RAM is sufficient for the automation layer itself
- no additional GPU requirement beyond the existing Sway/Wayland setup
- writable `$HOME`
- `~/.local/bin` in `PATH`

## Install

```bash
nu scripts/install.nu
```

Verify:
```bash
autosway state workspaces
autosway state outputs
autosway state tree
```

Enable the category launcher:
```ini
bindsym $mod+d exec autosway-launcher
```

Enable Swaybar widgets:
```ini
bar {
    status_command autosway-status
}
```

First workflow:
```bash
autosway workspace 1
autosway launch foot
autosway state tree
```
