#!/bin/bash

grep -q "TearFree" /etc/X11/xorg.conf.d/20-intel.conf ||
cat << EOF | sudo tee -a /etc/X11/xorg.conf.d/20-intel.conf
GSection "Device"
Identifier "Intel Graphics"
Driver "intel"
Option "TearFree" "true"
EndSection
EOF

grep -q "xinput set-prop 11 318 1" ~/.xsessionrc ||
touch ~/.xsessionrc
cat << EOF | tee -a ~/.xsessionrc
xinput set-prop 11 318 1
xinput --set-prop "Apple SPI Touchpad" "Coordinate Transformation Matrix" 4 0 0 0 4 0 0 0 1
EOF
