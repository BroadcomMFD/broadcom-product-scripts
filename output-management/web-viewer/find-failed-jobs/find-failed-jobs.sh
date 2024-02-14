#!/bin/bash

###
### To get help information run the script with the --help argument.
###
### This script has been designed to be compatible with the following platforms:
### - Linux
### - Windows using Git Bash.
###   Tested with Git for Windows 2.43.0: https://git-scm.com/download/win
### - macOS with the GNU date (gdate) and GNU grep (ggrep) executables installed.
###   GNU date and GNU grep can be installed for example using Homebrew, see:
###     - https://formulae.brew.sh/formula/coreutils
###     - https://formulae.brew.sh/formula/grep
###
### Zowe CLI and the Zowe CLI View plugin must be installed and configured
### before use. You must also specify a value for any empty variable in the
### CONFIGURATION section below.
###

### CONFIGURATION ###

# Dataset prefix of the View database you wish to use.
VIEW_DATABASE=

# Line used to visually separate parts of matched job output.
SEPARATOR='----------'

# Default job name filter pattern.
NAME_FILTER_DEFAULT='*'

# Default start of searched archival range.
DATE_FROM_DEFAULT='yesterday'

# Default end of searched archival range.
DATE_TO_DEFAULT='today'

# Default number of context lines to print for search matches.
CONTEXT_DEFAULT=3

########################################

function printHelp() {
    cat <<EOHELP
USAGE

    $0 [OPTION]...

    The script will use the View Zowe CLI plugin to locate failed jobs in a single View database and
    optionally search for text within the job outputs. Any combination of the following arguments
    can be specified to customize the script behavior.

        --help              Prints this help text, then exits.

        --name <pattern>    Job name filter pattern. Can contain an asterisk as a wildcard.
                            Defaults to '${NAME_FILTER_DEFAULT}'.

        --xcode <xcode>     Job XCode (exception) value.
                            By default all non-empty XCode values are matched.

        --from <from>       Start of the searched archival date range.
                            Only supports day resolution, time information is ignored.
                            Defaults to '${DATE_FROM_DEFAULT}'.

        --to <to>           End of the searched archival date range.
                            Only supports day resolution, time information is ignored.
                            Defaults to '${DATE_TO_DEFAULT}'.

        --download          Download the output of each found job into the current directory.
                            The file name format is '$(getDownloadFileName '<jobname>' '<jobid>')'.
                            Existing files with matching names will be overwritten!

        --search <text>     Search for specified text within the identified jobs.
                            Matches are included in the output and saved into a file.
                            The file name format is '$(getSearchFileName '<jobname>' '<jobid>')'.
                            Existing files with matching names will be overwritten!
                            If specified, the --download argument is implicitly enabled.

        --context <lines>   Number of context lines before and after any matched lines that will be
                            included in the output. You can specify '0' to only output the matched
                            lines. This argument is ignored if '--search' is not specified.
                            Defaults to '${CONTEXT_DEFAULT}'.

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

        VIEW_DATABASE       Dataset prefix of the View database you wish to use.
                            A repository referencing this View database must be configured within
                            your Web Viewer instance.
                            The value can be obtained for example from the Web Viewer repository
                            list page or the first line of the View 3270 primary selection screen.

        SEPARATOR           A string used for visual separation of individual sections of matched
                            job output when using the '--search' argument.

        NAME_FILTER_DEFAULT Specifies the default value for the '--name' argument.

        DATE_FROM_DEFAULT   Specifies the default value for the '--from' argument.

        DATE_TO_DEFAULT     Specifies the default value for the '--to' argument.

        CONTEXT_DEFAULT     Defines the default value for the '--context' argument.


EXAMPLES

    Where not specified explicitly the search job archival date range is between
    '${DATE_FROM_DEFAULT}' and '${DATE_TO_DEFAULT}'.

    Find all failed jobs:

        $0

    Find failed jobs that start with EVJDA:

        $0 --name 'EVJDA*'

    Find all jobs that failed with exception code 4095:

        $0 --xcode 4095

    Find jobs that start with EVJDA and failed with exception code 4095:

        $0 --name 'EVJDA*' --xcode 4095

    Find all failed jobs from the last 14 days:

        $0 --from "14 days ago"

    Find all failed jobs from the year 2023:

        $0 --from 2023-01-01 --to 2023-12-31

    Find jobs that failed with exception code 4095 and download their content:

        $0 --xcode 4095 --download

    Find all jobs that failed with exception code 4095.
    Download and search the output of these jobs for the text 'ERROR':

        $0 --xcode 4095 --search 'ERROR'
EOHELP
}

# Prints a summary of the actions the script will take.
function printSummary() {
    if [ "${jobNameFilter}" == '*' ]; then
        jobNameScope="jobs"
    else
        jobNameScope="'${jobNameFilter}' jobs"
    fi

    echo "Will look for ${jobNameScope} ${xcodeScope} between '${dateFromRaw}' and '${dateToRaw}' in View database ${VIEW_DATABASE}."

    if [ ${download} -eq 1 ]; then
        echo "The output of each found job will be downloaded into the current working directory."
    fi

    if [ -n "${search}" ]; then
        if [ ${context} -ne 0 ]; then
            contextScope=" with ${context} preceding and trailing lines"
        else
            contextScope=""
        fi

        echo "Will search for text '${search}' within output of found jobs and print matched lines${contextScope}."
    fi

    echo
}

# Converts date specification into standard ISO8601 format.
function convertDateTime() {
    ${gdate} -d "${1}" --iso-8601
}

# Formats date using active locale settings.
function formatDateTime() {
    ${gdate} --date="${1}"
}

# Returns a filename that should be safe across all supported platforms.
function getSafeFileName() {
    echo "$@" | tr '<>:"/\\|?*"' _
}

# Returns the safe filename used for downloaded job output.
function getSafeDownloadFileName() {
    getSafeFileName $(getDownloadFileName $@)
}

# Returns the safe filename used for job content matches.
function getSafeSearchFileName() {
    getSafeFileName $(getSearchFileName $@)
}

# Returns the filename used for downloaded job output.
function getDownloadFileName() {
    echo "$1-$2.txt"
}

# Returns the filename used for job content matches.
function getSearchFileName() {
    echo "$1-$2-matches.txt"
}

# Outputs error message and terminates the script.
function error() {
    echo "(ERROR) $@" >&2
    exit 1
}

### Logic ###

# MacOS compatibility logic.
if [[ "${OSTYPE}" == "darwin"* ]]; then
    # Requires GNU date
    command -v gdate >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        gdate=gdate
    else
        error "GNU date must be installed in order to run this script on macOS."
    fi

    # Requires GNU grep
    command -v ggrep >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        ggrep=ggrep
    else
        error "GNU grep must be installed in order to run this script on macOS."
    fi
else
    gdate=date
    ggrep=grep
fi

# Establish defaults.
jobNameFilter=$NAME_FILTER_DEFAULT
xcodeFilter="[^,]\\+"
xcodeScope="failed with any exception code"
dateFromRaw=$DATE_FROM_DEFAULT
dateToRaw=$DATE_TO_DEFAULT
download=0
search=
context=$CONTEXT_DEFAULT

# Parse provided arguments.
while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            printHelp
            exit 0
            ;;
        --name)
            jobNameFilter=$2
            shift
            ;;
        --xcode)
            if [ -z "$2" ]; then
                error "An empty xcode filter value is not supported."
            fi
            xcodeFilter=$2
            xcodeScope="failed with exception code ${xcodeFilter}"
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
            download=1
            ;;
        --search)
            download=1
            search=$2
            ;;
        --context)
            context=$2
            ;;
    esac
    shift
done

set -e # Exit if any provided date specifications are invalid
dateFrom=$(convertDateTime "${dateFromRaw}")
dateTo=$(convertDateTime "${dateToRaw}")
set +e

# Check if required configuration values are set.
if [ -z "${VIEW_DATABASE}" ]; then
    error "The VIEW_DATABASE configuration value must be set first at the beginning of the script."
fi

# Lookup which Web Viewer repository matches the requested View database.
repository=$(zowe caview list repositories \
    --output-format csv \
    --header false \
    --filter-path ${VIEW_DATABASE} \
    -f Identifier \
    | head -n 1)

if [ -z "$repository" ]; then
    error "Unable to find a Web Viewer repository for View database '${VIEW_DATABASE}'."
fi

IFS=',' read repositoryId <<< "${repository}"

# Output summary of what will be done.
printSummary

# Search for matching jobs.
zowe caview list reports \
    $repositoryId \
    --output-format csv \
    --header false \
    -f JobName -f JobID -f ArchivalDate -f ReportHandle -f XCode \
    --filter-name "${jobNameFilter}" \
    --from ${dateFrom} \
    --to ${dateTo} \
    | ${ggrep} ",${xcodeFilter}$" \
    | while read report; do

    IFS=',' read jobName jobId dateTime handle xcode <<< "${report}"

    formattedDateTime=$(formatDateTime "${dateTime}")

    printf "Job %8s (%8s) failed with XCode %6s on %s.\n" \
        "${jobName}" "${jobId}" "${xcode}" "${formattedDateTime}"

    # Download job content if requested.
    if [ ${download} -eq 1 ]; then
        downloadFile=$(getSafeDownloadFileName "${jobName}" "${jobId}")

        zowe caview download report ${repositoryId} ${handle} "${downloadFile}"

        # Search for text within job content if requested.
        if [ -n "${search}" ]; then
            searchFile=$(getSafeSearchFileName "${jobName}" "${jobId}")

            ${ggrep} \
                --context ${context} \
                --line-number \
                --initial-tab \
                --group-separator "${SEPARATOR}" \
                "${search}" \
                "${downloadFile}" \
                > "${searchFile}"

            if [ $? -eq 0 ]; then
                echo "The following content matches were found (also saved into ${searchFile}):"
                echo "${SEPARATOR}"
                cat ${searchFile}
                echo "${SEPARATOR}"
            else
                echo "No content matches found."
                rm ${searchFile}
            fi
        fi
    fi

    echo
done
