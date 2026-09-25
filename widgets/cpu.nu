#!/usr/bin/env nu
let line = (open --raw /proc/stat | lines | where {|x| $x | str starts-with "cpu "} | first)
let v = ($line | split row " " | where {|x| $x != ""} | skip 1 | each {|x| $x | into int})
let total = ($v | math sum)
let idle = $v.3
let pct = (100 - (($idle * 100) / $total) | math round | into int)
{full_text:$"󰻠 ($pct)%",color:(if $pct >= 85 {"#ff6b6b"} else if $pct >= 60 {"#ffd166"} else {"#8ab4f8"}),separator:true} | to json
