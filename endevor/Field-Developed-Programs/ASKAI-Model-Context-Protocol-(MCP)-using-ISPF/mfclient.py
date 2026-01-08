import sys       #Import standard Python sys lib
# Name the directory where the 'requests' are found
sys.path.append('/u/your/lib/python3.11/site-packages/pip/_vendor')    # where is your requests folder
import requests
from requests.auth import HTTPBasicAuth
import json

##  Show the passed arguments
#print("#Arguments:", sys.argv�1:�)   # Additional arguments passed
#AIASKmessage = sys.argv�1:2�
#print("#AIASKmessage :", type(AIASKmessage), AIASKmessage)

response = requests.post('http://12.34.56:5000/query', json={'query': sys.argv�1�})    # use your url
print(response.json()�"message"�)
