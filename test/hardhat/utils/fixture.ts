import { ethers } from "hardhat";
import {utils, Contract} from "ethers";

export const kernelFixture = async () => {
  const beneficiary = (await ethers.getSigners())[0];

  const EllipticCurve = await ethers.getContractFactory("Secp256r1");
  const EntryPointFactory = await ethers.getContractFactory("EntryPoint");
  const KernelFacFactory = await ethers.getContractFactory("KernelFactoryPasskeys");
  const SampleNFTFactory = await ethers.getContractFactory("SampleNFT");

  const entryPoint = await EntryPointFactory.deploy();
  const ellipticCurve = await EllipticCurve.deploy();
  const factory = await KernelFacFactory.deploy(entryPoint.address);
  const sampleNFT = await SampleNFTFactory.deploy();

  let kernel = '';

  const createKernel = async (
    owner: any, 
    passkeysPubX: string, 
    passkeysPubY: string,
    origin: string,
    authData: string
  ) => {
    const _data = ethers.utils.concat([
        ethers.utils.arrayify(owner.address),
        ethers.utils.arrayify(passkeysPubX),
        ethers.utils.arrayify(passkeysPubY),
        Buffer.from([origin.length]),
        Buffer.from(origin),
        Buffer.from([ethers.utils.arrayify(authData).length]),
        ethers.utils.arrayify(authData)
    ]);
    const createTx = await factory.connect(owner).createAccount(
      owner.address,
      passkeysPubX,
      passkeysPubY,
      origin,
      ethers.utils.arrayify(authData),
      0
    );
    const res = await createTx.wait();
    console.log(res.events);
    const event = res.events?.find((e: any) => e.eventSignature === "AccountCreated(address,address,bytes,uint256)");
    if (event?.topics?.[1]) {
      kernel = '0x' + event?.topics[1]?.slice(26,)
    }
  }

  const getInitCode = (
    owner: string,
    passkeysPubX: string,
    passkeysPubY: string,
    origin: string,
    authData: string,
  ) => {
    const abiCoder = utils.defaultAbiCoder;
    const createAccountData = ethers.utils.concat([
      ethers.utils.arrayify(owner),
      ethers.utils.arrayify(passkeysPubX),
      ethers.utils.arrayify(passkeysPubY),
      Buffer.from([origin.length]),
      Buffer.from(origin),
      Buffer.from([ethers.utils.arrayify(authData).length]),
      ethers.utils.arrayify(authData)
    ]);

    return utils.solidityPack(
      ['address', 'bytes'],
      [
        factory.address,
        '0x47e46e13' +
          abiCoder
            .encode(
              ['address', 'uint256', 'uint256', 'string', 'bytes', 'uint256'],
              [
                owner,
                passkeysPubX,
                passkeysPubY,
                origin,
                utils.arrayify(authData),
                0
              ]
            )
            .slice(2),
      ]
    );
  }

  const fillUserOp = async (sender: string, initCode?: string) => {
    const abiCoder = utils.defaultAbiCoder;
    const nonce = (await entryPoint.getNonce(sender, 0)).toString();
    const op = {
      initCode: initCode ?? '0x',
      sender,
      nonce,
      callData: '0x940d3c60' +
      abiCoder
        .encode(
          ['address', 'uint256', 'bytes', 'uint8'],
          [
            sampleNFT.address,
            0,
            '0x6a627842' +
              abiCoder.encode(['address'], [sender]).slice(2),
            0,
          ]
        )
        .slice(2),
      callGasLimit: 10000000,
      verificationGasLimit: 10000000,
      preVerificationGas: 50000,
      maxFeePerGas: 50000,
      maxPriorityFeePerGas: 1000,
      signature: '0x',
      paymasterAndData: '0x',
    };
    const opHash = await entryPoint.getUserOpHash(op);
    return { op, opHash };
  }

  const sendUserOp = async (ops: any) => {
    const sendRes = await entryPoint.connect(beneficiary).handleOps(ops, beneficiary.address);
    await sendRes.wait();
  }

  const depositEntryPoint = async (staker: any) => {
    await entryPoint.connect(beneficiary).depositTo(staker, { value: "1000000000000000000" });
  }

  const getKernelAddress = async (
    owner: any, 
    passkeysPubX: string, 
    passkeysPubY: string,
    origin: string,
    authData: string
  ) => {
    const _data = ethers.utils.concat([
      ethers.utils.arrayify(owner.address),
      ethers.utils.arrayify(passkeysPubX),
      ethers.utils.arrayify(passkeysPubY),
      Buffer.from([origin.length]),
      Buffer.from(origin),
      Buffer.from([ethers.utils.arrayify(authData).length]),
      ethers.utils.arrayify(authData)
    ]);
    const account = await factory.connect(owner).getAccountAddress(
      owner.address,
      passkeysPubX,
      passkeysPubY,
      origin,
      ethers.utils.arrayify(authData),
      0
    );
    return account;
  }

  return {
    getInitCode,
    createKernel,
    depositEntryPoint,
    fillUserOp,
    sendUserOp,
    getKernelAddress
  }

}

export type KernelFixture = Awaited<ReturnType<typeof kernelFixture>>;