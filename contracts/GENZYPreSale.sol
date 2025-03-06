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

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./OwnerWithdrawable.sol";

contract GENZY_PRESALE is ReentrancyGuard, OwnerWithdrawable {
    using SafeERC20 for IERC20;
    using SafeERC20 for IERC20Metadata;

    // State variables
    uint256 public rate; // Rate of sale token in terms of native currency
    address public saleToken; // Address of the token being sold
    uint256 public saleTokenDecimals; // Decimal places of the sale token
    uint256 public totalTokensforSale; // Total tokens available for sale

    // Whitelist of tokens that can be used to buy the sale token
    mapping(address => bool) public tokenWhitelist;

    // Price of each whitelisted token in terms of the sale token
    mapping(address => uint256) public tokenPrices;

    bool public isPresaleStarted; // Flag to check if presale has started

    // Records how many tokens each address has purchased
    mapping(address => uint256) public presaleData;

    uint256 public totalTokensSold; // Total tokens sold in the presale

    uint256 public totalInvolved; // Total involved in the presale

    // Mapping to check if an address has purchased tokens
    mapping(address => bool) public hasPurchased;

    // Public function to execute the purchase of tokens. Approval must be done beforehand.
    function execute(address _token, uint256 _amount) external payable nonReentrant {
        require(isPresaleStarted, "PreSale: Sale stopped!"); // Ensure presale is active

        uint256 saleTokenAmount;

        if (_token != address(0)) { // If using a whitelisted token
            require(_amount > 0, "Presale: Cannot buy with zero amount");
            require(tokenWhitelist[_token], "Presale: Token not whitelisted");

            saleTokenAmount = getTokenAmount(_token, _amount); // Calculate amount of sale tokens

            // Check if the total tokens sold does not exceed the limit
            require((totalTokensSold + saleTokenAmount) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");

            IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount); // Transfer payment from buyer to contract
            IERC20(saleToken).safeTransfer(msg.sender, saleTokenAmount); // Transfer sale tokens to buyer

        } else { // If using native currency (ETH)
            require(msg.value > 0, "Fund need to be greater than 0");
            saleTokenAmount = getTokenAmount(address(0), msg.value); // Calculate amount of sale tokens

            require((totalTokensSold + saleTokenAmount) <= totalTokensforSale, "PreSale: Total Token Sale Reached!");
            IERC20(saleToken).safeTransfer(msg.sender, saleTokenAmount); // Transfer sale tokens to buyer
        }

        // Check if the member is new
        if (!hasPurchased[msg.sender]) {
            hasPurchased[msg.sender] = true; // Mark the participant as having purchased tokens
            totalInvolved++; // Increase the unique participants counter
        }

        totalTokensSold += saleTokenAmount; // Update total tokens sold
        presaleData[msg.sender] += saleTokenAmount; // Record purchase for the sender
    }

    // Function to set the parameters for the sale token
    function setSaleTokenParams(address _saleToken, uint256 _totalTokensforSale) public onlyOwner {
        saleToken = _saleToken;
        saleTokenDecimals = IERC20Metadata(saleToken).decimals(); // Get decimals from the sale token
        totalTokensforSale += _totalTokensforSale; // Update total tokens for sale

        // Transfer the tokens from owner to this contract
        IERC20(saleToken).safeTransferFrom(msg.sender, address(this), _totalTokensforSale);
    }

    // Add a token to the whitelist with its price
    function addWhiteListedToken(address _token, uint256 _price) external onlyOwner {
        require(_price != 0, "Presale: Cannot set price to 0");
        tokenWhitelist[_token] = true; // Mark token as whitelisted
        tokenPrices[_token] = _price; // Set price for the whitelisted token
    }

    // Update the rate for purchasing with native currency
    function updateEthRate(uint256 _rate) external onlyOwner {
        rate = _rate;
    }

    // Update the price for a whitelisted token
    function updateTokenRate(address _token, uint256 _price) external onlyOwner {
        require(tokenWhitelist[_token], "Presale: Token not whitelisted");
        require(_price != 0, "Presale: Cannot set price to 0");
        tokenPrices[_token] = _price; // Update price for the specified token
    }

    // Toggle the presale state (started or stopped)
    function togglePresale(bool _state) external onlyOwner {
        isPresaleStarted = _state;
    }

    // Public view function to calculate the amount of sale tokens received for a given amount of a specific token
    function getTokenAmount(address token, uint256 amount) public view returns (uint256) {
        if (!isPresaleStarted) {
            return 0; // Return 0 if presale hasn't started
        }
        
        uint256 amountOut;
        
        if (token != address(0)) {
            require(tokenWhitelist[token], "Presale: Token not whitelisted"); // Check if token is whitelisted
            uint256 price = tokenPrices[token]; // Get price of the whitelisted token
            
            amountOut = (amount * (10 ** saleTokenDecimals)) / price; // Calculate amount of sale tokens based on price
        } else {
            amountOut = (amount * (10 ** saleTokenDecimals)) / rate; // Calculate amount based on native currency rate
        }
        
        return amountOut;
    }

}
