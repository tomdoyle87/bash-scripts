<h1>bash-scripts</h1>

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

<h2>connman-update-resolv</h2>
Allows OpenVPN users to use the dns servers from their VPN provider, with no requirement for resolvconf or openresolv. To use:

    cd /etc/openvpn
    sudo wget https://raw.githubusercontent.com/tomdoyle87/bash-scripts/main/connman-update-resolv
    sudo chmod u+x connman-update-resolv
    
Append the following to your vpn conf file:
    
    script-security 2                                               
    up /etc/openvpn/connman-update-resolv 
    down /etc/openvpn/connman-update-resolv

Update connman preferences not to use dnsproxy. Edit ```/etc/osmc/prefs.d/connman``` (should still work work with dnsproxy enabled, but not tested):

Replace:

    dnsproxy=yes
With:
    
    dnsproxy=no
Then restart connman with ```sudo systemctl restart connman```

(Optional. If you find the down script is not restoring the pre-vpn dns, this fall-back resolves this issue). To make sure this works consistently across shutdowns and reboots with systemd an override is requried:-

    
    [Service]
    ExecStartPre=/bin/sh -c "IFACE=$(connmanctl services | sed -n \"s/^\\*.* \\([^ ]*\\)$/\\1/p\"); if [ -n \"$IFACE\" ] && [ -f /etc/openvpn/pre-vpn-dns ]; then PRE_VPN_DNS=$(cat /etc/openvpn/pre-vpn-dns); connmanctl config \"$IFACE\" --nameservers $PRE_VPN_DNS; fi"

We also need to start openvpn from a stopped state when these scripts are first added and that connman currently has your actual nameservers rather than the vpn provided ones configured. One way to check this is:-


    IFACE=$(connmanctl services | awk '/^\*/ {print $NF; exit}')
    connmanctl services "$IFACE" \
        | sed -n 's/.*Nameservers\.Configuration = \[\(.*\)\].*/\1/p' \
        | tr -d ',' \
        | xargs

If you ever change your locally configured nameservers you need to remove /etc/resolv.conf.connman-backup and repeat the above. 
    

<h2>UpdateChromium.ps1</h2>
Not a bash script, just a powershell script I put together with AI. For my office PC. Kept forgetting to manaully update. Can be run using a scheduled task. 
