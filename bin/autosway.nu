#!/usr/bin/env nu

# AutoSway capability CLI.
# This is intentionally not a raw swaymsg passthrough.

def sway [...args: string] {
  let result = (^swaymsg ...$args | complete)
  if $result.exit_code != 0 {
    error make {msg: ($result.stderr | str trim)}
  }
  $result.stdout
}

def json_state [...args: string] {
  sway ...$args | from json
}

def usage [] {
  print "autosway <state|workspace|focus|move|fullscreen|floating|scratchpad|launch|lock> ..."
  print ""
  print "state tree|workspaces|outputs|inputs"
  print "workspace <name>"
  print "focus <criteria>"
  print "move <criteria> workspace <name>"
  print "move <criteria> output <name>"
  print "fullscreen"
  print "floating"
  print "scratchpad show|move"
  print "launch <command> [args...]"
  print "lock"
}

def main [
  action: string = "help"
  subject?: string
  target?: string
  ...rest: string
] {
  match $action {
    "state" => {
      match ($subject | default "") {
        "tree" => { json_state -t get_tree | to json }
        "workspaces" => { json_state -t get_workspaces | to json }
        "outputs" => { json_state -t get_outputs | to json }
        "inputs" => { json_state -t get_inputs | to json }
        _ => { usage }
      }
    }

    "workspace" => {
      if $subject == null { error make {msg: "workspace name required"} }
      sway workspace $subject
    }

    "focus" => {
      if $subject == null { error make {msg: "Sway criteria required"} }
      sway $"[$subject]" focus
    }

    "move" => {
      if $subject == null or $target == null {
        error make {msg: "move requires: <criteria> workspace|output <name>"}
      }
      if $target == "workspace" {
        sway $"[$subject]" move container to workspace $rest.0
      } else if $target == "output" {
        sway $"[$subject]" move container to output $rest.0
      } else {
        error make {msg: "move target must be workspace or output"}
      }
    }

    "fullscreen" => { sway fullscreen toggle }
    "floating" => { sway floating toggle }

    "scratchpad" => {
      match ($subject | default "") {
        "show" => { sway scratchpad show }
        "move" => { sway move scratchpad }
        _ => { usage }
      }
    }

    "launch" => {
      if ($rest | length) == 0 {
        error make {msg: "launch requires a command"}
      }
      ^$subject ...$rest
    }

    "lock" => { ^swaylock -f }

    "help" => { usage }
    _ => { usage }
  }
}
