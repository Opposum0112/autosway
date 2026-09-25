#!/usr/bin/env nu

def sway [...args: string] {
  let result = (^swaymsg ...$args | complete)
  if $result.exit_code != 0 { error make {msg: ($result.stderr | str trim)} }
  $result.stdout
}
def state [...args: string] { sway ...$args | from json }
def config_path [] { $env.AUTOSWAY_CONFIG? | default ($env.HOME | path join ".config/autosway/widgets.nuon") }
def load_config [] { let p=(config_path); if ($p|path exists) { open $p } else { {widgets: []} } }
def save_config [cfg: record] { let p=(config_path); mkdir ($p|path dirname); $cfg|to nuon|save -f $p }
def usage [] {
  print "autosway <state|workspace|window|widget|bar|launch|lock> ..."
  print "state tree|workspaces|outputs|inputs"
  print "workspace <name>"
  print "window focus <criteria>"
  print "window move <criteria> workspace|output <name>"
  print "window fullscreen|floating"
  print "window scratchpad show|move"
  print "widget list|add|remove|set"
  print "widget set <name> color|format <value>"
  print "bar"
  print "launch <command> [args...]"
  print "lock"
}
def widget_default [name:string] {
  match $name {
    "clock" => {name:"clock",color:"#e6e6e6",format:"%H:%M"}
    "cpu" => {name:"cpu",color:"#8ab4f8"}
    "memory" => {name:"memory",color:"#81c995"}
    "battery" => {name:"battery",color:"#81c995"}
    _ => {name:$name}
  }
}
def render_bar [] {
  print '{"version":1,"click_events":false}'
  print '['
  mut first=true
  loop {
    let cfg=load_config
    let root=($env.AUTOSWAY_ROOT?|default($env.HOME|path join ".config/autosway"))
    let blocks=($cfg.widgets|each {|w|
      let p=($root|path join "widgets" $"($w.name).nu")
      if ($p|path exists) {
        let args=if $w.name=="clock" {[$w.format?|default("%H:%M")]} else {[]}
        let r=(^nu $p ...$args|complete)
        if $r.exit_code==0 {
          let b=($r.stdout|from json); let c=($w.color?|default(""))
          if ($c|is-empty) {$b} else {$b|upsert color $c}
        }
      }
    }|where {|x|$x!=null})
    let line=($blocks|to json)
    if $first {print $line;$first=false} else {print $",($line)"}
    sleep 1sec
  }
}
def main [action:string="help" subject?:string target?:string ...rest:string] {
  match $action {
    "state" => {match ($subject|default "") {
      "tree" => {state -t get_tree|to json}
      "workspaces" => {state -t get_workspaces|to json}
      "outputs" => {state -t get_outputs|to json}
      "inputs" => {state -t get_inputs|to json}
      _ => {usage}
    }}
    "workspace" => {if $subject==null {error make {msg:"workspace name required"}}; sway workspace $subject}
    "window" => {match ($subject|default "") {
      "focus" => {if $target==null {error make {msg:"window focus requires criteria"}}; sway $"[$target]" focus}
      "move" => {if $target==null or ($rest|length)<2 {error make {msg:"window move requires <criteria> workspace|output <name>"}}; let d=$rest.0;let n=$rest.1;if $d=="workspace"{sway $"[$target]" move container to workspace $n}else if $d=="output"{sway $"[$target]" move container to output $n}else{error make {msg:"destination must be workspace or output"}}}
      "fullscreen" => {sway fullscreen toggle}
      "floating" => {sway floating toggle}
      "scratchpad" => {match ($target|default "") {"show"=>{sway scratchpad show},"move"=>{sway move scratchpad},_=>{usage}}}
      _=>{usage}
    }}
    "widget" => {let cfg=load_config;match ($subject|default "") {
      "list"=>{$cfg.widgets|to json}
      "add"=>{if $target==null {error make {msg:"widget name required"}};if not ($cfg.widgets|any {|w|$w.name==$target}) {save_config ($cfg|upsert widgets ($cfg.widgets|append (widget_default $target)))}}
      "remove"=>{if $target==null {error make {msg:"widget name required"}};save_config ($cfg|upsert widgets ($cfg.widgets|where {|w|$w.name!=$target}))}
      "set"=>{if $target==null or ($rest|length)<2 {error make {msg:"widget set requires <name> <property> <value>"}};let p=$rest.0;let v=($rest|skip 1|str join " ");let u=($cfg.widgets|each {|w|if $w.name==$target {$w|upsert $p $v}else{$w}});save_config ($cfg|upsert widgets $u)}
      _=>{usage}
    }}
    "bar"=>{render_bar}
    "launch"=>{if $subject==null {error make {msg:"launch requires a command"}};^$subject ...$rest}
    "lock"=>{^swaylock -f}
    "help"=>{usage}
    _=>{usage}
  }
}
