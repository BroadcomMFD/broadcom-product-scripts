import os
import sys
import subprocess
import time
import requests
import json
import logging
import textwrap

logging.basicConfig(
        filename='/opt/xxx/scripts/scanjob.log', # Provide your log file and its path
        filemode='a',
        format='%(asctime)s - %(levelname)s - %(message)s',
        level=logging.DEBUG
)

#CUSTOMIZE ALL THE FOLLOWING FIELDS TO YOUR VALUES
INBOUND_DIR = "/opt/xxx/inbound"
OUTBOUND_DIR = "/opt/xxx/outbound"
SONAR_SCANNER_PATH = "/opt/sonar-scanner/bin/sonar-scanner"
SONAR_HOST_URL = "https://<your-sonarqube-instance.net>"
SONAR_PROJECT_KEY = "<your_project_key"
SONAR_TOKEN = "your SONAR_Token"

def run_sonar_scanner():
    try:
        subprocess.run([SONAR_SCANNER_PATH], check=True)
    except subprocess.CalledProcessError as e:
        logging.error(f"SonarScanner execution failed: {e}")
        sys.exit(1)

def get_ce_task_id():
    report_task_file = os.path.join(os.getcwd(), ".scannerwork", "report-task.txt")
    ce_task_id = None
    try:
        with open(report_task_file, 'r') as f:
            for line in f:
                if line.startswith("ceTaskId="):
                    ce_task_id = line.strip().split('=')[1]
                    break
    except FileNotFoundError:
        logging.error("report-task.txt not found. Ensure SonarScanner has been run.")
        sys.exit(1)
    return ce_task_id

def wait_for_analysis_completion(ce_task_id):
    status = ""
    url = f"{SONAR_HOST_URL}/api/ce/task?id={ce_task_id}"
    headers = {"Authorization": f"Bearer {SONAR_TOKEN}"}
    while True:
        response = requests.get(url, headers=headers)
        if response.status_code != 200:
            logging.error(f"Failed to get task status: {response.status_code}")
            sys.exit(1)
        task = response.json().get("task", {})
        status = task.get("status", "")
        if status in ["SUCCESS", "FAILED", "CANCELED"]:
            break
        time.sleep(5)
    if status != "SUCCESS":
        logging.info(f"Analysis task ended with status: {status}")
        sys.exit(1)

def get_analysis_results():
    url = f"{SONAR_HOST_URL}/api/issues/search"
    headers = {"Authorization": f"Bearer {SONAR_TOKEN}"}
    params = {
        "componentKeys": SONAR_PROJECT_KEY,
        "types": "BUG,VULNERABILITY,CODE_SMELL",
        "ps": 500,
        "p": 1
    }
    issues = []
    while True:
        response = requests.get(url, headers=headers, params=params)
        if response.status_code != 200:
            logging.error(f"Failed to retrieve issues: {response.status_code}")
            sys.exit(1)
        data = response.json()
        issues.extend(data.get("issues", []))
        paging = data.get("paging", {})
        if params["p"] * params["ps"] >= paging.get("total", 0):
            break
        params["p"] += 1
    return issues

def main():
    if len(sys.argv) != 3:
        logging.error("Usage: python3 script.py <input_file> <output_file>")
        sys.exit(1)

    config_filename = sys.argv[1]
    config_path = os.path.join(INBOUND_DIR, config_filename)
    output_filename = sys.argv[2]

    try:
        with open(config_path, 'r') as f:
            lines = f.readlines()[1:]


        files_received = []

        for line in lines:
            parts = line.strip().split()
            if len(parts) < 2:
                continue
            file_type, member = parts[0], parts[1]
            extension = ".cbl" if file_type.upper() == "COBOL" else ".cpy" if file_type.upper() == "COPYBOOK" else ""
            if  extension:
                files_received.append(f"{member}{extension}")

        ##Specify the path where your script needs to run from. In this sceneario above Inbound & Outbound folder structures.
        os.chdir("/opt/xxx")

        # Run SonarScanner
        run_sonar_scanner()

        # Wait for analysis to complete
        ce_task_id = get_ce_task_id()
        wait_for_analysis_completion(ce_task_id)

        # Retrieve analysis results
        issues = get_analysis_results()

        # Organize issues by file
        issues_by_file = {}
        for issue in issues:
            component = issue.get("component", "")
            rel_path = component.split(":", 1)[-1]
            base_name = os.path.basename(rel_path)
            if base_name not in issues_by_file:
                issues_by_file[base_name] = []
            issues_by_file[base_name].append({
                "type": issue.get("type"),
                "severity": issue.get("severity"),
                "message": issue.get("message")
            })

        # Write results to output file
        output_path = os.path.join(OUTBOUND_DIR, output_filename)
        with open(output_path, 'w',encoding='utf-8') as out:
            wrapper = textwrap.TextWrapper(width=131, subsequent_indent='     ')
            for file in files_received:
                out.write(f" Analysis results for {file}:\n")
                file_issues = issues_by_file.get(file, [])
                if file_issues:
                    for issue in file_issues:
                        line = f" - [{issue['severity']}] {issue['type']}: {issue['message']}"
                        wrapped_lines = wrapper.wrap(line)
                        for wrapped_line in wrapped_lines:
                         out.write(f"{wrapped_line}\n")
                else:
                    out.write("  - No issues found.\n")
                out.write("\n")
            out.write("Status: SUCCESS\n")

        logging.info(f"Processed {len(files_received)} files. Output written to {output_path}")


        # Delete processed files
        for file in files_received:
            file_path = os.path.join(INBOUND_DIR, file)
            if os.path.exists(file_path):
                os.remove(file_path)

    except Exception as e:
        logging.error(f"Error processing file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()

