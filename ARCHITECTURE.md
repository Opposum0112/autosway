# AutoSway Architecture

## Purpose

AutoSway is a small, scriptable desktop-automation layer for Sway. It combines Sway IPC, swaymsg, Nushell, and Goose recipes without introducing a monolithic desktop shell.

## Design principles

1. Sensible defaults — start with Sway's native ecosystem and configure only what is necessary.
2. Orthogonality — Sway manages windows; swaymsg is the control/API surface; Nushell handles structured automation; Fuzzel launches applications.
3. One job per component — avoid duplicating functionality across desktop frameworks.
4. State before action — automation should inspect Sway state before mutating it.
5. Verify after mutation — recipes should confirm that requested state was reached.
6. Explicit capabilities — agents should use a small allowlisted command surface rather than arbitrary compositor commands where practical.
7. Recipes are intent — Goose recipes describe the desired desktop workflow; scripts implement deterministic mechanics.

## Runtime model

~~~text
Goose recipe
    |
    v
Agent intent / workflow
    |
    v
AutoSway capability CLI
    |
    +---- state ----> swaymsg IPC ----> Sway state
    |
    +---- action ---> swaymsg IPC ----> Sway mutation
    |
    +---- events ---> swaymsg IPC ----> Nushell router
                                      |
                                      v
                                automation trigger
~~~

## Capability boundary

The initial CLI exposes:

- state tree
- state workspaces
- state outputs
- state inputs
- workspace <name>
- focus <criteria>
- move <criteria> workspace <name>
- move <criteria> output <name>
- fullscreen
- floating
- scratchpad show
- scratchpad move
- launch <command...>
- lock
- events <event>

The wrapper deliberately does not expose an unrestricted swaymsg passthrough as its primary agent interface.

## Event model

Sway IPC events can drive deterministic automation:

~~~text
window:new
    |
    v
autosway-events
    |
    +--> inspect event
    +--> apply policy
    +--> call autosway
    +--> verify
~~~

Use event automation for deterministic policies. Use Goose for workflows that require planning, contextual decisions, or natural-language intent.

## Goose integration

Goose recipes are portable YAML workflows. AutoSway recipes should:

1. inspect current state;
2. determine the smallest required mutation;
3. execute through the AutoSway CLI;
4. re-query state;
5. report what changed and what could not be completed.

## Security boundary

Desktop automation is powerful. A future MCP extension should expose the same capability vocabulary as the CLI rather than exposing raw swaymsg.

Recommended future layers:

~~~text
Recipe
  -> Capability schema
  -> Policy/authorization
  -> AutoSway adapter
  -> swaymsg / Sway IPC
~~~

This makes AutoSway a useful execution provider for a future portable execution-contract system.
