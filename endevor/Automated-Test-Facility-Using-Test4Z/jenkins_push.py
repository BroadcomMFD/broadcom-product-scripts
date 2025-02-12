import os
import platform
import sys
import requests
import json

# Jenkins configuration
file_name = sys.argv[1]
jenkins_user = "api_user"  # Replace with your Jenkins username
jenkins_token = "your api token" # Replace with your Jenkins token
trigger_token = "your_trigger_token" # Replace with your trigger token
url = "http://10.01.01.01:8080/job/NDVR_pipeline" # Replace with your Jenkins pipeline url:port jobname
jenkins_url = f"{url}/buildWithParameters?token={trigger_token}"
file_path = f"/u/ibmuser/results/{file_name}"

try:
    with open(file_path, "rb") as file:
      files = {
         'stashed_file': ('file_name', file, 'application/json')
      }

        # Send the POST request to Jenkins
      response = requests.post(
          jenkins_url,
          auth=(jenkins_user, jenkins_token),
          files=files
        )

       # Check the response
      if response.status_code == 201:
          print("Jenkins job triggered successfully.")
      else:
          print(f"Failed to trigger job: {response.status_code}")

except FileNotFoundError:
    print(f"Error: File not found at {file_path}")
except Exception as e:
    print(f"An error occurred: {e}")