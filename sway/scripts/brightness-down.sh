#!/bin/bash

current=$(brightnessctl get)
max=$(brightnessctl max)
min=$((max * 5 / 100))

if [ "$current" -gt "$min" ]; then
    brightnessctl set 5%-
fi
