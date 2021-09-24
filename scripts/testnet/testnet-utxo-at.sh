#!/bin/bash

#export CARDANO_NODE_SOCKET_PATH=node.socket
cardano-cli query utxo \
    --testnet-magic 1097911063 \
    --address $(cat $1)
