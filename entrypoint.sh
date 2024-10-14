#!/bin/sh

set -e

case "$1" in
    *.yaml|*.yml) set -- /opt/docker/registry serve "$@" ;;
    serve|garbage-collect|help|-*) set -- /opt/docker/registry "$@" ;;
esac

exec "$@"
