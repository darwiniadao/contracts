#!/usr/bin/env bash

set -eo pipefail

# multisig=0x8683A0ED2bAdb1F3AaBeA6686d78649F0Da774A0
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
multisig=$deployer

minDelay=60
az=0x0000000000000000000000000000000000000000

nonce=$(seth nonce $deployer)
nonce=$(( nonce + 2))
dcdao=$(dapp address $deployer $nonce)

token=$(dapp create DarwiniaCommunityDaoSBT $deployer)
timelock=$(dapp create TimelockController $minDelay [$dcdao] [$az] $multisig)
dapp create DCDAO $token $timelock
echo "token: $token"
echo "timelock: $timelock"
echo "dcdao: $dcdao"
