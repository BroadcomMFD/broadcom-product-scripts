# Timzone api
#  See https://timeapi.io/    and
#      https://timeapi.io/swagger/index.html
import os        #Import standard Python os lib
import platform  #Import standard Python platform lib
import sys       #Import standard Python sys lib
import requests
from requests.auth import HTTPBasicAuth

##  Build the complete url  here
url = "http://timeapi.io/api/TimeZone/AvailableTimeZones"
#
response = requests.get(url)
print(response.content)
#
