#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget build-essential go-lang -y

echo '**************************'
echo 'Installing XERO Node binary'
echo '**************************'
# Download node binary

wget https://github.com/xero-official/go-xerom/releases/download/1.0.0/geth-linux-amd64

# Make node executable
chmod +x geth-linux-amd64

echo '**************************'
echo 'Creating and setting up Chain/XERO Node system service'
echo '**************************'

cat > /tmp/xeronode.service << EOL
[Unit]
Description=XERO Node Node
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/geth-linux-amd64 --syncmode=fast --cache=512 -node --datadir=$HOME/.xerom
[Install]
WantedBy=default.target
EOL
        sudo systemctl stop xeronode
        sudo \mv /tmp/xeronode.service /etc/systemd/system
        sudo \mv geth-linux-amd64 /usr/sbin/
        sudo systemctl daemon-reload
        sudo systemctl enable xeronode && systemctl start xeronode
        sudo systemctl restart xeronode
        sudo systemctl status xeronode --no-pager --full

echo '**************************'
echo 'Setting Up Node dashboard'
echo '**************************'

# Download node Dashboard
wget https://github.com/xero-official/node-deployment-dashboard/raw/master/build/dashboard

# Make Dashboard executable
chmod +x dashboard

# Activate Dashboard
./dashboard
