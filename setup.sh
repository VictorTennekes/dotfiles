# Error checking
if [ $# -eq 0 ] ; then
    echo "Error: specify a installation mode"
	echo "Available modes: 1. Spaceship 2. Geometry"
    exit 0
fi

# Configure the argument
mode=$1

if [ $mode == "spaceship" ]
then
	echo "Configuring spaceship prompt"
	ln -s zshrc/spaceship/.zshrc ~/.zshrc
elif [ $mode == "Configuring spaceship prompt" ]
then
	echo "Configuring geometry prompt"
	ln -s zshrc/geometry/.zshrc ~/.zshrc
else
	echo "Error: Invalid option"
fi

# Vim setup
ln -s nvim ~/.config/nvim

read -p "do you wanna install fonts? (Y/n)" fonts
if [ "$fonts" = "" ] || [ "$fonts" = "y" ]
then
	echo "Installing fonts"
	brew tap homebrew/cask-fonts
	brew cask install font-hack-nerd-font
	brew cask install font-jetbrains-mono
	brew cask install font-fira-code
fi
