# AutoSway

AutoSway is a minimal, scriptable desktop-automation layer for Sway.

It combines Sway, swaymsg/Sway IPC, Nushell, Fuzzel, and optional Goose recipe orchestration.

## Philosophy

```text
Sensible defaults + orthogonal components + one job per component
+ state before action + verify after mutation + minimal configuration
```

## Architecture

```text
Goose recipe
    |
    v
AutoSway capability CLI
    |
  Nushell
    |
  swaymsg
    |
 Sway IPC
    |
    v
  Sway

Sway IPC events ---> Nushell event router
```

See ARCHITECTURE.md for the full design.

## Repository layout

```text
autosway/
|-- bin/
|   |-- autosway.nu
|   `-- autosway-events.nu
|-- config/
|   `-- event-policy.nuon
|-- docs/
|   |-- BOOTSTRAP.md
|   |-- GOOSE.md
|   `-- RECIPES.md
|-- recipes/
|   |-- external-monitor.yaml
|   `-- security-research.yaml
|-- scripts/
|   `-- install.nu
|-- ARCHITECTURE.md
`-- README.md
```

## Quick start

Run from a Sway session:

```bash
nu scripts/install.nu
autosway state workspaces
autosway state outputs
autosway state tree
```

Then:

```bash
autosway workspace 1
autosway launch foot
```

Install Goose separately if you want agent-driven recipes:

```bash
goose run --recipe recipes/security-research.yaml --interactive
```

## Why Sway IPC matters

Sway exposes a machine-readable IPC surface that can be queried and controlled with swaymsg. That lets ordinary shell tooling become a desktop automation layer.

```text
Sway state -> swaymsg -> Nushell structured data -> decision -> swaymsg -> Sway
```

This avoids requiring Quickshell, QML, Eww, or a monolithic desktop shell for automation.

## Agent boundary

AutoSway gives agents an explicit capability vocabulary instead of encouraging arbitrary generated compositor commands.

Current capabilities include state queries, workspace selection, window focus/movement, fullscreen/floating toggles, scratchpad operations, explicit process launch, and locking.

The intended future interface is an MCP server exposing the same capabilities as typed tools.

## Status

Bootstrap / experimental.

The repository establishes the architecture, capability CLI, event reader, installation bootstrap, and Goose recipe examples. The next development step is a typed capability layer and an AutoSway MCP server.

## Documentation

- ARCHITECTURE.md
- docs/BOOTSTRAP.md
- docs/GOOSE.md
- docs/RECIPES.md