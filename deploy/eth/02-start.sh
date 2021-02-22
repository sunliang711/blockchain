#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
# write your code below

source "loadConfig.sh" 2>/dev/null || { echo "loadConfig.sh not found."; exit 1; }

cat<<EOF
Start node with the following config:
        datadir:  ${datadir}
        port:   ${port}
        rpcaddr: ${rpcaddr}
        rpcport: ${rpcport}
        minerthreads: ${minerthreads}
        maxpeers: ${maxpeers}
        logfile: ${logfile}

EOF

option="${option} --datadir ${datadir}"
option="${option} --port ${port}"
if (( "${rpcport}" > 0 && "${rpcport}" < 65535 ));then
    echo "Enable json rpc at: ${rpcaddr}:${rpcport}"
    option="${option} --rpc --rpcaddr ${rpcaddr} --rpcport ${rpcport}"
fi
option="${option} --allow-insecure-unlock"
if (( "${minerthreads}" > 0 ));then
    echo "Enable mine, miner threads: ${minerthreads}"
    option="${option} --mine --miner.threads ${minerthreads}"
fi
option="${option} --maxpeers ${maxpeers}"

echo "Command line options to geth: ${option}"
geth ${option} 2>> "${logfile}"
