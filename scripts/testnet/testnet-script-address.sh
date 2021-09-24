#!/bin/bash

cardano-cli address build \
    --payment-script-file $1 \
    --testnet-magic 1097911063
