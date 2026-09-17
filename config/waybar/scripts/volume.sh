#!/bin/sh
# Realtime volume status for waybar (default sink)
# Emits JSON on every pulseaudio/pipewire event so the bar updates instantly.

ICONS_LOW=""
ICONS_MED=""
ICONS_HIGH=""
ICON_MUTED=""

print_status() {
  vol="$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n1 | grep -oE '[0-9]+%' | head -1 | tr -d '%')"
  [ -z "$vol" ] && return
  mute="$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o 'yes')"
  sink="$(pactl get-default-sink 2>/dev/null)"

  if [ -n "$mute" ]; then
    text="$ICON_MUTED"
    class="muted"
  elif [ "$vol" -le 33 ]; then
    text="$ICONS_LOW $vol%"
    class=""
  elif [ "$vol" -le 66 ]; then
    text="$ICONS_MED $vol%"
    class=""
  else
    text="$ICONS_HIGH $vol%"
    class=""
  fi

  printf '{"text":"%s","class":"%s","tooltip":"%s\\nVolume: %s%%"}\n' \
    "$text" "$class" "$sink" "$vol"
}

# initial state
print_status

# live updates
pactl subscribe 2>/dev/null | while read -r line; do
  case "$line" in
    *"on sink"*|*"on server"*) print_status ;;
  esac
done
