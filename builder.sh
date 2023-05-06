#!/bin/bash

sudo apt install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen 
sudo pacman --needed --noconfirm -S base-devel cmake unzip ninja tree-sitter curl

git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_YPE=RelWithDebInfo
git checkout release-0.9
git pull && git submodule update --init --recursive

make install

mv ./build/bin/nvim /usr/bin/nvim
