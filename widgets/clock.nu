#!/usr/bin/env nu
def main [format:string="%H:%M"] {
  {full_text:(date now|format date $format),separator:true}|to json
}
