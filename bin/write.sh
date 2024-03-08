#!/bin/bash

cat << EOF >> ~/.zshrc
export PATH="\$PATH:/$HOME/bin"

neofetch
TMOUT=900
TRAPALRM() {
MODELS=(\$(ls -d /$HOME/bin/models/*))
SEC=\`date +%S\`
I=\$((SEC%\$(echo \${#MODELS[@]})+1))
3d-ascii-viewer -z 120 \${MODELS[\$I]}
}
EOF

grep -q "XMODIFIERS=@im=fcitx" /etc/environment ||
cat << EOF | sudo tee -a /etc/environment
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF

grep -q "IgnoreCarrierLoss=3s" /etc/systemd/network/*.network ||
cat << EOF | sudo tee -a /etc/systemd/network/*.network
IPv6PrivacyExtensions=true
IgnoreCarrierLoss=3s
EOF

sudo sed -i -e "/^ *#Color$/c\ Color\n\ ILoveCandy" /etc/pacman.conf
sudo sed -i -e "/^ *#DefaultTimeoutStartSec=90s/c\ DefaultTimeoutStartSec=10s" /etc/systemd/system.conf
sudo sed -i -e "/^ *#DefaultTimeoutStopSec=90s/c\ DefaultTimeoutStopSec=10s" /etc/systemd/system.conf
sudo sed -i -e '/^ *exec -a/c\exec -a "$0" "$HERE/chrome" "$@" --gtk-version=4 --ozone-platform-hint=auto --enable-gpu-rasterization --enable-zero-copy \
--enable-features=TouchpadOverscrollHistoryNavigation --disable-smooth-scrolling --enable-fluent-scrollbars' /opt/google/chrome/google-chrome

if [[ $XDG_SESSION_TYPE = x11 ]] ; then
  grep -q "bash ~/.config/polybar/scripts/wallpaper.sh" ~/.zshrc ||
  cat << EOF >> ~/.zshrc
bash ~/.config/polybar/scripts/wallpaper.sh
EOF

  grep -q "xinput set-prop 11 318 1" ~/.xsessionrc ||
  cat << EOF | tee -a ~/.xsessionrc
xinput set-prop 11 318 1
xinput --set-prop "Apple SPI Touchpad" "Coordinate Transformation Matrix" 4 0 0 0 4 0 0 0 1
EOF

  grep -q "CornerCoasting" /etc/X11/xorg.conf.d/51-synaptics-tweaks.conf ||
  cat << EOF | sudo tee -a /etc/X11/xorg.conf.d/51-synaptics-tweaks.conf
Section "InputClass"
  Identifier "touchpad"
  Driver "synaptics"
  MatchIsTouchpad "on"
    Option "Tapping" "True"
    Option "TappingDrag" "True"
    Option "DisableWhileTyping" "True"
    Option "CornerCoasting" "0"
    Option "CoastingSpeed" "20"
    Option "CoastingFriction" "50"
EndSection
EOF

  cat << EOF | tee ~/.config/fusuma/config.yml
swipe:
  4:
    left:
      sendkey: 'LEFTMETA+LEFTCTRL+RIGHT' # next
    right:
      sendkey: 'LEFTMETA+LEFTCTRL+LEFT'  # previous
threshold:
  swipe: 0.7
interval:
  swipe: 0.8
---
context:
  application:  Google-chrome
swipe:
  3:
    begin:
      command: xdotool keydown Ctrl # hold ctrl down
    right:
      update:
        command: xdotool key Tab  # press tab
        interval: 3
    left:
      update:
        command: xdotool key Shift+Tab # press shift+tab
        interval: 3
    end:
      command: xdotool keyup Ctrl  Ctrl # release ctrl
    up:
      sendkey: 'LEFTCTRL+T'    # new tab
      keypress:
        LEFTSHIFT: # when press shift down
          sendkey: 'LEFTSHIFT+LEFTCTRL+T' # open last closed tab
    down:
      sendkey: 'LEFTCTRL+W'    # close tab
---
context:
  application:  firefox
swipe:
  3:
    begin:
      command: xdotool keydown Ctrl # hold ctrl down
    right:
      update:
        command: xdotool key Tab  # press tab
        interval: 3
    left:
      update:
        command: xdotool key Shift+Tab # press shift+tab
        interval: 3
    end:
      command: xdotool keyup Ctrl  Ctrl # release ctrl
    up:
      sendkey: 'LEFTCTRL+T'    # new tab
      keypress:
        LEFTSHIFT: # when press shift down
          sendkey: 'LEFTSHIFT+LEFTCTRL+T' # open last closed tab
    down:
      sendkey: 'LEFTCTRL+W'    # close tab
EOF
fi
