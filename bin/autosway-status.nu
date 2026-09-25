#!/usr/bin/env nu

# Swaybar i3bar JSON status generator.
# Each widget is an independent Nushell program.

def main [] {
  print '{"version":1,"click_events":false}'
  print '['
  mut first = true

  loop {
    let root = ($env.AUTOSWAY_ROOT? | default ($env.HOME | path join ".local/share/autosway"))
    let names = [cpu memory battery]

    let blocks = ($names | each {|n|
      let p = ($root | path join "widgets" $"($n).nu")
      if ($p | path exists) {
        ^nu $p | from json
      } else {
        null
      }
    } | where {|x| $x != null})

    let line = ($blocks | to json)

    if $first {
      print $line
      $first = false
    } else {
      print $",($line)"
    }

    sleep 1sec
  }
}