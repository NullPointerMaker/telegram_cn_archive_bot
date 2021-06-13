#!/bin/bash
# Python 3 launcher with stdout and stderr to file
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
name=$(basename "${BASH_SOURCE[0]}")
name=${name%.*}
command="python3 -u archive.py"
function doStart() {
  pid=$(pidof "$name")
  if [ ! "$pid" ]; then
    rm "$name.out" "$name.err"
    bash -c "exec -a $name $command &" 1>>"$name.out" 2>>"$name.err"
  fi
  pid=$(pidof "$name")
  echo "$pid started"
}
function doStop() {
  pid=$(pidof "$name")
  if [ "$pid" ]; then
    echo "$pid" stopped
    kill "$pid"
  fi
}
trap 'onCtrlC' INT
function onCtrlC() {
  doStop
}
if [ "$1" == "stop" ]; then
  doStop
  exit
elif [ "$1" == "start" ]; then
  doStart
  exit
elif [ "$1" == "restart" ]; then
  doStop
  sleep 1
  doStart
  exit
else
  doStart
  tail --pid="$pid" -qf "$name.out" "$name.err"
fi