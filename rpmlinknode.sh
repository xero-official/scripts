#!/usr/bin/env sh
_user="$(id -u -n)"

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
sudo yum install unzip wget -y

echo ''
echo ''
echo ''
echo '**************************'
echo 'Installing XERO Node binary'
echo '**************************'
echo ''
echo ''
echo ''

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/2.0.2/geth-linux.zip

# Unzip node binary
unzip geth-linux.zip

# Make node executable
chmod +x geth

echo ''
echo ''
echo ''
echo '**************************'
echo 'Creating and setting up system service'
echo '**************************'
echo ''
echo ''
echo ''

cat > /tmp/xerolinknode.service << EOL
[Unit]
Description=XERO Link Node
After=network.target

[Service]

User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/geth --syncmode=full --cache=512 -node --lightserv 50 --lightpeers 75

[Install]
WantedBy=default.target
EOL
sudo \mv /tmp/xerolinknode.service /etc/systemd/system
sudo \rm /usr/sbin/geth
sudo \mv geth /usr/sbin/
sudo systemctl enable xerolinknode && systemctl stop xerolinknode && systemctl start xerolinknode
systemctl status xerolinknode --no-pager --full

echo ''
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

echo ''
echo ''
echo ''
echo '**************************'
echo 'Printing your Nodes ID - Please save this somewhere you might need it - the script will pause for 2 minute to allow you to copy the Node ID, after 1 minute it will resume'
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
