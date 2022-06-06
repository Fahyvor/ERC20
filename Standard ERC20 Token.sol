// SPDX-License_Identifier: MIT
pragma solidity ^0.8.7;

    contract ERC20 {
        string public name = "Token Name";
        string public symbol = "Token Symbol";
        uint256 public decimal = 18;
       

    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) public allowance;
   
    uint256 totalSupply = 1000000 * 10 ** 18;

    constructor () {
        balances[msg.sender] = totalSupply;
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

    function balanceOf(address owner) public view returns (uint256) {
        return balances[owner];
    }

    function transfer(address receipient, uint256 amount) public payable returns (uint256) {
        require(amount <= balances[msg.sender], "Insufficient Balance");
        balances[msg.sender] -= amount;
        balances[receipient] += amount;
        emit Transfer(msg.sender, receipient, amount);
        return amount;
    }

    function approve(address delegate, uint256 value) public payable returns (bool) {
        value = allowance[msg.sender][delegate];
        emit Approval(msg.sender, delegate, value);
        return true;
    }
  
    function transferFrom(address owner, address buyer, uint256 amount) public payable returns (uint256) {
        require(amount <= balances[msg.sender]);
        require(amount <= allowance[msg.sender][owner]);

        balances[msg.sender] -= amount;
        allowance[msg.sender][owner] -= amount;
        balances[buyer] += amount;
        emit Transfer(owner, buyer, amount);
        return amount;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, _allowance[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender,  uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = _allowance[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20 decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(address account, uint256 amount) internal payable {
        require(account != address(0), "ERC: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function withdraw (address receiver, uint256 value) internal payable returns (uint256) {
        require(msg.sender == owner, "Only owner can call withdraw");
        require(msg.value <= value, "Insufficient Funds");

        receiver.transfer(value);
        balances[receiver] += value;
        return value; 
    }
    
    }