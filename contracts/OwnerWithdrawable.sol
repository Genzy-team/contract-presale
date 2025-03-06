// SPDX-License-Identifier: MIT

/* 

 ██████╗ ███████╗███╗   ██╗███████╗██╗   ██╗    ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗     
██╔════╝ ██╔════╝████╗  ██║╚══███╔╝╚██╗ ██╔╝    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║     
██║  ███╗█████╗  ██╔██╗ ██║  ███╔╝  ╚████╔╝     ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
██║   ██║██╔══╝  ██║╚██╗██║ ███╔╝    ╚██╔╝      ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║     
╚██████╔╝███████╗██║ ╚████║███████╗   ██║       ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗
 ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝   ╚═╝       ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝
                                        
##################################################### genzy.wtf ####################################################

*/

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// A contract that allows the owner to withdraw tokens and Ether
contract OwnerWithdrawable is Ownable {
    using SafeERC20 for IERC20; // Using SafeERC20 for safe ERC20 token operations

    // Constructor that sets the contract owner
    constructor() Ownable(msg.sender) {}

    // Function to receive Ether sent to the contract
    receive() external payable {}

    // Fallback function to handle calls that do not match any function
    fallback() external payable {}

    // Function to withdraw a specified amount of tokens to the owner's address
    function withdraw(address token, uint256 _amountIn) public onlyOwner {
        // Use safe transfer of tokens
        IERC20(token).safeTransfer(msg.sender, _amountIn);
    }

    // Function to withdraw all tokens of a specified type to the owner's address
    function withdrawAll(address token) public onlyOwner {
        // Get the balance of tokens in the contract
        uint256 amount = IERC20(token).balanceOf(address(this));
        // Call withdraw function to transfer all tokens
        withdraw(token, amount);
    }

    // Function to withdraw a specified amount of Ether to the owner's address
    function withdrawCurrency(uint256 _amountIn) public onlyOwner {
        // Transfer Ether to the owner's address
        payable(msg.sender).transfer(_amountIn);
    }
}
