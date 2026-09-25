#!/usr/bin/env nu

# Minimal Sway IPC event reader.
# It prints Sway's subscribed event stream. Policy/action routing is kept
# separate so event automation remains explicit and reviewable.

def main [
  event: string = "window"
] {
  let payload = $"[\"($event)\"]"
  ^swaymsg -t subscribe $payload
}
