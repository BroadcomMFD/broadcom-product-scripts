# Web Viewer - Find Failed Jobs

This sample bash script uses the View plug-in for Zowe CLI to perform the following tasks:

- Identify jobs with non-empty exception code (xcode) values archived in a View database.
- Optionally download the output of the identified jobs.
- Optionally search for specific text within the job outputs.

The script supports job filtering based on the following criteria:

- Job name
- Archival Date range
- Exception code

For platform support and prerequisites please review the help text at the start of the script.

For a description of all available command-line arguments and configuration values see the
script help output obtained by running the following command:

```
./find-failed-jobs.sh --help
```
