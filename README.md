# update-error-checking-cp
Bash script for checking automated cpanel update, upcp reports for any errors.

Suggest copying script to /usr/local/sbin/ and sceduling a cronjob to run about hour after cpanel updates:

0 0 * * * /bin/bash /usr/local/sbin/upcp-check.sh &>/dev/null
