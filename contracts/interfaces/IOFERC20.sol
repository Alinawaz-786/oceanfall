//SPDX-License-Identifier: MIT;

pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IOFERC20 is IERC20 {

    function cancelPendingTransaction(bytes32 txnId) external;
    function claimPendingTransaction(bytes32 txnId) external;
    function pendingTransactions(bytes32 txnId) external view returns(address sender, address receiver, uint amount, uint expireTime);
    function userPendingCount(address user) external view returns(uint countOut, uint countIn);
    function userPendingOutAtIndex(address user, uint index) external view returns(bytes32 txnId);
    function userPendingInAtIndex(address user, uint index) external view returns(bytes32 txnId);
    function isUserPendingIn(address user, bytes32 txnId) external view returns(bool isPending);
    function isUserPendingOut(address user, bytes32 txnId) external view returns(bool isPending);
    function pendingTxnCount() external view returns(uint count);
    function pendingTxnAtIndex(uint index) external view returns(bytes32 txnId);
    function isPendingTxn(bytes32 txnId) external view returns(bool isPending);
}

