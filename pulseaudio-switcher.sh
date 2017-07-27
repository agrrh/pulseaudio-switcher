#!/usr/bin/env bash

# Original found at:
# https://askubuntu.com/questions/4055/audio-output-device-fast-switch

sinks=($(pacmd list-sinks | grep index | \
    awk '{ if ($1 == "*") print "1"; else print "0" }'))
inputs=($(pacmd list-sink-inputs | grep index | awk '{print $2}'))

# Find active sink
active=0
for i in ${sinks[*]}
do
    if [ $i -eq 0 ]
        then active=$((active+1))
        else break
    fi
done

# Switch to next sink
swap=$(((active+1)%${#sinks[@]}))

pacmd set-default-sink $swap &> /dev/null
for i in ${inputs[*]}; do pacmd move-sink-input $i $swap &> /dev/null; done

# Get device name
IFS=";"
names=($(pacmd list-sinks | grep alsa.card_name | awk -F '"' '{print $2}' | tr '\n' ';'))
name="${names[$swap]}"

# Send notify
notify-send "Audio output switched" "$name" -i audio-card
