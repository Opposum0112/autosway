# Goose

Goose is the optional agent layer.

The intended relationship is:

```text
Goose
  ↓
natural-language intent
  ↓
AutoSway API
  ↓
Sway / Swaybar
```

Goose should use the AutoSway vocabulary rather than generating arbitrary `swaymsg` commands.

Useful operations include:

```text
state
workspace
window
widget
bar
launch
lock
```

## Widget creation

Widget management is intentionally agent-friendly.

For an existing widget implementation:

```text
Add a network widget.
Enable progress.
Make clicking it open btop.
```

the agent can use:

```text
autosway widget add network
autosway widget set network progress true
autosway widget set network action click launch foot -e btop
```

The widget implementation only reports state; AutoSway owns progress decoration and event dispatch.

## Action vocabulary

Prefer built-in actions:

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

This keeps the agent's control surface explicit instead of turning every widget into an arbitrary shell-execution hook.

A future native MCP server can expose the same operations without changing the underlying AutoSway implementation.
