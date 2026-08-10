#!/usr/bin/sh

ICON_ETHERNET=""
ICON_WIFI="󰤨"
ICON_DISCONNECTED="󰤮"

check_ethernet() {
  local interfaces=$(ip link show | grep -E "eth|enp|ens|enx" | grep -E "state UP|state UNKNOWN" | awk -F': ' '{print $2}')

  for iface in $interfaces; do
    if ip addr show "$iface" | grep -q "inet "; then
      echo "$ICON_ETHERNET"
      return 0
    fi
  done

  return 1
}

check_wifi() {
  local interfaces=$(ip link show | grep -E "wlan|wlp" | grep -E "state UP|state UNKNOWN" | awk -F': ' '{print $2}')

  for iface in $interfaces; do
    if ip addr show "$iface" | grep -q "inet "; then
      local signal=$(iwconfig "$iface" 2>/dev/null | grep "Link Quality" | awk '{print $2}' | awk -F'=' '{print $2}' | awk -F'/' '{print $1}')

      if [ -n "$signal" ]; then
        if [ "$signal" -gt 75 ]; then
          echo "󰤨"
        elif [ "$signal" -gt 50 ]; then
          echo "󰤥"
        elif [ "$signal" -gt 25 ]; then
          echo "󰤢"
        else
          echo "󰤟"
        fi
      else
        echo "$ICON_WIFI"
      fi
      return 0
    fi
  done

  return 1
}

if check_ethernet; then
  exit 0
elif check_wifi; then
  exit 0
else
  echo "$ICON_DISCONNECTED"
  exit 1
fi
