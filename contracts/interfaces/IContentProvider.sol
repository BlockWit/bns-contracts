// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


interface IContentProvider {

    function setContent(string name, string relativePath, string content) external;
    function getContent(string name, string realtivePath) external view returns (string);

}
