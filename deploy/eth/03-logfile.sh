#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
# write your code below

source "loadConfig.sh" 2>/dev/null || { echo "loadConfig.sh not found."; exit 1; }

while [ ! -e "${datadir}/logfile" ];do
    echo "Not found ${datadir}/logfile, wait ..."
    sleep 2
done

tail -f "${datadir}/logfile"
