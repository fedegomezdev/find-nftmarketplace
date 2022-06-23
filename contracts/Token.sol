// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FIND is ERC20 {
    constructor(uint256 initialSupply) ERC20("FIND", "FND") {
        _mint(msg.sender, initialSupply);
    }
}
