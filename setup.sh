#!/bin/bash

#
# This file must be ran as root
#

# useful unicode chars:
#✓ \xe2\x9c\x93
#✗ \xe2\x9c\x97

#--------------------------------------------------------------------
# Modifiable variables, please set them via environmental variables.
#--------------------------------------------------------------------
NODE_VERSION=${NODE_VERSION:-"v0.10.36"}
NODE_PACKAGE_URL=${FACTER_PACKAGE_URL:-"http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.pkg"}

# Make sure XCode Command Line Tools are installed
# before we do anything else - install if not
if ! type -p gcc > /dev/null; then
    echo -e "\xe2\x9c\x97 You Do NOT have XCode Command Line Tools installed.  Installing now"
    xcode-select --install
fi

# Check if PHP is installed
if ! type -p php > /dev/null; then
    echo -e "\xe2\x9c\x97 PHP is not installed.  Installing now"
    curl -s http://php-osx.liip.ch/install.sh | bash -s 5.6
    echo -e "\xe2\x9c\x93 PHP is installed"
fi

# Check if Composer is installed
if ! type -p composer > /dev/null; then
    echo "### INSTALLING Composer ###"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
  
fi


# Check if node.js is installed
if ! type -p node > /dev/null; then
  curl -O ${NODE_PACKAGE_URL}
  installer -pkg node-${NODE_VERSION}.pkg -target / >/dev/null  
fi

# Check if Homebrew is installed and then install all
# ruby pre-requisites 
if ! type -p brew > /dev/null; then
    ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"
    brew tap homebrew/dupes
    brew install git nano 
fi

# Install bash completion for Mac OS X
brew install bash-completion
echo "Add the following lines to your ~/.bash_profile:"
echo "  if [ -f $(brew --prefix)/etc/bash_completion ]; then"
echo "    . $(brew --prefix)/etc/bash_completion"
echo "  fi"


# Clone Nano Syntax Highlighting Files
if [ ! -d "~/.nano" ]; then
    git clone https://github.com/marcusmyers/nanorc.git ~/.nano
#    ln -s ./.nano ../.nano
#    ln -s ./.nanorc ../.nanorc
    cp ./.nanorc ~/.nanorc
fi

echo "### INSTALLING GEMS ###"
echo "--- Installing librarian-puppet gem..."
gem install librarian-puppet
echo -e "\xe2\x9c\x93 librarian-puppet is installed"
echo "--- Installing beaker gem..."
gem install beaker
echo -e "\xe2\x9c\x93 beaker is installed"
echo "--- Installing tugboat gem..."
gem install tugboat
echo -e "\xe2\x9c\x93 tugboat is installed"
echo "--- Installing rspec-puppet gem..."
gem install rspec-puppet
echo -e "\xe2\x9c\x93 rspec-puppet is installed"
echo "--- Installing puppet-blacksmith gem..."
gem install puppet-blacksmith
echo -e "\xe2\x9c\x93 puppet-blacksmith is installed"
echo "--- Installing rake gem..."
gem install rake
echo -e "\xe2\x9c\x93 rake is installed"
echo "--- Installing bundler gem..."
gem install bundler
echo -e "\xe2\x9c\x93 bundler is installed"
echo "--- Installing aws-sdk gem..."
gem install aws-sdk
echo -e "\xe2\x9c\x93 aws-sdk is installed"
