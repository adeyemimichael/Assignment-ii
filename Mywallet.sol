// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract MyWallet {

    // State variables
    address private owner;

    enum TxType { Sent, Received, Withdrawn }

    struct History {
        address sender;
        address receiver;
        uint256 amount;
        uint256 time;
        TxType tx_type;
    }

    mapping(uint256 => History) private transactionHistory;
    uint256 private transactionCount;

    // Constructor
    constructor () {
        owner = msg.sender;
    }

    // Functions
    function send_money(address to, uint256 amount) public {
        require(msg.sender == owner, "You are not the wallet owner");
        uint256 balance = address(this).balance;
        require(amount <= balance, "Insufficient amount");

        payable(to).transfer(amount);

        // Log transaction
        transactionHistory[transactionCount] = History({
            sender: msg.sender,
            receiver: to,
            amount: amount,
            time: block.timestamp,
            tx_type: TxType.Sent
        });
        transactionCount++;
    }

    function receive_money() public payable {
        require(msg.value > 0, "Must send some ether");

        // Log transaction
        transactionHistory[transactionCount] = History({
            sender: msg.sender,
            receiver: address(this),
            amount: msg.value,
            time: block.timestamp,
            tx_type: TxType.Received
        });
        transactionCount++;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "You are not the wallet owner");
        uint256 balance = address(this).balance;
        require(amount <= balance, "Insufficient amount");

        payable(owner).transfer(amount);

        // Log transaction
        transactionHistory[transactionCount] = History({
            sender: address(this),
            receiver: owner,
            amount: amount,
            time: block.timestamp,
            tx_type: TxType.Withdrawn
        });
        transactionCount++;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTransaction(uint256 index) public view returns (History memory) {
        return transactionHistory[index];
    }

    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
}
