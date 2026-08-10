#! /usr/bin/env bash

config_file="$HOME/.config/niri/config.kdl"  # 修改为你的配置文件路径

# 检查 clash 相关行是否被注释
if grep -q "^  http_proxy" "$config_file"; then
    # 当前未注释，添加注释
    sed -i '/\/\/ clash/,/no_proxy/ {
        /^  \(http_proxy\|https_proxy\|all_proxy\|no_proxy\)/s/^/\/\/ /
    }' "$config_file"
    echo "已注释 clash 代理配置"
else
    # 当前已注释，取消注释
    sed -i '/\/\/ clash/,/no_proxy/ {
        s/^\/\/ \(  \(http_proxy\|https_proxy\|all_proxy\|no_proxy\)\)/\1/
    }' "$config_file"
    echo "已取消注释 clash 代理配置"
fi
