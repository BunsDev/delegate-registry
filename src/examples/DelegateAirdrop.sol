// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

import {IDelegationRegistry} from "src/IDelegationRegistry.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

contract DelegateAirdrop {
    IDelegationRegistry public immutable delegateRegistry;

    address public immutable referenceToken;

    mapping(address vault => mapping(address delegate => uint256 claimed)) public delegateClaimed;

    constructor(address registry_, address referenceToken_) {
        delegateRegistry = IDelegationRegistry(registry_);
        referenceToken = referenceToken_;
    }

    function delegateClaimable(address vault, uint256 claimable) internal returns (uint256) {
        // Fetch the referenceToken balance delegated by the vault to msg.sender from the delegate registry
        uint256 balance = delegateRegistry.checkDelegateForBalance(msg.sender, vault, referenceToken, "");
        // Load the amount tokens already claimed by msg.sender on behalf of the vault
        uint256 alreadyClaimed = delegateClaimed[vault][msg.sender];
        // Revert if msg.sender has already used up all the delegated balance
        require(balance > alreadyClaimed, "Insufficient Delegation");
        // Calculate maximum further tokens that can be claimed by msg.sender on behalf of vault
        uint256 remainingLimit = balance - alreadyClaimed;
        // Reduce claimable to remainingLimit if the limit is smaller
        claimable = Math.min(claimable, remainingLimit);
        // Increment beneficiaryClaimed by this amount
        delegateClaimed[vault][msg.sender] += claimable;
        return claimable;
    }
}
