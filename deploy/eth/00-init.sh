#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
# write your code below

echo "Init script is useful when setup a Private chan"

source "loadConfig.sh" 2>/dev/null || { echo "loadConfig.sh not found."; exit 1; }

echo "geth --datadir ${datadir} init genesis.json..."
geth --datadir "${datadir}" init genesis.json
