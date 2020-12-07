#!/bin/bash
#
# make alarmpi image
#
# - http://archlinuxarm.org/platforms/armv6/raspberry-pi
# - http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
# - http://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
# - http://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-4
#

set -xe

NAME=${1:-ArchLinuxARM-rpi-latest}
#NAME=ArchLinuxARM-rpi-2-latest
#NAME=ArchLinuxARM-rpi-3-latest
#NAME=ArchLinuxARM-rpi-4-latest

echo '################## download image #######################'

wget http://os.archlinuxarm.org/os/${NAME}.tar.gz

if ! curl -sSL http://archlinuxarm.org/os/${NAME}.tar.gz.md5 | md5sum -c
then
    exit 1
fi

echo '################## install softwares ####################'

which mkfs.vfat || apt install -y dosfstools

echo '################## make partitions ######################'

# 1G   == 1073741824B == 2097152S
# 100M == 104857600B  == 204800S

# Method 1
dd if=/dev/zero of=${NAME}.img bs=1024 count=$((2*1024*1024))

# Method 2
#fallocate -l 1G ${NAME}.img

# Method 1
fdisk ${NAME}.img <<EOF
n
p
 
 
+200M
t
c
n
p
 
 
 
w
EOF

# Method 2
#parted --script ${NAME}.img \
#    unit S \
#    mklabel msdos \
#    mkpart primary fat32 2048 206847 \
#    mkpart primary ext4 206848 2097151

# Method 3 (alpha)
# sfdisk -d ${NAME}.img > alarmpi.out
# sfdisk -f ${NAME}.img < alarmpi.out

echo '################## make filesystems #####################'
 
LOOP=$(losetup -f --show ${NAME}.img)
partx -s ${LOOP}
partx -a ${LOOP}
 
mkfs.vfat -v -I ${LOOP}p1
mkfs.ext4 -v ${LOOP}p2

mkdir boot root
mount -v -t vfat ${LOOP}p1 boot
mount -v -t ext4 ${LOOP}p2 root

echo '################## copy files ###########################'
 
tar xzf ${NAME}.tar.gz -C root . >/dev/null 2>&1
sync
mv root/boot/* boot

if [ $NAME == "ArchLinuxARM-rpi-aarch64-latest" ]; then
    sed -i 's/mmcblk0/mmcblk1/g' root/etc/fstab
fi

umount boot root
rmdir boot root
partx -d ${LOOP}
losetup -d ${LOOP}

echo '################## make image ###########################'

zip ${NAME}.img.zip ${NAME}.img
gzip ${NAME}.img
chmod a+rw ${NAME}.img.gz

echo '################## done #################################'
