#!/usr/bin/python3
import sys
import re
import os

## Function to validate read status of share.
def read():
    global st
    st = ' '
    while st != 'ro' or st != 'rw':
        st = input("Does the share need to be read only or read write (ro/rw):")
        if st == 'ro' or st == 'rw':
            break
        else:
            print("Invalid input, please try again?.")
## IP Validation regex. 
regex = "^(?=\d+\.\d+\.\d+\.\d+($|\/))(([1-9]?\d|1\d\d|2[0-4]\d|25[0-5])\.?){4}(\/([0-9]|[1-2][0-9]|3[0-2]))?$"

## Function to validate IPs and networks.
def check(Ip):  
  
    global ip
    if(re.search(regex, Ip)):  
        print("Valid Ip address")  
        ip = '1'  
    else:  
        print("Invalid Ip address, please try again")
        ip ='0'

## Function to validate yes no input.
def yes_or_no(question):
    global reply
    answer = input(question + "(yes/no): ").lower().strip()
    print("")
    while not(answer == "y" or answer == "yes" or \
    answer == "n" or answer == "no"):
        print("Input yes or no")
        answer = input(question + "(yes/no):").lower().strip()
        print("")
    if answer[0] == "y":
        return True
        reply = '1'
    if answer[0] == "n":
        reply = '0'
    else:
        return False

## Function to install NFS server
def install_server():  
    os.system('sudo apt-get update' and 'sudo apt-get install -y nfs-kernel-server')

reply = ' '
question = yes_or_no("Do you want to setup an NFS server? ")
if reply == '0':
   print("Exiting Setup")
   sys.exit()

ip = ' '
print("Installing Server")
install_server()
reply = ' '
question = yes_or_no("Do you want Restrict what IPs can access the Server? ")
if reply != '0':
    while ip !='1':
         Ip = input ("Please enter an IP network, for example 192.168.0.1/24. Or A single host, e.g. 192.168.1.15 ")
         check(Ip)
         if ip == '1':
             break
         if ip == '0':
             continue

if reply == '0':
    print("Not restricting IP")
    Ip = '?'

print("Now setting up share for automounts")
read()
print('/media/ ' + Ip + '(' + st + ',sync,no_root_squash)', file=open("/etc/exports", "a"))
print("Share for automounts complete")

reply = ' '
while reply != '0':
    question = yes_or_no("Do you wish to setup any additional shares e.g. /home/osmc/share ")
    if reply != '0':
        share = input("Please enter share path? ")
        while not os.path.isabs(share):
            share = input("Please try again, needs to be a absolute path ")
            os.path.isabs(share)
        if not os.path.exists(share):
             os.makedirs(share)
        read()
        print(share,Ip + '(' + st + ',sync,no_root_squash)', file=open("/etc/exports", "a"))
    if reply == '0':
        print ("No additional share to added")
        break

exportfs = '/usr/sbin/exportfs -ra'
os.system(exportfs)
print("Listing Shares: ")
showmount = '/sbin/showmount -e 127.0.0.1'
os.system(showmount)
print("Server setup completed")
