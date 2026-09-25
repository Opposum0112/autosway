#!/usr/bin/env nu

let root = ($env.PWD | path expand)
let bin = ($root | path join "bin")
let target = ($env.HOME | path join ".local/bin")

mkdir $target

let autosway_script = ($target | path join "autosway")
let events_script = ($target | path join "autosway-events")
let autosway_source = ($bin | path join "autosway.nu")
let events_source = ($bin | path join "autosway-events.nu")

let autosway_launcher = "#!/bin/sh\nexec nu '" + $autosway_source + "' \"$@\"\n"
let events_launcher = "#!/bin/sh\nexec nu '" + $events_source + "' \"$@\"\n"

$autosway_launcher | save -f $autosway_script
$events_launcher | save -f $events_script

^chmod +x $autosway_script $events_script

print $"installed ($autosway_script)"
print $"installed ($events_script)"
print "Ensure ~/.local/bin is in PATH."
print "Verify with: autosway state workspaces"