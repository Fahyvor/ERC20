// SPDX-License_Identifier: MIT
pragma solidity ^0.8.7;

import "IERC20Metadata.sol";
import "Ownable.sol";
import "Reentrancy.sol";
import "Context.sol";
    contract ERC20 is Context, IERC20Metadata, Ownable{

        string public override name;
        string public override symbol;
        uint256 public override totalSupply;
        uint256 public override decimals;
       
    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) public allowances;


    constructor (string memory _name, string memory _symbol, uint256 _totalSupply, uint256 _decimals) {
        balances[msg.sender] = _totalSupply;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimals = _decimals;
    }

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceOf(address owner) public view override returns (uint256) {
        return balances[owner];
    }

    function transfer(address receipient, uint256 amount) public override returns (uint256) {
        require(amount <= balances[msg.sender], "Insufficient Balance");
        balances[msg.sender] -= amount;
        balances[receipient] += amount;
        emit Transfer(msg.sender, receipient, amount);
        return amount;
    }

    function allowance(address owner, address spender, uint256 amount) external view override returns (uint256) {
        return amount;
    }

    function approve(address owner, address delegate, uint256 value) public override returns (uint256) {
        require(owner != address(0), "Inappropriate Transaction");
        require(delegate != address(0), "Inappropriate Transaction");
        allowances[msg.sender][delegate] += value;
        emit Approval(msg.sender, delegate, value);
        return value;
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual returns (uint256) {
        uint256 currentAllowance = allowances[owner][spender];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: Insufficient Allowance");
            unchecked {
                approve(owner, spender, currentAllowance - amount);
            }
        }
        return amount;
    }

    function Sell(address buyer, uint256 amount) public payable {
       require(amount <= balances[msg.sender], "Error, Not enough balance");
        balances[msg.sender] -= amount;
        balances[buyer] += amount;
    }

    function buyToken(address buyer, uint256 amount) external payable {
        require(buyer != msg.sender);
        amount = msg.value;
        balances[buyer] += amount;

    }

    function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(address(0) != newOwner, "Tokens cannot be sent to self");
        _transferOwnership(newOwner);
        balances[newOwner] = totalSupply;
    }
  
    function transferFrom(address owner, address buyer, uint256 amount) public override returns (bool) {
        require(amount <= balances[msg.sender]);
        require(amount <= allowances[msg.sender][owner]);

        balances[msg.sender] -= amount;
        allowances[msg.sender][owner] -= amount;
        balances[buyer] += amount;
        emit Transfer(owner, buyer, amount);
        return true;
    }

    function increaseAllowance (address spender, uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowances[owner][spender];
        currentAllowance += amount;

        approve(owner, spender, amount);

        return true;
    }

    function decreaseAllowance(address spender,  uint256 amount) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowances[owner][spender];
        require(currentAllowance >= amount, "ERC20 decreased allowance below zero");
        currentAllowance -= amount;

        approve(owner, spender, currentAllowance);

        return true;
    }

    function mint(address account, uint256 amount) internal onlyOwner {
        require(account != address(0), "ERC: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
       
        totalSupply += amount;
        balances[account] += amount;

        emit Transfer(address(0), account, amount);
        
        _afterTokenTransfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) internal{
        require(account != address(0), "Token: Burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        require(balances[account] >= amount, "Token: Burn amount exceeds limit");

        balances[account] -= amount;
        totalSupply -= amount;

        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function withdraw (address payable owner, uint256 value) public onlyOwner payable returns (uint256) {
        require(msg.sender == owner, "Only owner can call withdraw");
        require(msg.value <= value, "Insufficient Funds");

        owner.transfer(value);
        balances[owner] += value;
        return value; 
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual{}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    
    }
