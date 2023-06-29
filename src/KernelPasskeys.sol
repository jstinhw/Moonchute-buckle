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
import "./abstract/KernelStoragePasskeys.sol";
import "forge-std/console2.sol";
import {Secp256r1} from "src/utils/EllipticCurveLibrary.sol";

/// @title KernelPasskeys
/// @author jhw<justin84602@gmail.com>
/// @notice wallet kernel for passkeys 2FA
/// @dev supports only 1 owner, multiple plugins
contract KernelPasskeys is IAccount, EIP712, Compatibility, KernelStoragePasskeys {
    error InvalidNonce();
    error InvalidSignatureLength();
    error QueryResult(bytes result);

    string public constant name = "Kernel";

    string public constant version = "0.0.1";

    constructor(IEntryPoint _entryPoint) EIP712(name, version) KernelStoragePasskeys(_entryPoint) {}

    /// @notice initialize wallet kernel
    /// @dev this function should be called only once, implementation initialize is blocked by owner = address(1)
    /// @param _owner owner address
    function initialize(
        address _owner, 
        uint256 _passkeysPublicKeyX,
        uint256 _passkeysPublicKeyY,
        string calldata _origin,
        bytes calldata _authData
    ) external {
        WalletKernelStorage storage ws = getKernelStorage();
        require(ws.owner == address(0), "account: already initialized");
        ws.owner = _owner;
        ws.passkeysPublicKeyX = _passkeysPublicKeyX;
        ws.passkeysPublicKeyY = _passkeysPublicKeyY;
        ws.origin = _origin;
        ws.authData = _authData;
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
        WalletKernelStorage storage ws = getKernelStorage();

        bytes memory sigByOwner = userOp.signature[0:65];
        bytes calldata sigByPasskeys = userOp.signature[65:129];
        address owner = ws.owner;

        if (
            owner == ECDSA.recover(userOpHash, sigByOwner) &&
            _validatePasskeysSignature(userOp.sender, userOpHash, sigByPasskeys)
        ) {
            return 0;
        }

        bytes32 hash = ECDSA.toEthSignedMessageHash(userOpHash);
        address recoveredOwner = ECDSA.recover(hash, sigByOwner);

        if (owner != recoveredOwner || !_validatePasskeysSignature(userOp.sender, hash, sigByPasskeys)) {
            return SIG_VALIDATION_FAILED;
        }

        if (missingAccountFunds > 0) {
            // we are going to assume signature is valid at this point
            (bool success,) = msg.sender.call{value: missingAccountFunds}("");
            (success);
            return validationData;
        }
    }

    /// @notice validate signature using eip1271
    /// @dev this function will validate signature using eip1271
    /// @param _hash hash to be signed
    /// @param _signature signature
    function isValidSignature(bytes32 _hash, bytes calldata _signature) public view override returns (bytes4) {
        WalletKernelStorage storage ws = getKernelStorage();
        if (_signature.length < 129) {
            return 0xffffffff;
        }
        bytes memory sigByOwner = _signature[0:65];
        bytes calldata sigByPasskeys = _signature[65:129];
        
        if (ws.owner == ECDSA.recover(_hash, sigByOwner) && _validatePasskeysSignature(msg.sender, _hash, sigByPasskeys)) {
            return 0x1626ba7e;
        } else {
            return 0xffffffff;
        }
    }

    function _validatePasskeysSignature(address sender, bytes32 hash, bytes calldata signature) internal view returns (bool) {
        WalletKernelStorage storage ws = getKernelStorage();
        uint256 passkeysPubkeyX = ws.passkeysPublicKeyX;
        uint256 passkeysPubkeyY = ws.passkeysPublicKeyY;
        string storage origin = ws.origin;
        bytes storage authData = ws.authData;
        uint256 r = uint256(bytes32(signature[0:32]));
        uint256 s = uint256(bytes32(signature[32:64]));

        bytes memory encodeString = 
            abi.encodePacked(
                bytes('{"type":"webauthn.get",'),
                bytes('"challenge":"'),
                _convertBytes32ToStringLiteral(hash),
                bytes('","origin":"'),
                bytes(origin),
                bytes('","crossOrigin":'),
                bytes('false}')
            );
        bytes32 messageencodeHash = sha256(encodeString);
        bytes memory signatureBase = abi.encodePacked(authData, messageencodeHash);
        bytes32 signatureHash = sha256(signatureBase);
        return Secp256r1.Verify(uint256(signatureHash), [r, s], [passkeysPubkeyX, passkeysPubkeyY]);
    }

    function _convertBytes32ToStringLiteral (bytes32 hash) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            bytes1 char = bytes1(bytes32(hash << (8 * i)));
            bytesArray[i * 2] = _convertBytes1ToASCII(char >> 4);
            bytesArray[i * 2 + 1] =  _convertBytes1ToASCII(char & 0x0f);
        }
        return string(bytesArray);
    }

    function _convertBytes1ToASCII (bytes1 char) internal pure returns (bytes1) {
        return bytes1(uint8(char) > 9 ? uint8(char) + 87 : uint8(char) + 48);
    }
}
