#!/bin/bash
rpath="$(readlink ${BASH_SOURCE})"
if [ -z "$rpath" ];then
    rpath=${BASH_SOURCE}
fi
root="$(cd $(dirname $rpath) && pwd)"
cd "$root"
# write your code below

source "loadConfig.sh" 2>/dev/null || { echo "loadConfig.sh not found."; exit 1; }


function _wait(){
    # secs=$((5 * 60))
    secs=${1:?'missing seconds'}

    while [ $secs -gt 0 ]; do
       echo -ne "$secs\033[0K\r"
       sleep 1
       : $((secs--))
    done
}

cat<<EOF
Start node with the following config:
        chain(empty for private chain): ${chain}
        datadir:  ${datadir}
        port:   ${port}
        rpcaddr: ${rpcaddr}
        rpcport: ${rpcport}
        wsaddr: ${wsaddr}
        wsport: ${wsport}
        minerthreads: ${minerthreads}
        maxpeers: ${maxpeers}
        logfile: ${logfile}

EOF

if [ ! -d ${datadir} ];then
    echo "Create ${datadir}..."
    mkdir -p ${datadir}
fi


if [ -n "$chain" ];then
    option="${option} --${chain}"
fi
option="${option} --datadir ${datadir}"
option="${option} --port ${port}"
if (( "${rpcport}" > 0 && "${rpcport}" < 65535 ));then
    echo "Enable json rpc at: ${rpcaddr}:${rpcport}"
    # option="${option} --rpc --rpcaddr ${rpcaddr} --rpcport ${rpcport}"
    option="${option} --http --http.addr ${rpcaddr} --http.port ${rpcport} --http.vhosts=*"
fi
if (( "${wsport}" > 0 && "${wsport}" < 65535 ));then
    echo "Enable json rpc at: ${wsaddr}:${wsport}"
    option="${option} --ws --ws.addr ${wsaddr} --ws.port ${wsport} --ws.api eth,net,web3"
fi
option="${option} --allow-insecure-unlock"
if (( "${minerthreads}" > 0 ));then
    echo "Enable mine, miner threads: ${minerthreads}"
    option="${option} --mine --miner.threads ${minerthreads}"
fi
option="${option} --maxpeers ${maxpeers}"

duration=5
echo "Start geth in $duration seconds,press <ctrl-c> to quit."
_wait $duration

cat<<EOF

Run eth node with: geth ${option}

Issue 03-logfile.sh to attach console
Issue 04-console.sh to check logfile

EOF
geth ${option} 2>> "${logfile}"
