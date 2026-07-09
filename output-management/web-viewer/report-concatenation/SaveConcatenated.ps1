<#
 # Copyright (c) 2025 Broadcom.  All rights reserved.  The term "Broadcom"
 # refers to Broadcom Inc. and/or its subsidiaries.
 #
 # This software and all information contained therein is confidential and
 # proprietary and shall not be duplicated, used, disclosed or disseminated in
 # any way without the express written permission of Broadcom. All authorized
 # reproductions must be marked with this language.
 #
 # TO THE EXTENT PERMITTED BY APPLICABLE LAW, BROADCOM PROVIDES THIS SOFTWARE
 # "AS IS" WITHOUT WARRANTY OF ANY KIND, INCLUDING WITHOUT LIMITATION, ANY
 # IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 # NONINFRINGEMENT.  IN NO EVENT WILL BROADCOM BE LIABLE TO THE END USER OR ANY
 # THIRD PARTY FOR ANY LOSS OR DAMAGE, DIRECT OR INDIRECT, FROM THE USE OF THIS
 # MATERIAL, INCLUDING WITHOUT LIMITATION, LOST PROFITS, BUSINESS INTERRUPTION,
 # GOODWILL, OR LOST DATA, EVEN IF BROADCOM IS EXPRESSLY ADVISED OF SUCH LOSS
 # OR DAMAGE.
 #>

<#
.SYNOPSIS
    Sample script showcasing use of the Web Viewer 14 API to concatenate multiple versions
    of a report into one file in chronological archival order.
.DESCRIPTION
    Requires PowerShell 7 or later.
    Before use, configure the $INSTANCE variable within the script.
#>

param (
     [Parameter(Mandatory = $true)] [String] $ViewDatabase # Dataset prefix of the OM View database to be searched.
    ,[Parameter(Mandatory = $true)] [String] $ReportId     # Report ID.
    ,[Parameter(Mandatory = $true)] [String] $From         # Start (inclusive) of archival date range in the YYYY-MM-DD format.
    ,[Parameter(Mandatory = $true)] [String] $To           # End (inclusive) of archival date range in the YYYY-MM-DD format.
    ,[Parameter(Mandatory = $true)] [String] $OutputFile   # Path to the output file.
    ,[String] $Separator = "`f"                            # Separator string inserted between concatenated reports.
)

##
## Define static configuration values.
##

# Base URL for the Web Viewer 14 instance to be used.
# Example: https://production.example.com:8443/web-viewer
$INSTANCE = ""

##
## Define shared functions.
##

function CheckApiResponse {
    param (
        [String] $Operation = "Operation",
        [Int64] $HttpCode,
        [PSObject] $Response
    )

    if ($HttpCode -eq 200 -and ($Response -eq $null -or $Response.status -eq $null -or $Response.status -eq "SUCCESS")) {
        return
    }

    if ($Response -ne $null -and $Response.message -ne $null -and $Response.message.Count -ge 1) {
        $Message = $Response.message[0].longText
        if ($Message -eq $null) {
            $Message = $Response.message[0].shortText
        }
    }

    if ($Message -eq $null) {
        $Message = "Code $HttpCode"
    }

    throw "${Operation} failed: ${Message}"
}

##
## Check preconditions.
##

if ($PSVersionTable.PSVersion.Major -Lt 7) {
    throw "This script requires PowerShell 7 or later."
}

if ($INSTANCE -Eq "") {
    throw "You must set the value of the `$INSTANCE constant in this script before use."
}

if (Test-Path -Path $OutputFile) {
    throw "Output file path '${OutputFile}' already exists. Specify a different file path or delete it first."
}

##
## Obtain Web Viewer credentials.
##

$Credential = Get-Credential

##
## Log in to Web Viewer.
##

Write-Output "Logging in ..."
$Response = Invoke-RestMethod -Method "Post" -Uri "${INSTANCE}/api/v1/view/login" `
    -SkipHttpErrorCheck -StatusCodeVariable "HttpCode" `
    -Authentication Basic -Credential $Credential `
    -SessionVariable "ApiSession" `
    -AllowUnencryptedAuthentication
CheckApiResponse "Login" $HttpCode $Response

##
## Locate Web Viewer repository for specified View database.
##

Write-Output "Locating repository ..."
$Response = Invoke-RestMethod -Method "Get" -Uri "${INSTANCE}/api/v1/view/repository" `
    -SkipHttpErrorCheck -StatusCodeVariable "HttpCode" `
    -WebSession $ApiSession
CheckApiResponse "Repository search" $HttpCode $Response

$RepositoryId = $null
$RepositoryName = $null
$Repositories = $Response.result.repository
for ($i = 0; $i -lt $Repositories.Count -and $RepositoryId -eq $null; $i++) {
    if ($Repositories[$i].path -eq $ViewDatabase) {
        $RepositoryId = $Repositories[$i].id
        $RepositoryName = $Repositories[$i].name
    }
}
if ($RepositoryId -eq $null) {
    throw "No repository found for OM View database ${ViewDatabase}."
}
Write-Output "Will use repository '${RepositoryName}'."

##
## Identify matching reports.
##

$ArchivalDateFrom = ([int](Get-Date "${From}T00:00:00Z" -UFormat "%s")) * 1000
$ArchivalDateTo = ([int](Get-Date "${To}T00:00:00Z" -UFormat "%s")) * 1000

Write-Output "Searching for reports ..."
$Response = Invoke-RestMethod -Method "Get" -Uri "${INSTANCE}/api/v1/view/rptlist/${RepositoryId}" `
    -SkipHttpErrorCheck -StatusCodeVariable "HttpCode" `
    -WebSession $ApiSession `
    -Body @{
        name = $ReportId;
        arcDateFrom = $ArchivalDateFrom;
        arcDateTo = $ArchivalDateTo;
        onlineOnly = $True;
    }
CheckApiResponse "Report search" $HttpCode $Response
$Reports = $Response.result.'Report List'

if ($Reports.Count -eq 0) {
    Write-Output "Found no matching reports."
    Exit 0
}

##
## Download all matching reports in generation/sequence order.
##

$TotalRecords = 0
$DownloadedReports = 0
$DownloadedRecords = 0

$Reports | foreach { $TotalRecords += $PSItem.retrievableRecords }

Write-Output "Found $( $Reports.Count ) matching reports containing ${TotalRecords} total records."

$Reports | Sort-Object -Property reportID,gen,seqNum | foreach {
    Write-Progress -Id 1 `
        -Activity "Downloading reports" `
        -Status "$( $PSItem.reportID ) ($( $PSItem.gen ):$( $PSItem.seqNum ))" `
        -PercentComplete (($DownloadedRecords * 100) / $TotalRecords)

    Invoke-RestMethod -Method "Get" -Uri "${INSTANCE}/api/v1/view/rptdata/download/${RepositoryId}/$( $PSItem.handle )" `
        -SkipHttpErrorCheck -StatusCodeVariable "HttpCode" `
        -WebSession $ApiSession `
    | Add-Content $OutputFile
    CheckApiResponse "Download" $HttpCode $null

    $DownloadedRecords += $PSItem.retrievableRecords
    $DownloadedReports++

    # Insert separator between reports if requested.
    if ($Separator.Length -gt 0 -and $Reports.Count -gt 1 -and $DownloadedReports -lt $Reports.Count) {
        Add-Content $OutputFile $Separator
    }
}

Write-Progress -Id 1 -Completed
Write-Output "All report data was successfully concatenated into '$OutputFile'."
