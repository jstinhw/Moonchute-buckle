// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "./plugin/IPlugin.sol";
import "account-abstraction/core/Helpers.sol";
import "account-abstraction/interfaces/IAccount.sol";
import "account-abstraction/interfaces/IEntryPoint.sol";
import {EntryPoint} from  "account-abstraction/core/EntryPoint.sol";
import "./utils/Exec.sol";
import "./abstract/Compatibility.sol";
import "./abstract/KernelStorage.sol";
import "forge-std/console2.sol";

/// @title Kernel
/// @author taek<leekt216@gmail.com>
/// @notice wallet kernel for minimal wallet functionality
/// @dev supports only 1 owner, multiple plugins
contract Kernel is IAccount, EIP712, Compatibility, KernelStorage {
    error InvalidNonce();
    error InvalidSignatureLength();
    error QueryResult(bytes result);

    string public constant name = "Kernel";

    string public constant version = "0.0.1";

    constructor(IEntryPoint _entryPoint) EIP712(name, version) KernelStorage(_entryPoint) {}

    /// @notice initialize wallet kernel
    /// @dev this function should be called only once, implementation initialize is blocked by owner = address(1)
    /// @param _owner owner address
    function initialize(address _owner, address _twoFactor) external {
        WalletKernelStorage storage ws = getKernelStorage();
        require(ws.owner == address(0), "account: already initialized");
        ws.owner = _owner;
        ws.twoFactorAddress = _twoFactor;
    }

    /// @notice Query plugin for data
    /// @dev this function will always fail, it should be used only to query plugin for data using error message
    /// @param _plugin Plugin address
    /// @param _data Data to query
    function queryPlugin(address _plugin, bytes calldata _data) external {
        (bool success, bytes memory _ret) = Exec.delegateCall(_plugin, _data);
        if (success) {
            revert QueryResult(_ret);
        } else {
            assembly {
                revert(add(_ret, 32), mload(_ret))
            }
        }
    }

    /// @notice execute function call to external contract
    /// @dev this function will execute function call to external contract
    /// @param to target contract address
    /// @param value value to be sent
    /// @param data data to be sent
    /// @param operation operation type (call or delegatecall)
    function executeAndRevert(address to, uint256 value, bytes calldata data, Operation operation) external {
        require(
            msg.sender == address(entryPoint),
            "account: not from entrypoint or owner"
        );
        bool success;
        bytes memory ret;
        if (operation == Operation.DelegateCall) {
            (success, ret) = Exec.delegateCall(to, data);
        } else {
            (success, ret) = Exec.call(to, value, data);
        }
        if (!success) {
            assembly {
                revert(add(ret, 32), mload(ret))
            }
        }
    }

    /// @notice validate user operation
    /// @dev this function will validate user operation and be called by EntryPoint
    /// @param userOp user operation
    /// @param userOpHash user operation hash
    /// @param missingAccountFunds funds needed to be reimbursed
    /// @return validationData validation data
    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        require(msg.sender == address(entryPoint), "account: not from entryPoint");
        // if (userOp.signature.length == 65) {
        if (address(bytes20(userOp.callData[16:36])) == address(this)) {
            validationData = _validateUserOp(userOp, userOpHash);
        } else if (userOp.signature.length > 97) {
            // userOp.signature = address(plugin) + validUntil + validAfter + pluginData + pluginSignature
            // address plugin = address(bytes20(userOp.signature[0:20]));
            // uint48 validUntil = uint48(bytes6(userOp.signature[20:26]));
            // uint48 validAfter = uint48(bytes6(userOp.signature[26:32]));
            // bytes memory signature = userOp.signature[32:97];
            // (bytes memory data,) = abi.decode(userOp.signature[97:], (bytes, bytes));
            // bytes32 digest = _hashTypedDataV4(
            //     keccak256(
            //         abi.encode(
            //             keccak256(
            //                 "ValidateUserOpPlugin(address plugin,uint48 validUntil,uint48 validAfter,bytes data)"
            //             ), // we are going to trust plugin for verification
            //             plugin,
            //             validUntil,
            //             validAfter,
            //             keccak256(data)
            //         )
            //     )
            // );
            // uint48 validUntil = uint48(bytes6(userOp.signature[0:6]));
            // uint48 validAfter = uint48(bytes6(userOp.signature[6:12]));

            bytes memory signatureOwner = userOp.signature[0:65];
            bytes memory signatureTwoFactor = userOp.signature[65:130];
            address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(userOpHash), signatureOwner);
            address twoFactor = ECDSA.recover(ECDSA.toEthSignedMessageHash(userOpHash), signatureTwoFactor);

            if (getKernelStorage().owner != signer || getKernelStorage().twoFactorAddress != twoFactor) {
                return SIG_VALIDATION_FAILED;
            }
            validationData = 0;
        } else if (bytes4(userOp.callData[164:168]) == hex"940d3c60") {
            revert InvalidSignatureLength();
        } else {
            revert InvalidSignatureLength();
        }
        if (missingAccountFunds > 0) {
            // we are going to assume signature is valid at this point
            (bool success,) = msg.sender.call{value: missingAccountFunds}("");
            (success);
            return validationData;
        }
    }

    function _validateUserOp(UserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        WalletKernelStorage storage ws = getKernelStorage();
        if (ws.owner == ECDSA.recover(userOpHash, userOp.signature)) {
            return validationData;
        }

        bytes32 hash = ECDSA.toEthSignedMessageHash(userOpHash);
        address recovered = ECDSA.recover(hash, userOp.signature);
        if (ws.owner != recovered) {
            return SIG_VALIDATION_FAILED;
        }
    }

    /**
     * delegate the contract call to the plugin
     */
    function _delegateToPlugin(
        address plugin,
        UserOperation calldata userOp,
        bytes32 opHash,
        uint256 missingAccountFunds
    ) internal returns (bytes memory) {
        bytes memory data =
            abi.encodeWithSelector(IPlugin.validatePluginData.selector, userOp, opHash, missingAccountFunds);
        (bool success, bytes memory ret) = Exec.delegateCall(plugin, data); // Q: should we allow value > 0?
        if (!success) {
            assembly {
                revert(add(ret, 32), mload(ret))
            }
        }
        return ret;
    }

    /// @notice validate signature using eip1271
    /// @dev this function will validate signature using eip1271
    /// @param _hash hash to be signed
    /// @param _signature signature
    function isValidSignature(bytes32 _hash, bytes calldata _signature) public view override returns (bytes4) {
        WalletKernelStorage storage ws = getKernelStorage();
        if (_signature.length < 130) {
            return 0xffffffff;
        }
        bytes memory signatureOwner = _signature[0:65];
        bytes memory signatureTwoFactor = _signature[65:130];
        if (ws.owner == ECDSA.recover(_hash, signatureOwner) && ws.twoFactorAddress == ECDSA.recover(_hash, signatureTwoFactor)) {
            return 0x1626ba7e;
        }
        bytes32 hash = ECDSA.toEthSignedMessageHash(_hash);
        address recoveredOwner = ECDSA.recover(hash, signatureOwner);
        address recoveredTwoFactor = ECDSA.recover(hash, signatureTwoFactor);
        // Validate signatures
        if (ws.owner == recoveredOwner && ws.twoFactorAddress == recoveredTwoFactor) {
            return 0x1626ba7e;
        } else {
            return 0xffffffff;
        }
    }

    function lock() public pure {}
}
