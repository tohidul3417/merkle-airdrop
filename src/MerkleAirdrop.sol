// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdop__InvalidAirdrop();
    error MerkleAirdop__AlreadyClaimed();
    error MerkleAirdop__InvalidSignature();

    // some list of addresses
    // allow someone in the list to claim tokens
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    // It is good practice to precompile this hash: keccak256("AirdropClaim(address account,uint256 amount")
    bytes32 private constant MESSAGE_TYPEHASH = 0xba625b6ee4bd090d1127e6128bc2436a588514b6722bac2d537d01b46af3ff89;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claim(address account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdop__AlreadyClaimed();
        }
        // Signature verification logic
        bytes32 digest = getMessageHash(account, amount);
        if (!_isValidSignature(account, digest, v, r, s)) {
            revert MerkleAirdop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdop__InvalidAirdrop();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})));

        return _hashTypedDataV4(structHash);
    }

    function _isValidSignature(address expectedSigner, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        address actualSigner = ECDSA.recover(digest, v, r, s);
        return actualSigner != address(0) && actualSigner == expectedSigner;
    }

    // --- Getter / View function ---
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
