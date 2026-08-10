#!/bin/bash

# 获取当前音量状态（使用pamixer）
MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | awk '{print $5}' | sed 's/%//')

if [ "$MUTE" = "yes" ]; then
    dunstify -h string:x-dunst-stack-tag:volume -h int:value:0 "🔇 静音" "音量已静音。"
else
    dunstify -h string:x-dunst-stack-tag:volume -h int:value:"$VOLUME" "🔊 音量" "当前音量: $VOLUME%"
fi
