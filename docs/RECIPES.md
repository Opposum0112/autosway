# AutoSway Recipes

Recipes are Goose workflows for desktop automation.

## Recipe contract

A recipe should describe:

- intent — what desktop state is desired;
- preconditions — what must already be true;
- actions — which AutoSway capabilities may be used;
- verification — how the resulting Sway state is checked;
- failure behavior — what the agent should report instead of guessing.

Pattern:

~~~text
Inspect -> Plan -> Mutate -> Verify -> Report
~~~

## Security research workspace

A typical desired state might be:

~~~text
workspace 1 -> terminal
workspace 2 -> browser
workspace 3 -> packet analysis
workspace 4 -> logs
~~~

The agent should discover actual app IDs rather than assuming that every installation uses identical identifiers.

## External monitor

When a monitor appears:

1. query outputs;
2. identify the new output;
3. create/select the requested workspace;
4. move only the intended workspace;
5. verify output/workspace association.

## Recipe safety

Never instruct an agent to blindly run arbitrary generated Sway commands. Prefer the AutoSway capability CLI. If a workflow needs a capability that is not represented, add and review a new explicit capability first.
