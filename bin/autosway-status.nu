#!/usr/bin/env nu

def main [] {
  print '{"version":1,"click_events":false}'
  print '['
  loop {
    let root = ($env.AUTOSWAY_ROOT? | default ($env.HOME | path join ".local/share/autosway"))
    let names = [cpu memory battery]
    let blocks = ($names | each {|n|
      let p = ($root | path join "widgets" $"($n).nu")
      if ($p | path exists) { ^nu $p | from json } else { null }
    } | where {|x| $x != null})
    print ($blocks | to json)
    sleep 1sec
  }
}
