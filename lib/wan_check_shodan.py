import sys
import requests
import os
import csv
import argparse
from colors import *

#define project arguments
parser = argparse.ArgumentParser()
parser.add_argument("--public_ip", help="Provide a comma seperated list of public ip's")
parser.add_argument("--shodan_api_token", help="Provide the Shodan.io API token")
parser.add_argument("--customer", help="Provide the customer name, as in the project structure")
args = parser.parse_args()
#set exit value
exitcode = 0
# getting IPs from arguments
ips = args.public_ip.split(";")
# checking ip status
for ip in ips:
    # query and parse result
    query = "https://api.shodan.io/shodan/host/"+ip+"?key="+args.shodan_api_token
    data = requests.get(query)
    jsondata = data.json()
    openports = jsondata.get("ports","[]")
    vulns = jsondata.get("vulns","[]")
    # define approved list path
    approvedlistpath = "./customers/"+args.customer+"/approved_inbound_ports.csv"
    # check if list exists otherwise fail because at least an empty approved list is required.
    if os.path.exists(approvedlistpath):
        approvedports = []
        # read approved list to verify later.
        with open(approvedlistpath, newline='') as csvfile:
                portreader = csv.reader(csvfile, delimiter=";")
                row = 0
                for port in portreader:
                    if (row != 0):
                        if (port[0] == ip):
                            approvedports.append(port[1])
                    row = row + 1
        # check if detected ports are in approved ports, fail if not
        for x in range(len(openports)):
            porttocheck = str(openports[x])
            if porttocheck in approvedports:
                sys.stdout.write(GREEN)
                print(f"The following port is approved: {porttocheck}, on ip: {ip}")
            else:
                sys.stdout.write(RED)
                print(f"The following port is NOT approved: {porttocheck}, on ip: {ip}")
                exitcode = 1      
    else:
        sys.stdout.write(RED)
        print("file not found, provide an approved CSV file: "+approvedlistpath )
        exitcode = 1
    # check if any vulnerabilities have been found, fail if found
    if vulns != "[]":
        sys.stdout.write(RESET)
        print(f"Vulnerabilties have been found on ip: {ip}")
        for vuln in vulns:
            sys.stdout.write(RED)
            print(vuln)
        exitcode = 1

exit(exitcode)
    
