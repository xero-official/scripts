#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`

echo '**************************'
echo 'Disabling XEROMs Service'
echo '**************************'

#disable node service
sudo systemctl disable xeronode.service

echo '**************************'
echo 'Stopping XEROMs Service'
echo '**************************'

#stop node service
sudo systemctl stop xeronode.service

echo '**************************'
echo 'Removing XEROMs Geth Binary'
echo '**************************'

#removes geth binary
sudo rm -r /usr/sbin/geth-linux-amd64

echo '**************************'
echo 'Removing XEROMs .service File'
echo '**************************'

#deletes the .service file
sudo rm -r /etc/systemd/system/xeronode.service

echo '**************************'
echo 'Deleting XEROMs Database'
echo '**************************'

#removes geths database and files
sudo rm -r .xerom

echo '**************************'
echo 'Removing XERO Dashboard, install and kill scripts'
echo '**************************'

#removes node dashboard, install script and this script
sudo rm -r dashboard xero.sh killnode.sh
