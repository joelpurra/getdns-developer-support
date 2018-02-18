#!/usr/bin/env bash

set -e
set -u
set -o pipefail
set -x

externalExecutableExists() {
	local executable="$1"

	if builtin type "$executable" &>/dev/null;
	then
		return 0
	else
		return 1
	fi
}

function crossplatformReadlink {
	# https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
	# https://stackoverflow.com/a/1116890
	TARGET_FILE="$1"

	cd `dirname $TARGET_FILE`
	TARGET_FILE=`basename $TARGET_FILE`

	# Iterate down a (possible) chain of symlinks
	while [ -L "$TARGET_FILE" ]
	do
	    TARGET_FILE=`readlink $TARGET_FILE`
	    cd `dirname $TARGET_FILE`
	    TARGET_FILE=`basename $TARGET_FILE`
	done

	# Compute the canonicalized name by finding the physical path
	# for the directory we're in and appending the target file.
	PHYS_DIR=`pwd -P`
	RESULT=$PHYS_DIR/$TARGET_FILE
	echo "$RESULT"
}

# Must be executed in this file.
# Used to recursively call np and to find files to `source`.
declare -r THIS_SOURCE=$(crossplatformReadlink "$BASH_SOURCE")

declare -r THIS_SOURCE_DIR="${THIS_SOURCE%/*}"

declare -r BUILD_ROOT_DIR="${THIS_SOURCE_DIR}/getdns-node-builds"

if [[ -z "$GETDNS_TARGET" ]];
then
    echo "No GETDNS_TARGET defined" >&2
    exit 1
fi

set +u
declare -r GIT_REPOSITORY="${1:-}"
shift
set -u

if [[ -z "$GIT_REPOSITORY" ]];
then
    echo "No outside git repository specified: ${GIT_REPOSITORY}" >&2
    exit 1
fi

set +u
GIT_COMMITISH="${1:-}"
shift
set -u

if [[ -z "$GIT_COMMITISH" ]];
then
    echo "No outside git commit(ish) specified: ${GIT_COMMITISH}" >&2
    exit 1
fi

if ! externalExecutableExists "n";
then
    echo "Could not find command in \$PATH: n" >&2
    exit 1
fi

mkdir -p "$BUILD_ROOT_DIR"

declare -a NODE_TARGETS=("4.8.7" "6.13.0" "8.9.4" "9.5.0")

declare -a ORIGINAL_NODE_VERSION=$(node --version)

onExit() {
    # Restore node version
    n $ORIGINAL_NODE_VERSION
}

{ trap 'onExit' EXIT; }

for NODE_TARGET in ${NODE_TARGETS[@]};
do
(
    echo "Building getdns ${GETDNS_TARGET} in node {$NODE_TARGET}"

    pushd "$BUILD_ROOT_DIR" >/dev/null
    (
        # Gah. Didn't think it would be this much hassle.
        # export NVM_DIR="$HOME/.nvm"
        # [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm
        #
        # # Node version might already be installed, but whatever.
        # nvm install $NODE_TARGET
        # nvm use $NODE_TARGET

        # Install/use the target node version.
        # Requires an existing installation ;)
        # https://github.com/tj/n
        # Revert first, to "guarantee" a working version
        n $ORIGINAL_NODE_VERSION

        # npm --silent install n
        # ./node_modules/.bin/n $NODE_TARGET
        n $NODE_TARGET

        declare NODE_TARGET_EXACT=$(node --version)

        echo "Using node $(node --version) and npm $(npm --version)"

        declare GETDNS_NODE_TARGET="getdns-${GETDNS_TARGET}-node-${NODE_TARGET_EXACT}"

        mkdir -p "node-$GETDNS_NODE_TARGET"

        pushd "node-$GETDNS_NODE_TARGET" >/dev/null
        (
            git clone "$GIT_REPOSITORY" "." || git fetch --all --tags --prune
            git checkout --force "$GIT_COMMITISH"
            git clean -fdx

            npm --silent install |& tee ../$GETDNS_NODE_TARGET.npm-install.log || { echo "npm install failed" >&2 ; continue; }

            # Using a locally installed node-gyp.
            npm --silent install node-gyp
            ./node_modules/.bin/node-gyp configure --debug --verbose
            ./node_modules/.bin/node-gyp rebuild --debug --jobs 6 --verbose

            npm --silent test |& tee ../$GETDNS_NODE_TARGET.npm-test.log || { echo "npm test failed" >&2 ; continue; }
        )
        popd >/dev/null
    )
    popd >/dev/null
)
done;
