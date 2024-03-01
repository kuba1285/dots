#!/bin/bash

# update config
sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
echo -e "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment

# check for hyprland and remove it so the -nvidia package can be installed
if yay -Q hyprland &>> /dev/null ; then

  # Install the correct hyprland version
  yay -R --noconfirm hyprland &>> $INSTLOG
  yay -S --noconfirm hyprland-nvidia &>> $INSTLOG
  echo -e "\nsource = ~/.config/hypr/nvidia.conf" >> ~/.config/hypr/hyprland.conf
fi
