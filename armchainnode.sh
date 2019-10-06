#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'

# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget -y

echo '**************************'
echo 'Installing XERO Node binary'
echo '**************************'

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/2.0.2/geth-arm.zip

unzip geth-arm.zip

# Make node executable
chmod +x geth

echo '**************************'
echo 'Creating and setting up XERO Node system service'
echo '**************************'

cat > /tmp/xerochainnode.service << EOL
[Unit]
Description=XERO Chain Node
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 -node --datadir=$HOME/.xerom
[Install]
WantedBy=default.target
EOL

sudo systemctl stop xerochainnode
sudo \mv /tmp/xerochainnode.service /etc/systemd/system
sudo \rm /usr/sbin/geth
sudo \mv geth /usr/sbin/
sudo systemctl daemon-reload
sudo systemctl enable xerochainnode && systemctl start xerochainnode
sudo systemctl restart xerochainnode
sudo systemctl status xerochainnode --no-pager --full

echo '**************************'
echo 'Setting Up Node dashboard'
echo '**************************'

# Download node Dashboard
rm dashboard-arm

wget https://github.com/xero-official/node-deployment-dashboard/raw/master/build/dashboard-arm

# Make Dashboard executable
chmod +x dashboard-arm

sleep 15s

echo '**************************'
echo 'Printing your Nodes ID - Please save this somewhere you might need it - the script will pause for 2 minute to allow you to copy the Node ID, after 1 minute it will resume'
echo '**************************'

#Grab the Node ID
/usr/sbin/geth --exec "admin.nodeInfo.enode" attach ipc://./$HOME/.xerom/geth.ipc

sleep 1m

# Make Dashboard executable
chmod +x dashboard-arm

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

# Remove and cleanup
rm geth-arm.zip

# Activate Dashboard
./dashboard-arm

echo 'Done.'
