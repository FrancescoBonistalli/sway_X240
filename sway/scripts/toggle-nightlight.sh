#!/bin/bash

if pgrep -x wlsunset > /dev/null; then
    pkill -x wlsunset
else
    wlsunset -t 3999 -T 4000 &
    disown
fi
