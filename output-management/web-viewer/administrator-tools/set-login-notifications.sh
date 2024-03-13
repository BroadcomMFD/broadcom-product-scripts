#!/bin/bash

###
### To get help information run the script with the --help argument.
###

### CONFIGURATION ###

# Status indicator for the current server.
STATUS_CURRENT=⬤
# Status indicator for other servers that are currently available.
STATUS_AVAILABLE=🟢
# Status indicator for other servers that are not currently available.
STATUS_DOWN=🔴

############################

_ONE_OF_ARGUMENTS="--content, --servers, --status, --disable"
function printHelp() {
    cat <<EOHELP
USAGE

    $0 [OPTION]...

    This script allows you to update the login notification settings across all the servers defined
    in the ${_SERVER_DEFINITIONS} file. The script supports inclusion of a free-form text, directory
    of all servers, and status of all servers. Disabling the login notifications is also supported.

    Any combination of the following arguments can be specified to customize the script behavior.

        --help           Prints this help text, then exits.

        --content <file> Includes the content of the specified file in the generated login
                         notification. The file must contain Markdown formatted text.
                         This argument can be specified multiple times, in which case the
                         individual contents will be included in the specified order.

        --servers        If specified, the generated notification text will contain a section
                         listing all servers separated into their groups, including their
                         description. This content will be included at the end of the generated
                         notification text.

        --status         If specified, the generated notification text will contain information
                         about the current availability (online/offline) of each server.
                         If specified, the --servers argument is implicitly enabled.

        --status-legend  If specified, a legend describing the meaning of server status indicator
                         characters is included in the generated notification text. 
                         This argument is ignored if --status is not specified.

        --update-time    If specified, the generated notification text identifies the date and
                         of its last update done through this script.

        --acknowledge    If specified, the notification will be configured to require user
                         acknowledgement before presenting the login dialog.

        --disable        Disables login notifications and removes any previously configured content.
                         If specified, all other arguments are ignored.

        At least one of the following arguments must be specified: ${_ONE_OF_ARGUMENTS}


CONFIGURATION

    The following configuration variables are set within the CONFIGURATION section at the start of
    this script.

        STATUS_CURRENT   Character used to indicate the current server within the generated
                         notification text when the --status argument is used.
                         Current value: ${STATUS_CURRENT}

        STATUS_AVAILABLE Character used to indicate another server that is currently available
                         within the generated notification text when the --status argument is used.
                         Current value: ${STATUS_AVAILABLE}

        STATUS_DOWN      Character used to indicate another server that is currently not available
                         within the generated notification text when the --status argument is used.
                         Current value: ${STATUS_DOWN}


EXAMPLES

    Disable the login notifications:

        $0 --disable

    Enable login notifications, include a directory of all servers, do not require acknowledgement:

        $0 --servers

    Enable login notifications, include a directory of all servers along with indication of their
    current status, do not require acknowledgement:

        $0 --status

    Enable login notifications, include content from two files, require acknowledgement:

        $0 --content examples/banner.md --content examples/new-features.md --acknowledge

    Enable login notifications, include content from a file, include timestamp identifying last
    update time, do not require acknowledgement:

        $0 --content examples/maintenance.md --update-time
EOHELP
}

function buildConfiguration() {
    local enabled=$1
    local acknowledge=$2
    local contentFile=$3

    echo -n "{\"enabled\":${enabled},\"acknowledgement\":${acknowledge},\"content\":\""

    # Escape double quotes and backslashes.
    # Change any real newlines into escape sequences.
    sed 's/\(["\]\)/\\\1/g' "${contentFile}" | awk 1 ORS='\\n'
    echo -n '"}'
}

function buildStaticContent() {
    local file=$1

    cat "${file}"
}

function buildDirectory() {
    local targetServerName=$1
    local includeStatus=$2
    local includeStatusLegend=$3

    c="\n\n# Directory of Servers\n"
    for group in "${_GROUPS[@]}"; do
        c+="**[${group}]**\n"

        local serverName
        for serverName in "${_ORDER[@]}"; do
            declare -A server
            getServer "server" "${serverName}"

            if [ "${server[group]}" != "${group}" ]; then
                continue;
            fi

            local isTargetServer
            if [ "${serverName}" = "${targetServerName}" ]; then
                isTargetServer=true
            else
                isTargetServer=false
            fi

            # Approximation for detecting Angular vs React versions.
            if isServerOld "${serverName}"; then
                uiUrl="${server[url]}"
            else
                uiUrl="${server[url]}/ui/login"
            fi

            local statusIcon
            if ! $includeStatus; then
                statusIcon=""
            elif $isTargetServer; then
                statusIcon="${STATUS_CURRENT} "
            elif isServerAvailable "${serverName}"; then
                statusIcon="${STATUS_AVAILABLE} "
            else
                statusIcon="${STATUS_DOWN} "
            fi

            if $isTargetServer; then
                c+="${statusIcon}**${serverName}** - ${server[description]}\n"
            else
                c+="[${statusIcon}${serverName}](${uiUrl}) - ${server[description]}\n"
            fi
        done

        c+="\n"
    done

    if $includeStatus && $includeStatusLegend; then
        c+="_Legend_\n"
        c+="${STATUS_CURRENT} - _indicates the current server_\n"
        c+="${STATUS_AVAILABLE} - _indicates other available server_\n"
        c+="${STATUS_DOWN} - _indicates server is currently not available_\n"
    fi

    echo -n -e "${c}"
}

function buildTimestamp() {
    echo -n -e "\n\n_(Last Updated: $(${gnudate} --rfc-3339=s))_"
}

function printOperationSummary() {
    echo "[Operation Summary]"
    echo "Enable notifications ....... $(readableBoolean ${enableNotifications})"
    if $enableNotifications; then
    echo "Include server directory ... $(readableBoolean ${includeServers})"
    echo "Include server status ...... $(readableBoolean ${includeStatus})"
    echo "  ... with status legend ... $(readableBoolean ${includeStatusLegend})"
    echo "Include timestatmp ......... $(readableBoolean ${includeTimestamp})"
    if [ ${#contentFiles[@]} -le 0 ]; then
    echo "Include static content ..... $(readableBoolean false)"
    else
    echo "Include static content:"
    local file
    for file in "${contentFiles[@]}"; do
    echo "  - ${file}"
    done
    fi
    fi

    echo "${_SEPARATOR}"
}

############################

source "$(dirname "$0")/common.sh"

enableNotifications=true
includeServers=false
includeStatus=false
includeStatusLegend=false
includeTimestamp=false
acknowledge=false

declare -a contentFiles

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            printHelp
            exit 0
            ;;
        --content)
            if [ ! -r "${2}" ]; then
                error "File '${2}' does not exist or is not readable."
            fi

            contentFiles+=("$2")
            shift
            ;;
        --servers)
            includeServers=true
            ;;
        --status)
            includeServers=true
            includeStatus=true
            ;;
        --status-legend)
            includeStatusLegend=true
            ;;
        --update-time)
            includeTimestamp=true
            ;;
        --acknowledge)
            acknowledge=true
            ;;
        --disable)
            enableNotifications=false
            ;;
    esac
    shift
done

if ! ( (! $enableNotifications) || $includeServers || [ ${#contentFiles[@]} -gt 0 ]); then
    error "You must specify least one of the arguments: ${_ONE_OF_ARGUMENTS}"
fi

loadServerDefinitions

printOperationSummary

gatherUserCredentials

checkServerStates

echo "Updating login notification configuration ..."
for serverName in "${_ORDER[@]}"; do
    printf " %8s ..." "${serverName}"

    if ! isServerAvailable "${serverName}"; then
        echo " skipped"
        continue
    fi

    content=$(mktemp)

    if $enableNotifications; then
        for file in "${contentFiles[@]}"; do
            buildStaticContent "${file}" >> "${content}"
        done

        if $includeServers; then
            buildDirectory "${serverName}" ${includeStatus} ${includeStatusLegend} >> "${content}"
        fi

        if $includeTimestamp; then
            buildTimestamp >>"${content}"
        fi
    fi

    json=$(mktemp)
    buildConfiguration "${enableNotifications}" "${acknowledge}" "${content}" >"${json}"

    apiRequest "${serverName}" PUT "v1/configuration/ui/loginSplashScreen" "${json}" >/dev/null
    if [ $? -eq 0 ]; then
        echo " OK"
    else
        echo " Failed"
    fi
done
