# PiSP
Open-source PSP like console.

- EasyEDA schematics
- pipaOS w/ fbtft & PiSPWM

![PiSP](PiSP.gif)

## Installation
kind of outdated
```
cd PiSP
chmod +x install.sh
./install.sh
```
<<<<<<< HEAD

## fbtft
raspbian bloat comes with fbtft and x working, love fps is poor though

- install fbtft_device kernel module somehow
- enable spi (raspi-config)
- sudo modprobe fbtft_device name=adafruit22a rotate=270
- edit framebuffer to use /dev/fb1, check fbtft config for how...

## pilove
install pilove 0.4 image
lsblk, lists sd card
/dev/sdb = sd card, then
sudo cfdisk /dev/sdb
remove all partitions then copy image over
sudo dd bs=4M if=pilove...image.iso of=/dev/sdb conv=fsync
dd takes a while
=======
>>>>>>> fec599cb4d92673bcefe54ef871cc88faccd7848
