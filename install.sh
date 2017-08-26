#!/bin/bash.
# I have no idea if this works
echo "Updating system"
sudo apt-get update
sudo apt-get dist-upgrade

echo "Installing Lua"
sudo apt-get install lua5.1
sudo apt-get install liblua5.1-0-dev
sudo apt-get install luarocks
sudo apt-get install openssl
sudo apt-get install libssl-dev
sudo luarocks install luarocks
sudo luarocks install luasec

echo "Installing rpi-gpio"
sudo apt-get install python-rpi.gpio python3-rpi.gpio

echo "Installing RPi.GPIO.Lua"
sudo luarocks install rpi-gpio
sudo luarocks install darksidesync
sudo luarocks install copas

echo "Installing keypress simulator + debugging"
sudo apt-get install xdotool
sudo apt-get install xev

echo "Installing LÖVE"
sudo apt-get install love

echo "Creating LÖVE directory"
mkdir ~/.local/share/love/

echo "Installing love-imgui"
cd ~/ || return
git clone https://github.com/slages/love-imgui.git
cd love-imgui/ || return
cmake
make
mv imgui.so ~/.local/share/love/

echo "Installing PiSPOS"
cd ~/ || return
git clone https://github.com/twentytwoo/PiSP.git

echo "Installation complete"