// SPDX-License-Identifier: GPL-3.0

// 1、创建一个收款函数  -- 增加金额限制， 转换金额，转成美元 来算，一个Eth等价于美元
// 2、记录投资人信息
// 3、在一定时间里，如果能众筹到期望的资金，则打款给厂家进行发货
// 4、在一定时间里，如果不能众筹到目标金额，则退款给投资人
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

pragma solidity >=0.8.2 <0.9.0;

contract FundMe {
    AggregatorV3Interface dataFeed;
    address owner;
    uint256 developTimeStamp;
    uint256 lockTime;

    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        owner = msg.sender;
        lockTime = _lockTime;
        developTimeStamp = block.timestamp;
    }

    uint256 constant MIN_PAY_AMOUNT = 1 * 10**18; // 最小投资 1usd，因为payable是以wei来算的，所以这儿也要算18次方
    uint256 constant TARGET = 2 * 10**15;

    // 存储投资人地址和投资金额的映射关系 如果是1eth，这儿payable返回的是10^18,单位是按wei来算的
    mapping(address => uint256) public fundToAmount;

    function fund() public payable {
        require(convertPrice(msg.value) >= MIN_PAY_AMOUNT, "Send more Eth !");
        fundToAmount[msg.sender] = msg.value;
    }

    /**
     * 转换价格,喂价
     */

    function convertPrice(uint256 ethAomunt) internal view returns (uint256) {
        // 用户的金额 eth *  （eth-> usd）
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // 语言机获取的价格扩大了10^8，所以要除掉
        ethPrice = ethPrice / 10**8;
        return ethAomunt * ethPrice;
    }

    /**
     * Returns the latest answer.   这儿返回的是267424938090  就很好的解释了为啥上面要除8
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    /**
     * 获取众筹资金, 按usd计算
     */
    function getFund() public checkOwner windowClose {
        require(address(this).balance >= TARGET, "NOT REACH TARGET AMOUNT! ");

        // 设定限制条件，转移所有投资
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "tx failed !");
    }

    /**
     * 用户退款
     */
    function refund() public windowClose {
        require(address(this).balance < TARGET, "REACH TARGET AMOUNT! ");
        // 用户的投资
        uint256 userAmount = fundToAmount[msg.sender];
        require(userAmount > 0, " NOT MONEY REFUND FOR YOU !");

        // 设定限制条件，转移所有投资
        bool success = payable(msg.sender).send(userAmount);
        require(success, "tx failed !");
    }

    function transfrmOwnerShip(address newOwnerAddress) public {
        owner = newOwnerAddress;
    }

    modifier checkOwner() {
        require(msg.sender == owner, "This Operator can be owner !");
        _;
    }

    modifier windowClose() {
        require(
            block.timestamp >= developTimeStamp + lockTime,
            "Time is not Close !"
        );
        _;
    }
}
