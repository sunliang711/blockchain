#!/bin/bash

configFile="$1"
if [ -z "${configFile}" ];then
    echo -n "Enter configFile: "
    read configFile
fi

if [ ! -e "${configFile}" ];then
    echo "${configFile} not exist."
    exit 1
fi

echo "Loading config file: ${configFile}..."
source "${configFile}" || { echo "Loading config file error"; exit 1; }
