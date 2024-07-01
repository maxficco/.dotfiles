# The Sway configuration file in ~/.config/sway/config calls this script.
# make sure to chmod +x status.sh
# You should see changes to the status bar after saving this script.
# If not, $mod+Shift+c to reload the configuration.

# The abbreviated weekday (e.g., "Sat"), followed by the ISO-formatted date
# like 2018-10-06 and the time (e.g., 14:01:59)
date_formatted=$(date "+%a %F %H:%M:%S")
# Get the Linux version 
linux_version=$(uname -r)
# Returns the battery status: "Full", "Discharging", or "Charging".
battery_status=$(cat /sys/class/power_supply/BAT0/status)
# Returns capacity 0-100
battery_capacity=$(cat /sys/class/power_supply/BAT0/capacity)
# Get the default sink index
#default_sink=$(pactl info | grep "Default Sink" | cut -d ' ' -f3)
# Get volume information for the default sink
#volume_info=$(pactl list sinks | grep -A 15 "Name: $default_sink" | grep 'Volume:')
# Extract the percentage value
# volume=$(echo $volume_info | grep -o '[0-9]*%' | head -n 1)
volume=$(pamixer --get-volume-human)
# Get brightness and calculate percent
brightness_val=$(cat /sys/class/backlight/*/brightness)
max_brightness=$(cat /sys/class/backlight/*/max_brightness)
brightness=$(echo "$brightness_val" "$max_brightness" | awk '{printf "%.0f", ($1*100)/$2}')
#wifi
wifi=$(nmcli radio wifi | sed -e "s/enabled/on/" -e "s/disabled/off/")
#check syncthing
if pgrep -x "syncthing" > /dev/null
then
    sync=$(echo "on")
else
    sync=$(echo "off")
fi

# print to swaybar
echo $USER "->" $linux_version "|" wifi: $wifi "|" syncthing: $sync "|" volume: $volume "|" backlight: $brightness% "|" $battery_status $battery_capacity% "|" $date_formatted
