// SPDX-License-Identifier: GPL-3.0

// 1、创建一个收款函数  -- 增加金额限制， 转换金额，转成美元 来算，一个Eth等价于美元
// 2、记录投资人信息
// 3、在一定时间里，如果能众筹到期望的资金，则打款给厂家进行发货
// 4、在一定时间里，如果不能众筹到目标金额，则退款给投资人
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

pragma solidity >=0.8.2 <0.9.0;
contract FundMe {

    AggregatorV3Interface dataFeed;
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    uint256 MIN_PAY_AMOUNT = 10 * 10 ** 18; // usd


    mapping (address => uint256) public fundToAmount;
    function fund () payable public {
        require(convertPrice(msg.value) >= MIN_PAY_AMOUNT, "Send more Eth !");
        fundToAmount[msg.sender] = msg.value;

    }


    /**
     * 转换价格
     */

    function convertPrice(uint256 ethAomunt) internal view returns (uint256) {
        // 用户的金额 eth *  （eth-> usd） 
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // 语言机获取的价格扩大了10^8，所以要除掉
        ethPrice = ethPrice / 10 ** 8;
        return  ethAomunt * ethPrice;
        

    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
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
}