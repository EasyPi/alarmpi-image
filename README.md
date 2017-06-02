AlarmPi-Image
=============
 
[![](https://travis-ci.org/EasyPi/alarmpi-image.svg)](https://travis-ci.org/EasyPi/alarmpi-image)

Build ArchLinuxARM Image for RaspberryPi

Image                                 | Info
------------------------------------- | -------------------
[ArchLinuxARM-rpi-latest.img.gz][1]   | [raspberry-pi][4]
[ArchLinuxARM-rpi-2-latest.img.gz][2] | [raspberry-pi-2][5]
[ArchLinuxARM-rpi-3-latest.img.gz][3] | [raspberry-pi-3][6]

## How It Works

![](http://blog.hypriot.com/images/making-of-hypriotos/hypriotos-release.png)

## Flash Image

- Download image file
- Inject SD-card to PC
- Unmount filesystem
- Run `gunzip|dd` command
- Eject SD-card from PC

```bash
# For Pi0 and Pi1
gunzip -c ArchLinuxARM-rpi-latest.img.gz | dd of=/dev/mmcblk0 bs=4M

# For Pi2 and Pi3
gunzip -c ArchLinuxARM-rpi-2-latest.img.gz | dd of=/dev/mmcblk0 bs=4M
```

## Expand Filesystem

- Login via ssh (alarm:alarm)
- Swith to root (root:root)
- Recreate patition #2
- Reboot system
- Resize file system (/dev/mmcblk0p2)

```bash
fdisk /dev/mmcblk0
reboot
resize2fs /dev/mmcblk0p2
```

## Additional Configurations

- [ ] ssh
- [ ] wifi
- [ ] hostname
- [ ] locale
- [ ] timezone

[1]: https://github.com/EasyPi/alarmpi-image/releases/download/2017.06.01/ArchLinuxARM-rpi-latest.img.gz
[2]: https://github.com/EasyPi/alarmpi-image/releases/download/2017.06.01/ArchLinuxARM-rpi-2-latest.img.gz
[3]: https://github.com/EasyPi/alarmpi-image/releases/download/2017.06.01/ArchLinuxARM-rpi-3-latest.img.gz
[4]: http://archlinuxarm.org/platforms/armv6/raspberry-pi
[5]: http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
[6]: http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-3
