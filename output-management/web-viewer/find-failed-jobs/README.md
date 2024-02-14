# Web Viewer - Find Failed Jobs

This sample bash script uses the View Plug-in for Zowe CLI to:

- Identify jobs with non-empty exception code values (xcode) archived in a View database.
- Optionally downloads the content of the identified jobs.
- Optionally searches for specific text within identified jobs.

The script also support job filtering based on:

- Job name
- Archival Date range
- Exception code value

For platform support and prerequisites please read the embedded help at the start of the script.

For a description of all available options and configuration refer to the script help output:

```
./find-failed-jobs.sh --help
```
