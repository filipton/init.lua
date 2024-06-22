#!/bin/bash

sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen ripgrep
sudo pacman --needed --noconfirm -S base-devel cmake unzip ninja tree-sitter curl ripgrep

sudo rm -f /usr/local/lib/nvim/parser/*

git clone https://github.com/neovim/neovim
cd neovim
#git checkout release-0.10
git pull && git submodule update --init --recursive

make CMAKE_BUILD_TYPE=Release
sudo make install
sudo mv ./build/bin/nvim /usr/bin/nvim
