#!/bin/bash

# 使用 brightnessctl 获取当前亮度百分比
BRIGHTNESS=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')

# 使用堆栈标签确保亮度通知替换:cite[3]:cite[4]
dunstify -h string:x-dunst-stack-tag:brightness -h int:value:"$BRIGHTNESS" "💡 亮度" "当前亮度: $BRIGHTNESS%"
