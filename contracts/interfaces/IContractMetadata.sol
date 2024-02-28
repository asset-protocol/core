// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IContractMetadata {
    function name() external view returns (string memory);

    /**
     * ERC7572 contractURI
     */
    function contractURI() external view returns (string memory);

}
