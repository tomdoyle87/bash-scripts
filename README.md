<h2>bash-scripts</h1>

A little repository for what I hope are useful bash scripts

<h2>upcp-check.sh</h2>

Bash script for checking automated cpanel update, upcp reports for any errors.

Suggest copying script to /usr/local/sbin/ and sceduling a cronjob to run about hour after cpanel updates:

0 0 * * * /bin/bash /usr/local/sbin/upcp-check.sh &>/dev/null

<h2>nfs-server-setup.sh</h2>

A setup script for osmc nfs-server including automounts. Needs work as only allows one (non automounted additional share), also only inital setup no reconfigure. To run:

sudo bash nfs-server-setup.sh

<h2> cpanel-mass-generate-csr.ssh & cpanel-mass-install-ssl.ssh </h2>

Both require a csv spreadheet called domains.csv, 1st column domain, 2nd username. For the csr generation if company details are not constant, add columns to csv file and use awk to generate variables. For example if country is the third, add as a variable like this:

country=$(awk -F, -v r=$linenumber -v c=3 '{if(NR==r)print $c}' domains.csv)
