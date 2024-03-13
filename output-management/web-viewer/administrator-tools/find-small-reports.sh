#!/usr/bin/env bash

###
### To get help information run the script with the --help argument.
###

### CONFIGURATION ###

# Default report name filter pattern.
NAME_FILTER_DEFAULT='*'

# Default start of searched archival range.
DATE_FROM_DEFAULT='1 year ago'

# Default end of searched archival range.
DATE_TO_DEFAULT='today'

# Default number of threshold lines.
MAX_LINES_DEFAULT=10

# Default target directory.
DOWNLOAD_DIR_DEFAULT=$(pwd)

############################

function printHelp() {
    cat <<EOHELP
USAGE

    $0 [OPTION]...

    This script uses the View plug-in for Zowe CLI to locate reports with a number of lines below
    a chosen threshold across repositories in the servers defined in the ${_SERVER_DEFINITIONS} file.
    Any combination of the following arguments can be specified to customize the script behavior.

        --help               Prints this help text, then exits.

        --name <pattern>     Report name filter pattern. Can contain an asterisk as a wildcard.
                             Defaults to '${NAME_FILTER_DEFAULT}'.

        --lines <lines>      Threshold of number of lines. Only reports with less than or an equal
                             number of lines will match.
                             Defaults to ${MAX_LINES_DEFAULT} lines.

        --from <from>        Start of the searched archival date range.
                             Only supports date resolution, time information is ignored.

                             Defaults to '${DATE_FROM_DEFAULT}'.

        --to <to>            End of the searched archival date range.
                             Only supports date resolution, time information is ignored.
                             Defaults to '${DATE_TO_DEFAULT}'.

        --download           Download the content of each found report into the current directory.
                             Reports that are not available on disk (e.g., only on tape) are skipped.
                             The file name format is '$(getReportFileNameRaw '<system>' '<reportName>' '<jobId>')'.
                             Existing files with matching names will be overwritten!

        --download-dir <dir> Path to existing directory where downloaded report content is saved.
                             This argument is ignored if --download is not specified.
                             Defaults to the current working directory.

        --print              Print the content of each found report to the console.
                             Reports that are not available on disk (e.g., only on tape) are skipped.
                             If specified, the --download argument is implicitly enabled.

        Servers that are currently offline will be silently skipped.

        Refer to the following GNU manual pages for a description and examples of the
        supported date formats for the --from and --to arguments:

            Examples: http://gnu.org/software/coreutils/manual/html_node/Examples-of-date.html
            Formats:  http://gnu.org/software/coreutils/manual/html_node/Date-input-formats.html

        Note that certain special characters that can appear in report names are not supported in
        filenames on certain platforms (e.g., '?' on Windows) therefore those special characters
        will be replaced with an underscore in any generated filename.


CONFIGURATION

    The following configuration variables are set within the CONFIGURATION section at the start of
    this script.

        NAME_FILTER_DEFAULT  Specifies the default value for the --name argument.
                             Current value: ${NAME_FILTER_DEFAULT}

        DATE_FROM_DEFAULT    Specifies the default value for the --from argument.
                             Current value: ${DATE_FROM_DEFAULT}

        DATE_TO_DEFAULT      Specifies the default value for the --to argument.
                             Current value: ${DATE_TO_DEFAULT}

        MAX_LINES_DEFAULT    Specifies the default value for the --lines argument.
                             Current value: ${MAX_LINES_DEFAULT}

        DOWNLOAD_DIR_DEFAULT Specifies the default value for the --download-dir argument.
                             Current value: ${DOWNLOAD_DIR_DEFAULT}


EXAMPLES

    Where not specified explicitly the archival date range is between '${DATE_FROM_DEFAULT}' and '${DATE_TO_DEFAULT}'.

    Find all reports with 10 lines or less:

        $0 --lines 10

    Find reports that start with LREP and with 15 lines or less:

        $0 --name 'LREP*' --lines 15

    Find all reports with 20 lines or less from the last 14 days:

        $0 --from "14 days ago" --lines 20

    Find all reports with 25 lines or less from the year 2023:

        $0 --from 2023-01-01 --to 2023-12-31 --lines 25

    Find all reports with 30 lines or less and download their content:

        $0 --lines 30 --download

    Find all reports with 35 lines or less, download and print their content:

        $0 --lines 35 --print
EOHELP
}

# Converts date specification into standard ISO8601 format.
function convertDate() {
    ${gnudate} -d "${1}" --iso-8601
}

function validateDates() {
    local dateFrom="$1"
    local dateTo="$2"

    local from to
    from=$(${gnudate} -d "${dateFrom}" "+%s")
    to=$(${gnudate} -d "${dateTo}" "+%s")

    if [ "${from}" -lt 0 ] || [ "${to}" -lt 0 ]; then
        error "Archival date can not refer to dates prior to 1970-01-01."
    fi

    if [ "${from}" -ge 2147554800 ] || [ "${to}" -ge 2147554800 ]; then
        error "Archival date can not refer to dates after 2038-01-19."
    fi

    if [ "${from}" -gt "${to}" ]; then
        error "The 'from' date must be less than or equal to the 'to' date."
    fi
}

# Returns a filename that should be safe across all supported platforms.
function getSafeFileName() {
    echo "$*" | tr '<>:"/\\|?*"' _
}

function getReportFileNameRaw() {
    local system=$1
    local name=$2
    local jobid=$3

    echo "$system-$name-$jobid.txt"
}

# Returns the filename used for downloaded report content.
function getReportFileName() {
    getSafeFileName "$(getReportFileNameRaw "$@")"
}

function parseReportMetadata() {
    local -n _report="$1"; shift
    local reportMetadata="$*"

    IFS=','; local split=(${reportMetadata}); unset IFS

    _report[repository]=${split[0]}
    _report[jobid]=${split[1]}
    _report[archived]=${split[2]}
    _report[handle]=${split[3]}
    _report[status]=${split[4]}
    _report[lines]=${split[5]}
    _report[jobname]=${split[6]}
    # Allow for report name to contain commas
    if [ "${#split[@]}" -le 8 ]; then
        _report[name]=${split[7]}
    else
        local combinedName=$(echo "${reportMetadata}" | cut -d ',' -f 8-)
        _report[name]=${combinedName:1:-1}
    fi
}

function findSmallReports() {
    local -n _reports=$1
    local repositoryUniqueId=$2
    local maxLines=$3
    local reportNameFilter=$4
    local dateFrom=$5
    local dateTo=$6
    local download=$7
    local print=$8

    local -A repository
    getRepository "repository" "${repositoryUniqueId}"

    local -A server
    getServer "server" "${repository[server]}"

    local reportList=$(mktemp)

    zowe caview list reports \
        "${repository[identifier]}" \
        --protocol "${server[protocol]}" --hostname "${server[host]}" --port "${server[port]}" \
        --username "${_CREDENTIALS[username]}" --password "${_CREDENTIALS[password]}" \
        --output-format csv --header false \
        -f JobID -f ArchivalDate -f ReportHandle -f Status -f Lines -f JobName -f ReportName  \
        --filter-name "${reportNameFilter}" \
        --from "${dateFrom}" --to "${dateTo}" >"${reportList}" 2>/dev/null

    while read -r reportMetadata; do
        local fullMetadata="${repositoryUniqueId},${reportMetadata}"

        local -A report
        parseReportMetadata "report" "${fullMetadata}"

        if [ "${report[lines]}" -le "${maxLines}" ]; then
            _reports+=("${fullMetadata}")
        fi
    done <"${reportList}"
}

function downloadReport() {
    local -n _filePath="$1"; shift
    local reportMetadata="$*"

    declare -A report
    parseReportMetadata "report" "${reportMetadata}"

    if [ "${report[status]}" != "ONLINE" ]; then
        return 1
    fi

    declare -A repository
    getRepository "repository" "${report[repository]}"

    declare -A server
    getServer "server" "${repository[server]}"

    local fileName=$(getReportFileName "${server[name]}" "${report[name]}" "${report[jobid]}")
    _filePath="${downloadDir}/${fileName}"

    zowe caview download report \
        "${repository[identifier]}" "${report[handle]}" "${_filePath}" \
        --protocol "${server[protocol]}" --hostname "${server[host]}" --port "${server[port]}" \
        --username "${_CREDENTIALS[username]}" --password "${_CREDENTIALS[password]}"
}

function printReportInformation() {
    local prefix="$1"; shift
    local reportMetadata="$*"

    declare -A report
    parseReportMetadata "report" "${reportMetadata}"

    declare -A repository
    getRepository "repository" "${report[repository]}"

    declare -A server
    getServer "server" "${repository[server]}"

    maxDigits=${#maxLines}

    printf "%s(%s) %-10s [%8s:%8s] archived %s contains %${maxDigits}d lines.\n" \
        "${prefix}" "${server[name]}" "${report[name]}" \
        "${report[jobname]}" "${report[jobid]}" "${report[archived]}" "${report[lines]}"
}

function printOperationSummary() {
    echo "[Operation Summary]"
    echo "Maximum lines ..... ${maxLines}"
    echo "Name filter ....... ${reportNameFilter}"
    echo "Archival range .... ${dateFrom} -> ${dateTo}"
    echo "Download report ... $(readableBoolean ${download})"
    if ${download}; then
    echo "Download path ..... ${downloadDir}"
    fi
    echo "Print report ...... $(readableBoolean ${print})"
    echo "${_SEPARATOR}"
}

############################

source "$(dirname "$0")/common.sh"

checkZoweSetup

reportNameFilter=$NAME_FILTER_DEFAULT
maxLines=$MAX_LINES_DEFAULT
dateFromRaw=$DATE_FROM_DEFAULT
dateToRaw=$DATE_TO_DEFAULT
download=false
downloadDir=$DOWNLOAD_DIR_DEFAULT
print=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            printHelp
            exit 0
            ;;
        --name)
            reportNameFilter=$2
            shift
            ;;
        --lines)
            maxLines=$2
            shift
            ;;
        --from)
            dateFromRaw=$2
            shift
            ;;
        --to)
            dateToRaw=$2
            shift
            ;;
        --download)
            download=true
            ;;
        --download-dir)
            downloadDir=$2
            shift
            ;;
        --print)
            download=true
            print=true
            ;;
    esac
    shift
done

set -e # Exit if any provided date specifications are invalid
dateFrom=$(convertDate "${dateFromRaw}")
dateTo=$(convertDate "${dateToRaw}")
validateDates "${dateFrom}" "${dateTo}"
set +e

loadServerDefinitions

printOperationSummary

gatherUserCredentials

checkServerStates

loadServerRepositories

echo "Looking for reports matching provided criteria ..."

declare -a smallReports
for repositoryUniqueId in "${!_REPOSITORIES[@]}"; do
    declare -A repository
    getRepository "repository" "${repositoryUniqueId}"

    echo "  - (${repository[server]}) ${repository[name]}"

    findSmallReports "smallReports" "${repositoryUniqueId}" \
        "${maxLines}" "${reportNameFilter}" "${dateFrom}" "${dateTo}"
done

reportsFound=${#smallReports[@]}
if [ "${reportsFound}" -le 0 ]; then
    echo "No matching reports were found."
    exit 0
fi

echo "A total of ${reportsFound} matching report(s) were found:"
for reportMetadata in "${smallReports[@]}"; do
    printReportInformation "  - " "${reportMetadata}"

    if ${download}; then
        declare filePath

        downloadReport "filePath" "${reportMetadata}"

        if ${print} && [ $? -eq 0 ]; then
            echo "${_SEPARATOR}"
            cat "${filePath}"
            echo "${_SEPARATOR}"
        fi
    fi | sed -e 's/^/    /'
done
