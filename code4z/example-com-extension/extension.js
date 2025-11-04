const vscode = require('vscode');
const { registerReportCommand, ReportProvider } = require("./commands/enhanced-report");
const { openDocsCommand } = require('./commands/open-docs');
const { basicReport } = require('./commands/basic-report');

/**
 * @param {vscode.ExtensionContext} context
 */
function activate(context) {
	const log = vscode.window.createOutputChannel('Example.com', { log: true });

	// Open Docs
	const openDocsDisp = vscode.commands.registerCommand('com.example.open.docs', openDocsCommand);
	context.subscriptions.push(openDocsDisp);

	// Basic Report
	const basicReportDisp = vscode.commands.registerCommand('com.example.report.basic', basicReport(context));
	context.subscriptions.push(basicReportDisp);

	// Enhanced Report
	const reportDisp = vscode.commands.registerCommand('com.example.report.enhanced', registerReportCommand(context, log));
	const provider = new ReportProvider;
	const providerRegistration = vscode.workspace.registerTextDocumentContentProvider(ReportProvider.scheme, provider);
	context.subscriptions.push(reportDisp, providerRegistration);

	console.log('Congrats, your com.example extension is now active!');
}

function deactivate() { }

module.exports = {
	activate,
	deactivate
}