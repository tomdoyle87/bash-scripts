#!/bin/bash
read_status () {
	echo 'Does the share need to be read only or read write (ro/rw):'
	read st                                                                                                               
		if [[ -z "$st" ]]; then
			echo 'Please try again'
			read st                                                                                                         
		fi
		if [[ ! $st =~ ^(ro|rw|)$ ]]; then 
			  echo "Please try again, needs to be ro or rw."
			  read st
		fi
}
read -p 'Do you want to setup an NFS server?  (yes/no?): '
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
	if [[ -z "$ip" ]]; then
		echo 'Please try again'
		read ip
	fi
	if [[ ! $ip =~ ^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$|^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$) ]]; then
		echo 'Please try again, not a valid ip or network'
		read ip
	fi
	;;	
	[nN]|[nN][oO]) echo 'Access will not be restricted'	
	ip='?' ;;
	*) echo "Invalid argument" ;;
esac
echo 'Now setting up share for automounts'
read_status
echo '/media/' $ip'('$st',sync,no_root_squash)' >> /etc/exports
echo 'Share for automounts complete'
while [ "$e" != "[nN]|[nN][oO])" ]; do
	read -p 'Do you wish to setup any additional shares e.g. /home/osmc/share (yes/no?): '
		case $REPLY in
		[yY]|[yY][eE][sS]) echo 'Please enter share path'
		read share
		if [[ -z "$share" ]]; then
			echo 'Please try again'
			read share
		fi
		if [[ "$share" != /* ]]; then
			echo 'Please try again, needs to be a absolute path'
			read share
		fi
		if [[ ! -e $share ]]; then
			mkdir $share
		fi
		read_status
		echo $share $ip'('$st',sync,no_root_squash)' >> /etc/exports
		unset share
		;;
		[nN]|[nN][oO]) echo 'No additional share to added. Press Enter to continue...'
		read e
		break;;
		*) echo "Invalid argument" ;;
	esac
done
exportfs -ra
echo "Listing Shares:"
showmount -e 127.0.0.1
echo "Server setup completed"
unset ip
unset e
unset st
