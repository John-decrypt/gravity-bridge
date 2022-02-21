pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./Gravity.sol";

pragma experimental ABIEncoderV2;

contract CronosGravity is Gravity, AccessControl, Pausable, Ownable {
    bytes32 public constant RELAYER = keccak256("RELAYER");
    bytes32 public constant RELAYER_ADMIN = keccak256("RELAYER_ADMIN");

    //    modifier onlyRole(bytes32 role) {
    //        require(hasRole(role, msg.sender), "CronosGravity::Permission Denied");
    //        _;
    //    }

    constructor (
        // A unique identifier for this gravity instance to use in signatures
        bytes32 _gravityId,
        // How much voting power is needed to approve operations
        uint256 _powerThreshold,
        // The validator set
        address[] memory _validators,
        uint256[] memory _powers,
        address relayerAdmin
    ) Gravity(
        _gravityId,
        _powerThreshold,
        _validators,
        _powers
    ) {
        _setupRole(RELAYER_ADMIN, relayerAdmin);
        _setRoleAdmin(RELAYER, RELAYER_ADMIN);
        _setRoleAdmin(RELAYER_ADMIN, RELAYER_ADMIN);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function updateValset(
        // The new version of the validator set
        ValsetArgs calldata _newValset,
        // The current validators that approve the change
        ValsetArgs calldata _currentValset,
        // These are arrays of the parts of the current validator's signatures
        ValSignature[] calldata _sigs
    ) public override whenNotPaused onlyRole(RELAYER) {
        super.updateValset(_newValset, _currentValset, _sigs);
    }

    function submitBatch(
        // The validators that approve the batch
        ValsetArgs calldata _currentValset,
        // These are arrays of the parts of the validators signatures
        ValSignature[] calldata _sigs,
        // The batch of transactions
        uint256[] calldata _amounts,
        address[] calldata _destinations,
        uint256[] calldata _fees,
        uint256 _batchNonce,
        address _tokenContract,
        // a block height beyond which this batch is not valid
        // used to provide a fee-free timeout
        uint256 _batchTimeout
    ) public override whenNotPaused onlyRole(RELAYER) {
        super.submitBatch(
            _currentValset, _sigs, _amounts,
            _destinations, _fees, _batchNonce, _tokenContract,
            _batchTimeout
        );
    }

    function submitLogicCall(
        // The validators that approve the call
        ValsetArgs calldata _currentValset,
        // These are arrays of the parts of the validators signatures
        ValSignature[] calldata _sigs,
        LogicCallArgs memory _args
    ) public override whenNotPaused onlyRole(RELAYER) {
        super.submitLogicCall(
            _currentValset, _sigs, _args
        );
    }

    function sendToCronos(
        address _tokenContract,
        address _destination,
        uint256 _amount
    ) public override whenNotPaused {
        super.sendToCronos(
            _tokenContract, _destination, _amount
        );
    }

    function sendToCosmos(
		address _tokenContract,
		bytes32 _destination,
        uint256 _amount
    ) public override whenNotPaused {
        super.sendToCosmos(
            _tokenContract, _destination, _amount
        );
    }

    function transferRelayerAdmin (
        address _newAdmin
    ) public onlyRole(RELAYER_ADMIN) {
        grantRole(RELAYER_ADMIN, _newAdmin);
        revokeRole(RELAYER_ADMIN, msg.sender);
    }
}
