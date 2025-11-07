/**
 * SPDX-License-Identifier: MIT
 **/

pragma solidity ^0.8.20;

library LibTractorStorage {
    struct TractorStorage {
        mapping(bytes32 => uint256) blueprintNonce;
        mapping(address => mapping(bytes32 => uint256)) blueprintCounters;
        address payable activePublisher;
        string version;
        bytes32 currentBlueprintHash;
        address operator;
        mapping(uint256 key => bytes value) data;
    }
}
