pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./LibraToken.sol";

contract AirDropLibraToken is Ownable {
    using SafeMath for uint256;

    uint256 decimal = 10**uint256(18);
    uint256 TOTAL_AIRDROP_SUPPLY = 10000;
    uint256 TOTAL_AIRDROP_SUPPLY_UNITS = TOTAL_AIRDROP_SUPPLY ** decimal ;
    uint256 public distributedTotal = 0;

    uint256 airDropStartTime;
    uint256 airDropEndTime;

    // The token being dropped
    LibraToken public token;


    // List of admins
    mapping (address => bool) public airdropAdmins;

    mapping (address => bool) public airDrops;
    mapping (address => uint256) public airDropAmount;



    modifier onlyOwnerOrAdmin() {
        require(msg.sender == owner || airdropAdmins[msg.sender]);
        _;
    }



    function addAdmin(address _admin) public onlyOwner {
        airdropAdmins[_admin] = true;
    }


    modifier lessThanDistributedTotal{
        require(distributedTotal <= TOTAL_AIRDROP_SUPPLY_UNITS);
        _;
    }

    modifier onlyWhileAirDropPhaseOpen {
        require(block.timestamp > airDropStartTime && block.timestamp < airDropEndTime);
        require(token.balanceOf(this) > TOTAL_AIRDROP_SUPPLY_UNITS);
        _;
    }


    function AirDropLibraToken(
        uint256 _airDropTotal,
        uint256 _airDropStartTime,
        uint256 _airDropEndTime
    ) public {
        TOTAL_AIRDROP_SUPPLY = _airDropTotal;
        airDropStartTime = _airDropStartTime;
        airDropEndTime = _airDropEndTime;

    }


    function airdropTokens(address _recipient, uint256 amount) public onlyOwnerOrAdmin onlyWhileAirDropPhaseOpen lessThanDistributedTotal {
        require(amount > 0);

        uint256 airDropUnit = amount.mul(decimal);
        if (!airDrops[_recipient]) {
            airDrops[_recipient] = true;
            airDropAmount[_recipient] = airDropUnit;

            require(token.transfer(_recipient, airDropUnit));

            TOTAL_AIRDROP_SUPPLY = TOTAL_AIRDROP_SUPPLY.sub(airDropUnit);
            distributedTotal = distributedTotal.add(airDropUnit);
        }

    }



}
