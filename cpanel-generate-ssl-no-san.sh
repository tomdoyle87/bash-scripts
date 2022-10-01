#!/bin/bash

#Set Variables
domain=example.com
userfolder=example
fname=$(date +%F)
Send_CSR_To=root

#Change to customer company details
country=GB
state=Bucks
locality="Milton Keynes"
organization="Example PLC"
organizationalunit="Example Dept"
email=admin@$domain

#Create the request
echo "Creating CSR for "$domain
openssl req -new -newkey rsa:2048 -nodes -keyout $domain.key -out $domain.csr \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$domain/emailAddress=$email"

#Save Private key
key="$(cat $domain.key|perl -MURI::Escape -ne 'print uri_escape($_);' )"
uapi --user=$userfolder SSL upload_key key=$key friendly_name=$fname
rm -f $domain.key
/bin/mail -s "$(echo -e "CSR for $domain")" < $domain.csr $Send_CSR_To
echo "CSR key for "$domain: ; echo " " ; cat $domain.csr
echo " "
echo "CSR for "$domain", has been to sent to "$Send_CSR_To
rm -f $domain.csr
