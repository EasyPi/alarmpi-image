#!/bin/bash
#
# flash image to device
#

set -e

if [[ $(uname -s) != "Darwin" ]]
then
    echo "Only support MacOSX!"
    exit 4
fi

flash() {
    local IMG=${1?:image is missing}
    local DEV=${2?:device is missing}

    if [[ ! -f $IMG ]]
    then
        echo "No such image: $IMG"
        exit 1
    fi

    if [[ ! -b $DEV ]]
    then
        echo "No such device: $DEV"
        exit 2
    fi

    echo "+++ umount $DEV"
    diskutil umountDisk $DEV
    sleep 2

    echo "+++ write $IMG => $DEV"
    gzip -cd $IMG | pv | sudo dd of=/dev/r${DEV#/dev/} bs=32m
    sleep 2

    echo "+++ eject $DEV"
    diskutil eject $DEV
    sleep 2
}

main() {
    local IMAGES=($(ls *.img.gz))
    local DEVICES=($(diskutil list | awk '/\(external, physical\):$/ {print $1}'))
    local IMG DEV

    echo "=== SELECT IMAGE ==="

    if ((${#IMAGES[@]} == 0))
    then
        echo "No images to choose!"
        exit 1
    fi

    select IMG in "${IMAGES[@]}"
    do
        case $IMG in
            *.img.gz)
                break
                ;;
            *)
                echo "Select image failed!"
                exit 1
                ;;
        esac
    done

    echo "=== SELECT DEVICE ==="

    if ((${#DEVICES[@]} == 0))
    then
        echo "No devices to choose!"
        exit 2
    fi

    select DEV in "${DEVICES[@]}"
    do
        case $DEV in
            /dev/disk[0-9])
                break
                ;;
            *)
                echo "Select device failed!"
                exit 2
                ;;
        esac
    done

    echo "=== FLASH IMAGE TO DEVICE ==="
    echo
    echo "IMG: $IMG"
    echo "DEV: $DEV"
    echo
    read -p 'Do you want to continue? (Y/[N]): ' ANSWER

    if [[ $ANSWER == [Yy] ]]
    then
        flash $IMG $DEV
        exit 0
    else
        echo "Operation aborted!"
        exit 3
    fi
}

main
