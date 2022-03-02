// SPDX-License-Identifier: UNLICENSED


/**
  * @notice capital pool balance must be obtained from ContinuousInterest so is up-to-the-moment
  * @dev this might work better as simple pure functions in the host contract
  */
pragma solidity 0.8.4; 

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library Fractional {

    using SafeMath for uint256;
    uint constant PRECISION = 10 ** 18;

    /**
     * @notice calculates the capital pool balance for the given amount of LP tokens
     * @dev used when a user wants to withdraw tokens from the capital pool  
     * @param circulatingLP : Total number of currently minted LP tokens
     * @param capitalPoolBalance : Capital pool current balance
     * @param lpTokens : Amount of LP tokens user wants to withdraw from capital pool
     * @return capital : Amount of capital pool balance for the given LP tokens
     */
    function capitalForLpTokens(uint circulatingLP, uint capitalPoolBalance, uint lpTokens) internal pure returns(uint capital) {
        capital = lpTokens.mul(capitalPoolBalance).div(circulatingLP);
    }

    /**
     * @notice calculates the amount of LP tokens that will mint by calculating the current balance of capital pool, Interest given to it and amount of currently minted LP tokens
     * @dev used when a user deposit tokens in the capital pool  
     * @param circulatingLP : Total number of currently minted LP tokens
     * @param capitalPoolBalance : Capital pool current balance
     * @param capital : Amount of capital pool balance user wants to deposit in the capital pool
     * @return lpTokens : Amount of LP tokens that will be minted according the amount of tokens user deposit in the capital pool
     */
    function lpTokensForCapital(uint circulatingLP, uint capitalPoolBalance, uint capital) internal pure returns(uint lpTokens) {
	    //value of one LP token 
        uint tokenCapital = capitalForLpTokens(circulatingLP, capitalPoolBalance, PRECISION);      

        lpTokens = capital.mul(PRECISION).div(tokenCapital);
    }
}
