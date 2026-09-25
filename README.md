# AutoSway

AutoSway is a small, scriptable desktop-automation layer for Sway.

It combines **Sway IPC**, **Nushell**, **Fuzzel**, **Swaybar**, and optional **Goose** recipes. The goal is simple: keep Sway itself small, expose useful capabilities as deterministic commands, and compose them into reusable desktop workflows.

## Quickstart

### Prerequisites

- Sway + Wayland
- Nushell 0.90+
- `swaymsg`
- Fuzzel for the launcher
- Foot for the example terminal workflow
- GLib/GIO (`gio`) for launching `.desktop` applications
- `swaylock` for the lock capability
- Goose is optional

### Install

```bash
nu scripts/install.nu
```

### Verify

```bash
autosway state workspaces
autosway state outputs
autosway state tree
autosway workspace 1
autosway launch foot
```

### Enable the launcher and status bar

Add the following to your Sway configuration:

```ini
bindsym $mod+d exec autosway-launcher

bar {
    status_command autosway-status
}
```

See [Bootstrap](docs/BOOTSTRAP.md) for prerequisites, system requirements, installation, and configuration.

## Architecture

![Diagram showing AutoSway presentation, orchestration, capabilities, execution boundary, and Sway layers.](docs/architecture.svg)

The system is split into small layers:

```text
Presentation
  Fuzzel · Swaybar · Foot
           │
           ▼
Orchestration
  Nushell · recipes · events
           │
           ▼
Capabilities
  applications · windows
  workspaces · outputs · system
           │
           ▼
Execution boundary
  capability → swaymsg → Sway IPC
           │
           ▼
      Sway / Wayland
```

## Workflow

AutoSway follows a simple execution loop:

```text
Discover state
     ↓
Select capability or recipe
     ↓
Execute the smallest required action
     ↓
Verify the resulting state
     ↓
Report the result
```

For event-driven automation:

```text
Sway IPC event
      ↓
Event router
      ↓
Policy or recipe
      ↓
Capability
      ↓
swaymsg
      ↓
Verify
```

For agent-driven workflows, Goose remains outside the execution boundary:

```text
Goose → Recipe → AutoSway capabilities → swaymsg → Sway
```

## Components

- **Launcher** — category-first Fuzzel UI backed by XDG `.desktop` metadata.
- **Status** — independent Nushell widgets rendered through Swaybar's i3bar JSON protocol.
- **Capabilities** — explicit commands for state, windows, workspaces, outputs, application launch, and locking.
- **Recipes** — declarative workflows that compose capabilities.
- **Events** — opt-in Sway IPC event stream for deterministic automation.
- **Agent boundary** — Goose can orchestrate recipes without unrestricted generated `swaymsg` commands.

## Repository layout

```text
autosway/
├── bin/
│   ├── autosway.nu
│   ├── autosway-events.nu
│   ├── autosway-launcher.nu
│   └── autosway-status.nu
├── capabilities/
├── launcher/
├── widgets/
├── status/
├── recipes/
├── events/
├── config/
├── docs/
└── scripts/
```

## Design principles

1. **Sensible defaults** — use the native Sway/Wayland ecosystem where practical.
2. **One job per component** — keep presentation, orchestration, and execution separate.
3. **State before action** — inspect desktop state before mutating it.
4. **Verify after mutation** — confirm that the requested state was reached.
5. **Explicit capabilities** — keep automation and agents inside a reviewed capability boundary.
6. **Recipes express intent** — deterministic code performs the actual desktop operations.

## Status

Bootstrap / experimental. The current repository provides the capability CLI, event reader, category launcher, Swaybar widget pipeline, installer, and recipe examples.