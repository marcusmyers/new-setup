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

# This function will download a DMG from a URL, mount it, find
# the `pkg` in it, install that pkg, and unmount the package.
function install_dmg() {
  local name="$1"
  local url="$2"
  local target="$3"
  local dmg_path=$(mktemp -t ${name}_dmg)

  if [ ! -z "$target" ]; then
    target="/"
  fi 

  echo "Installing: ${name}"

  # Download the package into the temporary directory
  echo "-- Downloading DMG..."
  curl -L -o ${dmg_path} ${url} 2>/dev/null

  chmod 777 ${dmg_path}

  # Mount it
  echo "-- Mounting DMG..."
  local plist_path=$(mktemp -t nacs_mac_bootstrap)
  hdiutil attach -plist ${dmg_path} > ${plist_path}
  mount_point=$(grep -E -o '/Volumes/[-.a-zA-Z0-9]+' ${plist_path})

  # Install. It will be the only pkg in there, so just find any pkg
  echo "-- Installing pkg..."
  pkg_path=$(find ${mount_point} -name '*.pkg' -mindepth 1 -maxdepth 1)
  installer -pkg ${pkg_path} -target ${target} >/dev/null

  # Unmount
  echo "-- Unmounting and ejecting DMG..."
  hdiutil eject ${mount_point} >/dev/null
}

# Make sure XCode Command Line Tools are installed
# before we do anything else - install if not
if ! type -p gcc > /dev/null; then
    echo -e "\xe2\x9c\x97 You Do NOT have XCode Command Line Tools installed.  Installing now"
    xcode-select --install
fi

# Check if PHP is installed
#if ! type -p php > /dev/null; then
    echo -e "\xe2\x9c\x97 Installing latest version of php now"
    curl -s http://php-osx.liip.ch/install.sh | bash -s 5.6
    echo -e "\xe2\x9c\x93 PHP is installed"
#fi

# Check if Composer is installed
if ! type -p composer > /dev/null; then
  echo "--- Installing Composer..."
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  
  echo -e "\xe2\x9c\x93 Composer is installed"
fi

# Check if VritualBox is installed
# if not install it
if ! type -p vboxmanage > /dev/null; then
  echo "--- Installing VirtualBox..."
  install_dmg "VirtualBox" ${VIRTUALBOX_URL}
  curl -O ${VBOX_EXTPACK_URL}
  VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_PATCH}.vbox-extpack
  echo -e "\xe2\x9c\x93 VirtualBox is installed"
  rm ./Oracle_VM_VirtualBox_Extension_Pack-${VBOX_VERSION}-${VBOX_PATCH}.vbox-extpack
fi

# Check if Vagrant is installed
# if not install it
if ! type -p vagrant > /dev/null; then
  echo "--- Installing Vagrant..."
  install_dmg "Vagrant" ${VAGRANT_URL}
  echo -e "\xe2\x9c\x93 Vagrant is installed"
fi

# Check if Atom is installed
# if not install it
if [ ! -d "/Applications/Atom.app" ]; then
  echo "--- Installing Atom..."
  curl -O ${ATOM_URL}
  unzip atom-mac.zip
  mv Atom.app /Applications/Atom.app
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

# Check if Homebrew is installed and then install all
# ruby pre-requisites 
if ! type -p brew > /dev/null; then
  echo "--- Installing Homebrew.."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
  brew tap homebrew/dupes
  brew install nano rbenv ruby-build 
  rbenv init 
  echo -e "\xe2\x9c\x93 Homebrew is installed"
fi

# Install Ruby Version
echo "--- Installing Ruby ${RUBY_VERSION}..."
rbenv install ${RUBY_VERSION}
echo -e "\xe2\x9c\x93 Ruby ${RUBY_VERSION} is installed"

# Install bash completion for Mac OS X
brew install bash-completion

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
echo "--- Installing rake gem..."
gem install rake
echo -e "\xe2\x9c\x93 rake is installed"
echo "--- Installing bundler gem..."
gem install bundler
echo -e "\xe2\x9c\x93 bundler is installed"
echo "--- Installing aws-sdk gem..."
gem install aws-sdk
echo -e "\xe2\x9c\x93 aws-sdk is installed"


