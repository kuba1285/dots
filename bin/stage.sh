#!/bin/bash

# make files exec
chmod +x ~/.config/hypr/scripts/*

# stage the .desktop file
WLDIR=/usr/share/wayland-sessions
if [ ! -d "$WLDIR" ] ; then
    sudo mkdir $WLDIR
fi 
sudo cp $PARENT/src/hyprland.desktop $WLDIR

# add VScode extensions
echo -e "${CYAN}NOTE${RESET} - Adding VScode Extensions"
mkdir ~/.vscode
tar -xf $PARENT/src/extensions.tar.gz -C ~/.vscode/

# Copy the SDDM theme
echo -e "${CYAN}NOTE${RESET} - Setting up the login screen."
sudo tar -xf $PARENT/src/sugar-candy.tar.gz -C /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sugar-candy
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee -a /etc/sddm.conf.d/10-theme.conf

# Clean out other portals
echo -e "${CYAN}NOTE${RESET} - Cleaning out conflicting xdg portals..."
yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG
