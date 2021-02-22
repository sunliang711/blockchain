#!/bin/bash
while true;do
	date +%FT%T
	echo "send btc..."
	bitcoin-cli -regtest -rpcport=8338 -rpcuser=test -rpcpassword=test -rpcwallet=w1 sendtoaddress bcrt1qxadxtu3ylsz9rc2xlmf5fa4tm6zee06zuzg4d2 0.1
	sleep 2
	echo "generate block..."
	bitcoin-cli -regtest -rpcport=8338 -rpcuser=test -rpcpassword=test -rpcwallet=w1 -generate 1
	sleep 600
done
