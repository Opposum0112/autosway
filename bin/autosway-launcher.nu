#!/usr/bin/env nu

def desktop_files [] {
  [
    ($env.HOME | path join ".local/share/applications")
    "/usr/local/share/applications"
    "/usr/share/applications"
  ] | each {|d| if ($d | path exists) { glob ($d | path join "*.desktop") } else { [] }} | flatten | uniq
}

def entry [path:string] {
  let lines = (open --raw $path | lines)
  let name = ($lines | where {|x| $x | str starts-with "Name="} | first | default "" | str substring 5..)
  let cats = ($lines | where {|x| $x | str starts-with "Categories="} | first | default "" | str substring 11..)
  let nd = ($lines | where {|x| $x | str starts-with "NoDisplay="} | first | default "NoDisplay=false" | str downcase)
  if ($name | is-empty) or ($nd == "nodisplay=true") { null } else { {name:$name,categories:($cats | split row ";" | where {|x| $x != ""}),path:$path} }
}

def normalize [c:string] {
  match $c {
    "Development" => "Development"
    "Education" => "Education"
    "Game" | "Games" => "Games"
    "Graphics" => "Graphics"
    "Network" | "WebBrowser" | "Email" | "Chat" => "Internet"
    "AudioVideo" | "Audio" | "Video" | "Player" => "Multimedia"
    "Office" | "WordProcessor" | "Spreadsheet" => "Office"
    "Science" => "Science"
    "Settings" | "DesktopSettings" => "Settings"
    "System" | "FileManager" => "System"
    "Utility" | "Utilities" | "FileTools" => "Utilities"
    _ => "Other"
  }
}

def main [] {
  let items = (desktop_files | each {|p| entry $p} | where {|x| $x != null})
  let categories = ($items | each {|x| $x.categories | each {|c| normalize $c}} | flatten | uniq | sort)
  let cat = ($categories | str join "
" | ^fuzzel --dmenu --prompt "Applications › " | str trim)
  if ($cat | is-empty) { return }
  let name = ($items | where {|x| $x.categories | any {|c| (normalize $c) == $cat}} | sort-by name | get name | str join "
" | ^fuzzel --dmenu --prompt $"Applications › ($cat) › " | str trim)
  if ($name | is-empty) { return }
  let app = ($items | where name == $name | first)
  ^gio launch $app.path
}
