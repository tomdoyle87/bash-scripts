<h1>bash-scripts</h1>

A little repository for what I hope are useful bash scripts

<h2>upcp-check.sh</h2>

Bash script for checking automated cpanel update, upcp reports for any errors.

Suggest copying script to /usr/local/sbin/ and sceduling a cronjob to run about hour after cpanel updates:

0 0 * * * /bin/bash /usr/local/sbin/upcp-check.sh &>/dev/null
