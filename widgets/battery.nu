#!/usr/bin/env nu
let files=(glob "/sys/class/power_supply/BAT*/capacity")
if not ($files | is-empty) { let pct=(open $files.0|str trim|into int); {full_text:$"󰁹 ($pct)%",color:(if $pct<=15 {"#ff6b6b"} else if $pct<=30 {"#ffd166"} else {"#81c995"}),separator:true}|to json }
