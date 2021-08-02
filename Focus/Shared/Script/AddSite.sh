#!/bin/sh

function writeData(){
  eval  domain_name  = "$1"
  eval  domain_name_  = "$2"
  
  sudo -- sh -c -e "echo '${domain_name}' \n '${domain_name_}' >> /etc/hosts"
}
