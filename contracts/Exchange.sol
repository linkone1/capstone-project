//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    mapping(address => mapping(address => uint256)) public tokens;
    mapping(uint256 => _Order) public orders;
    uint256 public orderCount;
    mapping(uint256 => bool) public orderCancelled; // boolean/bool = True or False (statement)
    mapping(uint256 => bool) public orderFilled; // boolean/bool = True or False (statement)
    
    struct _Order {
        uint256 id;
        address user;
        address tokenGet;
        uint256 amountGet;
        address tokenGive;
        uint256 amountGive;
        uint256 timestamp;
    }


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

    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address creator,
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

        orderCount++;
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

    function cancelOrder(uint256 _id) public {
        // Fetch order
        _Order storage _order = orders[_id];
        // Cancel Order
        orderCancelled[_id] = true;

        // Ensure the caller of the function is the owner of the order
        require(address(_order.user) == msg.sender);

        // Order must exist
        require(_order.id == _id);

        // Emit event
        emit Cancel(
            _order.id,
            msg.sender,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive,
            block.timestamp
        );
    }

    // -------------------
    // EXECUTING ORDERS
    function fillOrder(uint256 _id) public {
        // 1. Must be valid orderId
        require(_id > 0 && _id <= orderCount, 'Order does not exist.');
        // 2. Order can't be filled
        require(!orderFilled[_id], 'The order cannot be filled.');
        // 3. Order can't be cancelled
        require(!orderCancelled[_id], 'The order cannot be cancelled.');

        // Fetch order
        _Order storage _order = orders[_id];
        
        // Swapping Tokens (trading)
        _trade(
            _order.id, 
            _order.user,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive
        );

        orderFilled[_order.id] = true;
    }

    function _trade(
        uint256 _orderId, 
        address _user,
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
    ) internal {
        // Fee is paid by the user who filled the order (msg.sender)
        // Fee is deducted from _amountGet

        uint256 _feeAmount = (_amountGet * feePercent) / 100;

        // Execute the trade
        // msg.sender is the user who filled the ordeer, while _user is who created the order.
        tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender] - (_amountGet + _feeAmount);
        tokens[_tokenGet][_user] = tokens[_tokenGet][_user] + _amountGet;

        // Charge fees
        tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount] + _feeAmount;

        tokens[_tokenGive][_user] = tokens[_tokenGive][_user] - _amountGive;
        tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender] + _amountGive;

        // Emit trade event
        emit Trade(
            _orderId,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            _user,
            block.timestamp
        );
    }
}
