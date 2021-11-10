import requests
import sys
from colors import *

# define exitcode
exitcode = 0
# define repo url
repourl = "<repo url>"
# check if HTTP download is allowed
# repo source TheZoo
query_http = "http://"+repourl+"/unzipped/Ransomware.WannaCry/ed01ebfbc9eb5bbea545af4d01bf5f1071661840480439c6e5babe8e080e41aa.exe"
# try to download the file on HTTP
try:
    # define content-size
    headeronly = requests.head(query_http)
    result = requests.get(query_http, timeout=5)
    if (result.headers.get('Content-Length') == headeronly.headers['Content-Length'] ):
        exitcode = 1
        sys.stdout.write(RED)
        print("The program was able to download the file using HTTP!")
        sys.stdout.write(RESET)
except:
    pass

query_https = "https://"+repourl+"/unzipped/Ransomware.WannaCry/ed01ebfbc9eb5bbea545af4d01bf5f1071661840480439c6e5babe8e080e41aa.exe"
# try to download the file on HTTP
try:
    # define content-size
    headeronly = requests.head(query_https, verify=False)
    result = requests.get(query_https, timeout=5, verify=False)
    if (result.headers.get('Content-Length') == headeronly.headers['Content-Length'] ):
        exitcode = 1
        sys.stdout.write(RED)
        print("The program was able to download the file using HTTPS!")
        sys.stdout.write(RESET)
except:
    pass

exit(exitcode)
