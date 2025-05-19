# Timzone api
#  See https://timeapi.io/    and
#      https://timeapi.io/swagger/index.html
#
# Enter a time zone
# "US/Arizona","US/Central","US/East-Indiana","US/Eastern"
# "US/Michigan","US/Mountain","US/Pacific" "Singapore". . .
# Examples:
# python TimeZoneTest.py "US/Central"
# python TimeZoneTest.py "US/Pacific"
# python TimeZoneTest.py "US/Eastern"
#
import os        #Import standard Python os lib
import platform  #Import standard Python platform lib
import sys       #Import standard Python sys lib
import requests
import json
#
from requests.auth import HTTPBasicAuth
##  Build the complete url  here
url = "https://timeapi.io//api/TimeZone/zone?timeZone="
#
print("#Arguments:", sys.argv[1:])   # Additional arguments passed
listtimeZone = sys.argv[1:2]
print("#listtimeZone :", type(listtimeZone), listtimeZone)
timeZone = listtimeZone[0]
timeZoneType = type(timeZone)
print('#', timeZoneType, timeZone)
url = url + timeZone
print("#url:", url)                  # complete url
#
response = requests.get(url)
print(response.content)
#
# Parsing the nested JSON string
data = json.loads(response.content)
# Accessing nested data
print("timeZone:", data['timeZone'])
print("currentLocalTime:", data['currentLocalTime'])
print("hasDayLightSaving:", data['hasDayLightSaving'])
#
