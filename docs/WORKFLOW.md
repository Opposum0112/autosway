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
Agent verifies result
```

Example:

```text
"Remove the battery and add a clock."

state → widget remove battery → widget add clock → verify
```

Example:

```text
"Make the focused desktop look cleaner."

Agent inspects state → chooses supported operations → applies changes → verifies

```

AutoSway does not require a separate recipe engine for these operations. A recipe can be added later when a workflow needs to be saved or repeated.
