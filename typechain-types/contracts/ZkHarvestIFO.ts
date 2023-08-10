/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PayableOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../common";

export interface ZkHarvestIFOInterface extends utils.Interface {
  functions: {
    "amountToRaise()": FunctionFragment;
    "burnUnsoldTokens()": FunctionFragment;
    "claim()": FunctionFragment;
    "claimRewards()": FunctionFragment;
    "claimableRewards(address)": FunctionFragment;
    "claimableTokens(address)": FunctionFragment;
    "close()": FunctionFragment;
    "commit()": FunctionFragment;
    "commitWithReferral(address)": FunctionFragment;
    "committedAmountPerWallet(address)": FunctionFragment;
    "configure(uint256,uint256,uint256,uint256,uint256,uint256)": FunctionFragment;
    "hasClaimedReferralRewards(address)": FunctionFragment;
    "hasFinalized(address)": FunctionFragment;
    "maxAmountPerWallet()": FunctionFragment;
    "minAmountPerWallet()": FunctionFragment;
    "minAmountToRaise()": FunctionFragment;
    "open()": FunctionFragment;
    "owner()": FunctionFragment;
    "raisedAmount()": FunctionFragment;
    "referralRewardBP()": FunctionFragment;
    "referralRewards(address)": FunctionFragment;
    "refund()": FunctionFragment;
    "refundableAmount(address)": FunctionFragment;
    "renounceOwnership()": FunctionFragment;
    "setTeam(address)": FunctionFragment;
    "state()": FunctionFragment;
    "supply()": FunctionFragment;
    "team()": FunctionFragment;
    "token()": FunctionFragment;
    "totalReferralRewards()": FunctionFragment;
    "transferOwnership(address)": FunctionFragment;
    "withdraw()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "amountToRaise"
      | "burnUnsoldTokens"
      | "claim"
      | "claimRewards"
      | "claimableRewards"
      | "claimableTokens"
      | "close"
      | "commit"
      | "commitWithReferral"
      | "committedAmountPerWallet"
      | "configure"
      | "hasClaimedReferralRewards"
      | "hasFinalized"
      | "maxAmountPerWallet"
      | "minAmountPerWallet"
      | "minAmountToRaise"
      | "open"
      | "owner"
      | "raisedAmount"
      | "referralRewardBP"
      | "referralRewards"
      | "refund"
      | "refundableAmount"
      | "renounceOwnership"
      | "setTeam"
      | "state"
      | "supply"
      | "team"
      | "token"
      | "totalReferralRewards"
      | "transferOwnership"
      | "withdraw"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "amountToRaise",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "burnUnsoldTokens",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "claim", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "claimRewards",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "claimableRewards",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "claimableTokens",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(functionFragment: "close", values?: undefined): string;
  encodeFunctionData(functionFragment: "commit", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "commitWithReferral",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "committedAmountPerWallet",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "configure",
    values: [
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "hasClaimedReferralRewards",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasFinalized",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "maxAmountPerWallet",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "minAmountPerWallet",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "minAmountToRaise",
    values?: undefined
  ): string;
  encodeFunctionData(functionFragment: "open", values?: undefined): string;
  encodeFunctionData(functionFragment: "owner", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "raisedAmount",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "referralRewardBP",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "referralRewards",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(functionFragment: "refund", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "refundableAmount",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(
    functionFragment: "renounceOwnership",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "setTeam",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(functionFragment: "state", values?: undefined): string;
  encodeFunctionData(functionFragment: "supply", values?: undefined): string;
  encodeFunctionData(functionFragment: "team", values?: undefined): string;
  encodeFunctionData(functionFragment: "token", values?: undefined): string;
  encodeFunctionData(
    functionFragment: "totalReferralRewards",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "transferOwnership",
    values: [PromiseOrValue<string>]
  ): string;
  encodeFunctionData(functionFragment: "withdraw", values?: undefined): string;

  decodeFunctionResult(
    functionFragment: "amountToRaise",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "burnUnsoldTokens",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "claim", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "claimRewards",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "claimableRewards",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "claimableTokens",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "close", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "commit", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "commitWithReferral",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "committedAmountPerWallet",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "configure", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "hasClaimedReferralRewards",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "hasFinalized",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "maxAmountPerWallet",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "minAmountPerWallet",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "minAmountToRaise",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "open", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "owner", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "raisedAmount",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "referralRewardBP",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "referralRewards",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "refund", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "refundableAmount",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "renounceOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "setTeam", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "state", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "supply", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "team", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "token", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "totalReferralRewards",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "transferOwnership",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;

  events: {
    "Claim(address,uint256)": EventFragment;
    "Commit(address,uint256,address)": EventFragment;
    "OwnershipTransferred(address,address)": EventFragment;
    "Refund(address,uint256)": EventFragment;
    "RewardsClaim(address,uint256)": EventFragment;
    "StateChange(uint8)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Claim"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Commit"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "OwnershipTransferred"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Refund"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "RewardsClaim"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "StateChange"): EventFragment;
}

export interface ClaimEventObject {
  account: string;
  amount: BigNumber;
}
export type ClaimEvent = TypedEvent<[string, BigNumber], ClaimEventObject>;

export type ClaimEventFilter = TypedEventFilter<ClaimEvent>;

export interface CommitEventObject {
  account: string;
  amount: BigNumber;
  referral: string;
}
export type CommitEvent = TypedEvent<
  [string, BigNumber, string],
  CommitEventObject
>;

export type CommitEventFilter = TypedEventFilter<CommitEvent>;

export interface OwnershipTransferredEventObject {
  previousOwner: string;
  newOwner: string;
}
export type OwnershipTransferredEvent = TypedEvent<
  [string, string],
  OwnershipTransferredEventObject
>;

export type OwnershipTransferredEventFilter =
  TypedEventFilter<OwnershipTransferredEvent>;

export interface RefundEventObject {
  account: string;
  amount: BigNumber;
}
export type RefundEvent = TypedEvent<[string, BigNumber], RefundEventObject>;

export type RefundEventFilter = TypedEventFilter<RefundEvent>;

export interface RewardsClaimEventObject {
  account: string;
  amount: BigNumber;
}
export type RewardsClaimEvent = TypedEvent<
  [string, BigNumber],
  RewardsClaimEventObject
>;

export type RewardsClaimEventFilter = TypedEventFilter<RewardsClaimEvent>;

export interface StateChangeEventObject {
  newState: number;
}
export type StateChangeEvent = TypedEvent<[number], StateChangeEventObject>;

export type StateChangeEventFilter = TypedEventFilter<StateChangeEvent>;

export interface ZkHarvestIFO extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: ZkHarvestIFOInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    amountToRaise(overrides?: CallOverrides): Promise<[BigNumber]>;

    burnUnsoldTokens(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    claim(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    claimRewards(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    claimableRewards(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    claimableTokens(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    close(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    commit(
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    commitWithReferral(
      _referral: PromiseOrValue<string>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    committedAmountPerWallet(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    configure(
      _supply: PromiseOrValue<BigNumberish>,
      _amountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountPerWallet: PromiseOrValue<BigNumberish>,
      _maxAmountPerWallet: PromiseOrValue<BigNumberish>,
      _referralRewardBP: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    hasClaimedReferralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    hasFinalized(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    maxAmountPerWallet(overrides?: CallOverrides): Promise<[BigNumber]>;

    minAmountPerWallet(overrides?: CallOverrides): Promise<[BigNumber]>;

    minAmountToRaise(overrides?: CallOverrides): Promise<[BigNumber]>;

    open(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    owner(overrides?: CallOverrides): Promise<[string]>;

    raisedAmount(overrides?: CallOverrides): Promise<[BigNumber]>;

    referralRewardBP(overrides?: CallOverrides): Promise<[BigNumber]>;

    referralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    refund(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    refundableAmount(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    renounceOwnership(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    setTeam(
      _team: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    state(overrides?: CallOverrides): Promise<[number]>;

    supply(overrides?: CallOverrides): Promise<[BigNumber]>;

    team(overrides?: CallOverrides): Promise<[string]>;

    token(overrides?: CallOverrides): Promise<[string]>;

    totalReferralRewards(overrides?: CallOverrides): Promise<[BigNumber]>;

    transferOwnership(
      newOwner: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    withdraw(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;
  };

  amountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

  burnUnsoldTokens(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  claim(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  claimRewards(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  claimableRewards(
    _account: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  claimableTokens(
    _account: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  close(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  commit(
    overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  commitWithReferral(
    _referral: PromiseOrValue<string>,
    overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  committedAmountPerWallet(
    arg0: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  configure(
    _supply: PromiseOrValue<BigNumberish>,
    _amountToRaise: PromiseOrValue<BigNumberish>,
    _minAmountToRaise: PromiseOrValue<BigNumberish>,
    _minAmountPerWallet: PromiseOrValue<BigNumberish>,
    _maxAmountPerWallet: PromiseOrValue<BigNumberish>,
    _referralRewardBP: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  hasClaimedReferralRewards(
    arg0: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  hasFinalized(
    arg0: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  maxAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

  minAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

  minAmountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

  open(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  owner(overrides?: CallOverrides): Promise<string>;

  raisedAmount(overrides?: CallOverrides): Promise<BigNumber>;

  referralRewardBP(overrides?: CallOverrides): Promise<BigNumber>;

  referralRewards(
    arg0: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  refund(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  refundableAmount(
    _account: PromiseOrValue<string>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  renounceOwnership(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  setTeam(
    _team: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  state(overrides?: CallOverrides): Promise<number>;

  supply(overrides?: CallOverrides): Promise<BigNumber>;

  team(overrides?: CallOverrides): Promise<string>;

  token(overrides?: CallOverrides): Promise<string>;

  totalReferralRewards(overrides?: CallOverrides): Promise<BigNumber>;

  transferOwnership(
    newOwner: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  withdraw(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    amountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

    burnUnsoldTokens(overrides?: CallOverrides): Promise<void>;

    claim(overrides?: CallOverrides): Promise<void>;

    claimRewards(overrides?: CallOverrides): Promise<void>;

    claimableRewards(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    claimableTokens(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    close(overrides?: CallOverrides): Promise<void>;

    commit(overrides?: CallOverrides): Promise<void>;

    commitWithReferral(
      _referral: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<void>;

    committedAmountPerWallet(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    configure(
      _supply: PromiseOrValue<BigNumberish>,
      _amountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountPerWallet: PromiseOrValue<BigNumberish>,
      _maxAmountPerWallet: PromiseOrValue<BigNumberish>,
      _referralRewardBP: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<void>;

    hasClaimedReferralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    hasFinalized(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    maxAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

    minAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

    minAmountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

    open(overrides?: CallOverrides): Promise<void>;

    owner(overrides?: CallOverrides): Promise<string>;

    raisedAmount(overrides?: CallOverrides): Promise<BigNumber>;

    referralRewardBP(overrides?: CallOverrides): Promise<BigNumber>;

    referralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    refund(overrides?: CallOverrides): Promise<void>;

    refundableAmount(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    renounceOwnership(overrides?: CallOverrides): Promise<void>;

    setTeam(
      _team: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<void>;

    state(overrides?: CallOverrides): Promise<number>;

    supply(overrides?: CallOverrides): Promise<BigNumber>;

    team(overrides?: CallOverrides): Promise<string>;

    token(overrides?: CallOverrides): Promise<string>;

    totalReferralRewards(overrides?: CallOverrides): Promise<BigNumber>;

    transferOwnership(
      newOwner: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<void>;

    withdraw(overrides?: CallOverrides): Promise<void>;
  };

  filters: {
    "Claim(address,uint256)"(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): ClaimEventFilter;
    Claim(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): ClaimEventFilter;

    "Commit(address,uint256,address)"(
      account?: PromiseOrValue<string> | null,
      amount?: null,
      referral?: null
    ): CommitEventFilter;
    Commit(
      account?: PromiseOrValue<string> | null,
      amount?: null,
      referral?: null
    ): CommitEventFilter;

    "OwnershipTransferred(address,address)"(
      previousOwner?: PromiseOrValue<string> | null,
      newOwner?: PromiseOrValue<string> | null
    ): OwnershipTransferredEventFilter;
    OwnershipTransferred(
      previousOwner?: PromiseOrValue<string> | null,
      newOwner?: PromiseOrValue<string> | null
    ): OwnershipTransferredEventFilter;

    "Refund(address,uint256)"(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): RefundEventFilter;
    Refund(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): RefundEventFilter;

    "RewardsClaim(address,uint256)"(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): RewardsClaimEventFilter;
    RewardsClaim(
      account?: PromiseOrValue<string> | null,
      amount?: null
    ): RewardsClaimEventFilter;

    "StateChange(uint8)"(newState?: null): StateChangeEventFilter;
    StateChange(newState?: null): StateChangeEventFilter;
  };

  estimateGas: {
    amountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

    burnUnsoldTokens(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    claim(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    claimRewards(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    claimableRewards(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    claimableTokens(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    close(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    commit(
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    commitWithReferral(
      _referral: PromiseOrValue<string>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    committedAmountPerWallet(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    configure(
      _supply: PromiseOrValue<BigNumberish>,
      _amountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountPerWallet: PromiseOrValue<BigNumberish>,
      _maxAmountPerWallet: PromiseOrValue<BigNumberish>,
      _referralRewardBP: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    hasClaimedReferralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasFinalized(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    maxAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

    minAmountPerWallet(overrides?: CallOverrides): Promise<BigNumber>;

    minAmountToRaise(overrides?: CallOverrides): Promise<BigNumber>;

    open(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    owner(overrides?: CallOverrides): Promise<BigNumber>;

    raisedAmount(overrides?: CallOverrides): Promise<BigNumber>;

    referralRewardBP(overrides?: CallOverrides): Promise<BigNumber>;

    referralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    refund(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    refundableAmount(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    renounceOwnership(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    setTeam(
      _team: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    state(overrides?: CallOverrides): Promise<BigNumber>;

    supply(overrides?: CallOverrides): Promise<BigNumber>;

    team(overrides?: CallOverrides): Promise<BigNumber>;

    token(overrides?: CallOverrides): Promise<BigNumber>;

    totalReferralRewards(overrides?: CallOverrides): Promise<BigNumber>;

    transferOwnership(
      newOwner: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    withdraw(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    amountToRaise(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    burnUnsoldTokens(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    claim(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    claimRewards(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    claimableRewards(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    claimableTokens(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    close(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    commit(
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    commitWithReferral(
      _referral: PromiseOrValue<string>,
      overrides?: PayableOverrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    committedAmountPerWallet(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    configure(
      _supply: PromiseOrValue<BigNumberish>,
      _amountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountToRaise: PromiseOrValue<BigNumberish>,
      _minAmountPerWallet: PromiseOrValue<BigNumberish>,
      _maxAmountPerWallet: PromiseOrValue<BigNumberish>,
      _referralRewardBP: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    hasClaimedReferralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasFinalized(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    maxAmountPerWallet(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    minAmountPerWallet(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    minAmountToRaise(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    open(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    owner(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    raisedAmount(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    referralRewardBP(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    referralRewards(
      arg0: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    refund(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    refundableAmount(
      _account: PromiseOrValue<string>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    renounceOwnership(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    setTeam(
      _team: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    state(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    supply(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    team(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    token(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    totalReferralRewards(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    transferOwnership(
      newOwner: PromiseOrValue<string>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    withdraw(
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;
  };
}