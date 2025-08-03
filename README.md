# Merkle Airdrop

[](https://www.google.com/search?q=https://github.com/tohidul3417/merkle-airdrop/actions/workflows/test.yml)
[](https://opensource.org/licenses/MIT)

This project is a Foundry-based implementation of a gas-efficient and secure airdrop system using Merkle proofs. It allows for a large number of addresses to be included in an airdrop while minimizing the on-chain data storage and verification costs. The core of this project is to prove that a specific user is eligible for an airdrop without storing the entire list of eligible users on-chain. This repository was created as part of the "Airdrop and Signatures" section of the Advanced Foundry course offered by Cyfrin Updraft.

## Architecture

The protocol is centered around two main smart contracts:

  * **`MerkleAirdrop.sol`**: This is the core contract that manages the airdrop logic. It stores the Merkle root, which is a cryptographic commitment to the entire set of airdrop recipients and their respective amounts. The contract exposes a `claim` function that allows users to receive their tokens by providing a valid Merkle proof and a signature.
  * **`BagelToken.sol`**: A standard ERC20 token used for the airdrop. The `MerkleAirdrop` contract holds these tokens and distributes them to claimants. It includes a `mint` function restricted to the owner to create new tokens.

The off-chain part of the project involves generating a Merkle tree from a list of addresses and amounts. This is handled by scripts within the `script/` directory.

## Getting Started

### Prerequisites

  * [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  * [Foundry](https://getfoundry.sh/)

### Installation

1.  **Clone the repository** (including submodules):

    ```bash
    git clone --recurse-submodules https://github.com/tohidul3417/merkle-airdrop.git
    cd merkle-airdrop
    ```

2.  **Install dependencies**:

    ```bash
    forge install
    ```

3.  **Build the project**:

    ```bash
    forge build
    ```

4.  **Set up environment variables**:
    Create a `.env` file in the root of the project. This file will hold your RPC URLs and other sensitive information.

    ```bash
    touch .env
    ```

    Add the following variables to your `.env` file, replacing the placeholder values:

    ```
    SEPOLIA_RPC_URL="YOUR_SEPOLIA_RPC_URL"
    PRIVATE_KEY="YOUR_PRIVATE_KEY"
    ETHERSCAN_API_KEY="YOUR_ETHERSCAN_API_KEY"
    ```

-----

### ⚠️ Advanced Security: The Professional Workflow for Key Management

Storing a plain-text `PRIVATE_KEY` in a `.env` file is a significant security risk. If that file is ever accidentally committed to GitHub, shared, or compromised, any funds associated with that key will be stolen instantly.

The professional standard is to **never store a private key in plain text**. Instead, we use Foundry's built-in **keystore** functionality, which encrypts your key with a password you choose.

Here is the clear, step-by-step process:

#### **Step 1: Create Your Encrypted Keystore**

This command generates a new private key and immediately encrypts it, saving it as a secure JSON file.

1.  **Run the creation command:**

    ```bash
    cast wallet new
    ```

2.  **Enter a strong password:**
    The terminal will prompt you to enter and then confirm a strong password. **This is the only thing that can unlock your key.** Store this password in a secure password manager (like 1Password or Bitwarden).

3.  **Secure the output:**
    The command will output your new wallet's **public address** and the **path** to the encrypted JSON file (usually in `~/.foundry/keystores/`).

      * Save the public address. You will need it to send funds to your new secure wallet.
      * Note the filename of the keystore file.

At this point, your private key exists only in its encrypted form. It is no longer in plain text on your machine.

#### **Step 2: Fund Your New Secure Wallet**

Use a faucet or another wallet to send some testnet ETH to the new **public address** you just generated.

#### **Step 3: Use Your Keystore Securely for Deployments**

Now, when you need to send a transaction (like deploying a contract), you will tell Foundry to use your encrypted keystore. Your private key is **never** passed through the command line or stored in a file.

1.  **Construct the command:**
    Use the `--keystore` flag to point to your encrypted file and the `--ask-pass` flag to tell Foundry to securely prompt you for your password.
2.  **Example Deployment Command:**
    ```bash
    # This command deploys the MerkleAirdrop on Sepolia
    forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop \
        --rpc-url $SEPOLIA_RPC_URL \
        --keystore ~/.foundry/keystores/UTC--2025-07-27T...--your-wallet-address.json \
        --ask-pass \
        --broadcast
    ```
3.  **Enter your password when prompted:**
    Foundry will pause and securely ask for the password you created in Step 1.

**The Atomic Security Insight:** When you run this command, Foundry reads the encrypted file, asks for your password in memory, uses it to decrypt the private key for the single purpose of signing the transaction, and then immediately discards the decrypted key. The private key never touches your shell history or any unencrypted files. This is a vastly more secure workflow.

-----

## Usage

### Testing

The project includes a test suite to ensure the correctness of the airdrop functionality.

  * **Run all tests**:
    ```bash
    forge test
    ```
  * **Check test coverage**:
    ```bash
    forge coverage
    ```

### Deployment and Interaction

The `script/` directory contains Foundry scripts for deploying the contracts and interacting with the airdrop. The `Makefile` also provides convenient commands for these actions.

  * **Deploy the contracts**:
    ```bash
    make deploy ARGS="--network sepolia"
    ```
  * **Generate the Merkle tree input file**:
    ```bash
    make generate
    ```
  * **Generate the Merkle root and proofs**:
    ```bash
    make make
    ```
  * **Claim the airdrop**:
    ```bash
    make claim
    ```

-----

## ⚠️ Security Disclaimer

This project was built for educational purposes and has **not** been audited. Do not use in a production environment or with real funds. Always conduct a full, professional security audit before deploying any smart contracts.

-----

## License

This project is distributed under the MIT License. See `LICENSE` for more information.
