
//SPDX-License-Identifier: MIT;

pragma solidity 0.8.4;

import './interfaces/IOFERC20.sol';
import './libraries/HitchensUnorderedKeySet.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OFERC20 is ERC20, IOFERC20 {
    using SafeMath for uint;

    bytes32 private constant NULL_BYTES32 = bytes32(0);
    string private constant _name = 'Ocean Falls Capital Pool';
    string public constant _symbol = 'OFCP';
    uint8 public constant _decimals = 18;

    uint256 public nonce = 1;
    using HitchensUnorderedKeySetLib for HitchensUnorderedKeySetLib.Set;

    //Struct to store the information of the pending transaction
    struct PendingTransaction {
         address sender;
         address receiver;
         uint256 amount;
         uint256 expireTime;
    }    
    mapping(bytes32 => PendingTransaction) public override pendingTransactions;
    HitchensUnorderedKeySetLib.Set pendingTransactionsSet;
    
    event LogNewPendingTransaction(bytes32 key, address sender, address reciever, uint256 balance, uint256 expiryTime);
    event LogRemPendingTransaction(address sender, bytes32 key);

    struct UserPending {
        HitchensUnorderedKeySetLib.Set pendingOut;
        HitchensUnorderedKeySetLib.Set pendingIn;
    }
    mapping(address => UserPending) userPending;

    constructor() ERC20(_name, _symbol) {}

    /**
     * @notice Transaction first needs to get expire. If the receiver does not claim it then the sender can cancel it
     * @param _txnId : Transaction Id of the pending transaction that sender of the transaction wants to cancel
     */
    function cancelPendingTransaction(bytes32 _txnId) external override virtual {
        PendingTransaction storage t = pendingTransactions[_txnId];
        require(t.sender == msg.sender, "OFERC20.cancelPendingTransaction: not transaction sender");
        require(t.expireTime < block.timestamp, "OFERC20.cancelPendingTransaction: not expired");
        require(_txnId != NULL_BYTES32, "OFERC20.cancelPendingTransaction: invalid txn id");
        _remPendingTransaction(_txnId, t.sender);
    }
    
    /**
     * @notice Receiver can only claim the transaction before it gets expire. Receiver will receive full amount of tokens that were send to him/her.    
     * @param _txnId : Transaction Id of the pending transaction that receiver wants to claim 
     */
    function claimPendingTransaction(bytes32 _txnId) external override {
        PendingTransaction storage t = pendingTransactions[_txnId];
        require(t.receiver == msg.sender, "OFERC20.claimPendingTransaction: not transaction receiver");
        require(t.expireTime >= block.timestamp, "OFERC20.cancelPendingTransaction: expired");
        require(_txnId != NULL_BYTES32, "OFERC20.claimPendingTransaction: invalid txn id");
        _remPendingTransaction(_txnId, t.receiver);
    }

    /**
     * @notice Store new pending transaction all info
     * @dev Called in safe transfer of capital reserve 
     * @param _sender : sender of the LP tokens
     * @param _receiver : receiver of the LP tokens 
     * @param _amount : amount of LP tokens that user sends to the non whitelisted user
     * @param _expiryTime : expiry time of the transaction (UNIX time stamp)
     */
    function _newPendingTransaction(address _sender, address _receiver, uint256 _amount, uint256 _expiryTime) internal {
        bytes32 key = _genId();
        PendingTransaction storage t = pendingTransactions[key];
        UserPending storage s = userPending[_sender];
        UserPending storage r = userPending[_receiver];
        s.pendingOut.insert(key);
        r.pendingIn.insert(key);
        pendingTransactionsSet.insert(key);
        t.sender = _sender;
        t.receiver = _receiver;
        t.amount = _amount;
        t.expireTime = _expiryTime;
        _transfer(_sender, address(this), _amount);
        emit LogNewPendingTransaction(key, _sender, _receiver, _amount, _expiryTime);
    }

    /**
     * @notice removes all traces of a pending transaction
     * @dev Called when a user claim or reject a pending transaction
     * @param _key : Transaction ID of the pending transaction
     * @param _user : address of the sender/receiver depending on the scenario
     */
    function _remPendingTransaction(bytes32 _key, address _user) internal {
        PendingTransaction storage t = pendingTransactions[_key];
        UserPending storage s = userPending[t.sender];
        UserPending storage r = userPending[t.receiver];
        s.pendingOut.remove(_key);
        r.pendingIn.remove(_key);
        pendingTransactionsSet.remove(_key);
        _transfer(address(this), _user, t.amount);
        delete pendingTransactions[_key];
        emit LogRemPendingTransaction(msg.sender, _key);
    }

    /**
     * @notice Generates the ID based on the contract address and number of the pending transactions send.
     * @return returns the txnID of the pending transaction
     */
    function _genId() private returns(bytes32) {
        nonce++;
        return keccak256(abi.encodePacked(address(this), nonce));
    }    

    /**
     * View functions
     */
    
    /**
     * @notice returns total count of pending transactions that a user had send and received.
     * @param _user : address of the user who sends/receives pending transaction
     * @return countOut : Total number of the pending transaction user send
     * @return countIn : Total number of the pending transactions user receive
     */
    function userPendingCount(address _user) external override view returns(uint countOut, uint countIn) {
        UserPending storage u = userPending[_user];
        countOut = u.pendingOut.count();
        countIn = u.pendingIn.count();
    }

    /**
     * @notice returns the pending transaction ID that a user has send to another user at a given Index
     * @param _user : address of the sender of pending transactions
     * @param _index : index of the pending out transaction array
     * @return txnId : pending transaction id
     */
    function userPendingOutAtIndex(address _user, uint _index) external override view returns(bytes32 txnId) {
        UserPending storage u = userPending[_user];
        txnId = u.pendingOut.keyAtIndex(_index);
    }

    /**
     * @notice returns the pending transaction ID that a user has received at a given Index
     * @param _user : address of the receiver of pending transactions
     * @param _index : index of the pending in transaction array
     * @return txnId : pending transaction id
     */
    function userPendingInAtIndex(address _user, uint _index) external override view returns(bytes32 txnId) {
        UserPending storage u = userPending[_user];
        txnId = u.pendingIn.keyAtIndex(_index);
    }

    /**
     * @notice returns true if the give transaction ID exits in a users Pending In list (array) else returns false
     * @param _user : address of the receiver of pending transactions
     * @param _txnId : Transaction Id that user wants to check, If exits or not
     * @return isPending : true if the user has a pending received transaction of the given id
     */
    function isUserPendingIn(address _user, bytes32 _txnId) external override view returns(bool isPending) {
        UserPending storage u = userPending[_user];
        isPending = u.pendingIn.exists(_txnId);
    }

    /**
     * @notice returns true if the give transaction ID exits in a users Pending Out list (array) else returns false
     * @param _user : address of the sender of pending transactions
     * @param _txnId : Transaction Id that user wants to check, If exits or not
     * @param _txnId : Transaction Id that user wants to check, If exits or not
     * @return isPending : true if the user has a pending sent transaction of the given id
     */
    function isUserPendingOut(address _user, bytes32 _txnId) external override view returns(bool isPending) {
        UserPending storage u = userPending[_user];
        isPending = u.pendingOut.exists(_txnId);
    }

    /**
     * @notice returns the total number of transactions that are pending
     * @return count : total pending transactions in the system
     */
    function pendingTxnCount() external override view returns(uint count) {
        count = pendingTransactionsSet.count();
    }
    
    /**
     * @notice returns transaction ID at the given index in pending transaction array
     * @return txnId : transaction id
     */
    function pendingTxnAtIndex(uint _index) external override view returns(bytes32 txnId) {
        txnId = pendingTransactionsSet.keyAtIndex(_index);
    }

    /**
     * @notice returns true if the given transaction Id is valid else return false
     * @return isPending : true if the transaction id is a pending transaction
     */
    function isPendingTxn(bytes32 _txnId) external override view returns(bool isPending) {
        isPending = pendingTransactionsSet.exists(_txnId);
    }
}

