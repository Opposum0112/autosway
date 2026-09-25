# Bootstrap

## Prerequisites

- Sway running as the current Wayland compositor.
- Nushell installed as nu.
- swaymsg available in PATH.
- Goose installed if you want agent-driven recipes.
- Fuzzel and Foot are optional for launcher/terminal workflows.

## Install AutoSway

From the repository root:

~~~nu
nu scripts/install.nu
~~~

Verify:

~~~bash
autosway state workspaces
autosway state outputs
autosway state tree
~~~

## First deterministic workflow

~~~bash
autosway workspace 1
autosway launch foot
~~~

Then inspect:

~~~bash
autosway state tree
~~~

## Goose

Run an example recipe:

~~~bash
goose run --recipe recipes/security-research.yaml --interactive
~~~

Goose recipes support YAML instructions, prompts, parameters, extensions, and subrecipes. Goose also supports recipe execution through the CLI. See the official Goose recipe reference for current syntax.

## Event router

The event router is intentionally opt-in:

~~~bash
autosway-events window
~~~

Start it only after reviewing the policy in config/event-policy.nuon.

## Sway configuration

AutoSway does not replace your Sway configuration. Add only the bindings you want, for example:

~~~ini
bindsym $mod+d exec fuzzel
bindsym $mod+Return exec foot
bindsym $mod+l exec swaylock
~~~

Keep the compositor configuration small and put higher-level automation in AutoSway scripts.
