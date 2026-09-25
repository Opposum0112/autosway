#!/usr/bin/env nu
let root=($env.FILE_PWD?|default(pwd))
let home=$env.HOME
let bin=($home|path join ".local/bin")
let cfg=($home|path join ".config/autosway")
let wd=($cfg|path join "widgets")
mkdir $bin
mkdir $wd
let wrapper=$"#!/bin/sh
exec nu '($root|path join "autosway.nu")' \"$@\"
"
$wrapper|save -f ($bin|path join "autosway")
^chmod +x ($bin|path join "autosway")
cp ($root|path join "config/widgets.nuon") ($cfg|path join "widgets.nuon")
for f in (glob ($root|path join "widgets/*.nu")) {cp $f ($wd|path join ($f|path basename))}
print $"installed ($bin|path join "autosway")"
print "Add: status_command autosway bar"
