// import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { constants, utils } from "ethers";
import { ethers, network } from "hardhat";
import {getECDSAKey, signECDSA} from "./utils/ecdsa";
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

  before (async function () {
    owner = (await ethers.getSigners())[0];

    ({ getInitCode, createKernel, depositEntryPoint, fillUserOp, sendUserOp, getKernelAddress } = await kernelFixture());
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
});