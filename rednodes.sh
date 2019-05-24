#!/usr/bin/env sh
_user="$(id -u -n)"

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'

# install dependencies
sudo yum install unzip wget go-lang -y

echo '**************************'
echo 'Installing XERO Node binary'
echo '**************************'

# Download node binary
wget https://github.com/xero-official/go-xerom/releases/download/1.0.0/geth-linux-amd64

# Make node executable
chmod +x geth-linux-amd64

echo '**************************'
echo 'Creating and setting up system service'
echo '**************************'

cat > /tmp/xeronode.service << EOL
[Unit]
Description=XERO Node
After=network.target

[Service]

User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/geth-linux-amd64 --syncmode=fast --cache=512

[Install]
WantedBy=default.target
EOL
        sudo \mv /tmp/xeronode.service /etc/systemd/system
        sudo \rm /usr/sbin/geth-linux-amd64
        sudo \mv geth-linux-amd64 /usr/sbin/
        sudo systemctl enable xeronode && systemctl stop xeronode && systemctl start xeronode
        systemctl status xeronode --no-pager --full

echo 'Done.'
