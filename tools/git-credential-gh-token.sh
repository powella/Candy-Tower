#!/bin/sh
# Git credential helper for this repo.
#
# Order of preference:
#   1. The GH_TOKEN project secret, for github.com only, when it is set.
#   2. The macOS Keychain (git credential-osxkeychain) otherwise.
#
# Install once per clone:
#   git config --local credential.helper '!exec "$(git rev-parse --show-toplevel)/tools/git-credential-gh-token.sh" "$@"'
#   git config --local --add credential.helper osxkeychain
#
# The token is never written to disk or printed; it is read from the
# environment at the moment git asks for it.

set -u

op=${1:-get}

# git sends the credential request on stdin.
req=$(cat)

host=
old_ifs=$IFS
IFS='
'
for line in $req; do
    case $line in
        host=*) host=${line#host=} ;;
    esac
done
IFS=$old_ifs

if [ "$op" = "get" ] && [ -n "${GH_TOKEN:-}" ] && [ "$host" = "github.com" ]; then
    printf 'username=%s\npassword=%s\n\n' "${GH_USERNAME:-powella}" "$GH_TOKEN"
    exit 0
fi

# Fall back to the Keychain for every other operation and host.
printf '%s\n\n' "$req" | git credential-osxkeychain "$op"
