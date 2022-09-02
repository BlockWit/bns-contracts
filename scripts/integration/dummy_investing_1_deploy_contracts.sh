#!/bin/bash
echo "Using network 'bsctestnet_special'.

Market deployed: https://etherscan.io/address/0xc9D7aaE52FF15064bC997CC3484297e8A0137FB2
PricePolicy deployed: https://etherscan.io/address/0xE30Cb661964f7B19Ae57B98C4b9DF64B4dA5D91d
InvestNFT deployed: https://etherscan.io/address/0x57428f84f9f7cAf45E4087510695d05aeD9F469f
DividendManager deployed: https://etherscan.io/address/0x148783330779A97B70d4a80315D88fa2B65a38CD
Configuration params: --market 0xc9D7aaE52FF15064bC997CC3484297e8A0137FB2 --pricing 0xE30Cb661964f7B19Ae57B98C4b9DF64B4dA5D91d --nft 0x57428f84f9f7cAf45E4087510695d05aeD9F469f --dividends 0x148783330779A97B70d4a80315D88fa2B65a38CD
Verification params: npx truffle run verify InvestNFTMarket@0xc9D7aaE52FF15064bC997CC3484297e8A0137FB2 InvestNFTMarketPricePolicy@0xE30Cb661964f7B19Ae57B98C4b9DF64B4dA5D91d InvestNFT@0x57428f84f9f7cAf45E4087510695d05aeD9F469f DividendManager@0x148783330779A97B70d4a80315D88fa2B65a38CD
success";
