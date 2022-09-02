#!/bin/bash

PRIVATE_KEY=7d4dd9bcd1e9ba59fa5e0a0f6436c9c3cd05b4d071d270445c88e1286d42d9d7
BSCSCAN_KEY=XUNFSCK7525E43VKN2JGWCC6N69IFFKRGW

ADDR_BUSD=0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee
ADDR_USDT=0x337610d27c682E347C9cD60BD4b3b107C9d34dDd
ADDR_DEVS=0x3552CB128b2c3a789a16c8f244eDC6a64Fe3eE93
ADDR_TEAM=0x04E438a8898223Dbcdb91fCa7A42792d41827c3F
ADDR_FUND=0xE694Ad76d68999Ca4f6777b100ceedbc73D6BAA3

NETWORK=bsctestnet_special

EXEC_TYPE_DUMMY=dummy
EXEC_TYPE_NORMAL=normal
EXEC_TYPE=$EXEC_TYPE_NORMAL

REPO_REL_PATH=scripts/integration
REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS=$REPO_REL_PATH/dummy_bns_1_deploy_contracts.sh
REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS_VERIFY=$REPO_REL_PATH/dummy_bns_1_deploy_contracts_verify.sh
REPO_DUMMY_BNS_2_CONFIGURE_CONTRACTS=$REPO_REL_PATH/dummy_bns_2_configure_contracts.sh
REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS=$REPO_REL_PATH/dummy_investing_1_deploy_contracts.sh
REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS_VERIFY=$REPO_REL_PATH/dummy_investing_1_deploy_contracts_verify.sh
REPO_DUMMY_INVESTING_2_CONFIGURE_CONTRACTS=$REPO_REL_PATH/dummy_investing_2_configure_contracts.sh

cd ../../

if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
  npx truffle compile;
fi;

echo "ETHERSCAN_KEY =" > ./.env
echo "BSCSCAN_KEY = $BSCSCAN_KEY" >> ./.env
echo "INFURA_KEY =" >> ./.env
echo "ETH_MAIN_PRIVATE_KEYS = [\"0x$PRIVATE_KEY\"]" >> ./.env
echo "ETH_TEST_MNEMONIC = \"\"" >> ./.env

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle exec scripts/bns/1_deploy_contracts.js --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS;
echo "$RESULT";

ADDR_DOMAIN_MARKET=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $4 }');
ADDR_DOMAIN_PRICING=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $6 }');
ADDR_DOMAIN_NAMES=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $8 }');
ADDR_DOMAIN_NFT=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $10 }');
ADDR_DOMAIN_ROUTER=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $12 }');
ADDR_DOMAIN_PROVIDER=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $14 }');

echo "Parsed domain market address $ADDR_DOMAIN_MARKET";
echo "Parsed domain pricing address $ADDR_DOMAIN_PRICING";
echo "Parsed domain names policy address $ADDR_DOMAIN_NAMES";
echo "Parsed domain NFT address $ADDR_DOMAIN_NFT";
echo "Parsed domain content router address $ADDR_DOMAIN_ROUTER";
echo "Parsed domain simple content provider address $ADDR_DOMAIN_PROVIDER";

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle run verify BNSDomainNameMarket@$ADDR_DOMAIN_MARKET BNSMarketPricePolicy@$ADDR_DOMAIN_PRICING BNSNamesPolicy@$ADDR_DOMAIN_NAMES BNSNFT@$ADDR_DOMAIN_NFT BNSContentRouter@$ADDR_DOMAIN_ROUTER BNSSimpleContentProvider@$ADDR_DOMAIN_PROVIDER --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS_VERIFY;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS_VERIFY;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_BNS_1_DEPLOY_CONTRACTS_VERIFY;
echo "$RESULT";

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle exec scripts/investing/1_deploy_contracts.js --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS;
echo "$RESULT";

ADDR_INVESTING_MARKET=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $4 }');
ADDR_INVESTING_PRICING=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $6 }');
ADDR_INVESTING_NFT=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $8 }');
ADDR_INVESTING_DIVIDENDS=$(echo "$RESULT" | grep 'Configuration params:' | awk '{ print $10 }');

echo "Parsed domain investing market address $ADDR_INVESTING_MARKET";
echo "Parsed domain investing pricing address $ADDR_INVESTING_PRICING";
echo "Parsed domain investing NFT address $ADDR_INVESTING_NFT";
echo "Parsed domain dividends address $ADDR_INVESTING_DIVIDENDS";

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle run verify InvestNFTMarket@$ADDR_INVESTING_MARKET InvestNFTMarketPricePolicy@$ADDR_INVESTING_PRICING InvestNFT@$ADDR_INVESTING_NFT DividendManager@$ADDR_INVESTING_DIVIDENDS --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS_VERIFY;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS_VERIFY;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_INVESTING_1_DEPLOY_CONTRACTS_VERIFY;
echo "$RESULT";

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle exec scripts/bns/2_configure_contracts.js --market $ADDR_DOMAIN_MARKET --pricing $ADDR_DOMAIN_PRICING --names $ADDR_DOMAIN_NAMES --nft $ADDR_DOMAIN_NFT --router $ADDR_DOMAIN_ROUTER --provider $ADDR_DOMAIN_PROVIDER --dividends $ADDR_INVESTING_DIVIDENDS --usdt $ADDR_USDT --busd $ADDR_BUSD --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_BNS_2_CONFIGURE_CONTRACTS;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_BNS_2_CONFIGURE_CONTRACTS;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_BNS_2_CONFIGURE_CONTRACTS;
echo "$RESULT";

RESULT="";
CUR_COMMAND="";
if [ $EXEC_TYPE == $EXEC_TYPE_NORMAL ]; then
    CUR_COMMAND="npx truffle exec scripts/investing/2_configure_contracts.js --market $ADDR_INVESTING_MARKET --pricing $ADDR_INVESTING_PRICING --nft $ADDR_INVESTING_NFT --dividends $ADDR_INVESTING_DIVIDENDS --usdt $ADDR_USDT --busd $ADDR_BUSD --devs $ADDR_DEVS --team $ADDR_TEAM --fund $ADDR_FUND --network $NETWORK";
else
    CUR_COMMAND=$REPO_DUMMY_INVESTING_2_CONFIGURE_CONTRACTS;
fi
echo $CUR_COMMAND;
RESULT=$($CUR_COMMAND);
echo "#!/bin/bash" > $REPO_DUMMY_INVESTING_2_CONFIGURE_CONTRACTS;
echo "echo \"$RESULT\";" >> $REPO_DUMMY_INVESTING_2_CONFIGURE_CONTRACTS;
echo "$RESULT";


