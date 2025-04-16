const vscode = require('vscode');
const { registerReportCommand, ReportProvider } = require("./commands/enhanced-report");
const { openDocsCommand } = require('./commands/open-docs');
const { simpleReport } = require('./commands/basic-report');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
	const log = vscode.window.createOutputChannel('Example.com', { log: true });

	// Report on Dataset
	const reportDisp = vscode.commands.registerCommand('com.example.report.on.dataset', registerReportCommand(context, log));
	const provider = new ReportProvider;
	const providerRegistration = vscode.workspace.registerTextDocumentContentProvider(ReportProvider.scheme, provider);
	context.subscriptions.push(reportDisp, providerRegistration);

	// Simple Report
	const simpleReportDisp = vscode.commands.registerCommand('com.example.simple.report', simpleReport(context));
	context.subscriptions.push(simpleReportDisp);

	// Open Docs
	const openDocsDisp = vscode.commands.registerCommand('com.example.open.docs', openDocsCommand);
	context.subscriptions.push(openDocsDisp);

	console.log('Congrats, your com.example extension is now active!');
}

function deactivate() { }

module.exports = {
	activate,
	deactivate
}