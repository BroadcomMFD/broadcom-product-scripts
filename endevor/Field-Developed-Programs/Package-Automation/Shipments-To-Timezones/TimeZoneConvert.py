# Timzone api convert remote time to local time
#  See https://timeapi.io/    and
#      https://timeapi.io/swagger/index.html
#
# Enter a remote time zone and a remote time
# Examples:
# python TimeZoneTest.py "US/Pacific 12:00:00"
# python TimeZoneTest.py "Singapore  04:00:00"
# Remote TimeZone, local date and time are received as parms
#
import os        #Import standard Python os lib
import platform  #Import standard Python platform lib
import sys       #Import standard Python sys lib
import requests
import json
#
from requests.auth import HTTPBasicAuth
##  These values are fixed for this routine
localTimezone = "US/Eastern"
url = "https://timeapi.io/api/conversion/converttimezone"
# show the arguments passed
print("#Arguments:", sys.argv[1:])   # Additional arguments passed
listparameters = sys.argv[1:2]
print("#listparameters :", type(listparameters), listparameters)
timeZone  = listparameters[0]
remoteDate = sys.argv[2]
remoteTime = sys.argv[3]
timeZoneType = type(timeZone)
print('#', timeZoneType, timeZone)
print('# local date+time', remoteDate, remoteTime)
#
data = {
    "fromTimeZone": str(timeZone),
    "dateTime": remoteDate+" "+remoteTime,
    "toTimeZone": localTimezone,
    "dstAmbiguity": str("")
      }
#
headers={
    'Content-type': 'application/json',
    'Accept': 'application/json',
    'connection': 'keep-alive',
    'vary': 'Accept-Encoding'
      }
#
# print("Type for data is",type(data),"data=",data)
#
# POST the request ....
response = requests.post(url, json=data, headers=headers)
# Print the response from the server
print(response.json())
#
# Parsing the nested JSON string
data = json.loads(response.content)
# Accessing nested data
print("conversionResult:", data['conversionResult'])
#
