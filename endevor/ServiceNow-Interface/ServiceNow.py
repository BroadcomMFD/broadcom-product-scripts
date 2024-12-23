#                                                                       
import os        #Import standard Python os lib                         
import platform  #Import standard Python platform lib          s         
import sys       #Import standard Python sys lib                        
import requests                                                         
from requests.auth import HTTPBasicAuth                                 
import json                                                             
                                                                         
print("Script name:", sys.argvÝ0¨)                                      
                                                                         
##  Build the complete url  here                                        
url = "https://somewhere.service-now.com/api/now/table/problem?sysparm_query=number="
print("#Arguments:", sys.argvÝ1:¨)   # Additional arguments passed      
listticketnumber = sys.argvÝ1:2¨                                        
print("#listticketnumber :", type(listticketnumber), listticketnumber)      
ticketnumber = listticketnumberÝ0¨                                      
ticketnumberType = type(ticketnumber)                                   
print('#' + ticketnumberType, ticketnumber)                             
url = url + ticketnumber                                                
print("#url:", url)                  # complete url                     
#                                                                       
response = requests.get(url, auth=HTTPBasicAuth('user', 'passw')
print(response.content)                                                 
out = json.loads(response.content)                                      
n = outÝ'result'¨                                                       
                                               
#                                             
#n type <class 'list'>                        
#out type <class 'dict'>                      
#                                             
                                               
if len(n) == 0:                               
    print("error - no output")                 
elif "number" in nÝ0¨.keys():                 
    print("Exists")                            
else:                                         
    print("error - not found")                 
                                                                       