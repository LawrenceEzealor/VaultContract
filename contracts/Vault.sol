// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Vault {
    address public owner;

    struct Beneficiary {
        uint256 amount;
        bool hasReceived;
        uint deadline;
    }

    mapping(address => uint256) donors;

    mapping(address => mapping(address => Beneficiary[])) donorToBeneficiaries;

    uint256 contractBalance;

    Beneficiary[] allBeneficiary;

    function donate(address _receiver, uint _duration) external payable {
        require(msg.sender != address(0), "Zero address not allowed");

        require(msg.value > 0, "NO ZERO AMOUNT");

        donors[msg.sender] += msg.value;

        donorToBeneficiaries[msg.sender][_receiver].push(
            Beneficiary({
                amount: msg.value,
                deadline: (block.timestamp + _duration),
                hasReceived: false
            })
        );

        contractBalance = contractBalance + msg.value;
    }

    function claimGrant(address _donor, uint _index) external {
        require(msg.sender != address(0), "Zero address not allowed");

        require(
            !donorToBeneficiaries[_donor][msg.sender][_index].hasReceived,
            "Amount has been collected"
        );

        require(
            donorToBeneficiaries[_donor][msg.sender][_index].amount > 0,
            "Amount too low"
        );

        require(
            block.timestamp >
                donorToBeneficiaries[_donor][msg.sender][_index].deadline,
            "Not yet time to get benefit"
        );

        uint amount = donorToBeneficiaries[_donor][msg.sender][_index].amount;

        payable(msg.sender).transfer(amount);

        Beneficiary storage benf = donorToBeneficiaries[_donor][msg.sender][
            _index
        ];
        benf.amount -= amount;
        benf.deadline = 0;
        benf.hasReceived = true;

        contractBalance = contractBalance - amount;
    }
}
