#!/bin/bash

PRIVATE_KEY=7d4dd9bcd1e9ba59fa5e0a0f6436c9c3cd05b4d071d270445c88e1286d42d9d7
NODE=

cd ../../
echo "ETHERSCAN_KEY =" > ./.env
echo "INFURA_KEY =" >> ./.env
echo "ETH_MAIN_PRIVATE_KEYS = [\"$PRIVATE_KEY\"]" >> ./.env
echo "ETH_TEST_MNEMONIC = \"\"" >> ./.env

npx truffle exec scripts/investing/1_deploy_contracts.js
