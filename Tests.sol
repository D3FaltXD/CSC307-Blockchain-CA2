// SPDX-License-Identifier: GPL-3.0
        

        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
import "remix_accounts.sol";

// Import the contract to be tested
import "./Token.sol";



contract TokenTestSuite {
    Token token;         // Instance of the Token contract
    address owner;       // Owner address (account-0)
    address nonOwner;    // Non-owner address (account-1)
    address recipient;   // Recipient address (account-2)

    /// `beforeAll` runs before all other tests
    function beforeAll() public {
        // Initialize the accounts for testing
        owner = TestsAccounts.getAccount(0);
        nonOwner = TestsAccounts.getAccount(1);
        recipient = TestsAccounts.getAccount(2);

        // Deploy the Token contract
        token = new Token();
    }


function testInitialBalance() public {
    uint256 initialBalance = token.balances(token.owner());
   
    Assert.equal(initialBalance,1000, "Not Matching");
}

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
    function testInsufficientBalanceTransfer() public {
        uint256 transferAmount = 1100;

        // Attempt to transfer more tokens than the owner has
        bool success = false;
        try token.transfer(recipient, transferAmount) {
            success = true;
        } catch {}

        Assert.equal(success, false, "Transfer should fail due to insufficient balance");
    }
        function testMintingTokens() public {
        uint256 initialSupply = token.totalSupply();

        // Owner minting tokens
        uint256 mintAmount = 100;
        token.mint(mintAmount);

        uint256 newSupply = token.totalSupply();
        Assert.equal(newSupply, initialSupply + mintAmount, "Owner's minting failed");

        // Non-owner trying to mint tokens
    bool success = false;
try token.mint(mintAmount) { // remove from:nonOwner part here
    require(msg.sender == owner, "Only owner can mint");
} catch {}

        Assert.equal(success, false, "Non-owner should not be able to mint tokens");
    }
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
}