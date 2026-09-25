# AutoSway

AutoSway is a small, agent-driven control layer for Sway.

You tell Goose (or another agent) what you want. AutoSway gives the agent a small interface for reading Sway state, changing windows/workspaces, and creating/configuring Swaybar widgets. Sway remains the desktop and `swaymsg` remains the control plane.

## Quickstart

### Prerequisites

- Linux with Sway + Wayland
- Nushell 0.103+ (background jobs are used for bar click handling)
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

## Agent-driven widgets

Widgets are intentionally agent-configurable. An agent can add a widget, enable progress rendering, change its appearance, and attach interactions without changing AutoSway itself.

Examples:

```text
Add a network widget with a progress indicator.
Make CPU show progress.
Make clicking CPU open btop.
Make the network widget open btop when clicked.
Make the memory widget green.
Remove the battery widget.
```

The corresponding API is small:

```text
autosway widget add network
autosway widget set network progress true
autosway widget set network width 8
autosway widget set network action click launch foot -e btop
autosway widget set cpu action click launch foot -e btop
autosway widget set memory color "#81c995"
```

### Progress widgets

A widget can return a numeric `value` from 0-100. If its configuration contains `progress: true`, AutoSway adds a compact bar:

```text
CPU 72% ██████░░
RAM 64% █████░░░
BAT 81% ███████░
```

This keeps progress rendering generic. Individual widgets only report state.

### Interactive widgets

AutoSway enables the Swaybar/i3bar click-event protocol and maps buttons to a small event vocabulary:

```text
button 1 → click
button 2 → middle_click
button 3 → right_click
button 4 → scroll_up
button 5 → scroll_down
```

Actions are declarative and limited to built-in operation types:

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

For example:

```text
autosway widget set volume action click volume_mute
autosway widget set volume action scroll_up volume_up
autosway widget set volume action scroll_down volume_down
```

The agent does not need to generate arbitrary shell commands for widget interaction.

## Agent-driven examples

Ask your agent:

```text
Add a clock to my bar.
Add a network widget and show RX/TX progress.
Make CPU clickable and open btop.
Make volume respond to scroll.
Remove the battery widget.
Make the clock green.
Show CPU and memory.
Switch to workspace 3.
Move the focused window to workspace research.
```

The agent uses:

```text
autosway state ...
autosway workspace ...
autosway window ...
autosway widget ...
autosway bar
autosway launch ...
autosway lock
```

For example:

```text
"Add a green interactive CPU widget"

Goose
  ↓
widget add cpu
  ↓
widget set cpu progress true
  ↓
widget set cpu action click launch foot -e btop
  ↓
Swaybar reads state + click events
  ↓
CPU progress is displayed and clicking it opens btop
```

## Workflow

```text
User
  ↓
Goose / Agent
  ↓ intent
AutoSway
  ├── Sway operations → swaymsg → Sway
  └── Widget operations → config + widget scripts → Swaybar
                              ↑             ↓
                         agent config   click events
                              └──── AutoSway actions
  ↓
Agent verifies the result
```

AutoSway is intentionally not another desktop shell or automation framework. It is the thin agent-facing layer over Sway.

## Repository structure

```text
autosway/
├── autosway.nu
├── install.nu
├── config/
│   └── widgets.nuon
├── widgets/
│   ├── clock.nu
│   ├── cpu.nu
│   ├── memory.nu
│   ├── battery.nu
│   └── network.nu
└── docs/
    ├── architecture.svg
    ├── BOOTSTRAP.md
    ├── GOOSE.md
    └── WORKFLOW.md
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
- list, add, remove, and configure widgets
- agent-created progress indicators
- agent-created click/right-click/scroll actions
- declarative built-in widget actions
- runtime widget configuration
- clock, CPU, memory, battery, and network widgets
- Swaybar click-event dispatch

## Current status

**Early prototype / agent-control foundation.**

Implemented:
- thin Nushell API
- Sway IPC control and state queries
- Swaybar status stream
- runtime widget configuration
- generic progress rendering
- generic widget event dispatch
- declarative widget actions
- clock, CPU, memory, battery, and network widgets
- simple installer
- agent-oriented architecture

Still to validate:
- live Sway/Swaybar integration on the target desktop
- automated tests against a live Sway session
- native Goose/MCP integration
- automatic widget discovery
- persistent agent preferences

## Principle

> **Goose is the brain. AutoSway is the control surface. Sway is the desktop.**
