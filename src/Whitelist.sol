// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Import the Merkle utility from the murky library for constructing and verifying Merkle trees
import {Merkle} from "murky/src/Merkle.sol";

// Define the WhiteList contract
contract Whitelist {
    // Instantiate a Merkle tree object from the murky library
    Merkle m = new Merkle();

    // Public variable to store the Merkle root, which will be set when the contract is deployed
    bytes32 public merkleRoot;

    // Constructor function, called when the contract is deployed
    // It sets the Merkle root, which is provided as a parameter
    constructor(bytes32 _merkleRoot) {
        merkleRoot = _merkleRoot;  // Store the passed Merkle root
    }

    // Function to check if an address is in the whitelist using a Merkle proof
    // The function is "view" since it doesn't modify the state
    // Parameters:
    // - proof: The Merkle proof, which is an array of hashes used to verify membership
    // - maxAllowanceToMint: The maximum amount of tokens (or NFTs) that the address is allowed to mint
    function checkInWhitelist(
        bytes32[] calldata proof,
        uint64 maxAllowanceToMint
    ) public view returns (bool) {
        // Generate the leaf node by hashing the sender's address and their minting allowance
        // The leaf is the hashed representation of the current user (`msg.sender`) and their max mint allowance
        bytes32 leaf = keccak256(
            abi.encodePacked(msg.sender, maxAllowanceToMint)
        );

        // Verify the Merkle proof using the root, the proof provided, and the leaf node
        // This checks if the proof matches the Merkle root, proving the sender is whitelisted
        bool newVerified = m.verifyProof(merkleRoot, proof, leaf);

        // Return true if the proof is valid (i.e., the address is whitelisted), otherwise false
        return newVerified;
    }
}
