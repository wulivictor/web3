// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
contract HelloWolrd{
    // 三中数据类型
    // struct mapping array
    struct Info{
        uint256 id;
        string phrase;
        address addr;
    }

    mapping (uint256 id => Info info)  infoMapping;


    string varString = "hello world !";

    // view 就是只读变量，不写， returns 就是定义返回值
    function sayHello(uint256  _id) public view returns (string memory) {
        if (infoMapping[_id].addr == address(0x0)) {
            return addinfo(varString);
        }
        return  addinfo(infoMapping[_id].phrase);
    }

    function setHello(uint256  _id, string memory _phrase) public {
        Info memory info = Info(_id, _phrase, msg.sender);
        infoMapping[_id] = info;
    }


    // internal就是内部调用，不暴漏出去， pure就是只运算

    function addinfo(string memory val) internal pure returns (string memory) {
        return string.concat(val, ": from Frank to Bob");
    }
}