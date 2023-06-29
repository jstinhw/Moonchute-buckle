// import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { constants, utils } from "ethers";
import { ethers, network } from "hardhat";
import {getECDSAKey, signECDSA, signTypedHashECDSA} from "./utils/ecdsa";
import {kernelFixture} from "./utils/fixture";
import type { KernelFixture } from "./utils/fixture";
import {faucet} from "./utils/faucet";

describe("PasskeysValidator", function () {
  const { provider } = ethers;
  let owner: any;
  
  let getInitCode: KernelFixture["getInitCode"];
  let createKernel: KernelFixture["createKernel"];
  let depositEntryPoint: KernelFixture["depositEntryPoint"];
  let fillUserOp: KernelFixture["fillUserOp"];
  let sendUserOp: KernelFixture["sendUserOp"];
  let getKernelAddress: KernelFixture["getKernelAddress"];
  let verifyTypedDataSignature: KernelFixture["verifyTypedDataSignature"];

  before (async function () {
    owner = (await ethers.getSigners())[0];

    ({ 
      getInitCode, 
      createKernel, 
      depositEntryPoint, 
      fillUserOp, 
      sendUserOp, 
      getKernelAddress, 
      verifyTypedDataSignature 
    } = await kernelFixture());
  })
  
  it("Should pass passkeys", async function () {
    const { privateKey, publicKey } = getECDSAKey();
    const origin = "http://localhost:3000";
    const authDataStr = "SZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2MFAAAAAA".replace(/-/g, '+').replace(/_/g, '/');
    const authData = '0x' + Buffer.from(authDataStr, 'base64').toString('hex')

    await createKernel(
      owner,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    )
    const sender = await getKernelAddress(
      owner,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    );
    await depositEntryPoint(sender);
    await faucet(sender, provider);
  
    const {op, opHash} = await fillUserOp(
      sender,
    )
    const sigByOwner = await owner.signMessage(utils.arrayify(opHash as any));
    const signByPasskeys = signECDSA(privateKey, opHash, origin, authDataStr);
    op.signature = utils.hexConcat([
      sigByOwner,
      signByPasskeys
    ])
    await sendUserOp([op]);
  });

  it("Should pass creating account with initCode", async function () {
    const { privateKey, publicKey } = getECDSAKey();
    const origin = "http://localhost:3000";
    const authDataStr = "SZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2MFAAAAAA".replace(/-/g, '+').replace(/_/g, '/');
    const authData = '0x' + Buffer.from(authDataStr, 'base64').toString('hex')

    const sender = await getKernelAddress(
      owner,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    );
    await depositEntryPoint(sender);

    const initCode = getInitCode(
      owner.address,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    );
    const {op, opHash} = await fillUserOp(
      sender,
      // ethers.utils.concat([
      //   ethers.utils.arrayify("0xd5416221"),
      //   ethers.utils.arrayify("0xffffffff"),
      // ]),
      initCode
    )
    const sigByOwner = await owner.signMessage(utils.arrayify(opHash as any));
    const signByPasskeys = signECDSA(privateKey, opHash, origin, authDataStr);
    op.signature = utils.hexConcat([
      sigByOwner,
      signByPasskeys
    ])
    await sendUserOp([op]);
  })

  it("Should pass sign typed hash data", async function () {
    const { privateKey, publicKey } = getECDSAKey();
    const origin = "http://localhost:3000";
    const authDataStr = "SZYN5YgOjGh0NBcPZHZgW4_krrmihjLHmVzzuoMdl2MFAAAAAA".replace(/-/g, '+').replace(/_/g, '/');
    const authData = '0x' + Buffer.from(authDataStr, 'base64').toString('hex')

    await createKernel(
      owner,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    )
    const kernel = await getKernelAddress(
      owner,
      publicKey[0],
      publicKey[1],
      origin,
      authData
    );
    await depositEntryPoint(kernel);

    const domain = {
      "name": "Seaport",
      "version": "1.5",
      "chainId": "80001",
      "verifyingContract": "0x00000000000000ADc04C56Bf30aC9d3c0aAF14dC"
    }
    const types = {
      "OrderComponents": [
          {
              "name": "offerer",
              "type": "address"
          },
          {
              "name": "zone",
              "type": "address"
          },
          {
              "name": "offer",
              "type": "OfferItem[]"
          },
          {
              "name": "consideration",
              "type": "ConsiderationItem[]"
          },
          {
              "name": "orderType",
              "type": "uint8"
          },
          {
              "name": "startTime",
              "type": "uint256"
          },
          {
              "name": "endTime",
              "type": "uint256"
          },
          {
              "name": "zoneHash",
              "type": "bytes32"
          },
          {
              "name": "salt",
              "type": "uint256"
          },
          {
              "name": "conduitKey",
              "type": "bytes32"
          },
          {
              "name": "counter",
              "type": "uint256"
          }
      ],
      "OfferItem": [
          {
              "name": "itemType",
              "type": "uint8"
          },
          {
              "name": "token",
              "type": "address"
          },
          {
              "name": "identifierOrCriteria",
              "type": "uint256"
          },
          {
              "name": "startAmount",
              "type": "uint256"
          },
          {
              "name": "endAmount",
              "type": "uint256"
          }
      ],
      "ConsiderationItem": [
          {
              "name": "itemType",
              "type": "uint8"
          },
          {
              "name": "token",
              "type": "address"
          },
          {
              "name": "identifierOrCriteria",
              "type": "uint256"
          },
          {
              "name": "startAmount",
              "type": "uint256"
          },
          {
              "name": "endAmount",
              "type": "uint256"
          },
          {
              "name": "recipient",
              "type": "address"
          }
      ]
    };
    const value = {
      "offerer": "0x6892C2A7e4213C9C52352405f0d0349e91F4365c",
      "offer": [
          {
              "itemType": "2",
              "token": "0x34bE7f35132E97915633BC1fc020364EA5134863",
              "identifierOrCriteria": "5465",
              "startAmount": "1",
              "endAmount": "1"
          }
      ],
      "consideration": [
          {
              "itemType": "1",
              "token": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa",
              "identifierOrCriteria": "0",
              "startAmount": "9750000000000000000",
              "endAmount": "9750000000000000000",
              "recipient": "0x6892C2A7e4213C9C52352405f0d0349e91F4365c"
          },
          {
              "itemType": "1",
              "token": "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa",
              "identifierOrCriteria": "0",
              "startAmount": "250000000000000000",
              "endAmount": "250000000000000000",
              "recipient": "0x0000a26b00c1F0DF003000390027140000fAa719"
          }
      ],
      "startTime": "1687505434",
      "endTime": "1690097434",
      "orderType": "0",
      "zone": "0x0000000000000000000000000000000000000000",
      "zoneHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "salt": "24446860302761739304752683030156737591518664810215442929802324019812916215244",
      "conduitKey": "0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000",
      "totalOriginalConsiderationItems": "2",
      "counter": "0"
    }
    const sigTypeDataOwner = await owner._signTypedData(domain, types, value);
    const typeDataHash = utils._TypedDataEncoder.hash(domain, types, value);
    const sigTypeDataPasskeys =  signTypedHashECDSA(privateKey, typeDataHash, origin, authDataStr)
    const sigTypeDataAgg = utils.hexConcat([
      sigTypeDataOwner,
      sigTypeDataPasskeys
    ])
    console.log("recoveredAddress:", utils.recoverAddress(typeDataHash, sigTypeDataOwner));
    console.log("address:", owner.address);
    await verifyTypedDataSignature(kernel, typeDataHash, sigTypeDataAgg)
  })
});