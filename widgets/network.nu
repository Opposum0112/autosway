#!/usr/bin/env nu
def totals [] {
  open --raw /proc/net/dev
  | lines
  | skip 2
  | each {|line|
      let parts=($line|str trim|split row " " | where {|x|$x!=""})
      if ($parts|is-empty) {null} else {
        let iface=$parts.0|str replace ":" ""
        if $iface=="lo" {null} else {rx:($parts.1|into int),tx:($parts.9|into int)}
      }
    }
  | where {|x|$x!=null}
  | reduce -f {rx:0,tx:0} {|x,acc| {rx:($acc.rx+$x.rx),tx:($acc.tx+$x.tx)}}
}
let now=(date now)
let path=($env.AUTOSWAY_NETWORK_STATE?|default($env.TMPDIR?|default("/tmp"))|path join $"autosway-network-($env.USER?|default("user")).nuon")
let cur={time:$now,rx:(totals).rx,tx:(totals).tx}
let old=if ($path|path exists) {open $path} else {null}
$cur|to nuon|save -f $path
let rx_rate=if $old==null {0} else {((($cur.rx-$old.rx)/((($cur.time-$old.time)/1sec)|into float))|into int|max 0)}
let tx_rate=if $old==null {0} else {((($cur.tx-$old.tx)/((($cur.time-$old.time)/1sec)|into float))|into int|max 0)}
let rx_mbps=(($rx_rate*8)/1000000|math round)
let tx_mbps=(($tx_rate*8)/1000000|math round)
let peak=($env.AUTOSWAY_NETWORK_PEAK_MBPS?|default(100)|into int)
let pct=(((($rx_mbps|max $tx_mbps)*100)/$peak)|math round|into int|max 0|min 100)
{full_text:$"󰛳 RX ($rx_mbps) TX ($tx_mbps) Mb/s",value:$pct,color:"#8ab4f8",separator:true}|to json
