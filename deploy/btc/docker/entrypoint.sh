#!/bin/bash
if [ -z "${BASH_SOURCE}" ]; then
    this=${PWD}
else
    rpath="$(readlink ${BASH_SOURCE})"
    if [ -z "$rpath" ]; then
        rpath=${BASH_SOURCE}
    elif echo "$rpath" | grep -q '^/'; then
        # absolute path
        echo
    else
        # relative path
        rpath="$(dirname ${BASH_SOURCE})/$rpath"
    fi
    this="$(cd $(dirname $rpath) && pwd)"
fi

if [ -r ${SHELLRC_ROOT}/shellrc.d/shelllib ];then
    source ${SHELLRC_ROOT}/shellrc.d/shelllib
elif [ -r /tmp/shelllib ];then
    source /tmp/shelllib
else
    # download shelllib then source
    shelllibURL=https://gitee.com/sunliang711/init2/raw/master/shell/shellrc.d/shelllib
    (cd /tmp && curl -s -LO ${shelllibURL})
    if [ -r /tmp/shelllib ];then
        source /tmp/shelllib
    fi
fi


###############################################################################
# write your code below (just define function[s])
# function is hidden when begin with '_'

# write your code above
###############################################################################
configFile=bitcoin.conf

defaultPort=8333
defaultRpcPort=8332
defaultRpcBind=0.0.0.0
defaultRpcUser=user1
defaultRpcPassword=user1password
defaultRpcTimeout=30
defaultRpcAllowIps=0.0.0.0/0

defaultNetwork=main

defaultMaxUpload=0

makeconfig(){
    cat<<-EOF
This function needs the following environment variables to generate bitcoin.conf:
    network(available values: main test signet regtest ) port max_upload
    rpc_port rpc_bind rpc_user rpc_password rpc_timeout
    rpc_allowips (format:10.1.1.1:192.168.1.0/24)
EOF
    usedNetwork=${network:-${defaultNetwork}}
    case $usedNetwork in
        main)
            echo "#network: main" > ${configFile}
            ;;
        test)
            echo "testnet=1" > ${configFile}
            ;;
        signet)
            echo "signet=1" > ${configFile}
            ;;
        regtest)
            echo "regtest=1" > ${configFile}
            ;;

        *)
            echo "${RED}network not support${NORMAL}"
            return 1
            ;;
    esac
    echo "txindex=1" >> ${configFile}
    echo "port=${port:-${defaultPort}}" >> ${configFile}

    cat<<-EOF>>${configFile}

# RPC related settings:
server=1
rest=1
rpcport=${rpc_port:-${defaultRpcPort}}
rpcbind=${rpc_bind:-${defaultRpcBind}}
rpcuser=${rpc_user:-${defaultRpcUser}}
rpcpassword=${rpc_password:-${defaultRpcPassword}}
rpcclienttimeout=${rpc_timeout:-${defaultRpcTimeout}}
EOF

    usedRpcAllowIps=${rpc_allowips:-${defaultRpcAllowIps}}
    ips=$(echo ${usedRpcAllowIps} | tr ":" "\n")
    for ip in $ips;do
        echo "rpcallowip=$ip" >> ${configFile}
    done

    echo -e "# RPC end\n" >> ${configFile}

    echo "maxuploadtarget=${max_upload:-${defaultMaxUpload}}" >> ${configFile}

}

run(){
    makeconfig
    (cd datadir && ln -sf ../bitcoin.conf .)
    bitcoind --datadir=datadir --conf=bitcoin.conf

}

em(){
    $ed $0
}

function _help(){
    cd "${this}"
    cat<<EOF2
Usage: $(basename $0) ${bold}CMD${reset}

${bold}CMD${reset}:
EOF2
    perl -lne 'print "\t$2" if /^\s*(function)?\s*(\S+)\s*\(\)\s*\{$/' $(basename ${BASH_SOURCE}) | perl -lne "print if /^\t[^_]/"
}

case "$1" in
     ""|-h|--help|help)
        _help
        ;;
    *)
        "$@"
esac
