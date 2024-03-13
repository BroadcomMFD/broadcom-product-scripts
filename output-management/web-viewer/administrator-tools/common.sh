#!/bin/bash

###
### Common logic shared by multiple sample scripts in the directory.
###

####################

# Name of file containing server definitions.
_SERVER_DEFINITIONS="$(dirname "$0")/servers.txt"
# Label used for unknown metadata values.
_METADATA_UNKNOWN="unknown"
# Line used as visual separator in various outputs.
_SEPARATOR='--------------------'

####################

# Ordered set of defined groups.
declare -a _GROUPS
# Associative array of defined servers.
# Key is server name.
# Value is the server metadata as supported by parseServerMetadata().
declare -A _SERVERS
# Ordered set of server names.
declare -a _ORDER
# Server status information.
# Key is server name.
# Value is the server status metadata as supported by parseStatusMetadata().
declare -A _STATUS
# Associative array of all discovered repositories.
# Key is concatenated server name and repository id.
# Value is the repository metadata as supported by parseRepositoryMetadata().
declare -A _REPOSITORIES
# Authenticated session token for each Server.
# Key is server name. Value is a session token.
declare -A _SESSIONS
# User credentials (username and password).
declare -A _CREDENTIALS

function apiLogin() {
    local serverName="$1"
    local userName="$2"
    local userPassword="$3"
    local responseHeaders="$(mktemp)"
    local -A server

    getServer "server" "$serverName"

    curl --request POST \
        --silent --show-error \
        --output /dev/null --dump-header "${responseHeaders}" \
        --basic --user "${userName}:${userPassword}" \
        "${server[api]}/v1/view/login" 

    if [ $? -ne 0 ]; then
        return 1
    fi

    if ! isHttpSuccess "${responseHeaders}"; then
        return 2
    fi

    local guid
    guid=$(sed -nr 's/^guid: ([[:alnum:]]{64})[[:space:]]*$/\1/p' "${responseHeaders}" | tr -d '\r\n')

    if [ -z "${guid}" ]; then
        return 3
    fi

    saveSession "${serverName}" "${guid}"
    return 0
}

function apiRequest() {
    local serverName="$1"
    local httpMethod="$2"
    local apiEndpoint="$3"
    local requestBodyFile="$4"

    local -A server
    getServer "server" "${serverName}"

    local responseHeaders=$(mktemp)
    local responseBody=$(mktemp)

    if [ -n "${requestBodyFile}" ]; then
        local contentType="application/json"
        if [ "${apiEndpoint}" = "v1/configuration/ui/loginSplashScreen" ]; then
            # Approximation for detection of APIs that require a different content
            # type for this operation. Working around broken API compatibility.
            if isServerOld "${serverName}"; then
                contentType="text/plain"
            fi
        fi

        curl --request "${httpMethod}" \
            --silent --show-error \
            --output "${responseBody}" --dump-header "${responseHeaders}" \
            --header "guid: $(getSession "${serverName}")" \
            --header "Content-Type: ${contentType}" \
            --data @"${requestBodyFile}" \
            "${server[api]}/${apiEndpoint}"
    else
        curl --request "${httpMethod}" \
            --silent --show-error \
            --output "${responseBody}" --dump-header "${responseHeaders}" \
            --header "guid: $(getSession "${serverName}")" \
            "${server[api]}/${apiEndpoint}"
    fi

    if [ $? -ne 0 ]; then
        return 1
    fi

    if ! isHttpSuccess "${responseHeaders}"; then
        return 2
    fi

    cat "${responseBody}"
    return 0
}

function isHttpSuccess() {
    local responseHeaders="$1"

    ${gnugrep} --extended-regexp --quiet \
        "HTTP/[[:digit:]]\.[[:digit:]] 2[[:digit:]]{2}" \
        "${responseHeaders}"
}

function addGroup() {
    local groupName="$*"

    local existing
    for existing in "${_GROUPS[@]}"; do
        if [ "${existing}" = "${groupName}" ]; then
            return 0
        fi
    done

    _GROUPS+=("${groupName}")
}

function parseServerMetadata() {
    local -n _server="$1"; shift
    local serverMetadata="$*"

    IFS=';'; local split=(${serverMetadata}); unset IFS

    _server[name]=${split[0]}
    _server[protocol]=${split[1]}
    _server[host]=${split[2]}
    _server[port]=${split[3]}
    _server[description]=${split[4]}
    _server[group]=${split[5]}

    if ! [[ "${_server[protocol]}" =~ ^https?$ ]]; then
        error "Unsupported protocol '${_server[protocol]}' specified for server ${_server[name]}."
    fi

    if ! [[ ${_server[port]} =~ ^[0-9]+$ && ${_server[port]} -ge 1 && ${_server[port]} -le 65535 ]]; then
        error "Invalid port '${_server[port]}' specified for server ${_server[name]}."
    fi


    local baseUrl="${_server[protocol]}://${_server[host]}:${_server[port]}/web-viewer"
    _server[url]="${baseUrl}"
    _server[api]="${baseUrl}/api"
}

function parseRepositoryMetadata() {
    local -n _repository="$1"; shift
    local repositoryMetadata="$*"

    IFS=','; local split=(${repositoryMetadata}); unset IFS

    _repository[server]=${split[0]}
    _repository[identifier]=${split[1]}
    _repository[path]=${split[2]}
    # Allow for repository name to contain commas
    if [ "${#split[@]}" -le 4 ]; then
        _repository[name]=${split[3]}
    else
        local combinedName=$(echo "${repositoryMetadata}" | cut -d ',' -f 4-)
        _repository[name]=${combinedName:1:-1}
    fi
}

function parseStatusMetadata() {
    local -n _status="$1"; shift
    local statusMetadata="$*"

    IFS=';'; local split=(${statusMetadata}); unset IFS

    _status[available]=${split[0]}
    _status[sysplex]=${split[1]}
    _status[lpar]=${split[2]}
    _status[jobname]=${split[3]}
    _status[jobid]=${split[4]}
    _status[version]=${split[5]}
}

function addServer() {
    local serverMetadata="$*"

    local -A server
    parseServerMetadata "server" "$serverMetadata"

    if [ -n "${_SERVERS[${server[name]}]}" ]; then
        error "Duplicate server name specified in definition: ${server[name]}"
    fi

    _SERVERS[${server[name]}]="$serverMetadata"
    _ORDER+=("${server[name]}")
}

function addStatus() {
    local serverName="$1"
    local isAvailable=$2
    local sysplex="$3"
    local lpar="$4"
    local jobname="$5"
    local jobid="$6"
    local version="$7"

    _STATUS[${serverName}]="${isAvailable};${sysplex};${lpar};${jobname};${jobid};${version}"
}

function addStatusUnknown() {
    local serverName="$1"
    local isAvailable=$2

    addStatus "${serverName}" "${isAvailable}" "${_METADATA_UNKNOWN}" "${_METADATA_UNKNOWN}" \
        "${_METADATA_UNKNOWN}" "${_METADATA_UNKNOWN}" "${_METADATA_UNKNOWN}"
}

function addRepository() {
    local repositoryMetadata="$*"
    local -A repository

    parseRepositoryMetadata "repository" "$repositoryMetadata"

    local repositoryUniqueName="${repository[server]}${repository[identifier]}"

    _REPOSITORIES[$repositoryUniqueName]="$repositoryMetadata"
}

function getServer() {
    local outputVariable=$1
    local serverName=$2

    parseServerMetadata "${outputVariable}" "${_SERVERS[${serverName}]}"
}

function getStatus() {
    local outputVariable=$1
    local serverName=$2

    parseStatusMetadata "${outputVariable}" "${_STATUS[${serverName}]}"
}

function getRepository() {
    local outputVariable=$1
    local repositoryUniqueName=$2

    parseRepositoryMetadata "${outputVariable}" "${_REPOSITORIES[${repositoryUniqueName}]}"
}

function isServerAvailable() {
    local serverName="$1"

    local -A status
    getStatus "status" "${serverName}"

    if ${status[available]}; then
        return 0
    else
        return 1
    fi
}

# Identifies a server instance that does not support the status API endpoint.
function isServerOld() {
    local serverName="$1"

    local -A status
    getStatus "status" "${serverName}"

    if [ "${status[version]}" = "${_METADATA_UNKNOWN}" ]; then
        return 0
    else
        return 1
    fi
}

function saveSession() {
    local serverName="$1"
    local guid="$2"

    _SESSIONS[${serverName}]="${guid}"
}

function getSession() {
    local serverName="$1"

    echo "${_SESSIONS[${serverName}]}"
}

function checkAvailability() {
    local serverName="$1"

    local -A server
    getServer "server" "$serverName"

    bash -c "</dev/tcp/${server[host]}/${server[port]}" 2>/dev/null
    if [ $? -ne 0 ]; then
        return 1
    fi

    if ! apiLogin "${serverName}" "${_CREDENTIALS[username]}" "${_CREDENTIALS[password]}"; then
        error "Failed to log in. Stopping execution to avoid account lockout."
    fi

    return 0
}

function loadServerDefinitions() {
    echo "Loading server definitions ..."

    if [ ! -r "${_SERVER_DEFINITIONS}" ]; then
        error "Servers definition file ${_SERVER_DEFINITIONS} does not exist or is not readable."
    fi

    # Normalize line endings.
    local fileEndings=$(file --dereference "${_SERVER_DEFINITIONS}" \
        | ${gnugrep} --extended-regexp 'CR[^ ]*' --only-matching)
    local unifiedServerDefinitions
    case "${fileEndings}" in
        "CRLF")
            unifiedServerDefinitions=$(mktemp)
            dos2unix --quiet --remove-bom --newfile \
                "${_SERVER_DEFINITIONS}" "${unifiedServerDefinitions}"
            ;;
        "CR")
            unifiedServerDefinitions=$(mktemp)
            mac2unix --quiet --remove-bom --newfile \
                "${_SERVER_DEFINITIONS}" "${unifiedServerDefinitions}"
            ;;
        *)
            unifiedServerDefinitions="${_SERVER_DEFINITIONS}"
            ;;
    esac

    currentGroup=""
    while IFS='' read -r line || [ -n "${line}" ]; do
        if [ -z "${line// }" ]; then # Empty or blank line
            continue
        elif [[ "${line}" == "#"* ]]; then # Comment
            continue
        elif [[ "${line}" == "["* ]]; then # Group start
            if ! [[ "${line}" == *"]" ]]; then
                error "Group names must be enclosed between brackets ([...]): \`${line}\`"
            fi

            group="${line:1:-1}"
            if [ -z "${group}" ]; then
                error "Group names can not be empty."
            fi

            addGroup "${group}"
            currentGroup="${group}"
        else # Server definition
            addServer "${line};${currentGroup}"
        fi
    done <"${unifiedServerDefinitions}"

    if [ "${#_SERVERS[@]}" -le 0 ]; then
        error "At least one server must be defined."
    fi
}

function loadServerStatus() {
    local serverName="$1"

    if ! checkAvailability "${serverName}"; then
        addStatusUnknown "${serverName}" "false"
        return 0
    fi

    local status=$(mktemp)
    apiRequest "${serverName}" GET "v2/server/status" >"${status}"
    if [ $? -eq 0 ]; then
        local sysplex=$(sed -nr 's/.*sysplexName":"([^"]+).*/\1/p' "${status}")
        local lpar=$(sed -nr 's/.*lparName":"([^"]+).*/\1/p' "${status}")
        local jobname=$(sed -nr 's/.*jobName":"([^"]+).*/\1/p' "${status}")
        local jobid=$(sed -nr 's/.*jobId":"([^"]+).*/\1/p' "${status}")
        local version=$(sed -nr 's/.*productVersion":"([^"]+).*/\1/p' "${status}")

        addStatus "${serverName}" "true" "${sysplex}" "${lpar}" "${jobname}" "${jobid}" "${version}"
    else
        addStatusUnknown "${serverName}" "true"
    fi
}

function loadServerRepositories() {
    for serverName in "${_ORDER[@]}"; do
        local -A server
        getServer "server" "$serverName"

        if ! isServerAvailable "${serverName}"; then
            continue;
        fi

        echo "Loading repositories for server ${server[name]} ..."

        local repositories=$(mktemp)

        zowe caview list repositories \
            --protocol "${server[protocol]}" --hostname "${server[host]}" --port "${server[port]}" \
            --username "${_CREDENTIALS[username]}" --password "${_CREDENTIALS[password]}" \
            --output-format csv --header false \
            -f Identifier -f Path -f Name>"${repositories}"

        while read -r repositoryMetadata; do
            addRepository "${server[name]},${repositoryMetadata}"
        done <"${repositories}"
    done
}

function checkServerStates() {
    echo "Checking availability and loading status information ..."

    for serverName in "${_ORDER[@]}"; do
        loadServerStatus "${serverName}"
    done
}

function gatherUserCredentials() {
    echo "Please provide your (administrator) credentials."
    read    -r -p "Username: " username
    read -s -r -p "Password: " password
    echo

    _CREDENTIALS[username]="${username}"
    _CREDENTIALS[password]="${password}"
}

function stopExecution() {
    echo
    echo "Execution stopped."
    exit
}

function cleanupFiles() {
    if [ -n "${TMPDIR}" ] && [ -d "${TMPDIR}" ]; then
        rm -r "${TMPDIR}"
    fi
}

function error() {
    echo
    echo "(ERROR) $*" >&2
    exit 1
}

function checkZoweSetup() {
    if ! command -v zowe >/dev/null 2>&1; then
        error "Zowe CLI must be installed to run this script."
    fi

    if ! zowe plugins validate '@broadcom/caview-for-zowe-cli' >/dev/null 2>&1; then
        error "The View Plug-in for Zowe CLI must be installed to run this script."
    fi
}

function readableBoolean() {
    local boolean=$1

    if ${boolean}; then
        echo "Yes"
    else
        echo "No"
    fi
}

####################

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    error "This script is not designed to be executed directly."
fi

# Setup signal traps
trap stopExecution SIGINT
trap cleanupFiles  EXIT

# Setup common temporary directory.
export TMPDIR=$(mktemp -d)

# Establish MacOS compatibility.
if [[ "${OSTYPE}" == "darwin"* ]]; then
    # Requires GNU date
    if command -v gdate >/dev/null 2>&1; then
        gnudate="gdate"
    else
        error "GNU date (gdate) must be installed in order to run this script on macOS."
    fi

    # Requires GNU grep
    if command -v ggrep >/dev/null 2>&1; then
        gnugrep="ggrep"
    else
        error "GNU grep (ggrep) must be installed in order to run this script on macOS."
    fi
else
    gnudate="date"
    gnugrep="grep"
fi
