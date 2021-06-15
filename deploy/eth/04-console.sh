#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
# write your code below

source "loadConfig.sh" 2>/dev/null || { echo "loadConfig.sh not found."; exit 1; }
echo "rpc port:$rpcport"
while ! nc -z 127.0.0.1 $rpcport >/dev/null 2>&1;do
    echo "wait rpc port working..."
    sleep 2
done
echo "attach to node with datadir: ${datadir}..."
geth --datadir "${datadir}" attach
