#!/usr/bin/env nu

let root = ($env.PWD | path expand)
let bin = ($root | path join "bin")
let widgets = ($root | path join "widgets")
let target = ($env.HOME | path join ".local/bin")
let data = ($env.HOME | path join ".local/share/autosway")

mkdir $target
mkdir $data
mkdir ($data | path join "widgets")

def install-wrapper [source:string, name:string] {
  let target_path = ($env.HOME | path join ".local/bin" $name)
  let wrapper = $"#!/bin/sh\nexec nu '($source)' \"$@\"\n"
  $wrapper | save -f $target_path
  ^chmod +x $target_path
  print $"installed ($target_path)"
}

install-wrapper ($bin | path join "autosway.nu") "autosway"
install-wrapper ($bin | path join "autosway-events.nu") "autosway-events"
install-wrapper ($bin | path join "autosway-launcher.nu") "autosway-launcher"
install-wrapper ($bin | path join "autosway-status.nu") "autosway-status"

for f in (glob ($widgets | path join "*.nu")) {
  let dest = ($data | path join "widgets" ($f | path basename))
  cp $f $dest
}

print "Ensure ~/.local/bin is in PATH."
print "Verify: autosway state workspaces"
