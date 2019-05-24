#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`
_upgrade="No"
_nodetype="masternode"

for opt in "$@"
do
 if [ $opt = "-chainnode" ] ; then
    _nodetype="chainnode"
 elif [ $opt = "-xeronode" ] ; then
    _nodetype="xeronode"
  elif [ $opt = "-linknode" ] ; then
     _nodetype="linknode"
 elif [ $opt = "-supernode" ] ; then
    _nodetype="supernode"
 elif [ $opt = "-upgrade" ] ; then
    _upgrade="Yes"
 else
    echo "Invalid option: $opt"
 fi
done

if [ $_nodetype = "supernode" ] ; then
    echo "XERO/ethoFS Super Node Setup Initiated"
fi
if [ $_nodetype = "linknode" ] ; then
    echo "XERO/ethoFS Link Node Setup Initiated"
fi
if [ $_nodetype = "xeronode" ] ; then
    echo "XERO Node Setup Initiated"
fi
if [ $_nodetype = "chainnode" ] ; then
    echo "XERO Chain Node Setup Initiated"
fi
if [ $_upgrade = "Yes" ] ; then
    echo "Upgrade Option Selected"
fi

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget build-essential go-lang -y

echo '**************************'
echo 'Installing XERO Node binary'
echo '**************************'
# Download node binary

wget https://github.com/xero-official/go-xerom/releases/download/1.0.0/geth-linux-amd64.tar.gz

tar -xzf geth-linux-amd64.tar.gz

# Make node executable
chmod +x geth

# Remove and cleanup
rm geth-linux-amd64.tar.gz

echo '**************************'
echo 'Creating and setting up Chain/XERO Node system service'
echo '**************************'

cat > /tmp/xeronode.service << EOL
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
        sudo systemctl stop xeronode
        sudo \mv /tmp/xeronode.service /etc/systemd/system
        sudo \mv geth /usr/sbin/
        sudo systemctl daemon-reload
        sudo systemctl enable xeronode && systemctl start xeronode
        sudo systemctl restart xeronode
        sudo systemctl status xeronode --no-pager --full

echo '**************************'
echo 'Masternode Setup Complete....Deploying IPFS'
echo '**************************'

cd $HOME
wget https://github.com/Ether1Project/Ether-1-GN-Binaries/releases/download/0.0.9.1/ipfs.tar.gz
tar -xzf ipfs.tar.gz
chmod +x ipfs

# Remove and cleanup
rm ipfs.tar.gz

echo '**************************'
echo 'Creating and setting up IPFS system service'
echo '**************************'

cat > /tmp/ipfs.service << EOL
[Unit]
Description=IPFS Node System Service
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/ipfs daemon --migrate --enable-namesys-pubsub  --enable-gc
[Install]
WantedBy=default.target
EOL
        sudo systemctl stop ipfs
        sudo \mv /tmp/ipfs.service /etc/systemd/system
        sudo \mv ipfs /usr/sbin/
        if [ $_upgrade = "No" ] ; then
            sudo rm -r $HOME/.ipfs
            ipfs init
        fi
        ipfs bootstrap rm --all
        if [ $_nodetype = "gatewaynode" ] ; then
            _maxstorage="78GB"
            sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/ipfs
            ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/80
        fi
        if [ $_nodetype = "masternode" ] ; then
            _maxstorage="38GB"
        fi
        if [ $_nodetype = "servicenode" ] ; then
            _maxstorage="18GB"
        fi
        ipfs config Datastore.StorageMax $_maxstorage
        ipfs config --json Swarm.ConnMgr.LowWater 400
        ipfs config --json Swarm.ConnMgr.HighWater 600
        ipfs bootstrap add /ip4/207.148.27.84/tcp/4001/ipfs/QmTFUcUuMSN7KLytjtqnHCjixqd4ig3PrSbdQ2mW9Q8qeY
        ipfs bootstrap add /ip4/66.42.109.75/tcp/4001/ipfs/QmV856mLWnTDaj5LQvS3dCa3qjz4DNC9cKQJNSrwtqcHzT
        ipfs bootstrap add /ip4/95.179.136.216/tcp/4001/ipfs/QmdFCa2ix51sV8FADGKDadKPGB55kdEQMZm9VKVSRTbVhC
        ipfs bootstrap add /ip4/45.63.116.102/tcp/4001/ipfs/QmSfEKCzPWA6MmG2ZLK4Vqnq6oB6rvrLyUpHdNqng5nQ4t
        ipfs bootstrap add /ip4/149.28.167.176/tcp/4001/ipfs/QmRwQ49Zknc2dQbywrhT8ArMDS9JdmnEyGGy4mZ1wDkgaX
        ipfs bootstrap add /ip4/140.82.54.221/tcp/4001/ipfs/QmeG81bELkgLBZFYZc53ioxtvRS8iNVzPqxUBKSuah2rcQ
        ipfs bootstrap add /ip4/45.77.170.137/tcp/4001/ipfs/QmTZsBNb7dfJJmwuAdXBjKZ7ZH6XbpestZdURWGJVyAmj2
        sudo chown -R $_user:$_user $HOME/.ipfs
cat > /tmp/swarm.key << EOL
/key/swarm/psk/1.0.0/
/base16/
38307a74b2176d0054ffa2864e31ee22d0fc6c3266dd856f6d41bddf14e2ad63
EOL
        sudo \mv /tmp/swarm.key $HOME/.ipfs
        sudo systemctl daemon-reload
        sudo systemctl enable ipfs && systemctl start ipfs
        sudo systemctl restart ipfs
        sudo systemctl status ipfs --no-pager --full
echo '**************************'
echo 'IPFS Setup Complete....Deploying ethoFS'
echo '**************************'
cd $HOME
wget https://github.com/Ether1Project/Ether-1-GN-Binaries/releases/download/0.0.9.1/ethoFS.tar.gz
tar -xzf ethoFS.tar.gz
chmod +x ethoFS

# Remove and cleanup
rm ethoFS.tar.gz

echo '**************************'
echo 'Creating and setting up ethoFS system service'
echo '**************************'

cat > /tmp/ethoFS.service << EOL
[Unit]
Description=ethoFS Node System Service
After=network.target
[Service]
User=$_user
Group=$_user
Type=simple
Restart=always
ExecStart=/usr/sbin/ethoFS -$_nodetype
[Install]
WantedBy=default.target
EOL
        sudo systemctl stop ethoFS
        sudo \mv /tmp/ethoFS.service /etc/systemd/system
        sudo \mv ethoFS /usr/sbin/
        sudo systemctl daemon-reload
        sudo systemctl enable ethoFS && sudo systemctl start ethoFS
        sudo systemctl restart ethoFS
        sudo systemctl status ethoFS --no-pager --full
echo '**************************'
echo 'ethoFS Setup Complete'
echo '**************************'

echo '**************************'
echo 'Setting Up Node dashboard'
echo '**************************'

# Download node Dashboard
wget https://github.com/xero-official/node-deployment-dashboard/raw/master/build/dashboard

# Make Dashboard executable
chmod +x dashboard

# Activate Dashboard
./dashboard
