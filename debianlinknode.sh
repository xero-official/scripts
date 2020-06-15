#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

echo ''
echo ''
echo ''
echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
echo ''
echo ''
echo ''

# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget -y

echo ''
echo ''
echo ''
echo '**************************'
echo 'Installing XERO Link Node binary'
echo '**************************'
echo ''
echo ''
echo ''

# Clean up environment and stage install
mkdir -p /tmp/xerom
cd /tmp/xerom
rm -rf geth-linux.zip
rm -rf dashboard

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/2.1.0/geth-linux.zip

unzip geth-linux.zip

# Make node executable
chmod +x geth

echo ''
echo ''
echo ''
echo '**************************'
echo 'Creating and setting up XERO Link Node system service'
echo '**************************'
echo ''
echo ''
echo ''

cat > /tmp/xerom/xerolinknode.service << EOL
[Unit]
Description=XERO Link Node
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/geth --syncmode full --lightserv 50 --lightpeers 75 -node --cache=512 --datadir=$HOME/.xerom
[Install]
WantedBy=default.target
EOL
sudo systemctl stop xerolinknode
sudo \mv /tmp/xerom/xerolinknode.service /etc/systemd/system
sudo \rm /usr/sbin/geth
sudo \mv geth /usr/sbin/
sudo systemctl daemon-reload
sudo systemctl enable xerolinknode && systemctl start xerolinknode
sudo systemctl restart xerolinknode
sudo systemctl status xerolinknode --no-pager --full

echo ''
echo ''
echo '**************************'
echo 'Setting Up Node dashboard'
echo '**************************'
echo ''
echo ''
echo ''

# Download node Dashboard
wget https://github.com/xero-official/node-deployment-dashboard/raw/master/build/dashboard

# Make Dashboard executable
chmod +x dashboard

sleep 3s

echo ''
echo ''
echo ''
echo '**************************'
echo 'Printing your Node ID - Please save this somewhere you might need it'
echo '(note: The script will pause for 1 minute to allow you to copy the Node ID, after 1 minute it will resume.)'
echo '**************************'
echo ''
echo ''
echo ''

#Grab the Node ID
/usr/sbin/geth --exec "admin.nodeInfo.enode" attach ipc://./$HOME/.xerom/geth.ipc

sleep 1m

# Make Dashboard executable
chmod +x dashboard

echo ''
echo ''
echo ''
echo '**************************'
echo 'If you are going to setup your node manually - you can exit the dashboard by using option 5 - It is recommend you wait for the node to complete syncing before activating the dasboard'
echo '**************************'
echo ''
echo ''
echo ''

sleep 10s

# Activate Dashboard
./dashboard

echo 'Done.'
