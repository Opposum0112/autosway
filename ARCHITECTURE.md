# AutoSway Architecture

AutoSway is intentionally small.

It is not a desktop shell and it does not replace Sway. It gives an agent a predictable interface for controlling a Sway desktop.

## Runtime model

```text
                 Goose / Agent
                      │
                    intent
                      ▼
                 AutoSway API
                ┌─────┴─────┐
                │           │
                ▼           ▼
            Sway ops     Widgets
                │           │
             swaymsg     config
                │           │
                ▼           ▼
              Sway       Swaybar
                │           │
                └─────┬─────┘
                      ▼
                Desktop state
                      │
                      ▼
                 Agent verifies
```

## Small API

The agent-facing vocabulary is deliberately limited:

```text
state
workspace
window
widget
bar
launch
lock
```

### State

Read Sway state:

```text
autosway state tree
autosway state workspaces
autosway state outputs
autosway state inputs
```

### Windows and workspaces

```text
autosway workspace <name>
autosway window focus <criteria>
autosway window move <criteria> workspace <name>
autosway window move <criteria> output <name>
autosway window fullscreen
autosway window floating
autosway window scratchpad show
autosway window scratchpad move
```

### Widgets

```text
autosway widget list
autosway widget add clock
autosway widget remove battery
autosway widget set clock color "#00ff88"
autosway widget set clock format "%H:%M:%S"
```

Widget state lives in `~/.config/autosway/widgets.nuon`. This makes simple desktop changes persistent and agent-editable.

## Extension model

Adding a capability should normally mean adding one small provider rather than adding a new framework.

For example:

```text
widgets/network.nu
        ↓
widget add network
        ↓
agent can use network widget
```

The same idea can later cover audio, notifications, application profiles, or other desktop controls.

## Boundaries

- Goose decides **what** the user wants.
- AutoSway exposes **what can be changed**.
- `swaymsg` performs Sway operations.
- Swaybar renders the widget stream.
- The agent remains responsible for interpreting user intent and verifying the result.

The agent should use AutoSway rather than generating arbitrary compositor commands.

## Why Nushell?

Nushell is implementation glue, not the product abstraction. It gives the small control layer structured data, easy JSON handling, and simple scripting while leaving Sway as the actual desktop system.
