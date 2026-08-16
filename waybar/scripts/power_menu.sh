#!/bin/bash
chosen=$(printf "Suspend\nHibernate\nReboot\nShutdown" | rofi -dmenu -p " Power")
case $chosen in
    Suspend)   systemctl suspend ;;
    Hibernate) systemctl hibernate ;;
    Reboot)    systemctl reboot ;;
    Shutdown)  systemctl poweroff ;;
esac
