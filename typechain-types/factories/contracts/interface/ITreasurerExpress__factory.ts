/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ITreasurerExpress,
  ITreasurerExpressInterface,
} from "../../../contracts/interface/ITreasurerExpress";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256[]",
        name: "_weeksToClaim",
        type: "uint256[]",
      },
    ],
    name: "claimReward",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256[]",
        name: "_weeksToClaim",
        type: "uint256[]",
      },
    ],
    name: "claimRewardExpress",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_user",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_amount",
        type: "uint256",
      },
    ],
    name: "rewardUser",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class ITreasurerExpress__factory {
  static readonly abi = _abi;
  static createInterface(): ITreasurerExpressInterface {
    return new utils.Interface(_abi) as ITreasurerExpressInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ITreasurerExpress {
    return new Contract(address, _abi, signerOrProvider) as ITreasurerExpress;
  }
}
