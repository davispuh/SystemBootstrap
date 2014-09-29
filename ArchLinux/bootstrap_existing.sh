#!/bin/bash
#
# ArchLinux Installation Bootstrapping from Existing Linux
#
#
#
# Launch ./bootstrap_existing.sh install
#
#

CDIR=`pwd`
SCRIPT=`realpath $0`
TMP=/tmp

MAINMIRROR="https://mirrors.kernel.org/"
VERSION="2014.09.03"
ARCH="i686"
LOCATION="$MAINMIRROR/archlinux/iso/$VERSION"
BOOTSTRAP="archlinux-bootstrap-$VERSION-$ARCH.tar.gz"
SIGNATURE="$BOOTSTRAP.sig"
KEYID='0x9741E8AC'


SHASUM='79363c3f64f530775a225ba515582baac46057e7b9d509de58ededcc5944d9421d54547d89d4a86421d71d02abe00aa6ec29773c50f38b6a448ca6e2960bf3b2'


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

    ###
    # Check for tools
    CHECK_NOTFOUND=""

    CHECK_TOOL="curl"
    CHECK_COMMAND="curl --version"
    `$CHECK_COMMAND &> /dev/null`
    if [ $? -ne 0 ]; then
        CHECK_NOTFOUND="$CHECK_NOTFOUND $CHECK_TOOL"
    fi

    CHECK_TOOL="gpg"
    CHECK_COMMAND="gpg --version"
    `$CHECK_COMMAND &> /dev/null`
    if [ $? -ne 0 ]; then
        CHECK_NOTFOUND="$CHECK_NOTFOUND $CHECK_TOOL"
    fi

    CHECK_TOOL="tar"
    CHECK_COMMAND="tar --version"
    `$CHECK_COMMAND &> /dev/null`
    if [ $? -ne 0 ]; then
        CHECK_NOTFOUND="$CHECK_NOTFOUND $CHECK_TOOL"
    fi

    if [ ! -z "$CHECK_NOTFOUND" ]; then
        echo "ERROR! The following tools weren't found: $CHECK_NOTFOUND" >&2
        exit 1
    fi
    ###

    cd $TMP

    #
    # Download the bootstrap image from a mirror
    #
    curl -O $LOCATION/$BOOTSTRAP
    curl -O $LOCATION/$SIGNATURE

    gpg -q --no-verbose --refresh-keys > /dev/null >&2
    gpg -q --no-verbose --recv-keys "$KEYID"
    gpg -q --no-verbose --verify $SIGNATURE
    if [ $? -ne 0 ]; then
        echo "ERROR! Failed to verify signature of $SIGNATURE" >&2
        exit 1
    fi

    #
    # Extract the tarball
    #
    tar xzf $BOOTSTRAP
    rm -f $BOOTSTRAP $SIGNATURE
    cd "root.$ARCH"

    # Copy bootstrap script
    cp -L $CDIR/bootstrap.sh ./root/bootstrap.sh

    #############################################
    #
    # 2.8 Chroot and configure the base system
    #
    if [ ! -d /dev/shm ]; then
        mkdir -p /tmp/shm
        ln -s /tmp/shm /dev/shm
    fi
    
    echo 'pacman-key --init
pacman-key --populate archlinux
echo "2.3 Prepare the storage drive"
echo "2.4 Mount the partitions"
echo "Now launch /root/bootstrap.sh install"
' > ./root/init.sh
    chmod +x ./root/init.sh

    exec 2>&3

    ./bin/arch-chroot ./ /bin/bash -c "/root/init.sh && /bin/bash"
    if [ $? -ne 0 ]; then
        mount --rbind /proc proc
        mount --rbind /sys sys
        mount --rbind /dev dev
        mount --rbind /run run
        /bin/cp -f /etc/resolv.conf etc
        chroot ./ /bin/bash -c "/root/init.sh && /bin/bash"
    fi


    echo
    echo "Done! Now you should reboot!"

else

    echo "To start installation, type"
    echo "$0 install"

fi
