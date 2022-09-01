#!/bin/bash
echo "Using network 'bsctestnet_special'.

Market deployed: https://etherscan.io/address/0xb4a81bF133428eAb5b69f3d7fe318A2216DEff92
PricingController deployed: https://etherscan.io/address/0x3CFA8fb7E356F7631D9Eb39ceFAa6140B7df39c4
DomainNamesController deployed: https://etherscan.io/address/0x1f83F1d358C0ea577845FbaE5AFccecc4035bb17
NFT deployed: https://etherscan.io/address/0xe16932964a3e2dd794F3c8b0f5c1e18CB592794E
BNSSimpleStorage deployed: https://etherscan.io/address/0x6a87D7a6AE5B66dd096DB0f3c51341874E30788f
BNSRepository deployed: https://etherscan.io/address/0x6bf3950fcdFbC81e823BE66899fEeD336470fF54
Configuration params: --market 0xb4a81bF133428eAb5b69f3d7fe318A2216DEff92 --pricing 0x3CFA8fb7E356F7631D9Eb39ceFAa6140B7df39c4 --names 0x1f83F1d358C0ea577845FbaE5AFccecc4035bb17 --nft 0xe16932964a3e2dd794F3c8b0f5c1e18CB592794E --storage 0x6a87D7a6AE5B66dd096DB0f3c51341874E30788f --repository 0x6bf3950fcdFbC81e823BE66899fEeD336470fF54
Verification params: npx truffle run verify BNSDomainNameMarket@0xb4a81bF133428eAb5b69f3d7fe318A2216DEff92 BNSMarketPricePolicy@0x3CFA8fb7E356F7631D9Eb39ceFAa6140B7df39c4 BNSNamesPolicy@0x1f83F1d358C0ea577845FbaE5AFccecc4035bb17 BNSNFT@0xe16932964a3e2dd794F3c8b0f5c1e18CB592794E BNSSimpleStorage@0x6a87D7a6AE5B66dd096DB0f3c51341874E30788f BNSRepository@0x6bf3950fcdFbC81e823BE66899fEeD336470fF54
success";

