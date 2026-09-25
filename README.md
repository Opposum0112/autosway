# AutoSway

AutoSway is a small, agent-driven control layer for Sway.

You tell Goose (or another agent) what you want. AutoSway gives the agent a small interface for reading Sway state, changing windows/workspaces, and managing Swaybar widgets. Sway remains the desktop and `swaymsg` remains the control plane.

## Quickstart

### Prerequisites

- Linux with Sway + Wayland
- Nushell
- `swaymsg`
- Swaybar
- A terminal such as Foot
- Goose is optional

### Install

From this repository:

```bash
nu install.nu
```

Add this to your Sway config:

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

### Agent-driven examples

Ask your agent:

```text
Add a clock to my bar.
Remove the battery widget.
Make the clock green.
Show CPU and memory.
Switch to workspace 3.
Move the focused window to workspace research.
```

The agent uses a deliberately small interface:

```text
autosway state ...
autosway workspace ...
autosway window ...
autosway widget ...
autosway bar
```

## Workflow

```text
User
  ↓
Goose / Agent
  ↓ intent
AutoSway
  ├── Sway operations → swaymsg → Sway
  └── Widget operations → config → Swaybar
  ↓
Agent verifies the result
```

For example:

```text
"Add a green clock"

Goose
  ↓
widget add clock
  ↓
widget set clock color #00ff88
  ↓
Swaybar reads the updated configuration
  ↓
clock appears in green
```

AutoSway is intentionally not another desktop shell. It is the thin agent-facing layer over Sway.

## Repository structure

```text
autosway/
├── autosway.nu          # agent-facing control API
├── install.nu           # installer
├── config/
│   └── widgets.nuon     # widget state
├── widgets/
│   ├── clock.nu
│   ├── cpu.nu
│   ├── memory.nu
│   └── battery.nu
└── docs/
    └── architecture.svg
```

## Current capabilities

**Sway**
- inspect tree, workspaces, outputs, and inputs
- switch workspace
- focus and move windows
- fullscreen and floating
- scratchpad
- launch applications
- lock the session

**Widgets**
- list, add, and remove widgets
- change widget colour
- change clock format
- run the Swaybar status stream

New widgets are simply added under `widgets/` and can then be controlled through the same interface.

## Current status

**Early prototype / agent-control foundation.**

Implemented:
- thin Nushell API
- Sway IPC control and state queries
- Swaybar status stream
- runtime widget configuration
- clock, CPU, memory, and battery widgets
- simple installer
- agent-oriented architecture

Not yet implemented:
- native Goose/MCP integration
- automatic widget discovery
- persistent agent preferences
- broader desktop capabilities such as audio and notifications
- automated tests against a live Sway session

The project is intentionally small. Extensions should come from real agent use cases rather than from adding another framework.

## Principle

> **Goose is the brain. AutoSway is the control surface. Sway is the desktop.**
