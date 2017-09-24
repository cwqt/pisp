#!/bin/bash
echo "Updating system"
sudo apt-get update
sudo apt-get dist-upgrade

echo "Installing keypress simulator + debugging"
sudo apt-get install xdotool xev

echo "Creating LÖVE directory"
mkdir ~/.local/share/love/

echo "Installing love-imgui"
sudo apt-get install cmake luajit-5.1
cd ~/ || return
git clone https://github.com/slages/love-imgui.git
cd love-imgui/ || return
cmake ./
make
cp imgui.so ~/.local/share/love/imgui.so
cp imgui.so /usr/local/games/love*/src/imgui.so

echo "Installing fbcp"
sudo apt-get install cmake
git clone https://github.com/tasanakorn/rpi-fbcp
cd rpi-fbcp/
mkdir build
cd build/
cmake ..
make
sudo install fbcp /usr/local/bin/fbcp

echo "Making fbtft/fbcp autostart"




echo "Installation complete"
