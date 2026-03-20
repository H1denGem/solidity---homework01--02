// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    mapping ( address => uint256 ) public votesReceived; // candidate => vote count;
    address[] public candidateList; // List of candidates
    mapping ( address => bool ) public isCandidate;

    uint8 public constant maxCandidates = 3;

    error InvalidCandidateListLength(uint len, uint max);
    error InvalidCandidateAddress();

    constructor(address initialOwner, address[] memory _candidateList) Ownable(initialOwner) {

        require(_candidateList.length <= maxCandidates, InvalidCandidateListLength(_candidateList.length, maxCandidates));

        candidateList = _candidateList; // Initialize the candidate list

        for (uint i = 0; i < _candidateList.length; i++) {
            isCandidate[_candidateList[i]] = true;
        }
    }

    function vote(address candidate) public {

        require(candidate != address(0), InvalidCandidateAddress());

        require( isCandidate[candidate], InvalidCandidateAddress()); // Require that the person is in the candidate list

        votesReceived[candidate] = ++votesReceived[candidate];
    }

    function getVotes(address candidate) public view returns(uint count) {

        require(candidate != address(0), InvalidCandidateAddress());

        require( isCandidate[candidate], InvalidCandidateAddress()); // Require that the person is in the candidate list

        return votesReceived[candidate];
    }

    function resetVotes() public onlyOwner {

        uint len = candidateList.length;

        for(uint i = 0; i < len; i++) {
            votesReceived[candidateList[i]] = 0;
        }
    }
}

contract ReverseString {
    function reverse(string memory input) public pure returns (string memory) {
        uint256 length = bytes(input).length;
        bytes memory reversedBytes = new bytes(length);

        for (uint256 i = 0; i < length; i++) {
            reversedBytes[i] = bytes(input)[length - i - 1];
        }

        return string(reversedBytes);
    }
}

contract Int2RomaInt {
    function int2RomaInt(uint input) public pure returns (string memory roman) {
        if (input == 0) return "N";

        string[13] memory symbols = [
            "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"
        ];

        uint256[13] memory values = [uint256(1000), 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];

        for (uint i = 0; i < 13; i++) {
            while (input >= values[i]) {
                roman = string.concat(roman, symbols[i]);
                input -= values[i];
            }
        }
    }
}

contract RomaInt2Int {
    function romaInt2Int(string memory input) public pure returns (uint result) {
        bytes memory b = bytes(input);
        uint len = b.length;

        for (uint i = 0; i < len; i++) {
            bytes1 c = b[i];
            if (i < len - 1) {
                bytes1 next = b[i + 1];
                if (
                    (c == 'I' && next == 'V') ||
                    (c == 'I' && next == 'X') ||
                    (c == 'X' && next == 'L') ||
                    (c == 'X' && next == 'C') ||
                    (c == 'C' && next == 'D') ||
                    (c == 'C' && next == 'M')
                ) {
                    result += _getValue(next) - _getValue(c);
                    i++;
                    continue;
                }
            }
            result += _getValue(c);
        }
    }

    function _getValue(bytes1 c) private pure returns (uint) {
        if (c == 'N') return 0;
        if (c == 'I') return 1;
        if (c == 'V') return 5;
        if (c == 'X') return 10;
        if (c == 'L') return 50;
        if (c == 'C') return 100;
        if (c == 'D') return 500;
        if (c == 'M') return 1000;
        revert("Invalid Roman numeral");
    }
}

contract MergeSortedArray {

    // 两递增数组
    function merge(uint[] calldata arr1, uint[] calldata arr2) public pure returns (uint[] memory res) {
        uint len1 = arr1.length;
        uint len2 = arr2.length;
        uint i = 0;
        uint j = 0;
        uint k = 0;

        res = new uint[](len1 + len2);

        while (i < len1 && j < len2) {
            if (arr1[i] <= arr2[j]) {
                res[k] = arr1[i];
                i++;
            } else {
                res[k] = arr2[j];
                j++;
            }
            k++;
        }

        while (i < len1) {
            res[k] = arr1[i];
            i++;
            k++;
        }

        while (j < len2) {
            res[k] = arr2[j];
            j++;
            k++;
        }
    }
}

contract BinarySearch{

    uint constant MAX_LEN = 100;

    error TargetNotFound();
    error InvalidZeroArr();
    error ArrayTooLong(uint len, uint max);

    function binarySearch(uint[] calldata arr, uint target) public pure returns (uint index) {
        uint len = arr.length;

        if (len == 0) revert InvalidZeroArr();
        if (len >= MAX_LEN) revert ArrayTooLong(len, MAX_LEN);

        uint left = 0;          // 左边界
        uint right = len - 1;   // 右边界

        // 默认递增
        // 当左边界 <= 右边界时继续查找
        while (left <= right) {
            uint mid = left + (right - left) / 2;
            
            if (arr[mid] == target) {
                return mid;
            } else if (arr[mid] > target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        revert TargetNotFound();
    }
}
