#!/bin/bash

# Define variables
BIN=$(cd $(dirname $0); pwd)
PARENT=$(cd $(dirname $0)/../; pwd)
INSTLOG="$BIN/install.log"
LISTAPP="$BIN/list-app"
LISTCUSTOM="$BIN/list-custom"
LISTNVIDIA="$BIN/list-nvidia"
SERVICES=(
    sddm
    bluetooth
    tlp
    mbpfan
)
######

# set some colors
set_colors() {
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        CYAN=$(printf '\033[36m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null ; do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo -e "${GREEN}OK${RESET} - $1 is already installed."
    else
        # no package found so installing
        echo -en "${CYAN}NOTE${RESET} - Now installing $1 ."
        yay -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        
        # test to make sure package installed
        if yay -Q $1 &>> /dev/null ; then
            echo -e "${GREEN}OK${RESET} - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "${RED}ERROR${RESET} - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# function for install app from list
install_list() {
    if [[ -f "$1" ]] ; then
        echo -e "${CYAN}NOTE${RESET} - Installing applications from $1..."
        while IFS= read -r app ; do
            install_software "$app"
        done < "$1"
    else
        echo -e "${RED}ERROR${RESET} - applications list not found: $1"
    fi
}

wait_yn(){
    YN="xxx"
    while [ $YN != 'y' ] && [ $YN != 'n' ] ; do
        read -p "$1 [y/n]" YN
    done
}
######

clear
set_colors

# give the user an option to exit out
wait_yn "${YELLOW}ACITION${RESET} - Would you like to start with the install?"
if [[ $YN = y ]] ; then
    echo -e "${CYAN}NOTE${RESET} - Setup starting..."
    sudo touch /tmp/hyprv.tmp
else
    echo -e "${CYAN}NOTE${RESET} - This script will now exit, no changes were made to your system."
    exit
fi

# Disable wifi powersave mode
wait_yn "${YELLOW}ACITION${RESET} - Would you like to disable WiFi powersave?"
if [[ $YN = y ]] ; then
LOC="/etc/NetworkManager/conf.d/wifi-powersave.conf"
    echo -e "${CYAN}NOTE${RESET} - The following file has been created $LOC.\n"
    echo -e "[connection]\nwifi.powersave = 2" | sudo tee -a $LOC &>> $INSTLOG
    echo -en "${CYAN}NOTE${RESET} - Restarting NetworkManager service, Please wait."
    sleep 2
    sudo systemctl restart NetworkManager &>> $INSTLOG
    
    # wait for services to restore (looking at you DNS)
    for i in {1..6} ; do
        echo -n "."
        sleep 1
    done
    echo -en "Done!\n"
    sleep 2
    echo -e "${GREEN}OK${RESET} - NetworkManager restart completed."
fi

# Check for package manager
if [ ! -f /sbin/yay ] ; then  
    echo -en "${CYAN}NOTE${RESET} - Configuering yay."
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay
    makepkg -si --noconfirm &>> $INSTLOG &
    show_progress $!
    if [ -f /sbin/yay ] ; then
        echo -e "${GREEN}OK${RESET} - yay configured"
        cd ..
        
        # update the yay database
        echo -en "${CYAN}NOTE${RESET} - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo -e "${GREEN}OK${RESET} - yay updated."
    else
        # if this is hit then a package is missing, exit to review log
        echo -e "${RED}ERROR${RESET} - yay install failed, please check the install.log"
        exit
    fi
fi

# find the Nvidia GPU
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia ; then
    ISNVIDIA=true
else
    ISNVIDIA=false
fi

# Install listed pacakges
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install the packages?"
if [[ $YN = y ]] ; then
echo -e "${CYAN}NOTE${RESET} - Installing needed components, this may take a while..."
    install_list $LISTAPP
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to install custom applications from a list?"
if [[ $YN = y ]] ; then
    install_list $LISTCUSTOM
fi

# Setup Nvidia if it was found
if [[ "$ISNVIDIA" == true ]] ; then
    echo -e "${CYAN}NOTE${RESET} - Nvidia GPU support setup stage, this may take a while..."
    install_list $LISTNVIDIA

    # update config
    sudo sed -i 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio --config /etc/mkinitcpio.conf --generate /boot/initramfs-custom.img
    echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf &>> $INSTLOG
    echo -e "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a /etc/environment
    echo -e "\nsource = ~/.config/hypr/nvidia.conf" >> ~/.config/hypr/hyprland.conf

    # check for hyprland and remove it so the -nvidia package can be installed
    if yay -Q hyprland &>> /dev/null ; then
    
        # Install the correct hyprland version
        echo -e "${CYAN}NOTE${RESET} - Installing Hyprland, this may take a while..."
        
        yay -R --noconfirm hyprland &>> $INSTLOG &
        install_software hyprland-nvidia
    fi
fi

# forking by desktop environment
#case "$(neofetch de)" in  
#    *Aqua* ) echo aqua ;;
#esac

# Copy Config Files
wait_yn "${YELLOW}ACITION${RESET} - Would you like to copy config files?"
if [[ $YN = y ]] ; then
    echo -e "${CYAN}NOTE${RESET} - Copying config files..."

    # copy the configs directory
    cp -rT $PARENT/. ~/ &>> $INSTLOG
fi

# Activate zsh
wait_yn "${YELLOW}ACITION${RESET} - Would you like to activate zsh?"
if [[ $YN = y ]] ; then
    echo -e "${CYAN}NOTE${RESET} - ZSH, Engage!"
    chsh -s $(which zsh)
fi

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

# Font install for Rofi 
echo -e "${CYAN}NOTE${RESET} - Adding Fonts for Rofi"
sudo mkdir $HOME/.local/share/fonts
sudo cp $PARENT/src/Icomoon-Feather.ttf $HOME/.local/share/fonts

# Copy the SDDM theme
echo -e "${CYAN}NOTE${RESET} - Setting up the login screen."
sudo tar -xf $PARENT/src/sugar-candy.tar.gz -C /usr/share/sddm/themes/
sudo chown -R $USER:$USER /usr/share/sddm/themes/sugar-candy
sudo mkdir /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sugar-candy" | sudo tee -a /etc/sddm.conf.d/10-theme.conf

# Clean out other portals
echo -e "${CYAN}NOTE${RESET} - Cleaning out conflicting xdg portals..."
yay -R --noconfirm xdg-desktop-portal-gnome xdg-desktop-portal-gtk &>> $INSTLOG

# Enable services
for SERVICE in ${SERVICES[@]} ; do
    sudo systemctl enable $SERVICE --now &>> $INSTLOG
    sleep 2
done

# Install MBP audio driver
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install MBP audio driver?"
if [[ $YN = y ]] ; then
    echo -e "${CYAN}NOTE${RESET} - Installing driver, this may take a while..."
    cd
    git clone https://github.com/davidjo/snd_hda_macbookpro.git &>> $INSTLOG
    cd snd_hda_macbookpro/

    # run the following command as root or with sudo
    sudo ./install.cirrus.driver.sh &>> $INSTLOG
    show_progress $!
fi

source $BIN/write.sh
sudo gpasswd -a $USER input
fc-cache -fv &>> $INSTLOG

# Script is done
echo -e "${CYAN}NOTE${RESET} - Script had completed!"
