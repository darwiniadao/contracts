#!/usr/bin/env bash

set -eo pipefail

multisig=0x8683A0ED2bAdb1F3AaBeA6686d78649F0Da774A0
deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec

minDelay=0
az=0x0000000000000000000000000000000000000000

nonce=$(seth nonce $deployer)
nonce=$(( nonce + 2))
dcdao=$(dapp address $deployer $nonce)

token=$(dapp create DarwiniaCommunityDaoSBT $multisig)

wads=[0xa6B5EC845C8446A350a50bb58363c241ab7990b5,0x755d783fd1Cb2133A1ae25c2c1D73947Cb5DEb79,0xA4bE619E8C0E3889f5fA28bb0393A4862Cad35ad,0x7aE77149ed38c5dD313e9069d790Ce7085caf0A6,0x3ba1F5979Ac9cED405419733aCD5887e4F5F2FD7]

timelock=$(dapp create TimelockController $minDelay [$dcdao] $wads $az)
dapp create DCDAO $token $timelock

# seth send $token "rely(address)" $dcdao

echo "token: $token"
echo "timelock: $timelock"
echo "dcdao: $dcdao"
