#!/bin/bash
read -p 'Do you want setup a NFS server?  (yes/no?): '
case $REPLY in
        [yY]|[yY][eE][sS]) echo 'Installing Server'
        apt-get install -y nfs-kernel-server
        ;;
                [nN]|[nN][oO]) echo 'Exiting Setup'
                exit 0 ;;
                        *) echo "Invalid argument" ;;
esac
read -p 'Do you want Restrict what IPs can access the Server? (yes/no?): '
case $REPLY in
        [yY]|[yY][eE][sS]) echo 'Please enter an IP network, for example 192.168.0.1/24. Or A single host, e.g. 192.168.1.15'
        read ip
        ;;
                [nN]|[nN][oO]) echo 'Access will not be restricted'
                ip='?' ;;
                        *) echo "Invalid argument" ;;
esac
echo 'Now setting up share for automounts'
echo '/media/' $ip'(ro,sync,no_root_squash)' >> /etc/exports
echo 'Share for automounts complete'
read -p 'Do you wish to setup an additional shares e.g. /home/osmc/share (yes/no?): '
case $REPLY in
        [yY]|[yY][eE][sS]) echo 'Please enter share path'
        read share
                if [[ ! -e $share ]]; then
                        mkdir $share
                fi
        echo $share $ip'(ro,sync,no_root_squash)' >> /etc/exports
        ;;
                [nN]|[nN][oO]) echo 'No additional share to added.' ;;
                        *) echo "Invalid argument" ;;
esac
exportfs -ra
echo "Listing Shares:"
showmount -e 127.0.0.1
echo "Server setup completed"
unset ip
unset share
