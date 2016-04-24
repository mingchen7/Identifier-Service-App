#!/bin/bash

# get the tool of wget and unzip
apt-get install -y wget unzip 

# download sratoolkit
# For format convertion? 
echo "Downloading sratoolkit from ncbi..."
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.5.7/sratoolkit.2.5.7-ubuntu64.tar.gz
tar xvzf sratoolkit.2.5.7-ubuntu64.tar.gz
chmod a+x sratoolkit.2.5.7-ubuntu64/bin/*
cp -r sratoolkit.2.5.7-ubuntu64/bin/* /usr/bin

# download aspera connect
echo "Downloading Aspera Connect tool..."
wget http://download.asperasoft.com/download/sw/connect/3.6.2/aspera-connect-3.6.2.117442-linux-64.tar.gz
tar xvzf aspera-connect-3.6.2.117442-linux-64.tar.gz
./aspera-connect-3.6.2.117442-linux-64.sh
chmod a+x ~/.aspera/connect/bin/* 
echo "PATH=\$PATH:\$HOME/.aspera/connect/bin" >> ~/.bashrc


