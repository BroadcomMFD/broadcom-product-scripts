const vscode = require('vscode');
const util = require('node:util');
const execFile = util.promisify(require('node:child_process').execFile);

const CONFIG_PREFIX = 'example-com';
const REPORT_EXEC = 'reportExec';

/**
 * @type {vscode.ExtensionContext}
 */
let context;

/**
 * @type {vscode.LogOutputChannel}
 */
let log;

/**
 * @param {vscode.ExtensionContext} ctx
 * @param {vscode.LogOutputChannel} lg
 */

function registerReportCommand(ctx, lg) {
    context = ctx;
    log = lg;
    return reportCommand;
}

async function reportCommand() {
    await vscode.workspace.fs.createDirectory(context.globalStorageUri);
    const exec = vscode.workspace.getConfiguration(`${CONFIG_PREFIX}`).get(REPORT_EXEC);
    if (!exec) {
        const response = await vscode.window.showInformationMessage("Report exec setting missing, canceling action", 'Open Settings');
        if (response == 'Open Settings') {
            vscode.commands.executeCommand('workbench.action.openSettings', `${CONFIG_PREFIX}.${REPORT_EXEC}`);
        }
        return;
    }
    let arg = await vscode.window.showInputBox({
        placeHolder: 'Please enter a name of a PDS to inquire',
        value: context.globalState.get('arg'),
        validateInput: isValidDsn
    });
    if (!arg) {
        vscode.window.showInformationMessage("No dataset name provided, canceling action");
        return;
    }
    arg = arg.toUpperCase();
    context.globalState.update('arg', arg);
    const reportFileName = `report_on_${arg.toUpperCase()}.txt`;
    const reportFileUri = vscode.Uri.joinPath(context.globalStorageUri, reportFileName);
    // log.show();
    await vscode.window.withProgress({
        title: `Reporting on ${arg}`,
        location: vscode.ProgressLocation.Notification,
        cancellable: false
    }, async (progress, _token) => {
        progress.report({ increment: 20, message: `Execuring Report` });
        const reportOutputDsn = await executeReport(exec, arg);
        if (!reportOutputDsn) {
            vscode.window.showInformationMessage("No report output provided");
            return;
        }
        progress.report({ increment: 30, message: `Downloading Report` });
        await downloadReport(reportOutputDsn, reportFileUri);

    });

    const reportUri = vscode.Uri.from({ scheme: ReportProvider.scheme, path: reportFileName });
    await openReport(reportUri);
}

/**
 * @param {string} exec rexx or clist to execute
 * @param {string} arg argument to the report exec
 */

async function executeReport(exec, arg) {
    const { stdout, stderr } = await execFile('zowe', ["tso", "issue", "command", `exec '${exec}' '${arg}'`]);
    log.info(`Executing REXX exec: ${exec} ${arg}`);
    stdout.split("\n").forEach(line => line && log.info(line));
    stderr.split("\n").forEach(line => line && log.error(line));
    const dsnLine = stdout.split("\n").find(line => line.match(/^DSN=/));
    const dsn = dsnLine?.replace('DSN=', '');
    return dsn;
}
/**
 * @param {string} reportDsn dataset from which to download report
 * @param {vscode.Uri} reportUri file uri where to store the downloaded report
 */

async function downloadReport(reportDsn, reportUri) {
    const { stdout, stderr } = await execFile('zowe', ["files", "download", "data-set", reportDsn, "-f", reportUri.fsPath]);
    log.info(`Downloading report from ${reportDsn} to ${reportUri}`);
    stdout.split("\n").forEach(line => line && log.info(line));
    stderr.split("\n").forEach(line => line && log.error(line));
}
/**
 * @implements {vscode.TextDocumentContentProvider}
 */
class ReportProvider {
    static scheme = "com-example+report";
    /**
     * @param {vscode.Uri} uri
     * @param {vscode.CancellationToken} token
    */
    async provideTextDocumentContent(uri, token) {
        const fileUri = vscode.Uri.joinPath(context.globalStorageUri, uri.path);
        const content = await vscode.workspace.fs.readFile(fileUri);
        return content.toString();
    }
}

/**
 * @param {vscode.Uri} reportUri
 */

async function openReport(reportUri) {
    const document = await vscode.workspace.openTextDocument(reportUri);
    await vscode.window.showTextDocument(document);
}
/**
 *
 * @param {string} input
 */
function isValidDsn(input) {
    const datasetPattern = /^([A-Za-z@#$][0-9A-za-z@#$]{0,7}\.)+([A-Za-z@#$][0-9A-Za-z@#$]{0,7})$/;
    if (input.length <= 44 && input.match(datasetPattern)) {
        return;
    }
    return 'Please, enter a valid dataset name';
}

module.exports = {
    registerReportCommand,
    ReportProvider
}