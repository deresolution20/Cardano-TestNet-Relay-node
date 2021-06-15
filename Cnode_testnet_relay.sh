#!/bin/bash

echo "____________________________________________________________________________"
echo "This bash script will install the required libraries, ghcup and cabal. "
echo "It will then clone the cardano-node and build the cardano friends & family haskell node..."
echo "and has been tested on Ubuntu 20.04."
echo "The script comes with no warranty. Please exercise caution and use at your own risk."
echo "You should be at your desk to respond to prompts as they appear."
echo ""
echo ""
echo "____________________________________________________________________________"

echo "checking for updates/upgrades for your system"

#1. update/upgrade system
sudo apt update && sudo apt upgrade -y
echo ""
echo ""
sleep 5
echo "Installing the required libraries..." 

#2. get the required libraries
sudo apt-get install -y curl python3 build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev systemd libsystemd-dev libsodium-dev zlib1g-dev yarn make g++ jq libncursesw5 libtool autoconf git tmux htop nload
export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
echo ""
echo ""
echo "Installing Cabal..." 


#3. installing Cabal 3.2.0.0 to our local bin folder (.local/bin)
wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/

echo $(ghc --version)
echo $(cabal --version)

echo ""
echo ""
sleep 5

#4. verifying the system can find the cabal bin file and making sure the system knows where to look.  adding to user profile file (.bashrc), reloading it using the source command and checking if it is loaded.

echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc 
source ~/.bashrc 
echo $PATH

#5. checing if we have installed the latest cabal package
cabal update
cabal --version

#6 Installing GHC - Haskell code complier
mkdir -p ~/git
cd ~/git

wget https://downloads.haskell.org/ghc/8.10.4/ghc-8.10.4-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.10.4-x86_64-deb9-linux.tar.xz
rm ghc-8.10.4-x86_64-deb9-linux.tar.xz
cd ghc-8.10.4
./configure
sudo make install

#7. verifing the version of ghc
ghc --version

#8. installing libsodium
cd ~/git

git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install

#9. adding paths to .bashrc file and loading them

echo "export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"     >> ~/.bashrc
source ~/.bashrc


#10. downloading the Cardano Node source code from git (github)
cd ~/git
git clone https://github.com/input-output-hk/cardano-node.git

#11. Should have a new folder, - cardano-node with the source code of the node.  lets go to the directory and compile the version we want.

cd cardano-node
git checkout tags/1.27.0

echo ""
echo ""
echo "compiling the node..." 

#11. force the installation to use GHC version we just installed.

cabal configure --with-compiler=ghc-8.10.4

#12. Starting from tag 1.14.x we need to add libsodium libraries to Caedano node, so lets do that.

echo "package cardano-crypto-praos" >>  cabal.project.local
echo "  flags: -external-libsodium-vrf" >>  cabal.project.local

#13. Now we are ready to install (compile) cabal
cabal clean
cabal update
cabal build all

echo ""
echo ""
echo "installing cabal and building it..." 

#13.  creating new directoryto copy the cli and node files to loca/bin
mkdir -p ~/.local/bin/
cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-cli-1.27.0/x/cardano-cli/build/cardano-cli/cardano-cli ~/.local/bin/
cp -p dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-node-1.27.0/x/cardano-node/build/cardano-node/cardano-node ~/.local/bin/

#14.  checking if the installed binary file is in the correct location and latest version.
which cardano-node && which cardano-cli
cardano-node --version
cardano-cli --version



