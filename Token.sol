// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public isMinter;
    mapping(address => bool) public isBlacklisted;

    // Token metadata
    string public name = "Block Chain CA2";
    string public symbol = "CSC";
    uint256 public totalSupply;

    // Event to log transfers
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Constructor to set the owner and initial supply
    constructor() {
        owner = msg.sender;
        totalSupply = 1000; // Initial total supply
        balances[owner] = totalSupply;
        isMinter[owner] = true; // Owner is the initial minter
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to restrict access to minters

        function mint(uint256 _amount) public {
        totalSupply += _amount;
        balances[msg.sender] += _amount;
    }
    modifier onlyMinter() {
        require(isMinter[msg.sender], "Only minters can perform this action");
        _;
    }

    // Function to grant minter role
    function grantMinter(address minter) public onlyOwner {
        isMinter[minter] = true;
    }

    // Function to revoke minter role
    function revokeMinter(address minter) public onlyOwner {
        isMinter[minter] = false;
    }

    // Function to blacklist an address
    function blacklist(address addr) public onlyOwner {
        isBlacklisted[addr] = true;
    }

    // Function to remove from blacklist
    function removeFromBlacklist(address addr) public onlyOwner {
        isBlacklisted[addr] = false;
    }

    // Function to transfer tokens, restricted to minters and not blacklisted
    function transfer(address to, uint256 amount) public onlyMinter {
        require(!isBlacklisted[msg.sender], "Sender is blacklisted");
        require(!isBlacklisted[to], "Receiver is blacklisted");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
    }
}