# Workflow

AutoSway has one primary workflow:

```text
User request
    ↓
Goose / Agent
    ↓
Read state if necessary
    ↓
Choose AutoSway operation
    ↓
AutoSway changes Sway or widget state
    ↓
Swaybar renders widget state
    ↓
User interaction
    ↓
AutoSway dispatches a declarative widget action
    ↓
Agent verifies result
```

## Creating a widget

A widget does not need to be registered in a central framework. The agent can add a widget configuration and use a widget script already installed under `~/.config/autosway/widgets/`.

For a new widget implementation:

```text
widgets/foo.nu
       ↓
emits JSON state
       ↓
widget add foo
       ↓
Swaybar
```

A progress-capable widget can emit `value: 0..100`.

## Adding interaction

Interaction is configuration, not widget-specific plumbing:

```text
widget set foo action click launch foot -e btop
widget set foo action scroll_up volume_up
```

AutoSway maps Swaybar buttons to:

```text
click
middle_click
right_click
scroll_up
scroll_down
```

and resolves the configured event against the widget's action map.

## Example

```text
"Add a network progress widget and make it interactive."

Goose
  ↓
autosway widget add network
autosway widget set network progress true
autosway widget set network action click launch foot -e btop
  ↓
AutoSway
  ↓
network.nu → JSON state
  ↓
Swaybar
  ↓
click
  ↓
AutoSway action dispatcher
  ↓
foot -e btop
```

AutoSway does not require a separate recipe engine for these operations. A recipe can be added later when a workflow needs to be saved or repeated.
