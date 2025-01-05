//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    mapping(address => mapping(address => uint256)) public tokens;
    
    struct _Order {
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;
    }

    mapping(uint256 => _Order) public orders;
    uint256 public orderCount;


    event Deposit(
        address token,
        address user,
        uint256 amount, 
        uint256 balance
    );

    event Withdraw(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );

    event Order(
        uint256 id, 
        address user, 
        address tokenGet, 
        uint256 amountGet, 
        address tokenGive, 
        uint256 amountGive, 
        uint256 timestamp
    );


    constructor(address _feeAccount, uint256 _feePercent)  {
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }


    // -------------------
    // DEPOSIT & WITHDRAW TOKEN

    function depositToken(address _token, uint256 _amount) public {
        
        // Transfer tokens to exchange added Require() to add a second layer of extra confirmation of approval.
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));
        
        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount;
        
        // Emit an event
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]); 
    }

    function withdrawToken(address _token, uint256 _amount) public {
        // Ensure user has enough tokens to withdraw
        require(tokens[_token][msg.sender] >= _amount);

        // Transfer tokens to user
        Token(_token).transfer(msg.sender, _amount);

        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount;

        // Emit event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    // Check balances
    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
        {
            return tokens[_token][_user];
        }


    // ------------------
    // MAKE & CANCEL ORDERS

    // Token Give (the token they want to spend) - wich token, and how much?
    // Token Get (the token the want to receive) - wich token, and how much?
    function makeOrder(
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive, 
        uint256 _amountGive
    ) public {
    // Require token balance
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

        orderCount = orderCount + 1;
        orders[orderCount] = _Order(
            orderCount,    // id
            msg.sender,    // user
            _tokenGet,     // tokenGet
            _amountGet,    // amountGet
            _tokenGive,    // tokenGive (was incorrectly _amountGive)
            _amountGive,   // amountGive (was incorrectly _tokenGive)
            block.timestamp // timestamp
        );

        // Emit event
        emit Order(
            orderCount,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            block.timestamp
        );
    }
}
