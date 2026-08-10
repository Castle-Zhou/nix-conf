#!/usr/bin/env bash
# waybar custom/bandwidth：显示上下行网速
# 用法: bandwidth.sh -t <采样间隔秒> <网卡1> [网卡2 ...]
interval=1
if [ "$1" = "-t" ]; then
  interval="$2"
  shift 2
fi

sum_bytes() {
  local kind="$1" total=0 v
  shift
  for iface in "$@"; do
    if [ -r "/sys/class/net/$iface/statistics/${kind}_bytes" ]; then
      v=$(cat "/sys/class/net/$iface/statistics/${kind}_bytes")
      total=$((total + v))
    fi
  done
  echo "$total"
}

fmt() {
  # bytes/s -> 人类可读
  local b=$1
  if [ "$b" -ge 1048576 ]; then
    awk -v b="$b" 'BEGIN { printf "%.1fM", b/1048576 }'
  elif [ "$b" -ge 1024 ]; then
    awk -v b="$b" 'BEGIN { printf "%.0fK", b/1024 }'
  else
    echo "${b}B"
  fi
}

rx1=$(sum_bytes rx "$@"); tx1=$(sum_bytes tx "$@")
sleep "$interval"
rx2=$(sum_bytes rx "$@"); tx2=$(sum_bytes tx "$@")

drx=$(( (rx2 - rx1) / interval ))
dtx=$(( (tx2 - tx1) / interval ))

echo "↓ $(fmt "$drx") ↑ $(fmt "$dtx")"
