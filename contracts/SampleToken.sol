//SPDX-License-Identifier: MIT;
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Currency is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name,_symbol) {}
    
    /**
     * @param _amount : amount of tokens user wants to mint
     */
    function mint(uint256 _amount)public {
        _mint(msg.sender,_amount);
    }
    
    /**
     * @param _amount : amount of tokens user wants to burn
     */
    function burn(uint256 _amount) public {
        _burn(msg.sender,_amount);
    }
}
