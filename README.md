# AutoSway

AutoSway is a small, agent-driven control layer for Sway.

You tell an agent what you want to change. AutoSway gives the agent a small, predictable interface for reading Sway state, changing windows/workspaces, and managing Swaybar widgets. Sway remains the desktop; `swaymsg` remains the control plane.

## Quickstart

### Prerequisites

- Linux with Sway + Wayland
- Nushell
- `swaymsg`
- Swaybar
- A terminal such as Foot
- Goose or another agent is optional

### Install

From this repository:

```bash
nu install.nu
```

Then add the status command to your Sway config:

```ini
bar {
    status_command autosway bar
}
```

Reload Sway:

```bash
swaymsg reload
```

Check the API:

```bash
autosway state workspaces
autosway state outputs
autosway widget list
```

### Agent examples

An agent can turn requests such as these into AutoSway operations:

```text
"Add a clock to my bar."
"Remove the battery widget."
"Make the clock green."
"Show CPU and memory."
"Switch to workspace 3."
"Move the focused window to workspace research."
```

The corresponding interface is deliberately small:

```text
autosway state ...
autosway workspace ...
autosway window ...
autosway widget ...
autosway bar
```

## How it works

```text
User
  │
  ▼
Goose / Agent
  │  intent
  ▼
AutoSway
  │
  ├── Sway state/actions ──► swaymsg ──► Sway
  │
  └── Bar widgets ─────────► widget config ──► Swaybar
```

The agent does not need to know Sway's implementation details. It asks AutoSway for a desktop operation; AutoSway translates that operation into the appropriate Sway IPC command or widget configuration.

Sway's IPC can both query desktop state and execute Sway commands. Swaybar's `status_command` consumes the status stream, so widgets are kept as a small AutoSway-managed layer rather than mixed into the compositor itself. citeturn1search1turn1search0

## Typical workflow

```text
1. Agent understands the user's request
2. Agent reads current state when needed
3. Agent selects an AutoSway operation
4. AutoSway changes Sway or widget state
5. Agent verifies the result
```

For example:

```text
"Add a green clock"

Goose
  ↓
autosway widget add clock
  ↓
autosway widget set clock color #00ff88
  ↓
Swaybar reads the updated widget configuration
  ↓
clock appears in green
```

No desktop framework is being replaced. AutoSway is intentionally the thin agent-facing layer over Sway.

## Repository structure

```text
autosway/
├── autosway.nu          # agent-facing control API
├── install.nu           # simple installer
├── config/
│   └── widgets.nuon     # user-managed widget state
├── widgets/
│   ├── clock.nu
│   ├── cpu.nu
│   ├── memory.nu
│   └── battery.nu
└── docs/
    └── architecture.svg
```

## Current capabilities

### Sway

- inspect workspaces, outputs, inputs, and the layout tree
- switch workspace
- focus a window by Sway criteria
- move a window to a workspace or output
- toggle fullscreen
- toggle floating
- show/move scratchpad
- launch an application
- lock the session

### Widgets

- list widgets
- add a widget
- remove a widget
- change widget colour
- change clock format
- run the Swaybar status stream

Widgets are intentionally independent scripts. New widgets can be added without turning AutoSway into a large desktop framework.

## Current status

**Early prototype / agent-control foundation.**

Working design:

- thin Nushell API
- Sway IPC for compositor state and actions
- Swaybar status stream
- declarative widget configuration
- independently extensible widgets
- suitable boundary for Goose or another agent

Not yet implemented:

- native Goose/MCP server
- automatic discovery of arbitrary widget providers
- persistent agent memory/preferences
- broader desktop capabilities such as audio, notifications, and application-specific automation
- automated tests on a live Sway session

The project is intentionally small at this stage. The next extensions should be driven by real agent use cases rather than by adding another abstraction layer.

## Design principle

> **Goose is the brain. AutoSway is the small control surface. Sway is the desktop.**

AutoSway should grow by adding useful capabilities, not by becoming another desktop shell.
