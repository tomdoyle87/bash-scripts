#!/bin/bash
set -f
read_status () {
	echo 'Does the share need to be read only or read write (ro/rw):'
	read st
	while [[ -z "$st" ]]; do
        	echo 'Please try again'
        	read st
	done
	while [ "$st" != "ro" ] && [ "$st" != "rw" ]; do
		echo "Please try again, needs to be ro or rw."
		read st
	done
}
function validateIP() {
	local ip=$1
	local stat=1
	if [[ $ip =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$|^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$) ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
		&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}
while true; do
	read -p 'Do you want to setup an NFS server?  (yes/no?): '
		case $REPLY in
		[yY]|[yY][eE][sS]) echo 'Installing Server'
		apt-get install -y nfs-kernel-server
		break;;
		[nN]|[nN][oO]) echo 'Exiting Setup'
		exit 0 ;;
		*) echo "Invalid argument, please try again." ;;
	esac
done
while  [ "$e" != "[nN]|[nN][oO])" ] && [ "$e" != "*" ]; do
	read -p 'Do you want Restrict what IPs can access the Server? (yes/no?): '
		case $REPLY in
		[yY]|[yY][eE][sS]) echo 'Please enter an IP network, for example 192.168.0.1/24. Or A single host, e.g. 192.168.1.15'
		read ip
		while [[ -z "$ip" ]]; do
			echo 'Please try again'
			read ip
		done
		validateIP $ip
		while [ $? -eq 1 ]; do
			echo 'Please try again, not a valid ip or network'
			read ip
			validateIP $ip
		done
		break;;
		[nN]|[nN][oO]) echo 'Access will not be restricted'
		ip='*'
		break;;
		*) echo "Invalid argument, please try again." ;;
	esac
done
echo 'Now setting up share for automounts'
read_status
echo '/media/' $ip'('$st',sync,crossmnt,no_root_squash,no_subtree_check)' >> /etc/exports
echo 'Share for automounts complete'
while  [ "$e" != "[nN]|[nN][oO])" ] && [ "$e" != "*" ]; do
	read -p 'Do you wish to setup any additional shares e.g. /home/osmc/share (yes/no?): '
		case $REPLY in
		[yY]|[yY][eE][sS]) echo 'Please enter share path'
		read share
		while [[ -z "$share" ]]; do
			echo 'Please try again'
			read share
		done
		while [[ "$share" != /* ]]; do
			echo 'Please try again, needs to be a absolute path'
			read share
		done
		if [[ ! -e $share ]]; then
			mkdir $share
		fi
		read_status
		echo $share $ip'('$st',sync,crossmnt,no_root_squash,no_subtree_check)' >> /etc/exports
		unset share
		;;
		[nN]|[nN][oO]) echo 'No additional share to added. Press Enter to continue...'
		read e
		break;;
		*) echo "Invalid argument, please try again." ;;
	esac
done
exportfs -ra
echo "Listing Shares:"
showmount -e 127.0.0.1
echo "Server setup completed"
unset ip
unset e
unset st
set +f
