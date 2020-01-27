#!/bin/bash
brew install neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim
ln -s nvim ~/.config/nvim
ln -s zshrc/.zshrc ~/.zshrc
