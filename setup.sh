#!/bin/bash

#
# This file must be ran as root
#

# useful unicode chars:
#✓ \xe2\x9c\x93
#✗ \xe2\x9c\x97

# Make sure XCode Command Line Tools are installed
# before we do anything else - exit if not
if ! type -p gcc > /dev/null; then
    echo -e "\xe2\x9c\x97 You Do NOT have XCode Command Line Tools installed"
    exit 1
fi

# Check if PHP is installed
if ! type -p php > /dev/null; then
    curl -s http://php-osx.liip.ch/install.sh | bash -s 5.3
fi

# Check if Composer is installed
if ! type -p composer > /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
fi


# Check if Homebrew is installed and then install all
# ruby pre-requisites 
if ! type -p brew > /dev/null; then
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    brew install git ruby-build rbenv nodejs
fi

# Install bash completion for Mac OS X
brew install bash-completion
echo "Add the following lines to your ~/.bash_profile:"
echo "  if [ -f $(brew --prefix)/etc/bash_completion ]; then"
echo "    . $(brew --prefix)/etc/bash_completion"
echo "  fi"


# Clone Nano Syntax Highlighting Files
if [ ! -d "~/.nano" ]; then
    git clone https://github.com/marcusmyers/nanorc.git ./.nano
    ln -s ./.nano ../.nano
    ln -s ./.nanorc ../.nanorc
fi




# Link .bash_ps1 file
if [ ! -f "~/.bash_ps1" ]; then
    ln -s ./.bash_ps1 ../.bash_ps1
fi
