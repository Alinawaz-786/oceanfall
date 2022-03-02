// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.4;

contract Globals {
    // keccak256("ROLE_OCEAN_FALLS_GOVERNANCE")
    bytes32 public constant ROLE_OCEAN_FALLS_GOVERNANCE = 0xca07b9c1a2c0f12042b730fc371fc801cef2a7d2f03d4ee553b83200ccad032b;  

    // keccak256("ROLE_RESERVE_GOVERNANCE")  
    bytes32 public constant ROLE_RESERVE_GOVERNANCE = 0x357a672225bb6aeb630226af9da3a8ee5194399a812cca8e204cc76154158d6b;       
    
    // keccak256("ROLE_REGULATOR")  
    bytes32 public constant ROLE_REGULATOR = 0x6875f2084ac6ef0df0fefc0f79fad0f79cebc70445f0963b34e72ad37013406b;             
    
    // keccak256("ROLE_WHITELIST_OPERATOR")  
    bytes32 public constant ROLE_WHITELIST_OPERATOR = 0xe0616c68c377b30cd2e1f32e28c349edb49dd408cb68b4ae4ea1d18bb7d68799;      
    
    // keccak256("ROLE_WHITELISTED_USER")
    bytes32 public constant ROLE_WHITELISTED_USER = 0xd719c281ea0ec612ab10a7c47410009934d7cfdd7ea175dda614a480727628fc;  

    // keccak256('FEATURE_TRADING') 
    bytes32 public constant FEATURE_TRADING = 0x6d549dfec25827802a4ef58e6968d93a468e7c5a4e53c662a28ca8657ca155da;              
}
