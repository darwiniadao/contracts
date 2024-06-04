all    :; dapp build
clean  :; dapp clean
test   :; dapp test
deploy :; dapp create DarwiniaCommunityDaoSBT ${DAO}

deploy-dao :; @bin/deploy.sh
