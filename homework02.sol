// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BeggingContract is Ownable {

    mapping(address => uint256) private _donateRecord;
    address[] public donators;

    uint public totalAmout;

    address[3] private _rank;
    uint[3] private _rankAmount;

    uint256 private immutable DONATION_END_TIME; // 捐赠结束时间（部署后1天）
    uint256 private constant ONE_DAY = 86400;    // 1天的秒数（固定常量）

    error WithdrawFailed();
    error NoMoney();
    error DonationEnd();
    
    event Donate(address donator, uint amount);

    constructor(address owner) Ownable(owner) {

        DONATION_END_TIME = block.timestamp + ONE_DAY;
    }

    function donate() external payable {

        require(block.timestamp < DONATION_END_TIME, DonationEnd());

        require(msg.value > 0, NoMoney());

        uint newtotal = _donateRecord[msg.sender] + msg.value;

        _donateRecord[msg.sender] += msg.value;
        
        if(newtotal == msg.value) {

            donators.push(msg.sender);
        }

        totalAmout += msg.value;

        emit Donate(msg.sender, msg.value);

        _updateRanking(msg.sender, newtotal);
    }
    
    function withdraw() public onlyOwner {

        require(totalAmout != 0, NoMoney());

        uint amount = totalAmout;

        totalAmout = 0;

        (bool success, ) = address(owner()).call{value: amount}("");
        require(success, WithdrawFailed());
    }

    function getDonation(address donator) external view returns (uint) {

        return _donateRecord[donator];
    }

    function _updateRanking(address donor, uint256 amount) private {

        if (amount <= _rankAmount[2]) {
            return; // 金额小于等于第三名，无需更新
        }

        // 找到当前捐赠者在排行榜中的位置（如果已在榜）
        int256 existingIndex = -1;
        for (uint256 i = 0; i < 3; i++) {
            if (_rank[i] == donor) {
                existingIndex = int256(i);
                break;
            }
        }

        if (existingIndex != -1) {
            // 情况1：捐赠者已在榜，更新金额后重新排序
            _rankAmount[uint256(existingIndex)] = amount;
        } else {
            // 情况2：捐赠者不在榜，替换第三名并重新排序
            _rank[2] = donor;
            _rankAmount[2] = amount;
        }

        _sortTop3();
    }


    function _sortTop3() private {

        for (uint i = 0; i < 2; i++) {
            for (uint j = 0; j < 2 - i; j++) {
                if (_rankAmount[j] < _rankAmount[j + 1]) {
                    // 交换金额
                    ( _rankAmount[j], _rankAmount[j + 1] ) = ( _rankAmount[j + 1], _rankAmount[j] );
                    // 交换地址
                    ( _rank[j], _rank[j + 1] ) = ( _rank[j + 1], _rank[j] );
                }
            }
        }
    }


    function getTop3Donors() 
        external 
        view 
        returns (
            address top1, uint256 top1Amount,
            address top2, uint256 top2Amount,
            address top3, uint256 top3Amount
        ) 
    {
        return (
            _rank[0], _rankAmount[0],
            _rank[1], _rankAmount[1],
            _rank[2], _rankAmount[2]
        );
    }
}