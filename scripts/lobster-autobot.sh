#!/bin/bash

# This script will automatically build and submit the lobster challenge from starting vote to ending vote
# given the following parameters. Simplification made here is that there is only one utxo in the wallet address.
#
# lobster-script address file
# wallet address file
# wallet signing key file
# starting vote
# ending vote
# new counter
# "mainnet" or "testnet"

lobsterAddrFile=$1
lobsterAddr=$(cat $lobsterAddrFile)
walletAddrFile=$2
walletAddr=$(cat $walletAddrFile)
walletSignFile=$3
startVote=$4
endVote=$5
newCounter=$6
whichNet=$7

mainnet="--mainnet"
testnet="--testnet-magic 1097911063"

case "$whichNet" in
    mainnet)
        runon=$mainnet
        ;;
    testnet)
        runon=$testnet
        ;;
    *)
        echo "Incorrect value, provide mainnet or testnet"
        exit 1
        ;;
esac

lobsterQueryUtxo=$(cardano-cli query utxo --address $lobsterAddr $runon | grep LobsterNFT)
walletQueryUtxo=$(cardano-cli query utxo --address $walletAddr $runon | grep lovelace | head -1)

walletUtxo=$(echo "$walletQueryUtxo" | awk '{ print $1"#"$2 }')
lobsterUtxo=$(echo "$lobsterQueryUtxo" | awk '{ print $1"#"$2 }')
lobsterOldCounter=$(echo "$lobsterQueryUtxo" | sed 's/.*+\s\(.*\)\s.*\.LobsterCounter.*/\1/')
lobsterNewCounter=$(expr $newCounter + $lobsterOldCounter)
lobsterVotes=$(echo "$lobsterQueryUtxo" | sed 's/.*+\s\(.*\)\s.*\.LobsterVotes.*/\1/')

one=whyloveone.json
two=meatismurder.json
three=animalsarefriends.json
four=bekind.json
five=watchdominion.json

choice=$(expr $(expr $lobsterVotes + 1) % 5)

case $choice in
    1)
        metadata=$one
        ;;
    2)
        metadata=$two
        ;;
    3)
        metadata=$three
        ;;
    4)
        metadata=$four
        ;;
    0)
        metadata=$five
        ;;
esac

echo "Lobster autobot values:"
echo "======================="
echo "lobster address file: $lobsterAddrFile"
echo "lobster address: $lobsterAddr"
echo "wallet address file: $walletAddrFile"
echo "wallet address: $walletAddr"
echo "wallet signing file: $walletSignFile"
echo "start vote: $startVote"
echo "end vote: $endVote"
echo "new counter: $newCounter"
echo "which net: $runon"
echo "lobster utxo: $lobsterUtxo"
echo "wallet utxo: $walletUtxo"
echo "lobster old counter: $lobsterOldCounter"
echo "lobster new counter: $lobsterNewCounter"
echo "lobster votes: $lobsterVotes"
echo "lobster metadata: $metadata"

# loop from startVote to endVote
# call the lobster-contribute script to submit a transaction

while [ $lobsterVotes -lt $endVote ]
do

    if [ $lobsterVotes -ge $startVote ]
    then
        
        echo "calling lobster contribute"
        ./lobster-contribute.sh $walletUtxo $lobsterUtxo $walletAddrFile $walletSignFile $lobsterOldCounter $lobsterNewCounter $lobsterVotes $metadata
        startVote=$(expr $lobsterVotes + 1)

    fi 
    
    echo "sleeping for 5 seconds..."
    sleep 5

    lobsterQueryUtxo=$(cardano-cli query utxo --address $lobsterAddr $runon | grep LobsterNFT)
    walletQueryUtxo=$(cardano-cli query utxo --address $walletAddr $runon | grep lovelace | head -1)

    lobsterUtxo=$(echo "$lobsterQueryUtxo" | awk '{ print $1"#"$2 }')
    walletUtxo=$(echo "$walletQueryUtxo" | awk '{ print $1"#"$2 }')
    lobsterOldCounter=$(echo "$lobsterQueryUtxo" | sed 's/.*+\s\(.*\)\s.*\.LobsterCounter.*/\1/')
    lobsterNewCounter=$(expr $newCounter + $lobsterOldCounter)
    lobsterVotes=$(echo "$lobsterQueryUtxo" | sed 's/.*+\s\(.*\)\s.*\.LobsterVotes.*/\1/')

    echo "lobster utxo: $lobsterUtxo"
    echo "wallet utxo: $walletUtxo"
    echo "lobster old counter: $lobsterOldCounter"
    echo "lobster new counter: $lobsterNewCounter"
    echo "lobster votes: $lobsterVotes"
    echo "start vote: $startVote"

    choice=$(expr $(expr $lobsterVotes + 1) % 5)

    case $choice in
        1)
            metadata=$one
            ;;
        2)
            metadata=$two
            ;;
        3)
            metadata=$three
            ;;
        4)
            metadata=$four
            ;;
        0)
            metadata=$five
            ;;
    esac

done


