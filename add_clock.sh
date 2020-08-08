#!/bin/bash

for i in {1..20}; do
    a=$(gsettings get org.gnome.gnome-panel.layout object-id-list)
    echo "$i) $a"
    if [[ $a == *"menu"* ]]; then
        gsettings set org.gnome.desktop.interface clock-show-date true
        gsettings set org.gnome.desktop.interface clock-show-seconds true
        gsettings set com.canonical.indicator.datetime time-format 24-hour
        gsettings set org.gnome.gnome-panel.object:/org/gnome/gnome-panel/layout/objects/clock-applet/ object-iid 'ClockAppletFactory::ClockApplet'
        gsettings set org.gnome.gnome-panel.object:/org/gnome/gnome-panel/layout/objects/clock-applet/ toplevel-id 'top-panel'
        gsettings set org.gnome.gnome-panel.object:/org/gnome/gnome-panel/layout/objects/clock-applet/ pack-type 'end'
        gsettings set org.gnome.gnome-panel.object:/org/gnome/gnome-panel/layout/objects/clock-applet/ pack-index '0'
        gsettings set org.gnome.gnome-panel.layout object-id-list "[`gsettings get org.gnome.gnome-panel.layout object-id-list  | awk '{ gsub("\[|\]",""); print;}'`, 'clock-applet']"
        a=$(gsettings get org.gnome.gnome-panel.layout object-id-list)
        echo "result $a"
        break
    fi
    sleep 1
done
