#!/bin/sh
set -e
# Simple entrypoint that forwards to firebase CLI
if [ "$#" -eq 0 ]; then
  set -- "emulators:start"
fi
exec firebase "$@"
