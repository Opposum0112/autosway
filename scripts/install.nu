#!/usr/bin/env nu

let root = ($env.PWD | path expand)
let bin = ($root | path join "bin")
let target = ($env.HOME | path join ".local/bin")

mkdir $target

for name in ["autosway.nu", "autosway-events.nu"] {
  let src = ($bin | path join $name)
  let dst_name = ($name | str replace ".nu" "")
  let dst = ($target | path join $dst_name)

  if $dst | path exists {
    rm -f $dst
  }

  ln -s $src $dst
  print $"installed ($dst)"
}

print ""
print "Ensure ~/.local/bin is in PATH."
print "Verify with: autosway state workspaces"
