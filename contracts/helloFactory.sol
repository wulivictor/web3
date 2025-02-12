// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import {HelloWolrd} from "./hello.sol";

contract helloFactory {
    HelloWolrd hw;
    HelloWolrd[] hellos;

    function createHello() public {
        hw = new HelloWolrd();
        hellos.push(hw);
    }

    function getHelloByIndex(uint256 _id) public view returns (HelloWolrd) {
        return hellos[_id];
    }

    function callHello(uint256 _id) public view returns  (string memory) {
        return hellos[_id].sayHello(_id);
    }

    function setHello(uint256 _id, string memory _phrase) public  {
        hellos[_id].setHello(_id, _phrase);
    }
}
