#!/bin/sh
# Base44 dev helper: continuously (re)build the WASM client into client/dist.
#
# `trunk watch` regenerates dist/index.dev.html on every (re)build; the game
# server serves dist/index.html, so this script copies the fresh build over it.
set -eu
cd /app/client

TRUNK_OPTS="--minify --no-sri --skip-version-check --filehash false"

trunk watch $TRUNK_OPTS index.dev.html &
WATCH_PID=$!

while kill -0 "$WATCH_PID" 2>/dev/null; do
    # NOTE: dash's -nt is false when the second file is missing, so check explicitly.
    if [ ! -f dist/index.html ] || [ dist/index.dev.html -nt dist/index.html ]; then
        cp -f dist/index.dev.html dist/index.html
    fi
    sleep 2
done

wait "$WATCH_PID"
