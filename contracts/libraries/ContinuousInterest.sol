// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4; 

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./PRBMathUD60x18.sol";

library ContinuousInterest {

    using SafeMath for uint256;
    using PRBMathUD60x18 for uint256;

    struct Pool {
        //rate to pay per interval, Must be in the fixed point notation
        uint interestRate;                
        
        //micro-interest rate, not APR. Smaller units interest gas cost for O(log n) exponentiation  
        uint intervalSeconds;               
        
        //timeStamp when these values were last updated
        uint processedTimeStamp;            
        
        //last computed pool balance. always use poolBalances() 
        uint processedCapitalPoolBalance;   
        
        //last computed remaining interest funds on hand. always use poolBalances() 
        uint processedInterestPoolBalance;  
    }
    
    /**
     * @notice increases the balance of capital reserve pool whenever a user deposits the ERC20 tokens in it 
     * @param self : ContinouInterest (this library) type object 
     * @param amount : Number of tokens user wants to Deposit in capital reserve pool
     */
    function increaseCapitalPoolBalance(Pool storage self, uint amount) internal {
        //compute and store interest first
        _updatePoolBalances(self); 
        self.processedCapitalPoolBalance = self.processedCapitalPoolBalance.add(amount);
    }
    
    /**
     * @notice decreases the balance of capital reserve pool whenever a user withdraws the ERC20 tokens from it 
     * @param self : ContinouInterest (this library) type object 
     * @param amount : Number of tokens user wants to WithDraw from capital reserve pool
     */
    function decreaseCapitalPoolBalance(Pool storage self, uint amount) internal {
        //compute and store interest first
        _updatePoolBalances(self);
        self.processedCapitalPoolBalance = self.processedCapitalPoolBalance.sub(amount ,"ContinuousInterest : Insufficient capital balance");        
    }

    /**
     * @notice increases the balance of interest pool whenever Reserve Governence deposits the ERC20 tokens in it 
     * @param self : ContinouInterest (this library) type object 
     * @param amount : Number of tokens Reserve Governance wants to Deposit in Interest pool
     */
   function increaseInterestPoolBalance(Pool storage self, uint amount) internal {
         //compute and store interest first
        _updatePoolBalances(self); 
        self.processedInterestPoolBalance = self.processedInterestPoolBalance.add(amount);        
    }

    /**
     * @notice decreases the balance of interest pool whenever Reserve Governence withdraws the ERC20 tokens from it 
     * @param self : ContinouInterest (this library) type object 
     * @param amount : Number of tokens Reserve Governance wants to Withdraw from Interest pool
     */
    function decreaseInterestPoolBalance(Pool storage self, uint amount) internal {
        //compute and store interest first
        _updatePoolBalances(self); 
        self.processedInterestPoolBalance = self.processedInterestPoolBalance.sub(amount ,"ContinuousInterest : Insufficient interest balance");        
    }    
    
    /**
     * @notice This function returns the current balances of the capital and interest pool 
     * @dev This function calculates the current Interest, subtract it from the interest pool add it to the capital pool and the returns it
     * In case of insolvency when Interest pool balance becomes too low to pay the interest to capital pool, This function will give all the balance in Interest pool to capital pool and make Interest pool balance 0    
     * @param self : ContinouInterest (this library) type object
     * @return capitalPoolBal : Capital reserve pool current balance
     * @return interestPoolBal : Interest pool current balance
     */
    function poolBalances(Pool storage self) internal view returns(uint256 capitalPoolBal, uint256 interestPoolBal) 
    {
        uint timeStamp = block.timestamp;
        uint processedTimeStamp = self.processedTimeStamp;
        uint intervalSeconds = self.intervalSeconds;
        uint interestRate = self.interestRate;
             interestPoolBal = self.processedInterestPoolBalance;
        
        capitalPoolBal = _compoundBalance(self.processedCapitalPoolBalance, interestRate, intervalSeconds, processedTimeStamp, timeStamp);  
        uint interestDeducted = capitalPoolBal.sub(self.processedCapitalPoolBalance,"Capital Pool Balance overflow");

        if(interestPoolBal >= interestDeducted) { //continuous allocation of interest capital available to capital pool
               interestPoolBal = interestPoolBal.sub(interestDeducted,"ContinuousInterest : insufficient Balance in Interest Pool");
        } else { //insolvent, all available interest to capital pool
            capitalPoolBal = self.processedCapitalPoolBalance.add(self.processedInterestPoolBalance);
            interestPoolBal = 0; 
        }
    }

    /**
     * @notice Does not apply interest retroactively if the interest pool balance is allowed to fall to zero
     * @param self : ContinouInterest (this library) type object
     */
    function _updatePoolBalances(Pool storage self) private {
        (uint capitalPoolBal, uint interestPoolBal) = poolBalances(self);
        self.processedCapitalPoolBalance = capitalPoolBal;
        self.processedInterestPoolBalance = interestPoolBal;
        self.processedTimeStamp = block.timestamp;
    }

    /**
     * @notice calculates the Interest on the capital pool balance according to the given interest rate after the given time interval
     * @param initialBalance : current balance of capital pool before any further calculation
     * @param interestRate : initial interest rate
     * @param intervalSeconds : after every, that many seconds the interest will be calculated
     * @param startTime : last time when the capital and interest pool balances were calculated
     * @param endTime : current time stamp
     * @return balanceWithInterest : Balance of the capital pool with interest
     */
    function _compoundBalance(uint initialBalance, uint interestRate, uint intervalSeconds, uint startTime, uint endTime) private pure returns(uint balanceWithInterest) {
        balanceWithInterest = initialBalance.mulPrb(_periodInterest(interestRate, _getPeriods(intervalSeconds, startTime, endTime)));
    }

    /**
     * @notice calculates exponential part of the Interest formula
     * @param intervalInterest : Interest rate of one Interval
     * @param periods : Total number of Time Intervals that have been passed
     * @return compoundedRate : Interest according to the interest rate and time intervals passed
     */
    function _periodInterest(uint intervalInterest, uint periods) private pure returns(uint compoundedRate) {
        compoundedRate = _mathPower(intervalInterest, periods);
    }
    
    /**
     * @notice calculates the number of intervals that has been passed until now from the last time it was called
     * @param intervalSeconds : Time spam after which the interest has to calculated
     * @param startTime : last time when the capital and interest pool balances were calculated
     * @param endTime : current time stamp
     */
    function _getPeriods(uint intervalSeconds, uint startTime, uint endTime) private pure returns(uint intervalPeriods) {
        intervalPeriods = endTime.sub(startTime,"ContinuousInterest : Error while Computing Intervals");
        intervalPeriods = intervalPeriods.div(intervalSeconds);
    }

    /**
     * @notice calculates the per interval rate to the intervals passed
     * @param x : base of the Power
     * @param y : Exponent of the power
     * @return  xPowerY : Power of the x base to the exponent y
     */
    function _mathPower(uint x, uint y) private pure returns(uint xPowerY) {  
        xPowerY = x.powu(y);  
    }
}

