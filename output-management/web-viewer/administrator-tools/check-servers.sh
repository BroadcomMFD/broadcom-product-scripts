#!/usr/bin/env bash

###
### To get help information run the script with the --help argument.
###

############################

function printHelp() {
    cat <<EOHELP
USAGE

    $0

    This script checks the availability and basic status information of all the servers defined in
    the ${_SERVER_DEFINITIONS} file. Summary information for each server is printed to
    standard output. Optionally a list of repositories defined to each server can also be printed.
    Any combination of the following arguments can be specified to customize the script behavior.

        --help               Prints this help text, then exits.

        --repositories       If specified, the output will also contain a list of repositories
                             defined to each server.


EXAMPLES

    List all servers, their current availability, and status information:

        $0

    List all servers, their current availability, status information, and defined repositories:

        $0 --repositories
EOHELP
}

function printServerSummary() {
    local serverName="$1"
    local listRepositories=$2

    local -A status
    getStatus "status" "${serverName}"

    local task
    if [ "${status[jobname]}" = "${_METADATA_UNKNOWN}" ]; then
        task="${_METADATA_UNKNOWN}"
    else
        task="${status[jobname]}:${status[jobid]}"
    fi

    echo "[${serverName}]"
    echo "Available ... $(readableBoolean "${status[available]}")"
    echo "Version ..... ${status[version]}"
    echo "Sysplex ..... ${status[sysplex]}"
    echo "LPAR ........ ${status[lpar]}"
    echo "Task ........ ${task}"

    if ! ${listRepositories}; then
        return
    fi

    echo "Repositories:"
    for repositoryUniqueId in "${!_REPOSITORIES[@]}"; do
        declare -A repository
        getRepository "repository" "${repositoryUniqueId}"

        if [ "${repository[server]}" = "${serverName}" ]; then
            echo "  - ${repository[name]} (${repository[path]})"
        fi
    done
}

############################

source "$(dirname "$0")/common.sh"

checkZoweSetup

listRepositories=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help)
            printHelp
            exit 0
            ;;
        --repositories)
            listRepositories=true
            ;;
    esac
    shift
done


loadServerDefinitions

gatherUserCredentials

checkServerStates

if $listRepositories; then
    loadServerRepositories
fi

echo "${_SEPARATOR}"
for serverName in "${_ORDER[@]}"; do
    printServerSummary "${serverName}" ${listRepositories}
    echo "${_SEPARATOR}"
done
