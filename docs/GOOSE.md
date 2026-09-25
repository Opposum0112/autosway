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

A future native MCP server can expose the same operations without changing the underlying AutoSway implementation.
