import sys
import csv
import os
import argparse
import requests
from colors import *

# define project arguments
parser = argparse.ArgumentParser()
parser.add_argument("--customer", help="Provide the customer name, as in the project structure")
args = parser.parse_args()
# set exit value
exitcode = 0
# define openports array
openports=[]
# detect open ports 1-65535
# This will take a long time!
porttoverify = 1
while porttoverify < 1024:
    query = "http://portquiz.net:"+str(porttoverify)
    # try to make the call, if it timesout, it's not open.
    try:
        result = requests.get(query, timeout=0.2)
        openports.append(porttoverify)
    except:
        pass
    porttoverify = porttoverify + 1     

# define approved list path
approvedlistpath = "./customers/"+args.customer+"/approved_outbound_ports.csv"
# define approvedports array
approvedports = []
# get approved open ports
with open(approvedlistpath, newline='') as csvfile:
                portreader = csv.reader(csvfile, delimiter=";")
                row = 0
                for port in portreader:
                    if (row != 0):
                            approvedports.append(port[0])
                    row = row + 1
# check for unapprove open ports
for openport in openports:
    if str(openport) in approvedports:
        sys.stdout.write(GREEN)
        print(f"Apporved open port: {openport}")
    else:
        sys.stdout.write(RED)
        print(f"UNAPPROVED open port: {openport}")
        exitcode=1

exit(exitcode)
