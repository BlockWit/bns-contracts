#!/bin/bash
echo "Using network 'bsctestnet_special'.

NFT. Grant minter role to Market.
Result: successful tx: https://etherscan.io/tx/0xbd23be2d1f72acba26c570a9e1b6446976d1dde956ef7909fa03fa323f8e8586
Market. Set NFT.
Result: successful tx: https://etherscan.io/tx/0x4e53f8a55737438f89d292511794fd548f8cf3330b1c263207989047ee4fea3c
Market. Set PricingController.
Result: successful tx: https://etherscan.io/tx/0x81e40a892a452644eccd522f9f3e6e66b206a776a6df2d45899ccc2d992ca284
Market. Set DomainNamesController.
Result: successful tx: https://etherscan.io/tx/0x6a939ada135a2d28ae232dff728da4227e2eda0f5bca17d63cb99dde8e07c507
Market. Set BUSD.
Result: successful tx: https://etherscan.io/tx/0xa7e3efb5effa2a9f0fe0d21d8c479f6384ed1e8feeafbc98d92d86ad3309ef47
Market. Set USDT.
Result: successful tx: https://etherscan.io/tx/0xcd7ca979c55e486058f2be557e4cd3112745707dcad8d61421d7fc558f08086f
Market. Set fundraising wallet.
Result: successful tx: https://etherscan.io/tx/0x44294abf7f71e439110b43205af549ffdb3b3c26354f6467be7df477761c171b
PricingController. Set prices.
Result: successful tx: https://etherscan.io/tx/0xa7c61a5cf90bfda9d385ce42e3a846c9ea1529f990846e3fd01b346f035dc171
success
npx truffle exec scripts/investing/2_configure_contracts.js --market 0xB703D5b8a6Ca479c82F878c17a8f6bB125A7F3Ef --pricing 0x476Db2EFFf7336186b3df00a66cd21bFDd0fb482 --nft 0xFBEB5B5B63DBa8C7C923E675D2df308E4EA3f3a9 --dividends 0x6999714cBFb9eF0fA89F11E198D64495F4483a4c --usdt 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd --busd 0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee --devs 0x3552CB128b2c3a789a16c8f244eDC6a64Fe3eE93 --team 0x04E438a8898223Dbcdb91fCa7A42792d41827c3F --fund 0xE694Ad76d68999Ca4f6777b100ceedbc73D6BAA3 --network bsctestnet_special
Using network 'bsctestnet_special'.

NFT. Set DividendManager.
Result: successful tx: https://etherscan.io/tx/0x5cb58bbca94c55c3124de6e804190b952473e9d009ba8c1889bdf608f908ed4c
NFT. Grant minter role to Market.
Result: successful tx: https://etherscan.io/tx/0xe333b8ef3cef96d0d3997109ed48392bb8f2acb48cc2d06a5a35b8a8ead37a9b
Market. Set NFT.
Result: successful tx: https://etherscan.io/tx/0xa026a9cd5ddef6ede706fb8b45aa838c38f6b365709c34728fdfa70e3a3807ea
Market. Set PricingPolicy.
Result: successful tx: https://etherscan.io/tx/0x051e373bb214a3d3dea3bd75fd76c963071a77bf259df7efa4eb3ea3265d7879
Market. Set BUSD.
Result: successful tx: https://etherscan.io/tx/0x7aafee470dc2c1e4852fe51bfc54b2b16bb7ef6f19f616b1d8ea5b3fb6ca3875
Market. Set USDT.
Result: successful tx: https://etherscan.io/tx/0xfe39ddfb7d59be48c1416dd49938b85a9a9ee110b9f0d043fd9a3599cb425551
DividendManager. Set depositary.
Result: successful tx: https://etherscan.io/tx/0xb212142c6c1b73a1c9be179adf371f8903f01511052636ae5c320350f55a76e2
DividendManager. Set BUSD.
Result: successful tx: https://etherscan.io/tx/0x348de483c67d987d7d92c8fd10c895c2be536479a02caad0da90c13ceb476700
DividendManager. Set USDT.
Result: successful tx: https://etherscan.io/tx/0x3ab06cb60f1253870c824a9024992a38d628522e4e53a5dd4725326f2936d7f4
PricingPolicy. Set price.
Result: successful tx: https://etherscan.io/tx/0x3faf3526758d7739cf212d6cae42dcc735a3c93cdfc2b5ac69303b89e5170a61
NFT. Mint dev shares.
Result: successful tx: https://etherscan.io/tx/0xd119717b75c591ab9dea0555ed9796254ef5ee9ca3631f15d57b8386a4c95a03
NFT. Mint team shares.
Result: successful tx: https://etherscan.io/tx/0x01c64987a01a88e11a8298d93b45fcb804b0e14dc0a664a41aeb8cd23ac3ba85
NFT. Mint fund shares.
Result: successful tx: https://etherscan.io/tx/0xcaf6b1d15cbf22fb8dc7e06e2da71a5b5c1e4668855b320cae4f02d29d61fd54
success";
