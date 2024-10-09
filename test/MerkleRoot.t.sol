// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "../src/Whitelist.sol";
import {Merkle} from "murky/src/Merkle.sol";

contract CounterTest is Test {

      //variable for holding an instance of our Whitelist contract
    Whitelist public whitelist;


    //function for encodin leaf nodes
    function encodeLeaf(
        address _address,
        uint64 _spots
    ) public pure returns (bytes32) {
        //we're using keccak256 as the hashing algorithm
        return keccak256(abi.encodePacked(_address, _spots));
    }

      function test_MerkleRoot() public {

        //initialize a merkle tree
        Merkle m = new Merkle();

        //create an array of elements to put in the Merkle tree
        bytes32[] memory list = new bytes32[](6);
        list[0] = encodeLeaf(vm.addr(1), 2);
        list[1] = encodeLeaf(vm.addr(2), 2);
        list[2] = encodeLeaf(vm.addr(3), 2);
        list[3] = encodeLeaf(vm.addr(4), 2);
        list[4] = encodeLeaf(vm.addr(5), 2);
        list[5] = encodeLeaf(vm.addr(6), 2);

        //compute the merkle root
        bytes32 root = m.getRoot(list);

        //deploy the whitelist contract
        whitelist = new Whitelist(root);
        
        // Check for valid addresses
        for (uint8 i = 0; i < 6; i++) {
            //get proof for the value at index "i" in the list
            bytes32[] memory proof = m.getProof(list, i);


            // Impersonate the current address being tested
            // This is done because our contract uses `msg.sender` as the 'original value' for
            // the address when verifying the Merkle Proof
            vm.prank(vm.addr(i + 1));
            // Check that the contract can verify the presence of this address
            // in the Merkle Tree using just the Root provided to it
            // By giving it the Merkle Proof and the original values
            // It calculates `address` using `msg.sender`, and we provide it the number of NFTs
            // that the address can mint ourselves
            bool verified = whitelist.checkInWhitelist(proof, 2);

            assertEq(verified, true);
        }


        //make an empty bytes32 array as an invalid proof
        bytes32[] memory invalidProof;

        // Check for invalid addresses
        bool verifiedInvalid = whitelist.checkInWhitelist(invalidProof, 2);
        assertEq(verifiedInvalid, false);
    }

}