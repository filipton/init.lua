#!/bin/bash

sudo apt install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl doxygen
sudo pacman --needed -S base-devel cmake unzip ninja tree-sitter curl

git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_YPE=RelWithDebInfo
make install

mv ./build/bin/nvim /usr/bin/nvim

git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim
