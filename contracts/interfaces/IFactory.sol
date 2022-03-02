//SPDX-License-Identifier: UNLICENSED;

pragma solidity 0.8.4;

interface IFactory{
    function isWhitelisted(address _user) external view returns(bool);
}

