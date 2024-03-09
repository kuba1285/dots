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

# set some colors
function set_colors() {
    if [ -t 1 ]; then
        RED=$(tput setaf 1)
        GREEN=$(tput setaf 2)
        YELLOW=$(tput setaf 3)
        CYAN=$(tput setaf 6)
        BOLD=$(tput bold)
        RESET=$(tput sgr0)
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
function show_progress() {
    while ps | grep $1 &> /dev/null ; do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
function install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo  "${GREEN}OK${RESET} - $1 is already installed."
    else
        # no package found so installing
        echo -n "${CYAN}NOTE${RESET} - Now installing $1 ."
        yay -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        
        # test to make sure package installed
        if yay -Q $1 &>> /dev/null ; then
            echo "${GREEN}OK${RESET} - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo "${RED}ERROR${RESET} - $1 install had failed, please check install.log"
            exit
        fi
    fi
}

# function for install app from list
function install_list() {
    if [[ -f "$1" ]] ; then
        echo "${CYAN}NOTE${RESET} - Installing applications from $1..."
        while IFS= read -r app ; do
            install_software "$app"
        done < "$1"
    else
        echo "${RED}ERROR${RESET} - applications list not found: $1"
    fi
}

function wait_yn(){
    YN="xxx"
    while [ $YN != 'y' ] && [ $YN != 'n' ] ; do
        read -p "$1 [y/n]" YN
    done
}
######

clear
set_colors

# give the user an option to exit
wait_yn "${YELLOW}ACITION${RESET} - Would you like to start with the install?"
if [[ $YN = y ]] ; then
    echo "${CYAN}NOTE${RESET} - Setup starting..."
    sudo touch /tmp/hyprv.tmp
else
    exit
fi

# Check for package manager
if [ ! -f /sbin/yay ] ; then  
    echo -n "${CYAN}NOTE${RESET} - Configuering yay."
    cd
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay
    makepkg -si --noconfirm &>> $INSTLOG &
    show_progress $!
    cd
    rm -rf yay
    if [ -f /sbin/yay ] ; then
        echo "${GREEN}OK${RESET} - yay configured"
        cd ..
        echo -n "${CYAN}NOTE${RESET} - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo "${GREEN}OK${RESET} - yay updated."
    else
        echo "${RED}ERROR${RESET} - yay install failed, please check the install.log"
        exit
    fi
fi

# Install listed pacakges
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install apps from the list?"
if [[ $YN = y ]] ; then
    install_list $LISTAPP
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to install custom apps from the list?"
if [[ $YN = y ]] ; then
    install_list $LISTCUSTOM
fi

# Setup Nvidia if it was found
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia ; then
    install_list $LISTNVIDIA
    source $BIN/nvidia.sh
fi

# Install custom app
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install custom app?"
if [[ $YN = y ]] ; then
    source $BIN/custom.sh &>> $INSTLOG &
    show_progress $!
    echo "${GREEN}OK${RESET} - Installed."
fi

# Install MBP audio driver
wait_yn "${YELLOW}ACITION${RESET} - Would you like to install MBP audio driver?"
if [[ $YN = y ]] ; then
    cd
    git clone https://github.com/davidjo/snd_hda_macbookpro.git &>> $INSTLOG
    cd snd_hda_macbookpro/
    sudo ./install.cirrus.driver.sh &>> $INSTLOG &
    show_progress $!
    cd
    rm -rf snd_hda_macbookpro
    echo "${GREEN}OK${RESET} - Installed."
fi

# Copy Config Files
wait_yn "${YELLOW}ACITION${RESET} - Would you like to copy config files?"
if [[ $YN = y ]] ; then
    cp -rT $PARENT/. ~/ &>> $INSTLOG &
    show_progress $!
    echo "${GREEN}OK${RESET} - Done."
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to stage the original file?"
if [[ $YN = y ]] ; then
    source $BIN/stage.sh &>> $INSTLOG &
    show_progress $!
    echo "${GREEN}OK${RESET} - Done."
fi

wait_yn "${YELLOW}ACITION${RESET} - Would you like to write to the config files?"
if [[ $YN = y ]] ; then
    source $BIN/write.sh &>> $INSTLOG &
    show_progress $!
    echo "${GREEN}OK${RESET} - Done."
fi

# Enable services
wait_yn "${YELLOW}ACITION${RESET} - Would you like to write to enable services?"
if [[ $YN = y ]] ; then
    for service in ${SERVICES[@]} ; do
        sudo systemctl enable $service --now &>> $INSTLOG
        sleep 2
    done
fi

sudo gpasswd -a $USER input
chsh -s $(which zsh) $USER
fc-cache -fv &>> $INSTLOG

echo "${CYAN}NOTE${RESET} - Script had completed!"
