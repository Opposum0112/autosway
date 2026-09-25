# Goose integration

AutoSway treats Goose as an optional orchestration layer.

Recommended execution boundary:

~~~text
Goose -> AutoSway CLI -> swaymsg -> Sway IPC
~~~

Avoid:

~~~text
Goose -> arbitrary generated swaymsg
~~~

This gives the agent a stable capability vocabulary.

## Future MCP extension

A future AutoSway MCP server should expose typed tools such as:

- get_tree
- get_workspaces
- get_outputs
- focus
- move_window
- switch_workspace
- launch
- fullscreen
- floating
- scratchpad

The MCP layer should call the same internal capability implementation used by the CLI so CLI and agent execution have one source of truth.

## Recipes as contracts

Keep recipes declarative:

~~~text
intent -> capability calls -> verification
~~~

This keeps model-specific reasoning outside the deterministic execution layer.
