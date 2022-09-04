#!/bin/bash
echo "Using network 'bsctestnet_special'.

Market deployed: https://etherscan.io/address/0xD41474FD77e299B1617196B006aeD5B2a18dB601
PricingController deployed: https://etherscan.io/address/0x6fbFc3ffc2430fa889922A90DBD4bd5d1cb7E857
DomainNamesController deployed: https://etherscan.io/address/0xAE14d09166ffd7B5e43eE9a5afa5C38700c88375
NFT deployed: https://etherscan.io/address/0x8f76317FD6607f1E59bd1eE4FeceB4Fd0FA7C290
BNSContentRouter deployed: https://etherscan.io/address/0x52e2d2ab27DBb1B350b4A49EE20f0e0952C46ed7
BNSSimpleContentProvider deployed: https://etherscan.io/address/0xE45c88FB74c3CbaC6499a832424B427fA0Aa75cA
Configuration params: --market 0xD41474FD77e299B1617196B006aeD5B2a18dB601 --pricing 0x6fbFc3ffc2430fa889922A90DBD4bd5d1cb7E857 --names 0xAE14d09166ffd7B5e43eE9a5afa5C38700c88375 --nft 0x8f76317FD6607f1E59bd1eE4FeceB4Fd0FA7C290 --router 0x52e2d2ab27DBb1B350b4A49EE20f0e0952C46ed7 --provider 0xE45c88FB74c3CbaC6499a832424B427fA0Aa75cA
Verification params: npx truffle run verify BNSDomainNameMarket@0xD41474FD77e299B1617196B006aeD5B2a18dB601 BNSMarketPricePolicy@0x6fbFc3ffc2430fa889922A90DBD4bd5d1cb7E857 BNSNamesPolicy@0xAE14d09166ffd7B5e43eE9a5afa5C38700c88375 BNSNFT@0x8f76317FD6607f1E59bd1eE4FeceB4Fd0FA7C290 BNSContentRouter@0x52e2d2ab27DBb1B350b4A49EE20f0e0952C46ed7 BNSSimpleContentProvider@0xE45c88FB74c3CbaC6499a832424B427fA0Aa75cA
success";
