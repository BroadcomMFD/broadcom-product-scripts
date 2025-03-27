const vscode = require('vscode');
const url = 'https://techdocs.broadcom.com/us/en/ca-mainframe-software/devops/code4z/2-0.html';

async function openDocsCommand() {
    const docsUrl = vscode.Uri.parse(url);
    vscode.env.openExternal(docsUrl);
}

module.exports = {
    openDocsCommand
}
