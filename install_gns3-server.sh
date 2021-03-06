#!/bin/bash

# The MIT License (MIT)
# 
# Copyright (c) 2016 thejoker8814
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Run apt-get update 
sudo apt-get update --assume-yes
sudo apt-get dist-upgrade --assume-yes

# Install required build tools
sudo apt-get install make gcc cmake --assume-yes

# Install GNS3 Python dependencies
sudo apt-get install python3.4 --assume-yes
sudo apt-get install python3-setuptools python3-pyqt5 python3-pyqt5.qtsvg \
python3-pyqt5.qtwebkit  python3-ws4py python3-netifaces \
python3-psutil python3-jsonschema python3-dev --assume-yes
# netifaces is being replaced by psutils issue
# https://github.com/GNS3/gns3-server/issues/344

# Install PIP to allow easy upgrades of GNS3 later
sudo apt-get install python3-pip --assume-yes

# Install dynamips dependencies
sudo apt-get install cmake libelf-dev uuid-dev libpcap-dev --assume-yes

# Install GIT
sudo apt-get install git --assume-yes

# Clone GNS3 source and compile it
# latest stable release 1.4.0
cd ~
git clone git://github.com/GNS3/gns3-server
cd ./gns3-server/
git checkout tags/$(git describe --abbrev=0 --tags)
sudo python3 setup.py install

# Clone dynamips source and compile it
# latest stable version
cd ~
git clone git://github.com/GNS3/dynamips.git
cd ./dynamips/
git checkout tags/$(git describe --abbrev=0 --tags)
mkdir build
cd ./build/
cmake ..
make
sudo make install
sudo setcap cap_net_admin,cap_net_raw=ep /usr/local/bin/dynamips

# Install IOU prequisuites
sudo apt-get install libssl1.0.0 --assume-yes
# sudo ln -s /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/libcrypto.so.4
sudo ln -s /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 /lib/libcrypto.so.4
sudo apt-get install bison flex

# install 32-bit dependencies required!
# http://forum.gns3.net/topic11294.html
#
# dpkg --add-architecture i386
# apt-get update
# apt-get install libc6:i386 libstdc++6:i386
# apt-get install libssl1.0.0:i386
# ln -s /lib/i386-linux-gnu/libcrypto.so.1.0.0 /lib/i386-linux-gnu/libcrypto.so.4
## WORKS!

cd ~
git clone https://github.com/ndevilla/iniparser.git
cd ./iniparser/
git checkout tags/$(git describe --abbrev=0 --tags)
make
sudo cp libiniparser.* /usr/lib/
sudo cp src/iniparser.h /usr/local/include
sudo cp src/dictionary.h /usr/local/include
cd ..

# install IOUYAP
cd ~
git clone https://github.com/GNS3/iouyap.git
cd ./iouyap/
git checkout tags/$(git describe --abbrev=0 --tags)
sudo make install
cd ..

# Install ubridge
cd ~
git clone https://github.com/GNS3/ubridge.git
git checkout tags/$(git describe --abbrev=0 --tags)
cd ./ubridge/
make
sudo make install
cd ..

# VPCS
#sudo apt-get install libc6-dev libutil-freebsd-dev --assume-yes
#wget http://sourceforge.net/projects/vpcs/files/0.8/vpcs-0.8-src.tbz
#wget http://sourceforge.net/projects/vpcs/files/0.8/vpcs-0.8-src.tbz.asc
#tar xfj vpcs-0.8-src.tbz
#cd ./vpcs-0.8/src/
#./mk.sh

cd ~
git clone https://github.com/GNS3/gns3-gui.git
cd ./gns3-gui/
# source or download? 

sudo cp vpcs /usr/local/bin/
cd ../..

# Install cpulimit
sudo apt-get install cpulimit --assume-yes

# Install Virtual-Box
# sudo apt-get install virtualbox --assume-yes 

# Install Qemu
sudo apt-get install qemu-system-x86 qemu-utils --assume-yes

####################
## Configuration  ##
####################

# setting up a user for gns3
sudo useradd --home-dir /home/gns3/ --user-group --create-home --groups sudo --shell /bin/false gns3

# setting up working directories 
sudo mkdir -p /home/gns3/.config/GNS3/ssl/

sudo mkdir -p /home/gns3/GNS3/images/
sudo mkdir -p /home/gns3/GNS3/configs/
sudo mkdir -p /home/gns3/GNS3/projects/
sudo chmod 0700 -R /home/gns3/
sudo chown gns3:gns3 -R /home/gns3/

sudo mkdir /var/log/gns3/
sudo chown gns3:gns3 /var/log/gns3/ 

# import default gns3server.conf
sudo cp ~/gns3server-healess/defaults/gns3_server.conf /home/gns3/GNS3/.config/

# install autostart and daemon mode
sudo cp ~/gns3server-healess/defaults/gns3.conf.upstart /etc/init/gns3.conf
sudo chown root:root /etc/init/gns3.conf

# setup self-signed certificatesi
SUBJ="/C=CA/ST=Alberta/O=GNS3SELF/localityName=Calgary/commonName=localhost/organizationalUnitName=GNS3Server/emailAddress=gns3cert@gns3.com"
sudo openssl req -nodes -new -x509 -newkey rsa:4096 -sha256 -keyout server.key -out server.cert -days 365 -subj "$SUBJ"
sudo mv server.* /home/gns3/.config/GNS3/ssl/
sudo chown -R gns3: /home/gns3/.config/GNS3/ssl/
sudo chmod 0600 /home/gns3/.config/GNS3/ssl/server.key

# create credentials

