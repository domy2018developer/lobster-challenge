#!/bin/bash
#export CARDANO_NODE_SOCKET_PATH=node.socket
cardano-cli query protocol-parameters \
    --testnet-magic 1097911063 \
    --out-file "testnet-protocol-parameters.json"
