# Bootstrap

## Requirements

AutoSway is designed for an existing Sway desktop.

Required:
- Linux + Sway + Wayland
- Nushell 0.103+
- `swaymsg`
- Swaybar

Optional:
- Goose or another agent
- Foot or another terminal
- `btop` for the example interactive CPU/network actions

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

## Widget model

Widgets are small Nushell scripts that emit JSON. AutoSway adds the generic fields needed by Swaybar, including a unique `name`.

A widget may also emit:

```json
{"full_text":"CPU 72%","value":72}
```

and configuration can enable:

```text
progress: true
width: 8
```

AutoSway renders the progress value without requiring the widget to know anything about Swaybar formatting.

## Interactive widgets

AutoSway enables Swaybar click events. The bar sends click notifications to AutoSway, which maps mouse buttons to widget actions.

Configure one with:

```bash
autosway widget set cpu action click launch foot -e btop
autosway widget set volume action scroll_up volume_up
autosway widget set volume action scroll_down volume_down
```

Supported action types are deliberately small:

```text
launch
workspace
lock
volume_up
volume_down
volume_mute
fullscreen
floating
```

This gives an agent a safe semantic surface instead of requiring arbitrary shell commands for every click.

## First agent workflow

Ask the agent:

```text
Create a network widget with RX/TX progress and make it open btop when clicked.
```

The intended sequence is:

```text
inspect → widget add → configure progress → configure action → verify
```

The widget configuration is stored at:

```text
~/.config/autosway/widgets.nuon
```

## Current status

This is an early prototype. The widget control model is implemented, but live-Sway/Swaybar integration and automated testing are still required before calling it production-ready.
