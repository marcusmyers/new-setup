#!/bin/bash

#
# This file must be ran as root
#

# Make sure XCode Command Line Tools are installed
# before we do anything else - exit if not
if ! type -p gcc > /dev/null; then
    echo "You Do NOT have XCode Command Line Tools installed"
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


# Clone Nano Syntax Highlighting Files
if [ ! -d "~/.nano" ]; then
    git clone https://github.com/marcusmyers/nanorc.git ~/.nano
    mv ./.nanorc ../.nanorc
fi
