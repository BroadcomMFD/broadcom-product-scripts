// @ts-nocheck
const vscode = require('vscode');
const util = require('node:util');
const execFile = util.promisify(require('node:child_process').execFile);

const REXX_EXEC = "PUBLIC.REXX(BASIC)";

const basicReport = context => async () => {
    await vscode.workspace.fs.createDirectory(context.globalStorageUri);
    const reportUri = vscode.Uri.joinPath(context.globalStorageUri, "report.txt");

    const dsn = await vscode.window.showInputBox({
        placeHolder: 'Please enter a name of a PDS to inquire'
    });

    const output = await execRexx(dsn);
    await vscode.workspace.fs.writeFile(reportUri, Buffer.from(output, 'utf-8'));

    const document = await vscode.workspace.openTextDocument(reportUri);
    await vscode.window.showTextDocument(document);
}

async function execRexx(dsn) {
    const { stdout, stderr } = await execFile('zowe', ["tso", "issue", "command", `exec '${REXX_EXEC}' '${dsn}'`]);
    return stdout;
}

module.exports = {
    basicReport
}