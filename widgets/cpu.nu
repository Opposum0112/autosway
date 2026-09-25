#!/usr/bin/env nu
let load=(open --raw /proc/loadavg | split row " " | first | into float)
let cores=(^nproc | str trim | into int)
let pct=((($load / $cores) * 100) | math round | into int | max 0 | min 100)
{full_text:$"󰻠 CPU ($pct)%",value:$pct,color:(if $pct >= 85 {"#ff6b6b"} else if $pct >= 60 {"#ffd166"} else {"#8ab4f8"}),separator:true} | to json
