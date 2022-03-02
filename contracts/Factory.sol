//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./Globals.sol";
import "./CapitalReserve.sol";
import "./interfaces/IFactory.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Factory is AccessControl, Globals, IFactory {

    address[] public capitalReserves;
    uint256 public allowableInterest;
    event CapitalReservePoolDeployed(address reserve, address reserveGovernance, address regulator, address token, uint256 interestRate);
  
   constructor(){
        _setupRole(ROLE_OCEAN_FALLS_GOVERNANCE, msg.sender);
   }
   
   /**
    * @notice : maximum allowable Interest rate must be set first in order to deploy capital reserve
    * @param _reserveGov : reserve governance of the capital reserve
    * @param _token : token type of the capital reserve i:e Weth,WBTC
    * @param _interestRate : interest rate that will be given to user. If interest rate is 10% then decimals^(1/periods) calculated value must be given. Example : 1.10^(1/525600) = 1.000000181 (365*24*60 = 525600) 
    *                       1.000000181 = 1000000181000000000(This value will be given as a parameter)
    * @param _regulator : regulator of the capital reserve
    * @param _intervalSeconds : Interest will be calculated after intervals of seconds. If user wants to calculate interest after every minute than 60(input value) will be given as a parameter.
    * @return reserveAddr : address of the reserve deployed
    */
    function deployCapitalReserve(
        address _reserveGov, 
        address _regulator, 
        address _token, 
        uint256 _interestRate,
        uint256 _intervalSeconds) 
        public payable onlyRole(ROLE_OCEAN_FALLS_GOVERNANCE) 
        returns(address reserveAddr)
    {
        require(_interestRate > 0, "Factory.deployCapitalReserve: rate must be greater than zero");
        require(_interestRate<=allowableInterest,"Factory.deployCapitalReserve : Interest rate must be less than maximum allowable interest rate.");
             
        // CapitalReserve r = new CapitalReserve(_reserveGov, _regulator, _token, _interestRate, msg.sender, address(this), _intervalSeconds);
        // reserveAddr = address(r);
        // capitalReserves.push(reserveAddr);
        // emit CapitalReservePoolDeployed(reserveAddr, _reserveGov, _regulator, _token, _interestRate); 
    }

    /**
     * @notice This function only returns count of the deployed interest not the addresses
     * @return the total number of reserves deployed 
     */
    function reserveCount() external view returns(uint256) {
        return capitalReserves.length;
    }
    
    /**
     * @dev 1.10 = 1100000000000000000, input format is same as of the deployCapitalReserve
     * @param _allowableInterest : Maximum Allowable Interest  rate Limit. 
     * @notice OF Governance must set this limit in order to deploy the capital reserve
     */
    function setMaxInterestLimit(uint256 _allowableInterest) public onlyRole(ROLE_OCEAN_FALLS_GOVERNANCE) {
        allowableInterest = _allowableInterest;
    }
    
    /**
     * @notice A user can contribute in any reserve deployed through this factory, Once he/she get in the Whitelist
     * @param _user : User that Ocean Falls Governance wants to whitelist
     */
    function whitelist(address _user) public onlyRole(ROLE_OCEAN_FALLS_GOVERNANCE) {
        _setupRole(ROLE_WHITELISTED_USER, _user);
    }
    
    /**
     * @notice Every Reserve check the user for Whitelist role by calling this function
     * @param _user : Address of the user that capital reserve wants to check
     * @return If user is in the whitelist returns true else return false
     */
    function isWhitelisted(address _user) external view override returns(bool) {
       return hasRole(ROLE_WHITELISTED_USER, _user);
    }
}

