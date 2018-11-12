#!/bin/bash -eu

JENKINS_UC_URL=http://updates.jenkins-ci.org/download/plugins
DEST_DIR=${REF:-/usr/share/jenkins/ref/plugins}
FAILED="$DEST_DIR/failed-plugins.txt"
DOWNLOADED=()

set -o pipefail

function usage() {
cat << EOF
    Usage: $0
            Mirrors plugins from Jenkins' update center

            -p  :   Plugin source file
            -d  :   Output directory

    Examples:
            $0 -p plugins.txt -d ~/jenkins/plugins  
EOF
}

function main() {
    local plugin version jenkinsVersion
    local plugins=()

    read_args "$@"
    mkdir -p "$DEST_DIR" || exit 1

    # Read plugins from stdin or from the command line arguments
    while IFS= read -r line; do
        plugins+=("$line")
    done < $PLUGINS_FILE
    
    echo "Downloading plugins..."
    for plugin in "${plugins[@]}"; do
        if [[ $plugin =~ .*:.* ]]; then
            version=$(versionFromPlugin "${plugin}")
            plugin="${plugin%%:*}"
        fi
        processPlugin "$plugin" "$version" "true" &
    done
    wait
    
    echo -e "\n[INFO] Plugins downloaded during this execution:"
    for p in "${DOWNLOADED[@]}"; do
        echo "$p"
    done 

    if [[ -f $FAILED ]]; then
        echo "Some plugins failed to download!" "$(<"$FAILED")" >&2
        exit 1
    fi
}


function processPlugin() {
    local plugin originalPlugin version
    plugin="$1"
    version="${2:-latest}"

    if ! downloadPlugin "$plugin" "$version"; then
        # some plugin don't follow the rules about artifact ID
        # typically: docker-plugin
        if ! downloadPlugin "${plugin}-plugin" "$version"; then
            echo "Failed to download plugin: $plugin or ${plugin}-plugin" >&2
            echo "Not downloaded: $plugin" >> "$FAILED"
            return 1
        fi
    fi

    resolveDependencies "$plugin" "$version"
}

function downloadPlugin() {
    local plugin version hpi url dest
    plugin="$1"
    version="$2"
    hpi="$DEST_DIR/download/plugins/$plugin/$version/${plugin}.hpi"

    if [ -f "$DEST_DIR/download/plugins/$plugin/$version/${plugin}.hpi" ]; then
        echo "[INFO] Already exists: '$plugin' ($version) - Skipping"
        return 0
    fi

    url="$JENKINS_UC_URL/$plugin/$version/${plugin}.hpi"
    dest="$DEST_DIR/download/plugins/$plugin/$version"

    echo "[INFO] Downloading: '$plugin' ($version)"
    mkdir -p $dest
    curl --connect-timeout 20 --retry 3 -sfL "$url" -o "$dest/${plugin}.hpi"
    DOWNLOADED+=("$plugin ($version)")
    return $?
}

function resolveDependencies() {
    local plugin version hpi dependencies
    plugin="$1"
    version="$2"
    hpi="$DEST_DIR/download/plugins/$plugin/$version/${plugin}.hpi"

    dependencies="$(unzip -p "$hpi" META-INF/MANIFEST.MF | tr -d '\r' | tr '\n' '|' | sed -e 's#| ##g' | tr '|' '\n' | grep "^Plugin-Dependencies: " | sed -e 's#^Plugin-Dependencies: ##')"

    if [[ ! $dependencies ]]; then
        echo "[INFO] Dependency Check: '$plugin' has no dependencies"
        return
    fi


    IFS=',' read -r -a array <<< "$dependencies"
    echo -e "[INFO] Dependency Check: '$plugin' has ${#array[@]} dependencies"
    parent=$plugin

    for d in "${array[@]}"
    do
        version=$(versionFromPlugin "${d}")
        plugin="${d%%:*}"
        if [[ $d == *"resolution:=optional"* ]]; then
            echo "[DEBUG] Skipping optional dependency $plugin"
        else
            if [ ! -f "$DEST_DIR/download/plugins/$plugin/$version/${plugin}.hpi" ]; then
                echo "[INFO] Dependency Check: Fetching '$plugin' ($version) for '$parent'"
                processPlugin "$plugin" "$version" &
            fi
        fi
    done
    wait
}

function versionFromPlugin() {
    local plugin=$1
    if [[ $plugin =~ .*:.* ]]; then
        echo "${plugin##*:}"
    else
        echo "latest"
    fi

}


function getLockFile() {
    printf '%s' "$DEST_DIR/${1}.lock"
}

function getArchiveFilename() {
    printf '%s' "$DEST_DIR/${1}.jpi"
}

function read_args() {
    while getopts "p:d:" opt; do
        case $opt in 
            p)
                PLUGINS_FILE=$OPTARG ;;
            d)
                DEST_DIR=$OPTARG ;;
            ?)
                usage ;;
        esac
    done
}

main "$@"
