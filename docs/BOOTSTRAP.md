# Bootstrap

## Requirements

AutoSway is designed for an existing Sway desktop.

Required:
- Linux + Sway + Wayland
- Nushell
- `swaymsg`
- Swaybar

Optional:
- Goose or another agent
- Foot or another terminal

No dedicated GPU, server, database, or background daemon is required by AutoSway.

## Install

From the repository:

```bash
nu install.nu
```

Add:

```ini
bar {
    status_command autosway bar
}
```

Then:

```bash
swaymsg reload
autosway state workspaces
autosway widget list
```

## First agent workflow

Ask the agent:

```text
Add a clock and make it green.
```

The intended sequence is:

```text
inspect → widget add → widget set → verify
```

The widget configuration is stored at:

```text
~/.config/autosway/widgets.nuon
```

## Current status

This is an early prototype. The control API and widget model are implemented, but live-Sway integration and automated testing are still required before calling it production-ready.
