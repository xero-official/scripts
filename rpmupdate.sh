#!/usr/bin/env sh
_user="$(id -u -n)"

echo ''
echo ''
echo ''
echo '**************************'
echo 'Stopping your node'
echo '**************************'
echo ''
echo ''
echo ''

systemctl stop xerochainnode
systemctl stop xeronode
systemctl stop xerolinknode
systemctl stop xerosupernode

echo ''
echo ''
echo ''
echo '**************************'
echo 'Removing chaindata'
echo '**************************'
echo ''
echo ''
echo ''

rm -r $HOME/.xerom/geth/chaindata

rm -r $HOME/.xerom/geth/nodes

echo ''
echo ''
echo ''
echo '**************************'
echo 'Downloading new Binary version'
echo '**************************'
echo ''
echo ''
echo ''

mkdir -p /tmp/xerom
cd /tmp/xerom
rm -rf geth-linux.zip

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/2.1.0/geth-linux.zip

unzip geth-linux.zip

# Make node executable
chmod +x geth

echo ''
echo ''
echo ''
echo '**************************'
echo 'Getting rid of the old binary and replacing it with a new one'
echo '**************************'
echo ''
echo ''
echo ''

sudo \rm /usr/sbin/geth
sudo \mv geth /usr/sbin/

echo ''
echo ''
echo ''
echo '**************************'
echo 'Starting new version'
echo '**************************'
echo ''
echo ''
echo ''

systemctl start xerochainnode
systemctl start xeronode
systemctl start xerolinknode
systemctl start xerosupernode

echo ''
echo ''
echo ''
echo '**************************'
echo 'Done √ - Thank you for updating!'
echo '**************************'
echo ''
echo ''
echo ''
