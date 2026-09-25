#!/usr/bin/env nu
let mem=(free -b | lines | where {|x| $x | str starts-with "Mem:"} | first | split row " " | where {|x| $x != ""}); let total=($mem.1|into int); let used=($mem.2|into int); let pct=(($used*100)/$total|math round|into int); {full_text:$"󰍛 ($pct)%",color:(if $pct>=85 {"#ff6b6b"} else if $pct>=65 {"#ffd166"} else {"#81c995"}),separator:true}|to json
