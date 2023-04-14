import { Signer, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type { MinimalAccount, MinimalAccountInterface } from "../MinimalAccount";
type MinimalAccountConstructorParams = [signer?: Signer] | ConstructorParameters<typeof ContractFactory>;
export declare class MinimalAccount__factory extends ContractFactory {
    constructor(...args: MinimalAccountConstructorParams);
    deploy(_entryPoint: PromiseOrValue<string>, overrides?: Overrides & {
        from?: PromiseOrValue<string>;
    }): Promise<MinimalAccount>;
    getDeployTransaction(_entryPoint: PromiseOrValue<string>, overrides?: Overrides & {
        from?: PromiseOrValue<string>;
    }): TransactionRequest;
    attach(address: string): MinimalAccount;
    connect(signer: Signer): MinimalAccount__factory;
    static readonly bytecode = "0x60a0346100bf57601f61138038819003918201601f19168301916001600160401b038311848410176100c4578084926020946040528339810103126100bf57516001600160a01b03811681036100bf576080527f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd880546001600160a01b03191660011790556040516112a590816100db82396080518181816103b3015281816105cf015281816106ca0152818161096801528181610ac10152610cb00152f35b600080fd5b634e487b7160e01b600052604160045260246000fdfe6080604052600436101561001b575b361561001957600080fd5b005b60003560e01c8063150b7a02146100db5780631626ba7e146100d65780633659cfe6146100d15780633a871cdd146100cc578063893d20e8146100c7578063940d3c60146100c2578063b0d691fe146100bd578063bc197c81146100b8578063c4d66de8146100b3578063d087d288146100ae578063f23a6e61146100a95763f2fde38b0361000e57610a72565b6109e5565b6108e9565b6107e6565b61071f565b61067f565b61054b565b6104da565b61046c565b610363565b6102cc565b610159565b6004359073ffffffffffffffffffffffffffffffffffffffff8216820361010357565b600080fd5b6024359073ffffffffffffffffffffffffffffffffffffffff8216820361010357565b9181601f840112156101035782359167ffffffffffffffff8311610103576020838186019501011161010357565b346101035760807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610103576101906100e0565b50610199610108565b5060643567ffffffffffffffff8111610103576101ba90369060040161012b565b505060206040517f150b7a02000000000000000000000000000000000000000000000000000000008152f35b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b90601f7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0910116810190811067ffffffffffffffff82111761025657604052565b6101e6565b67ffffffffffffffff811161025657601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe01660200190565b9291926102a18261025b565b916102af6040519384610215565b829481845281830111610103578281602093846000960137010152565b346101035760407ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101035760243567ffffffffffffffff81116101035736602382011215610103576103396103316020923690602481600401359101610295565b60043561113e565b7fffffffff0000000000000000000000000000000000000000000000000000000060405191168152f35b346101035760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101035761039a6100e0565b73ffffffffffffffffffffffffffffffffffffffff90817f00000000000000000000000000000000000000000000000000000000000000001633148015610440575b8015610437575b6103ec90610b7e565b807f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc55167fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b600080a2005b503330146103e3565b50817f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd8541633146103dc565b34610103577ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc606081360112610103576004359067ffffffffffffffff821161010357610160908236030112610103576104d26020916044359060243590600401610c96565b604051908152f35b346101035760007ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261010357602073ffffffffffffffffffffffffffffffffffffffff7f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd85416604051908152f35b346101035760807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610103576105826100e0565b60443567ffffffffffffffff8111610103576105a290369060040161012b565b6064929192356002811015610103576001906105ff73ffffffffffffffffffffffffffffffffffffffff807f0000000000000000000000000000000000000000000000000000000000000000163314908115610652575b506110a9565b61060881611134565b03610633576106229261061c913691610295565b90611245565b905b1561062b57005b602081519101fd5b61064c92610642913691610295565b906024359061121a565b90610624565b90507f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd854163314386105f9565b346101035760007ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261010357602060405173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000168152f35b9181601f840112156101035782359167ffffffffffffffff8311610103576020808501948460051b01011161010357565b346101035760a07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc360112610103576107566100e0565b5061075f610108565b5067ffffffffffffffff604435818111610103576107819036906004016106ee565b50506064358181116101035761079b9036906004016106ee565b5050608435908111610103576107b590369060040161012b565b50506040517fbc197c81000000000000000000000000000000000000000000000000000000008152602090f35b0390f35b346101035760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126101035761081d6100e0565b7f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd89081549073ffffffffffffffffffffffffffffffffffffffff80831661088b577fffffffffffffffffffffffff000000000000000000000000000000000000000091169116179055600080f35b60646040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601360248201527f416c726561647920696e697469616c697a6564000000000000000000000000006044820152fd5b34610103576000807ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc3601126109e2576040517f35567e1a00000000000000000000000000000000000000000000000000000000815230600482015281602482015260208160448173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000165afa9081156109dd5782916109a3575b604051828152602090f35b90506020813d82116109d5575b816109bd60209383610215565b810103126109d1576107e291505138610998565b5080fd5b3d91506109b0565b610c09565b80fd5b346101035760a07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261010357610a1c6100e0565b50610a25610108565b5060843567ffffffffffffffff811161010357610a4690369060040161012b565b505060206040517ff23a6e61000000000000000000000000000000000000000000000000000000008152f35b346101035760207ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc36011261010357610aa96100e0565b73ffffffffffffffffffffffffffffffffffffffff807f00000000000000000000000000000000000000000000000000000000000000001633148015610b52575b8015610b49575b610afa90610b7e565b7f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd891167fffffffffffffffffffffffff0000000000000000000000000000000000000000825416179055600080f35b50333014610af1565b50807f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd854163314610aea565b15610b8557565b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602d60248201527f6163636f756e743a206e6f742066726f6d20656e747279706f696e74206f722060448201527f6f776e6572206f722073656c66000000000000000000000000000000000000006064820152fd5b6040513d6000823e3d90fd5b9035907fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe181360301821215610103570180359067ffffffffffffffff82116101035760200191813603831361010357565b3d15610c91573d90610c778261025b565b91610c856040519384610215565b82523d6000602084013e565b606090565b9073ffffffffffffffffffffffffffffffffffffffff91827f0000000000000000000000000000000000000000000000000000000000000000163303610d5757610cfb610cf4610ce8610d0194611055565b92610140810190610c15565b3691610295565b90610db5565b7f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd8548216911603610d515780610d38575b50600090565b600080808093335af150610d4a610c66565b5038610d32565b50600190565b60646040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601c60248201527f6163636f756e743a206e6f742066726f6d20656e747279706f696e74000000006044820152fd5b610dca91610dc291610f94565b919091610e0b565b90565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052602160045260246000fd5b60051115610e0657565b610dcd565b610e1481610dfc565b80610e1c5750565b610e2581610dfc565b60018103610e8c576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601860248201527f45434453413a20696e76616c6964207369676e617475726500000000000000006044820152606490fd5b610e9581610dfc565b60028103610efc576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601f60248201527f45434453413a20696e76616c6964207369676e6174757265206c656e677468006044820152606490fd5b80610f08600392610dfc565b14610f0f57565b6040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602260248201527f45434453413a20696e76616c6964207369676e6174757265202773272076616c60448201527f75650000000000000000000000000000000000000000000000000000000000006064820152608490fd5b906041815114600014610fc257610fbe916020820151906060604084015193015160001a90610fcc565b9091565b5050600090600290565b9291907f7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a083116110495791608094939160ff602094604051948552168484015260408301526060820152600093849182805260015afa156109dd57815173ffffffffffffffffffffffffffffffffffffffff811615610d51579190565b50505050600090600390565b60405160208101917f19457468657265756d205369676e6564204d6573736167653a0a3332000000008352603c820152603c81526060810181811067ffffffffffffffff8211176102565760405251902090565b156110b057565b60846040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152602560248201527f6163636f756e743a206e6f742066726f6d20656e747279706f696e74206f722060448201527f6f776e65720000000000000000000000000000000000000000000000000000006064820152fd5b60021115610e0657565b9073ffffffffffffffffffffffffffffffffffffffff90817f439ffe7df606b78489639bc0b827913bd09e1246fa6802968a5b3694c53e0dd854169282611188610dc28484610f94565b1684146111f2576111a49161119f610dc292611055565b610f94565b16036111ce577f1626ba7e0000000000000000000000000000000000000000000000000000000090565b7fffffffff0000000000000000000000000000000000000000000000000000000090565b505050507f1626ba7e0000000000000000000000000000000000000000000000000000000090565b916000928392602083519301915af1903d604051906020818301016040528082526000602083013e90565b6000918291602082519201905af4903d604051906020818301016040528082526000602083013e9056fea264697066735822122022f4c2f7c8d3daed51166120f5cd396c53063894c2950172e1cdd1c53d2abafa64736f6c63430008120033";
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "contract IEntryPoint";
            readonly name: "_entryPoint";
            readonly type: "address";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "constructor";
    }, {
        readonly inputs: readonly [];
        readonly name: "InvalidNonce";
        readonly type: "error";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: true;
            readonly internalType: "address";
            readonly name: "newImplementation";
            readonly type: "address";
        }];
        readonly name: "Upgraded";
        readonly type: "event";
    }, {
        readonly inputs: readonly [];
        readonly name: "entryPoint";
        readonly outputs: readonly [{
            readonly internalType: "contract IEntryPoint";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "to";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "value";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "data";
            readonly type: "bytes";
        }, {
            readonly internalType: "enum Operation";
            readonly name: "operation";
            readonly type: "uint8";
        }];
        readonly name: "executeAndRevert";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "getNonce";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "getOwner";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_owner";
            readonly type: "address";
        }];
        readonly name: "initialize";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "bytes32";
            readonly name: "_hash";
            readonly type: "bytes32";
        }, {
            readonly internalType: "bytes";
            readonly name: "_signature";
            readonly type: "bytes";
        }];
        readonly name: "isValidSignature";
        readonly outputs: readonly [{
            readonly internalType: "bytes4";
            readonly name: "";
            readonly type: "bytes4";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "uint256[]";
            readonly name: "";
            readonly type: "uint256[]";
        }, {
            readonly internalType: "uint256[]";
            readonly name: "";
            readonly type: "uint256[]";
        }, {
            readonly internalType: "bytes";
            readonly name: "";
            readonly type: "bytes";
        }];
        readonly name: "onERC1155BatchReceived";
        readonly outputs: readonly [{
            readonly internalType: "bytes4";
            readonly name: "";
            readonly type: "bytes4";
        }];
        readonly stateMutability: "pure";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "";
            readonly type: "bytes";
        }];
        readonly name: "onERC1155Received";
        readonly outputs: readonly [{
            readonly internalType: "bytes4";
            readonly name: "";
            readonly type: "bytes4";
        }];
        readonly stateMutability: "pure";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "address";
            readonly name: "";
            readonly type: "address";
        }, {
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }, {
            readonly internalType: "bytes";
            readonly name: "";
            readonly type: "bytes";
        }];
        readonly name: "onERC721Received";
        readonly outputs: readonly [{
            readonly internalType: "bytes4";
            readonly name: "";
            readonly type: "bytes4";
        }];
        readonly stateMutability: "pure";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_newOwner";
            readonly type: "address";
        }];
        readonly name: "transferOwnership";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "address";
            readonly name: "_newImplementation";
            readonly type: "address";
        }];
        readonly name: "upgradeTo";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly components: readonly [{
                readonly internalType: "address";
                readonly name: "sender";
                readonly type: "address";
            }, {
                readonly internalType: "uint256";
                readonly name: "nonce";
                readonly type: "uint256";
            }, {
                readonly internalType: "bytes";
                readonly name: "initCode";
                readonly type: "bytes";
            }, {
                readonly internalType: "bytes";
                readonly name: "callData";
                readonly type: "bytes";
            }, {
                readonly internalType: "uint256";
                readonly name: "callGasLimit";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "verificationGasLimit";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "preVerificationGas";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "maxFeePerGas";
                readonly type: "uint256";
            }, {
                readonly internalType: "uint256";
                readonly name: "maxPriorityFeePerGas";
                readonly type: "uint256";
            }, {
                readonly internalType: "bytes";
                readonly name: "paymasterAndData";
                readonly type: "bytes";
            }, {
                readonly internalType: "bytes";
                readonly name: "signature";
                readonly type: "bytes";
            }];
            readonly internalType: "struct UserOperation";
            readonly name: "userOp";
            readonly type: "tuple";
        }, {
            readonly internalType: "bytes32";
            readonly name: "userOpHash";
            readonly type: "bytes32";
        }, {
            readonly internalType: "uint256";
            readonly name: "missingFunds";
            readonly type: "uint256";
        }];
        readonly name: "validateUserOp";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly stateMutability: "payable";
        readonly type: "receive";
    }];
    static createInterface(): MinimalAccountInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): MinimalAccount;
}
export {};