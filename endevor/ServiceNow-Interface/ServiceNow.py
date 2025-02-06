#                                                                               
import os        #Import standard Python os lib                                 
import platform  #Import standard Python platform lib                           
import sys       #Import standard Python sys lib                                
import requests                                                                 
from requests.auth import HTTPBasicAuth                                         
import json                                                                     
                                                                                
##  Build the complete url  here                                                
print("#Arguments:", sys.argv[1:])   # Additional arguments passed              
listticketnumber = sys.argv[1:2]                                                
print("#listticketnumber :", type(listticketnumber), listticketnumber)          
ticketnumber = listticketnumber[0]                                              
ticketnumberType = type(ticketnumber)                                           
mySubstring = ticketnumber[0:3]                 # does a substring              
#                                                                               
url = "https://your.service-now.com/api/now/table"                              
if mySubstring == 'PRB':                                                        
   print('problem ticket query')                                                
   url = url + "/problem?sysparm_query="                                        
else:                                                                           
   print('Change ticket query')                                                 
   url = url + "/change_request?sysparm_query="                                 
#                                                                               
url = url + ticketnumber                                                        
print("#url:", url)                  # complete url                             
#                                                                               
response = requests.get(url, auth=HTTPBasicAuth('admin', 'passw'))              
print(response.content)                                                         
out = json.loads(response.content)                                              
n = out['result']                                                               
                                                                                
#                                                                               
typeout = type(out)                                                             
typen   = type(n)                                                               
print("#n type", typen)                                                         
print("#out type", typeout)                                                     
#                                                                               
                                                                                
if len(n) == 0:                                                                 
   print("error - no output")                                                   
elif "number" in n[0].keys():                                                   
   print("Exists")                                                              
else:                                                                           
   print("error - not found")                                                   
                                                                                
