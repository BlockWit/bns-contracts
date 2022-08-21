// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "./RecoverableFunds.sol";

contract BNSRepository is RecoverableFunds {


    struct DomainNameRecord {
        bool exists;
        uint start;
        uint periodInDays;
        string name;
        string target;
    }

    mapping(string => address) public nameOwners;

    mapping(string => DomainNameRecord) public nameToNameRecord;

    function configure() public onlyOwner {

    }

    function setDomainName(address bnOwner, string memory name, string memory target, uint start, uint periodInDays) public onlyOwner {
        DomainNameRecord storage domainNameRecord = nameToNameRecord[name];
        if(domainNameRecord.exists) {
            require(domainNameRecord.start + domainNameRecord.periodInDays * 1 days < block.timestamp, "Requested name record busy!");
        }
        domainNameRecord.start = start;
        domainNameRecord.periodInDays = periodInDays;
        domainNameRecord.name = name;
        domainNameRecord.target = target;
        domainNameRecord.exists = true;
        nameOwners[name] = bnOwner;
    }

    function getAddressForDomainName(string memory name) public view returns (string memory) {
        DomainNameRecord memory domainNameRecord = nameToNameRecord[name];
        require(domainNameRecord.exists, "Requested name record not found!");
        require(domainNameRecord.start + domainNameRecord.periodInDays * 1 days > block.timestamp, "Requested name record expired!");
        return domainNameRecord.target;
    }

}
