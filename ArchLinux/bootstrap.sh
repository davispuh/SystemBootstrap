#!/bin/bash
#
# ArchLinux Installation Bootstrapping
#
#
#
# Manually boot Installation medium
#
# 2. Installation
#
# 2.2 Establish an internet connection
#
# 2.3 Prepare the storage drive
# 2.3.1 Choose a partition table type
# 2.3.2 Partitioning tool
# 2.3.3 Erase partition table
# 2.3.4 Partition scheme
# 2.3.6 Create filesystems
#
# 2.4 Mount the partitions
#
# Launch ./bootstrap.sh install
#
#

SCRIPT=`realpath $0`
ROOT="/mnt"


SHASUM='e7a248f829ceb8e1a4327cbbead8f61555de0439a1670dae6ee1c73b101d46ddcd5b6aef6428fc9f9d4407743c1d4d6d7174db64bf244da49741d475f7d527ce'


CLEAN="tr -d '\040\011\012\015'"


#################################################
#
# Installation start!
#

###
# Verify script's digest
cp $SCRIPT ./scripttmp

sed -i "0,/SHASUM=/{s/SHASUM=.*/SHASUM=''/}" ./scripttmp

`echo "$SHASUM  ./scripttmp" | sha512sum -c --status -`

if [ $? -ne 0 ]; then
    echo "ERROR! SHA checksum does not match for this script!" >&2
    echo "Possibly corrupted script!" >&2
    rm -f ./scripttmp
    exit 1
fi

rm -f ./scripttmp
###


if [ "$1" == "install" ]; then

    exec 3>&2
    exec 2> >(tee "$SCRIPT.log" >&2)

    mkdir -p $ROOT/tmp
    chmod -R 1777 $ROOT/tmp
    cd $ROOT

    #
    # 2.5 Select a mirror
    #
    
    echo 'Server = https://archlinux.limun.org/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
    echo 'Server = https://ftp.fau.de/archlinux/$repo/os/$arch' >> /etc/pacman.d/mirrorlist
    echo 'Server = https://archlinux.my-universe.com/$repo/os/$arch' >> /etc/pacman.d/mirrorlist

    #
    # 2.6 Install the base system
    #
    pacstrap ./ base base-devel
    if [ $? -ne 0 ]; then
        echo "ERROR! pacstrap  failed!" >&2
    fi

    #
    # 2.7 Generate an fstab
    #
    genfstab -U -p ./ >> ./etc/fstab

    # Copy itself bootstrap script
    cp -L -u $SCRIPT ./root/bootstrap.sh

    #############################################
    #
    # 2.8 Chroot and configure the base system
    #
    arch-chroot ./ /bin/bash -c "/root/bootstrap.sh chroot"

    #
    # 2.13 Unmount the partitions and reboot
    #
    echo
    echo "Done! Now you should reboot!"

elif [ "$1" == "chroot" ]; then

    exec 3>&2
    exec 2> >(tee "$SCRIPT.log" >&2)

    #
    # 2.8.1 Locale
    #
    
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    #
    # 2.8.2 Console font and keymap
    #
    echo "KEYMAP=us" > /etc/vconsole.conf
    echo "FONT=lat9w-16" >> /etc/vconsole.conf

    #
    # 2.8.3 Time zone
    #
    ln -s /usr/share/zoneinfo/Europe/Riga > /etc/localtime

    #
    # 2.8.4 Hardware clock
    #
    hwclock --systohc --utc

    #
    # 2.8.5 Kernel modules
    #
    

    #
    # 2.8.6 Hostname
    #
    echo "ArchLinux" > /etc/hostname
    # /etc/hosts

    ##############################################
    #
    # 2.9 Configure the network
    #
    echo '[Match]
Name=en*

[Network]
DHCP=yes' > /etc/systemd/network/dhcp.network

    ##############################################
    #
    # 2.10 Create an initial ramdisk environment
    #
    # @Config[:InitModules] > /etc/mkinitcpio.conf
    mkinitcpio -p linux


    ##############################################
    #
    # 2.12 Install and configure a bootloader
    #
    BOOTDEVICE=""

    FSTAB_MATCH="^(/dev/[a-z0-9]+) on (/[a-z0-9/]*) type ([a-z0-9]+)"
    while read -r line; do
        if [[ $line =~ $FSTAB_MATCH ]]; then
            FSTAB_DEVICE=${BASH_REMATCH[1]}
            FSTAB_PATH=${BASH_REMATCH[2]}
            if [ "$FSTAB_PATH" == "/boot" ]; then
                BOOTDEVICE=$FSTAB_DEVICE
            elif [ "$FSTAB_PATH" == "/" ] && [ -z "$BOOTDEVICE" ]; then
                BOOTDEVICE=$FSTAB_DEVICE
            fi
            FSTAB_UUID=`lsblk -f $FSTAB_DEVICE -o UUID -n`
        fi
    done <<< $"`mount | grep ^/dev/`"

    if [ -z "$BOOTDEVICE" ]; then
        echo "ERROR: Couldn't find boot device (typically /dev/sda)!" >&2
        exit 1
    fi

    

    #
    # 2.12.1.1 Syslinux
    #
    pacman --noconfirm -S syslinux

    
    syslinux-install_update -iam
    sed -i "s|root=/dev/sda3|root=$BOOTDEVICE|g" /boot/syslinux/syslinux.cfg
    

    


    ##############################################
    #
    # 3. Post-installation
    #
    
    pacman --noconfirm -S vim
    

    

    pacman --noconfirm -Syyu

    #
    # 2.11 Set the root password
    #
    echo "Creating password for root!"
    passwd

    systemctl enable systemd-networkd.service
    systemctl enable systemd-resolved.service
    mv /etc/resolv.conf /etc/resolv.conf.old
    ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

else

    echo "To start installation, type"
    echo "$0 install"
    echo
    echo "Next stage will be started automatically (to be executed inside actuall system)"
    echo "$0 chroot"

fi
