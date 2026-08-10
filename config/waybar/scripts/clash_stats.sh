#!/usr/bin/sh

service=$(systemctl is-active clash.service)

case $1 in
  "toggle")
    if [ $service == 'active' ]; then
      systemctl stop --user clash.service
      printf '%s' '%{F#df8e1d}󰄛%{F-}'
    else
      systemctl start --user clash.service
      printf '%s' '%{F#7c7f93}󰄛%{F-}'
    fi
    ;;
  "")
    if [ $service == "active" ]; then
      printf '%s' '%{F#df8e1d}󰄛%{F-}'
    else
      printf '%s' '%{F#7c7f93}󰄛%{F-}'
    fi
esac
