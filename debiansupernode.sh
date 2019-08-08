#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'

# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget -y

echo '**************************'
echo 'Installing XERO Super Node binary'
echo '**************************'


# Clean up environment and stage install
mkdir -p /tmp/xerom
cd /tmp/xerom
rm -rf geth-linux.zip
rm -rf dashboard

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/2.0.0/geth-linux.zip

unzip geth-linux.zip

# Make node executable
chmod +x geth

echo '**************************'
echo 'Creating and setting up XERO Super Node system service'
echo '**************************'

cat > /tmp/xerosupernode.service << EOL
[Unit]
Description=XERO Super Node
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/geth --syncmode full --lightserv 80 --lightpeers 100 -node --cache=512 --datadir=$HOME/.xerom
[Install]
WantedBy=default.target
EOL
sudo systemctl stop xerosupernode
sudo \mv /tmp/xerosupernode.service /etc/systemd/system
sudo \rm /usr/sbin/geth
sudo \mv geth /usr/sbin/
sudo systemctl daemon-reload
sudo systemctl enable xerosupernode && systemctl start xerosupernode
sudo systemctl restart xerosupernode
sudo systemctl status xerosupernode --no-pager --full

echo '**************************'
echo 'Setting Up Node dashboard'
echo '**************************'

# Download node Dashboard
wget https://github.com/xero-official/node-deployment-dashboard/raw/master/build/dashboard

# Make Dashboard executable
chmod +x dashboard

sleep 15s

echo '**************************'
echo 'Printing your Node ID - Please save this somewhere you might need it - the script will pause for 1 minute to allow you to copy the Node ID, after 1 minute it will resume'
echo '**************************'

#Grab the Node ID
/usr/sbin/geth --exec "admin.nodeInfo.enode" attach ipc://./home/xero/.xerom/geth.ipc

sleep 1m

# Make Dashboard executable
chmod +x dashboard

echo '**************************'
echo 'If you are going to setup your node manually - you can exit the dashboard by using option 5'
echo '**************************'

sleep 10s

# Activate Dashboard
./dashboard

echo 'Done.'
