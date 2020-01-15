#!/bin/bash
cd /var/cpanel/updatelogs # Change to cpanel updates logs directory.
VAR1=$(ls -tr up*|tail -1) # Find the latest log and set it as a variable.
egrep 'Error:|error:|Another app is currently holding the yum lock|Segmentation fault' $VAR1 > /tmp/update-check # Check for errors and output to temp file
if egrep 'Error:|error:|Another app is currently holding the yum lock|Segmentation fault' /tmp/update-check; then # If then to check for errors and send email alert if  required.
     /bin/mail -s "$(echo -e "Check to see if updates work, failed\nX-Priority: 1")" < /tmp/update-check root
fi
unset VAR1 # Unset variable. 
