#!/usr/bin/env bash
# shellcheck shell=bash

echo "### Initializing varroa script ###"
id
ls -lA
echo .

varroa_daemon() {
  while true; do
    ./varroab start
    ls -lA
    pid=$(cat varroa_pid)
    echo "### varroa started '$pid' ###"

    # while ps "$pid" >/dev/null; do
    #   sleep 1
    # done
    while true; do
      sleep 1
    done
    sleep 1
  done
}

case "$1" in
  start)
    echo "### Starting varroa ###"
    varroa_daemon
    ;;
  *)
    echo "### Executing varroa command '$*' ###"
    exec ./varroab "$@"
    ;;
esac
