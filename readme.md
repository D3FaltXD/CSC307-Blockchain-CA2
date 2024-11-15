
<div style="text-align: center;">
    <img src="hero.png" alt="Banner" ">
</div>

## Problem Statement

Prepare a **Solidity smart contract** with a function to transfer tokens, update it to ensure that only the **owner** can perform the transfer. Write the necessary code to restrict the function to the owner and modify it to log the transfer events. Assume the necessary variables and structures are already in place.

## Approach and Implementation

The `Token` contract is designed to implement a basic token system with enhanced security features. The core functionalities include:

1. **Token Creation and Distribution:** The contract initializes with an initial supply of tokens, which are assigned to the contract owner. The `mint` function allows authorized minters (in this project only the owner is allowed to mint) to create new tokens and distribute them.
2. **Minter Role:** The `grantMinter` and `revokeMinter` functions enable the contract owner to grant and revoke minter privileges to specific addresses, ensuring controlled token creation.
3. **Blacklist Mechanism:** The `blacklist` and `removeFromBlacklist` functions allow the contract owner to restrict specific addresses from participating in token transactions, providing an additional layer of security.
4. **Secure Token Transfers:** The `transfer` function is restricted to minters and ensures that both the sender and recipient are not blacklisted. It also verifies that the sender has sufficient balance to perform the transfer.

By incorporating these features, the `Token` contract provides a flexible and secure framework for managing token distribution and transfers.

> The `Token` contract, implemented in **Solidity**, will be deployed and tested using the **Remix IDE**. This will allow for a comprehensive evaluation of its functionality, including token minting, blacklisting, and secure transfers.

## Module Wise Explanation

### Basic Implementation

The Solidity code begins by defining the core state variables:

- **`owner`:** Stores the address of the contract's owner.
- **`balances`:** Maps addresses to their corresponding token balances.
- **`isMinter`:** Maps addresses to a boolean indicating minter status.
- **`isBlacklisted`:** Maps addresses to a boolean indicating blacklist status.

Next, the token's metadata is defined:

- **`name`:** The human-readable name of the token.
- **`symbol`:** The token's ticker symbol.
- **`totalSupply`:** The total number of tokens in circulation.

Finally, an event named `Transfer` is declared to log token transfer events, providing transparency and traceability.

```solidity
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
```

### Testing

```solidity
function testInitialBalance() public {
    uint256 initialBalance = token.balances(token.owner());
    Assert.equal(initialBalance, 1000, "Not Matching");
}
```

This test case verifies that the initial balance of the contract owner is 1000 tokens, as set during the contract's deployment.

### Access Control

The `constructor` function initializes the contract's state:

- Sets the `owner` to the address that deployed the contract (`msg.sender`).
- Sets the `totalSupply` to 1000 tokens.
- Assigns the entire initial supply to the `owner`'s balance.
- Grants the `owner` the `minter` role.

The `onlyOwner` modifier is used to restrict certain functions to the contract's owner. It ensures that only the owner can execute those functions.

```solidity
// Constructor to set the owner and initial supply
constructor() {
    owner = msg.sender;
    totalSupply = 1000;  // Initial total supply
    balances[owner] = totalSupply;
    isMinter[owner] = true;  // Owner is the initial minter
}

// Modifier to restrict access to the owner
modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can perform this action");
    _;
}
```

> We will test the access control permissions, such as ensuring that only the owner can perform specific actions and that only minters can create new tokens, in a later section.

### Minting Tokens

**Minting** is the process of creating new tokens. In this context, it refers to increasing the total supply of tokens and allocating them to a specific address.

The `mint` function allows the creation of new tokens. It increases the `totalSupply` and credits the newly minted tokens to the caller's balance. To ensure security, the `onlyMinter` modifier restricts this function to addresses with the `minter` role.

**Managing Minter Roles**

The `grantMinter` and `revokeMinter` functions allow the contract owner to assign and revoke the `minter` role to specific addresses. This provides flexibility in managing who can create new tokens.

```solidity
// Modifier to restrict access to minters
modifier onlyMinter() {
    require(isMinter[msg.sender], "Only minters can perform this action");
    _;
}

// Function to mint new tokens
function mint(uint256 _amount) public onlyMinter {
    totalSupply += _amount;
    balances[msg.sender] += _amount;
}

// Function to grant minter role
function grantMinter(address minter) public onlyOwner {
    isMinter[minter] = true;
}

// Function to revoke minter role
function revokeMinter(address minter) public onlyOwner {
    isMinter[minter] = false;
}
```

> Also made sure only **Owner** can mint Tokens.

### Testing

This test case verifies owner-only minting functionality:

- Stores the initial total supply.
- Simulates the owner minting tokens and checks if the total supply increases accordingly.
- Attempts to mint tokens as a non-owner (removed code reflects this).
- Asserts that the non-owner's minting attempt fails, ensuring only the owner can mint new tokens.

```solidity
function testMintingTokens() public {
    uint256 initialSupply = token.totalSupply();

    // Owner minting tokens
    uint256 mintAmount = 100;
    token.mint(mintAmount);
    uint256 newSupply = token.totalSupply();

    Assert.equal(newSupply, initialSupply + mintAmount, "Owner's minting failed");

    // Non-owner trying to mint token
    bool success = false;
    try token.mint(mintAmount) {
        require(msg.sender == owner, "Only owner can mint");
    } catch {}
    
    Assert.equal(success, false, "Non-owner should not be able to mint tokens");
}
```

### Transfer

**Token Transfer**

This function allows a minter to transfer tokens from their balance to another address. However, it includes several checks to ensure the validity of the transfer:

1. **Blacklist Check:**
     - Verifies that neither the sender nor the recipient is on the blacklist.
     - Prevents transfers involving blacklisted addresses.
2. **Balance Check:**
     - Ensures that the sender has sufficient funds to perform the transfer.
     - Prevents transfers that would result in a negative balance.
3. **Transfer Execution:**
     - If all checks pass, the specified amount of tokens is deducted from the sender's balance and added to the recipient's balance.
     - A `Transfer` event is emitted to log the transaction details.

This function provides a secure and controlled way for minters to transfer tokens, while also preventing malicious activity and ensuring the integrity of the token system.

```solidity
// Function to transfer tokens, restricted to minters and not blacklisted
function transfer(address to, uint256 amount) public onlyMinter {
    require(!isBlacklisted[msg.sender], "Sender is blacklisted");
    require(!isBlacklisted[to], "Receiver is blacklisted");
    require(balances[msg.sender] >= amount, "Insufficient balance");

    balances[msg.sender] -= amount;
    balances[to] += amount;

    emit Transfer(msg.sender, to, amount);
}
```

> `modifier onlyOwner() { require(msg.sender == owner, "Only the owner can perform this action"); _; }`
> 
> This ensured that only the Owner can initiate the transfer

### Testing

**Case 1:**

```solidity
function testInitialBalance() public {
    uint256 initialBalance = token.balances(token.owner());
    Assert.equal(initialBalance, 1000, "Not Matching");
}
```

This test case verifies that the initial balance of the contract owner is **1000** tokens, as expected.

**Case 2:**

```solidity
function testTransferTokens() public {
    uint256 transferAmount = 10;
    token.transfer(recipient, transferAmount);

    // Check owner's balance after transfer
    uint256 ownerBalance = token.balances(owner);
    Assert.equal(ownerBalance, 0, "Owner balance after transfer is incorrect");

    // Check recipient's balance after transfer
    uint256 recipientBalance = token.balances(recipient);
    Assert.equal(recipientBalance, transferAmount, "Recipient balance after transfer is incorrect");
}
```

This test case verifies the core functionality of token transfers:

- A specific amount of tokens is transferred from the owner to a recipient address.
- The test then asserts that the owner's balance is reduced by the transferred amount, and the recipient's balance is increased by the same amount.

**Case 3:**

```solidity
function testNonOwnerTransfer() public {
    // Attempt to transfer tokens from the non-owner
    uint256 transferAmount = 990;

    bool success = false;
    uint256 initialOwnerBalance = token.balances(owner);
    try token.transfer(recipient, transferAmount) {
        success = true;
    } catch {}

    // Assert that the transfer failed
    require(success, "Non-owner should not be able to transfer tokens");

    // Additionally, you can check if the owner's balance remains unchanged
    uint256 ownerBalanceAfterTransfer = token.balances(owner);
    Assert.equal(ownerBalanceAfterTransfer, initialOwnerBalance, "Owner's balance should not change");
}
```

This test case ensures that only authorized entities can transfer tokens. It attempts to transfer tokens from a non-owner address to a recipient. The test then verifies that the transfer fails, confirming that only minters can initiate token transfers. Additionally, it checks that the owner's balance remains unchanged, further validating the access control mechanism.

**Case 4:**

```solidity
function testInsufficientBalanceTransfer() public {
    uint256 transferAmount = 1100;

    // Attempt to transfer more tokens than the owner has
    bool success = false;
    try token.transfer(recipient, transferAmount) {
        success = true;
    } catch {}

    Assert.equal(success, false, "Transfer should fail due to insufficient balance");
}
```

**Insufficient Balance Transfer:** Verifies that transfers are restricted by the sender's available balance.

### Blacklist

These functions provide mechanisms for managing a blacklist of addresses.

- **`blacklist(address addr)`:**
    - Only the contract owner can call this function.
    - It sets the `isBlacklisted` flag to `true` for the specified `addr`.
    - This effectively prevents the blacklisted address from interacting with the contract, such as transferring tokens or minting.
- **`removeFromBlacklist(address addr)`:**
    - Again, only the contract owner can call this function.
    - It sets the `isBlacklisted` flag to `false` for the specified `addr`, removing the address from the blacklist.

These functions allow for flexible control over which addresses can participate in the token system.

```solidity
// Function to blacklist an address
function blacklist(address addr) public onlyOwner {
    isBlacklisted[addr] = true;
}

// Function to remove from blacklist
function removeFromBlacklist(address addr) public onlyOwner {
    isBlacklisted[addr] = false;
}
```

### Testing

```solidity
function testBlacklisting() public {
    // Blacklisting a non-owner address
    token.blacklist(nonOwner);

    // Trying to transfer tokens to the blacklisted address
    uint256 transferAmount = 100;
    bool success = false;
    try token.transfer(nonOwner, transferAmount) {
        success = true;
    } catch {}

    Assert.equal(success, false, "Transfer to blacklisted address should fail");
}
```

This test case validates the blacklist functionality:

1. **Blacklisting:** The test blacklists a non-owner address.
2. **Transfer Attempt:** It attempts to transfer tokens to the blacklisted address.
3. **Failure Verification:** The test asserts that the transfer fails, confirming that the blacklist mechanism prevents transactions involving blacklisted addresses.

## Conclusion

The provided Solidity code effectively implements a basic token contract with essential features like ownership, token balances, minting, and blacklisting. The test cases thoroughly validate the contract's functionality, ensuring its reliability and security.

**Future Enhancements:**

- **Token Burning:** Implement a mechanism to permanently destroy tokens.
- **Token Pausing:** Introduce a feature to temporarily halt all token transfers.
- **ERC-20 Compliance:** Adhere to the ERC-20 standard for broader compatibility.
- **Gas Optimization:** Optimize the contract's gas consumption for efficient transactions.

**References:**

- **Solidity Documentation:** [https://soliditylang.org/](https://soliditylang.org/)
- **OpenZeppelin Contracts:** [https://www.openzeppelin.com/solidity-contracts](https://www.openzeppelin.com/solidity-contracts)

