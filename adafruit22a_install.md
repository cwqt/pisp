### create pipaOS image
sudo dd if of pilove onto sd
move sd into pi3b
use ethernet to rpi-update
reboot

move sd into pi zero
sudo nano /boot/interfaces
if interfaces.txt cp to interfaces
change to wifi essid/passphrase
sudo reboot

### fbtft drivers should now also be installed
enable SPI via sudo pipaos-config
edit /boot/cmdline.txt
add fbcon=map:10 to end --if not using love
sudo apt-get install kbd
sudo dpkg-reconfigure console-setup
	Encoding to use on the console: <UTF-8>
	Character set to support: <Guess optimal character set>
	Font for the console: Terminus (default is VGA)
	Font size: 6x12 (framebuffer only)

### framebuffer mirroring fb0 (love SDL) onto fb1 (not using now)
sudo apt-get install cmake
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp/
mkdir build
cd build/
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp

### enable fbtft and initialse
sudo modprobe fbtft dma -- probs dont need
sudo modprobe fbtft_device name=adafruit22a rotate=270 debug=32

### overclock the shit out of it
sudo pipaos-config
- overclock
- turbo
reboot

### begin mirroring
fbcp &

### install PiSP stuff
git clone PiSP
cd PiSP
chmod +x install.sh
./install.sh

make sure to remove fbcon map from cmdline when using love else the console from fb1 will show through into the fb mirror

sudo modprobe fbtft dma
sudo modprobe fbtft_device name=adafruit22a rotate=270 fps=60 speed=48000000 -- gives approx 20fps