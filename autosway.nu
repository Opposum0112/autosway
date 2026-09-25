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
  print "widget list|add|remove|set|clear-action"
  print "widget set <name> color|format|progress|width <value>"
  print "widget set <name> action <click|right_click|scroll_up|scroll_down> <type> [args...]"
  print "bar"
  print "launch <command> [args...]"
  print "lock"
}

def widget_default [name:string] {
  match $name {
    "clock" => {name:"clock",color:"#e6e6e6",format:"%H:%M"}
    "cpu" => {name:"cpu",color:"#8ab4f8",progress:true,width:8,actions:{click:{type:"launch",args:["foot","-e","btop"]}}}
    "memory" => {name:"memory",color:"#81c995",progress:true,width:8}
    "battery" => {name:"battery",color:"#81c995",progress:true,width:8}
    "network" => {name:"network",color:"#8ab4f8",progress:true,width:8,actions:{click:{type:"launch",args:["foot","-e","btop"]}}}
    _ => {name:$name}
  }
}

def progress_text [value:int width:int] {
  let v=($value|max 0|min 100)
  let filled=(($v*$width)/100|math round|into int)
  let empty=($width-$filled)
  $"(char -u 2588)" | str repeat $filled | append (("░"|str repeat $empty)) | str join
}

def decorate_progress [block:record widget:record] {
  if not ($widget.progress? | default false) { return $block }
  if not ($block.value? != null) { return $block }
  let width=($widget.width? | default 8 | into int)
  let value=($block.value|into int)
  let bar=(progress_text $value $width)
  let text=($block.full_text|default "")
  $block|upsert full_text $"($text) ($bar)"
}

def run_action [action:record] {
  match ($action.type? | default "") {
    "launch" => {
      let args=($action.args? | default [])
      if ($args|is-empty) { return }
      let result=(^$args.0 ...($args|skip 1)|complete)
      if $result.exit_code != 0 { print $result.stderr }
    }
    "workspace" => { if $action.name? != null { sway workspace $action.name } }
    "lock" => { ^swaylock -f | complete | ignore }
    "volume_up" => { ^wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ | complete | ignore }
    "volume_down" => { ^wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- | complete | ignore }
    "volume_mute" => { ^wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle | complete | ignore }
    "fullscreen" => { sway fullscreen toggle }
    "floating" => { sway floating toggle }
    _ => {}
  }
}

def dispatch_event [event:record cfg:record] {
  let name=($event.name? | default "")
  let button=($event.button? | default 0 | into int)
  let action_name=(match $button {1=>"click",2=>"middle_click",3=>"right_click",4=>"scroll_up",5=>"scroll_down",_=>""})
  if ($action_name|is-empty) { return }
  let widget=($cfg.widgets|where {|w| $w.name==$name}|first)
  if $widget == null { return }
  let action=($widget.actions? | default {} | get -o $action_name)
  if $action != null { run_action $action }
}

def start_event_reader [] {
  job spawn {
    try {
      open --raw /dev/stdin
      | lines
      | each {|line|
          try {
            let parsed=($line|from json)
            if ($parsed|describe|str starts-with "list") {
              $parsed|each {|event| $event|job send 0}
            } else {
              $parsed|job send 0
            }
          }
        }
    }
  } | ignore
}

def render_bar [] {
  print '{"version":1,"click_events":true}'
  print '['
  mut first=true
  let event_reader=(start_event_reader)
  loop {
    loop {
      let incoming=(try { job recv --timeout 0sec } catch { null })
      if $incoming == null { break }
      dispatch_event $incoming (load_config)
    }
    let cfg=load_config
    let root=($env.AUTOSWAY_ROOT?|default($env.HOME|path join ".config/autosway"))
    let blocks=($cfg.widgets|each {|w|
      let p=($root|path join "widgets" $"($w.name).nu")
      if ($p|path exists) {
        let args=if $w.name=="clock" {[$w.format?|default("%H:%M")]} else {[]}
        let r=(^nu $p ...$args|complete)
        if $r.exit_code==0 {
          let b=($r.stdout|from json)
          let b=($b|upsert name $w.name)
          let b=($b|upsert instance $w.name)
          let c=($w.color?|default(""))
          let b=if ($c|is-empty) {$b} else {$b|upsert color $c}
          decorate_progress $b $w
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
    "widget" => {
      let cfg=load_config
      match ($subject|default "") {
        "list"=>{$cfg.widgets|to json}
        "add"=>{if $target==null {error make {msg:"widget name required"}};if not ($cfg.widgets|any {|w|$w.name==$target}) {save_config ($cfg|upsert widgets ($cfg.widgets|append (widget_default $target)))}}
        "remove"=>{if $target==null {error make {msg:"widget name required"}};save_config ($cfg|upsert widgets ($cfg.widgets|where {|w|$w.name!=$target}))}
        "clear-action"=>{if $target==null or ($rest|length)<1 {error make {msg:"widget clear-action requires <name> <event>"}};let event=$rest.0;let u=($cfg.widgets|each {|w|if $w.name==$target {let a=($w.actions?|default {})|reject {|k,v|$k==$event};$w|upsert actions $a}else{$w}});save_config ($cfg|upsert widgets $u)}
        "set"=>{
          if $target==null or ($rest|is-empty) {error make {msg:"widget set requires a name and property"}}
          let p=$rest.0
          if $p=="action" {
            if ($rest|length)<3 {error make {msg:"widget set <name> action <event> <type> [args...]"}}
            let event=$rest.1
            let typ=$rest.2
            let args=($rest|skip 3)
            let action=if $typ=="workspace" {{type:$typ,name:($args|first|default "")}} else {{type:$typ,args:$args}}
            let u=($cfg.widgets|each {|w|if $w.name==$target {let a=($w.actions?|default {})|upsert $event $action;$w|upsert actions $a}else{$w}})
            save_config ($cfg|upsert widgets $u)
          } else {
            if ($rest|length)<2 {error make {msg:"widget set requires <name> <property> <value>"}}
            let v=($rest|skip 1|str join " ")
            let v=if $p=="progress" {$v|into bool} else if $p=="width" {$v|into int} else {$v}
            let u=($cfg.widgets|each {|w|if $w.name==$target {$w|upsert $p $v}else{$w}})
            save_config ($cfg|upsert widgets $u)
          }
        }
        _=>{usage}
      }
    }
    "bar"=>{render_bar}
    "launch"=>{if $subject==null {error make {msg:"launch requires a command"}};^$subject ...$rest}
    "lock"=>{^swaylock -f}
    "help"=>{usage}
    _=>{usage}
  }
}
