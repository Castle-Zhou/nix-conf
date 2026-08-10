#!/usr/bin/env bash
# waybar custom/gpu：输出 NVIDIA GPU 利用率百分比
util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)
if [ -n "$util" ]; then
  echo "$util"
else
  echo "N/A"
fi
