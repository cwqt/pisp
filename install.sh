#!/bin/bash
echo "Updating system"
sudo apt-get update
sudo apt-get dist-upgrade

echo "Installing Lua"
sudo apt-get install lua5.1 liblua5.1-0-dev luarocks openssl libssl-dev
sudo luarocks install luarocks
sudo luarocks install luasec

echo "Installing rpi-gpio"
sudo apt-get install python-rpi.gpio python3-rpi.gpio

echo "Installing RPi.GPIO.Lua"
sudo luarocks install rpi-gpio
sudo luarocks install darksidesync
sudo luarocks install copas

echo "Installing keypress simulator + debugging"
sudo apt-get install xdotool xev

echo "Compiling LÖVE from source"
sudo apt-get install build-essential autotools-dev automake libtool pkg-config libdevil-dev libfreetype6-dev libluajit-5.1-dev libphysfs-dev libsdl2-dev libopenal-dev libogg-dev libvorbis-dev libflac-dev libflac++-dev libmodplug-dev libmpg123-dev libmng-dev libturbojpeg libtheora-dev
sudo apt-get install libturbojpeg0 # yes, ...0
cd ~/Downloads/ || return
wget "https://bitbucket.org/rude/love/downloads/love-0.10.2-linux-src.tar.gz"
tar -xvzf love*
cd love*
./configure
make

echo "Creating LÖVE directory"
mkdir ~/.local/share/love/

echo "Installing love-imgui"
sudo apt-get install cmake luajit-5.1
cd ~/ || return
git clone https://github.com/slages/love-imgui.git
cd love-imgui/ || return
cmake ./
make
mv imgui.so ~/.local/share/love/

echo "Installing PiSPOS"
cd ~/ || return
git clone https://github.com/twentytwoo/PiSP.git

echo "Installation complete"
