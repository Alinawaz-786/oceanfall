// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

import "./Globals.sol";
import './OFERC20.sol';
import "./FeatureControl.sol";
import "./libraries/Fractional.sol";
import "./libraries/ContinuousInterest.sol";
import "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Capital Reserve
 * @notice Capital reserve in the contract that accept the user tokens (Weth, WBTC etc) 
 * Deposit them in the capital reserve and mints its own tokens (LP tokens)
 * User can transfer the LP tokens to another user
 * @dev Interest is deposited in the Allocated Interest pool by the ReserveGovernance
 * LP tokens will be minted after calculating the current value of one LP token according to capital pool balance 
 */
contract CapitalReserve is Globals, OFERC20, FeatureControl {
    
    using Fractional for uint256;
    using ContinuousInterest for ContinuousInterest.Pool;  
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    ContinuousInterest.Pool continuousinterest;
    
    //capital reserve token
    IERC20 token; 
    
    IFactory factory;
    
    uint256 constant tenPOW18 = 1000000000000000000;
    uint256 public immutable interestRate;

    uint256 public maxTimeLimit;

    event DepositedToCapitalReserve(address _depositer, uint256 _amount);
    event WithdrawnFromCapitalReserve(address _withdrawer, uint256 _amount);
    
    event DepositedToInterestPool(address _depositer, uint256 _amount);
    event WithdrawnFromInterestPool(address _withdrawer, uint256 _amount);
    
    event TransactionPending(address _from, address _to, uint256 _amount, uint256 _expireTime);
    
    modifier _whiteList(address _user){
        require(factory.isWhitelisted(_user),"Factory._whitelisted : User is not In the WhiteList");
        _;
    }
    
    /** 
     * @notice constructor will set all the roles, features, ERC20 token and Interest rate to the respected value
     * @param _reserveGov : Reserve Governance of the capital reserve. Assigned in Factory contract
     * @param _regulator : Regulator Of the capital reserve. Assigned in Factory contract
     * @param _token : token like Weth,WBTC etc, that user will deposit in this reserve
     * @param _interestRate : interest rate of the reserve, Must be in the fixed point notation
     * @param _admin : deployer of the contract, Will be the address of the user who calls the deployCapitalReserve function of the Factory contract
     * @param _factory : address of the factory contract that deploy the capital reserve
     * @param _intervalSeconds : time interval after which the interest will calculate and deposit in the interest pool. Must be in seconds
     */
    constructor(address _reserveGov, address _regulator, address _token, uint256 _interestRate, address _admin, address _factory, uint _intervalSeconds) {
    	require(_token != address(0), "CapitalReserve.constructor : Token address is not set");
    	require(_interestRate != 0, "CapitalReserve.constructor : Interest rate can not be zero");
        token = IERC20(_token);    
        interestRate = _interestRate;
        continuousinterest.interestRate = _interestRate;
        continuousinterest.intervalSeconds = _intervalSeconds;

	    _setupRole(DEFAULT_ADMIN_ROLE,_admin);
	    _setupRole(DEFAULT_ADMIN_ROLE,address(_factory));
        _setupRole(ROLE_OCEAN_FALLS_GOVERNANCE , _admin);
        _setupRole(ROLE_RESERVE_GOVERNANCE , _reserveGov);
        _setupRole(ROLE_REGULATOR, _regulator);
        _setupRole(ROLE_WHITELIST_OPERATOR, _admin);
        _setupRole(ROLE_WHITELISTED_USER, _admin);
        setFeature(FEATURE_TRADING, true);        
        factory = IFactory(_factory);
    }
   
    /**
     * @notice user needs to approve sufficient tokens before calling this function
     * @dev mints sufficient amount of LP tokens according to capital reserve balance to users address
     * @param _amount : Amount of ERC20 tokens that user deposit is the capital pool and wants to get interest
     * @return function return true if executed successfully
     */
    function depositToCapitalReservePool(uint256 _amount) external _whiteList(msg.sender) returns(bool) {
                 
        token.safeTransferFrom(msg.sender,address(this),_amount);
        (uint256 _capitalBal, /* uint256 interestBal */) = continuousinterest.poolBalances();

        if(_capitalBal>0){
            uint _total = totalSupply().lpTokensForCapital(_capitalBal, _amount);
            _mint(msg.sender,_total);
        } else {
            _mint(msg.sender,_amount);
        }
        continuousinterest.increaseCapitalPoolBalance(_amount);
        emit DepositedToCapitalReserve(msg.sender, _amount);
        return true;
    }
    
    /**	
     * @notice Only Whitelist user can call this function
     * @dev LP tokens are taken from the users balance and burnt, the user is transferred token based on accumulated interest 
     * @param _amount : Amount of ERC20 deposited token that user wants to claim
     * @return function return true if executed successfully
     */
     function withdrawFromCapitalReservePool(uint256 _amount) external _whiteList(msg.sender) withFeature(FEATURE_TRADING) returns(bool) {
        (uint256 _capitalBal, /* uint256 interestBal */) = continuousinterest.poolBalances();
        uint256 _share = totalSupply().capitalForLpTokens(_capitalBal, _amount);
        token.safeTransfer(msg.sender, _share);
        _burn(msg.sender, _amount);
        continuousinterest.decreaseCapitalPoolBalance(_share);
        emit WithdrawnFromCapitalReserve(msg.sender, _amount);
        return true;
    }

    /**
     * @notice Reserve Governance can only claim tokens from interest pool that are not paid to capital pool
     * @param _amount : Amount of ERC20 tokens that reserve governance wants to withdraw from interest pool
     */
    function withdrawFromInterestPool(uint256 _amount) external onlyRole(ROLE_RESERVE_GOVERNANCE) {
        continuousinterest.decreaseInterestPoolBalance(_amount);
        token.safeTransfer(msg.sender,_amount);
        emit WithdrawnFromInterestPool(msg.sender, _amount);
    }

    /**
     * @notice only Reserve Governance can deposit funds to the Allocated Interest pool    
     * @param _amount : Amount of tokens Reserve Governance Wants to deposit in interest pool
     */
    function depositToInterestPool(uint256 _amount) external onlyRole(ROLE_RESERVE_GOVERNANCE) {
        token.safeTransferFrom(msg.sender,address(this),_amount);
        continuousinterest.increaseInterestPoolBalance(_amount);
        emit DepositedToInterestPool(msg.sender, _amount);
    }

    /**
     * @notice This function only transfer LP tokens to whitelisted user
     * @param _to : address of the receiver 
     * @param _amount: amount of LP tokens that user wants to send
     * @return success : function return true if executed successfully
     */
    function transfer(address _to, uint _amount) public override returns(bool success) {
        require(factory.isWhitelisted(_to), "CapitalReserve.transfer : receive is not whitelisted. Use safeTransfer");
        _transfer(_msgSender(), _to, _amount);
        return true;
    }
    
    /**
     * @notice if the receiver is not in the whitelist the tokens goes in the pending state    
     * @param _to : address of the receiver
     * @param _amount : amount of reserve tokens
     * @param _expireTime : time till when the receiver can claim the tokens (UNIX Timestamp)
     */
    function safeTransfer(address _to, uint256 _amount, uint256 _expireTime) external _whiteList(msg.sender) {
        require(_expireTime > block.timestamp,"CapitalReserve.safeTransfer : Invalid expire time");
        require(_expireTime-block.timestamp <= maxTimeLimit, "CapitalReserve.safeTransfer : expire time exceeds Maximum timeLimit");
        if(!factory.isWhitelisted(_to)) {
            _newPendingTransaction(msg.sender, _to, _amount, _expireTime);
            emit TransactionPending(msg.sender, _to, _amount, _expireTime);
        } else {
           _transfer(msg.sender, _to, _amount); 
        }       
    }

    /**
     * @notice returns the value stored in the Pool struct of ContinuosInterest
     * @return the ContinuosInterest type Object
     */
    function state() external view returns(ContinuousInterest.Pool memory) {
        return continuousinterest;
    }

    /**
     * @notice User can check the current values of Capital and Interest pool
     * @return capitalPool : Capital pool current balance
     * @return interestPool : Interest pool current balance
     */
    function getPoolBalances() public view returns(uint256 capitalPool, uint256 interestPool) {
        (capitalPool, interestPool) = continuousinterest.poolBalances();
    }

    /**
     * @return Interface ID
     */
    function interfaceId() external view returns(bytes4) {
        return token.totalSupply.selector ^ token.balanceOf.selector ^ token.transfer.selector ^ token.allowance.selector ^ token.approve.selector  ^ token.transferFrom.selector ;
    }    
    
    /**
     * @notice Limit Should be in seconds. 1 hour = 3600(Input value)
     * @param _limit = Maximum Time Limit allowed for the pending transactions
     */ 
    function setMaxTimeLimit(uint256 _limit) external onlyRole(ROLE_RESERVE_GOVERNANCE) {
        maxTimeLimit = _limit;
    }
    
    /**
     * @notice Only Reserve Governance can send the tokens to a user that are sent to this contract address accidentally
     * @dev Accidental tokens are those which a user sends directly to this contract address
     * @param _token : address of the ERC20 token from which the accidental transfer happened
     * @param _user : address of the user that has sent the tokens accidentally
     */ 
    function recoverAccidentalTransfer(address _token, address _user) external onlyRole(ROLE_RESERVE_GOVERNANCE) {
    	require(_token != address(0), "CapitalReserve.recoverAccidentalTransfer : Token address is invalid");
    	IERC20 temp = IERC20(_token);
    	if(temp == token){
    	    (uint256 _capitalPool, uint256 _interestPool) = continuousinterest.poolBalances();
    	    uint256 _total = _capitalPool.add(_interestPool);
    	    _total = token.balanceOf(address(this)).sub(_total);
    	    require(_total>0,"CapitalReserve.recoverAccidentalTransfer : No Accidental transfer of tokens");
    	    token.safeTransfer(_user, _total);
    	} else {
    	    require(temp.balanceOf(address(this))>0,"CapitalReserve.recoverAccidentalTransfer : No Accidental transfer of tokens");
    	    temp.safeTransfer(_user, temp.balanceOf(address(this)));
    	}
    }
}

