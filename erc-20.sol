//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns(uint256);
    function balanceOf(address account) external view returns(uint256);
    function transfer(address recipient, uint amount) external returns(bool);
    function allowance(address owner, address spender) external view returns(uint256);
    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Block is IERC20{

    string public name = "Aviral";   //name of the token
    string public symbol = "AVI";   //symbol of token
    uint public decimal = 0;        
    address public founder;         //initially, the balance of founder will be equal to the total supply
    uint public totalSupply;
    bool emergency;

    mapping(address=>mapping(address=>uint)) allowed;
    mapping(address=>uint) public balances;
    mapping(address=>bool) public ifAccFreezed;

    constructor(){
        founder = msg.sender;
        totalSupply = 1000;
        balances[founder] = totalSupply;
    }

    modifier onlyFounder() {
         require(msg.sender==founder, "Founder access only!");
        _;
    }

    modifier ifFreeze() {
        require(ifAccFreezed[msg.sender] == false, "Your account has been freezed!");
        _;
    }

    modifier ifEmergency() {
        require(emergency == false, "Temporary outage due to an emergency!");
        _;
    }

    function balanceOf(address account) external ifEmergency() view returns(uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external ifFreeze() ifEmergency() returns(bool) {
        require(amount > 0, "Amount must be greater than zero!");
        require(balances[msg.sender] >= amount, "You don't have enough balance!");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //writing a cheque
    function approve(address spender, uint256 amount) external ifFreeze() ifEmergency() returns(bool) {
        require(amount > 0, "Amount must be greater than zero!");
        require(balances[msg.sender] >= amount, "You don't have enough balance!");
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    //viewing cheque details
    function allowance(address owner, address spender) external ifFreeze() ifEmergency() view returns(uint256) {
        return allowed[owner][spender];
    }

    //cashing the cheque
    function transferFrom(address sender, address recipient, uint256 amount) external ifFreeze() ifEmergency() returns(bool) {
        require(amount > 0, "Amount must be greater than zero!");
        require(balances[msg.sender] >= amount, "You don't have enough balance!");
        require(allowed[sender][recipient] >= amount, "Sender has not authorized!");
        balances[sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    function burnTokens(uint256 quantity) external onlyFounder() {
        require(quantity<=totalSupply, "Invalid amount of tokens!");
        totalSupply -= quantity;
        balances[founder] = totalSupply;
    }

    function freezeAcc(address accToFreeze) external onlyFounder() {
        ifAccFreezed[accToFreeze] = true;
    }

    function unFreezeAcc(address accToUnFreeze) external onlyFounder() {
        ifAccFreezed[accToUnFreeze] = false;
    }

    function callEmergency() external onlyFounder() {
        emergency = true;
    }

    function liftEmergency() external onlyFounder() {
        emergency = false;
    }
}