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
RUBY_VERSION=${RUBY_VERSION:-"2.1.5"}
VAGRANT_VERSION=${VAGRANT_VERSION:-"1.7.2"}
VBOX_VERSION=${VBOX_VERSION:-"4.3.20"}
VBOX_PATCH=${VBOX_PATCH:-"96996"}
VBOX_EXTPACK_URL=${VBOX_EXTPACK_URL:-"http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_PATCH}.vbox-extpack"}
NODE_PACKAGE_URL=${NODE_PACKAGE_URL:-"http://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}.pkg"}
VIRTUALBOX_URL=${VIRTUALBOX_URL:-"http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VirtualBox-${VBOX_VERSION}-${VBOX_PATCH}-OSX.dmg"}
VAGRANT_URL=${VAGRANT_URL:-"https://dl.bintray.com/mitchellh/vagrant/vagrant_${VAGRANT_VERSION}.dmg"}
ATOM_URL=${ATOM_URL:-"https://atom.io/download/mac"}

# Make sure XCode Command Line Tools are installed
# before we do anything else - install if not
if ! type -p gcc > /dev/null; then
    echo -e "\xe2\x9c\x97 You Do NOT have XCode Command Line Tools installed.  Installing now"
    xcode-select --install
fi

# Check if Homebrew is installed and then install all
# ruby pre-requisites 
if ! type -p brew > /dev/null; then
  echo "--- Installing Homebrew.."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
  sleep 5
  brew update
  sleep 5
  brew tap homebrew/dupes
  sleep 5
  brew install nano rbenv ruby-build mysql 
  sleep 5
  rbenv init 
  echo -e "\xe2\x9c\x93 Homebrew is installed"
fi

# Install Ruby Version
echo "--- Installing Ruby ${RUBY_VERSION}..."
rbenv install ${RUBY_VERSION}
echo -e "\xe2\x9c\x93 Ruby ${RUBY_VERSION} is installed"
rbenv global ${RUBY_VERSION}

# Install bash completion for Mac OS X
brew install bash-completion

# Check if PHP is installed
if [ ! -d /usr/local/php5 ]; then
    echo -e "\xe2\x9c\x97 Installing latest version of php now"
    curl -s http://php-osx.liip.ch/install.sh | bash -s 5.6
    echo -e "\xe2\x9c\x93 PHP is installed"
fi

# Check if Composer is installed
if ! type -p composer > /dev/null; then
  echo "--- Installing Composer..."
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  
  echo -e "\xe2\x9c\x93 Composer is installed"
fi

# Check if VritualBox is installed
# if not install it
if [ ! -d /Applications/VirtualBox.app/ ]; then
  echo "--- Installing VirtualBox..."
  curl -OL ${VBOX_EXTPACK_URL}
  curl -OL ${VIRTUALBOX_URL} 
  hdiutil attach VirtualBox-${VBOX_VERSION}-${VBOX_PATCH}-OSX.dmg
  sleep 5
  $diskNum=$(diskutil list | grep 'VirtualBox' | grep -o 'disk[0-9]')
  sleep 10
  sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /
  sleep 5
  VBoxManage extpack install ./Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_PATCH}.vbox-extpack 
  hdiutil detach /dev/$diskNum
  rm ./VirtualBox-${VBOX_VERSION}-${VBOX_PATCH}-OSX.dmg
  echo -e "\xe2\x9c\x93 VirtualBox is installed"
fi

# Check if Vagrant is installed
# if not install it
if ! type -p vagrant > /dev/null; then
  echo "--- Installing Vagrant..."
  curl -OL ${VAGRANT_URL}
  hdiutil attach vagrant_${VAGRANT_VERSION}.dmg
  sleep 5
  $diskNum=$(diskutil list | grep 'Vagrant' | grep -o 'disk[0-9]')
  sudo installer -pkg /Volumes/Vagrant/Vagrant.pkg -target /
  sleep 10
  hdiutil detach /dev/$diskNum
  rm ./vagrant_${VAGRANT_VERSION}.dmg
  echo -e "\xe2\x9c\x93 Vagrant is installed"
  echo "--- Added all wanted/needed vagrant boxes..."
  vagrant box add laravel/homestead
  vagrant box add ubuntu/trusty64
fi

# Check if Atom is installed
# if not install it
if [ ! -d "/Applications/Atom.app" ]; then
  echo "--- Installing Atom..."
  curl -LO ${ATOM_URL}
  sleep 5
  mv mac ./atom-mac.zip
  sleep 5
  unzip atom-mac.zip
  sleep 5
  mv Atom.app /Applications/Atom.app
  sleep 5
  rm ./atom-mac.zip
  echo -e "\xe2\x9c\x93 Atom is installed"
fi 

# Check if node.js is installed
if ! type -p node > /dev/null; then
  echo "Attempting to install node from ${NODE_PACKAGE_URL}"
  curl -O ${NODE_PACKAGE_URL}
  sudo installer -pkg node-${NODE_VERSION}.pkg -target / >/dev/null  
  echo -e "\xe2\x9c\x93 Node is installed"
  rm node-${NODE_VERSION}.pkg
fi

# Clone Nano Syntax Highlighting Files
if [ ! -d "~/.nano" ]; then
    git clone https://github.com/marcusmyers/nanorc.git ~/.nano
#    ln -s ./.nano ../.nano
#    ln -s ./.nanorc ../.nanorc
    cp ./.nanorc ~/.nanorc
fi

echo "---Copy over alias and bash profile files..."
cp ./.bash_profile ~/
cp ./.aliases ~/
cp ./.bash_ps1 ~/
echo -e "\xe2\x9c\x93 Copied over aliases and bash profiles"


# Clone Unixorn Luggage and make
if [ ! -d "/usr/local/share/luggage" ]; then
  echo "--- Installing the luggage..."
  git clone https://github.com/unixorn/luggage.git
  cd luggage
  make bootstrap_files
  echo -e "\xe2\x9c\x93 luggage is installed"
fi

echo "---INSTALLING GEMS---"
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
echo "--- Installing bundler gem..."
gem install bundler
echo -e "\xe2\x9c\x93 bundler is installed"
echo "--- Installing aws-sdk gem..."
gem install aws-sdk
echo -e "\xe2\x9c\x93 aws-sdk is installed"


