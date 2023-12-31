/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IZKHarvestCallee,
  IZKHarvestCalleeInterface,
} from "../../../contracts/interface/IZKHarvestCallee";

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "sender",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "amount0",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "amount1",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "zkharvestCall",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IZKHarvestCallee__factory {
  static readonly abi = _abi;
  static createInterface(): IZKHarvestCalleeInterface {
    return new utils.Interface(_abi) as IZKHarvestCalleeInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IZKHarvestCallee {
    return new Contract(address, _abi, signerOrProvider) as IZKHarvestCallee;
  }
}
