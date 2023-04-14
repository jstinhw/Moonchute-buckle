import { Signer, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../common";
import type { SenderCreator, SenderCreatorInterface } from "../SenderCreator";
type SenderCreatorConstructorParams = [signer?: Signer] | ConstructorParameters<typeof ContractFactory>;
export declare class SenderCreator__factory extends ContractFactory {
    constructor(...args: SenderCreatorConstructorParams);
    deploy(overrides?: Overrides & {
        from?: PromiseOrValue<string>;
    }): Promise<SenderCreator>;
    getDeployTransaction(overrides?: Overrides & {
        from?: PromiseOrValue<string>;
    }): TransactionRequest;
    attach(address: string): SenderCreator;
    connect(signer: Signer): SenderCreator__factory;
    static readonly bytecode = "0x608060405234801561001057600080fd5b50610342806100206000396000f3fe608060405234801561001057600080fd5b506004361061002b5760003560e01c8063570e1a3614610030575b600080fd5b61004a6004803603810190610045919061017b565b610060565b6040516100579190610209565b60405180910390f35b60008083836000906014926100779392919061022e565b9061008291906102ad565b60601c905060008484601490809261009c9392919061022e565b8080601f016020809104026020016040519081016040528093929190818152602001838380828437600081840152601f19601f8201169050808301925050505050505090506000602060008351602085016000875af1905060005193508061010357600093505b50505092915050565b600080fd5b600080fd5b600080fd5b600080fd5b600080fd5b60008083601f84011261013b5761013a610116565b5b8235905067ffffffffffffffff8111156101585761015761011b565b5b60208301915083600182028301111561017457610173610120565b5b9250929050565b600080602083850312156101925761019161010c565b5b600083013567ffffffffffffffff8111156101b0576101af610111565b5b6101bc85828601610125565b92509250509250929050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b60006101f3826101c8565b9050919050565b610203816101e8565b82525050565b600060208201905061021e60008301846101fa565b92915050565b600080fd5b600080fd5b6000808585111561024257610241610224565b5b8386111561025357610252610229565b5b6001850283019150848603905094509492505050565b600082905092915050565b60007fffffffffffffffffffffffffffffffffffffffff00000000000000000000000082169050919050565b600082821b905092915050565b60006102b98383610269565b826102c48135610274565b92506014821015610304576102ff7fffffffffffffffffffffffffffffffffffffffff000000000000000000000000836014036008026102a0565b831692505b50509291505056fea2646970667358221220254a574c4e38345d2b38d3f9113ecde85268820b009a2b177cb400255eae75e464736f6c63430008120033";
    static readonly abi: readonly [{
        readonly inputs: readonly [{
            readonly internalType: "bytes";
            readonly name: "initCode";
            readonly type: "bytes";
        }];
        readonly name: "createSender";
        readonly outputs: readonly [{
            readonly internalType: "address";
            readonly name: "sender";
            readonly type: "address";
        }];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): SenderCreatorInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): SenderCreator;
}
export {};
