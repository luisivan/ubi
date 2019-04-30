pragma solidity ^0.4.24;

import "@aragon/os/contracts/apps/AragonApp.sol";
import "@aragon/os/contracts/lib/math/SafeMath.sol";
import "@aragon/apps-finance/contracts/Finance.sol";

contract UBI is AragonApp {
    using SafeMath for uint256;

    /// Events
    event Withdraw(address receiver, uint256 amount);
    event SetMaximumWithdrawal(uint256 maxWithdrawalAmount);

    /// State
    Finance public finance;
    address public token;
    uint256 public maxWithdrawalAmount;
    mapping (address => uint256) internal withdrawn;

    /// Errors
    string private constant ERROR_TOO_MUCH = "TOO_MUCH";

    /// ACL
    bytes32 constant public WITHDRAW_ROLE = keccak256("WITHDRAW_ROLE");
    bytes32 constant public CHANGE_MAXIMUM_WITHDRAWAL_ROLE = keccak256("CHANGE_MAXIMUM_WITHDRAWAL_ROLE");

    function initialize(Finance _finance, address _token) public onlyInit {
        initialized();

        finance = _finance;
        token = _token;
    }

    /**
     * @notice Withdraw `_amount`
     * @param _amount Amount to withdraw
     */
    function withdraw(uint256 _amount)
        external auth(INCREMENT_ROLE)
    {
        var alreadyWithdrawn = withdrawn[msg.sender];
        require(alreadyWithdrawn < maxWithdrawalAmount, ERROR_TOO_MUCH);

        finance.newImmediatePayment(token, msg.sender, _amount, "UBI");

        withdrawn[msg.sender] = alreadyWithdrawn.add(_amount);

        emit Withdraw(msg.sender, _amount);
    }

    /**
     * @notice Set the total maximum withdrawal per person to `_maxWithdrawalAmount`
     * @param _maxWithdrawalAmount Maximum withdrawal amount per person
     */
    function setMaximumWithdrawal(uint256 _maxWithdrawalAmount)
        external auth(CHANGE_MAXIMUM_WITHDRAWAL_ROLE)
    {
        maxWithdrawalAmount = _maxWithdrawalAmount;

        emit SetMaximumWithdrawal(_maxWithdrawalAmount);
    }
}
