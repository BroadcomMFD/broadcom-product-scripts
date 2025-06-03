# VS Code extension for the example.com company

This is an example of an extension a company `example.com` may want to create to supplement Code4z with custom, company specific functionality.

## Making your custom ISPF apps available in VS Code

If you have custom ISPF panels for your internal processes you may want to make their functionality available in VS Code as part of your DevOps modernization.

The following sections outline the steps to take.

### Update your ISPF application to run in plain TSO

1. Update your ISPF application to accept arguments instead of relying on screen inputs
1. Update the application to store its output to a dataset, or print it to the terminal instead of showing the result on an ISPF screen
1. Test your updated application by running it in TSO without ISPF and check its output.
1. Run your updated application through ZOWE CLI via the following command `zowe tso issue command "exec 'PUBLIC.REXX(REPOUT)' 'ARG1 ARG2'"`, where `PUBLIC.REXX(REPOUT)` is your REXX application and `ARG1` `ARG2` are the arguments that are passed to it. The syntax above works both in Windows CMD, PowerShell as well as Bourne compatible UNIX shells.

### Use the basic-report command in this extension

1. Update the `REXX_EXEC` constant in [basic-report.js](commands/basic-report.js#L6) to point to your application.
1. Start the extension by pressing `F5`. This will start a new VS Code window with this extension.
1. In this new VS Code window open the _Command Palette_ by pressing `F1`
1. Type `example.com` in the command palette input box 

Now you should see ![Command Palette](command-palette.png)

1. Select the `Basic Report on a Dataset` command
1. After a short moment an editor with the output of your applications will open

If you would like to try this out with a basic REXX program, you can use the included [basic-report.rexx](commands/basic-report.rexx) sample. The output should look similar to ![Report](report.png)

### Explore the enhanced-report

The [basic report](commands/basic-report.js) is only 30 lines long. It is as simple as possible to get started quickly. To make the extension real there is a lot more to do. For example:

- Input validation
- Error checking
- Remembering last entry
- Adding a progress bar
- Storing the report to a dataset and retrieving it from there
- Adding a VS Code Output channel to diagnose issues
- Adding a setting for the location of the REXX exec instead of hard coding it in the extension code

All of these enhancements have been added to the [enhanced report](commands/enhanced-report.js) with its corresponding [enhanced-report.rexx](commands/enhanced-report.rexx) REXX exec. This adds a little over 100 lines of code and illustrated many other useful VS Code APIs. It also adds typescript checking via [JS Doc](https://www.typescriptlang.org/docs/handbook/jsdoc-supported-types.html) annotations to help you catch errors while authoring the code rather than at runtime.

### Build the extension

The extension can be built by running the two following commands

```
# Install development dependencies - typescript, types, and vsce
npm ci
# Package the extension
npm run package
```

### Next steps

A few ideas about what you may want to try next:

- Remember last 10 user inputs and let them choose (in addition to typing a new one)
- Submit a JOB and retrieve its output instead of running a REXX exec
- Use the ZOWE SDK instead of ZOWE CLI (remove run-time dependency)
- Execute REXX exec over SSH or submit a JOB over FTP if you do not have ZOWE CLI available
- Copy the REXX exec to the mainframe before a command runs (in case the REXX does not exist) - self deploy
