// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../interface/IZKHToken.sol";

// ZKHToken with Governance.
contract ZKHToken is IZKHToken, ERC20Upgradeable, OwnableUpgradeable {
    using SafeMath for uint256;
    
    mapping (address => bool) private _isRExcludedFromFee; // excluded list from receive 
    mapping (address => bool) private _isSExcludedFromFee; // excluded list from send
    mapping (address => bool) private _isPair;
    
    uint256 public Tax = 0;
    
    uint256 public _maxTxAmount = 100 * 10**6 * 1e18;
    uint256 public constant _maxSupply = 100 * 10**6 * 1e18;
    
    address public dev1;
    address public dev2;
    address public feeAddress;
    
    event NewDeveloper(address);
    event ExcludeFromFeeR(address);	
    event ExcludeFromFeeS(address);	
    event IncludeInFeeR(address);
    event IncludeInFeeS(address);
    event SetPair(address,bool);
    event TaxUpdated(uint256,uint256);
    event FeeAddressUpdated(address);
    event Burn(uint256);
    
    modifier onlyDev() {
        require(msg.sender == dev1 || msg.sender == dev2 , "Error: Developer Required!");
        _;
    }

    function initialize(
        address _dev2, 
        address _feeAddress, 
        uint256 _initialMint
    ) public initializer {
        __ERC20_init('zkHarvest', 'ZKH');
        __Ownable_init();

        require(_dev2 != address(0), 'ZKH: dev cannot be the zero address');
     	require(_feeAddress != address(0), 'ZKH: feeAddress cannot be the zero address');
     	dev1 = msg.sender;
     	mint(msg.sender, _initialMint);
        dev2 = _dev2;
        feeAddress = _feeAddress;
        _isRExcludedFromFee[dev1] = true;
        _isSExcludedFromFee[dev1] = true;
        _isRExcludedFromFee[dev2] = true;
        _isSExcludedFromFee[dev2] = true;
        _isRExcludedFromFee[feeAddress] = true;
        _isSExcludedFromFee[feeAddress] = true;
    }
    
    /// @notice Creates `_amount` token to `_to`. Must only be called by the owner (zkhMaster).
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        require(_maxSupply >= totalSupply().add(_amount) , "Error : Total Supply Reached" );
        _mint(_to, _amount);
        _moveDelegates(address(0), _delegates[_to], _amount);
        return true;
    }
    
    function mint(uint256 amount) public onlyOwner returns (bool) {
        require(_maxSupply >= totalSupply().add(amount) , "Error : Total Supply Reached" );
        _mint(_msgSender(), amount);
        _moveDelegates(address(0), _delegates[_msgSender()], amount);
        return true;
    }
    
    // Exclude an account from receive fee
    function excludeFromFeeR(address account) external onlyDev {
        require(!_isRExcludedFromFee[account], "Account is already excluded From receive Fee");
        _isRExcludedFromFee[account] = true;	
        emit ExcludeFromFeeR(account);	
    }
    // Exclude an account from send fee
    function excludeFromFeeS(address account) external onlyDev {
        require(!_isSExcludedFromFee[account], "Account is already excluded From send Fee");
        _isSExcludedFromFee[account] = true;	
        emit ExcludeFromFeeS(account);	
    }
    // Include an account in receive fee	
    function includeInFeeR(address account) external onlyDev {	
         require( _isRExcludedFromFee[account], "Account is not excluded From receive Fee");	
        _isRExcludedFromFee[account] = false;	
        emit IncludeInFeeR(account);	
    }
    // Include an account in send fee
    function includeInFeeS(address account) external onlyDev {	
         require( _isSExcludedFromFee[account], "Account is not excluded From send Fee");	
        _isSExcludedFromFee[account] = false;	
        emit IncludeInFeeS(account);	
    }
    
    function setPair(address _pair, bool _status) external onlyDev {
        require(_pair != address(0), 'ZKH: Pair cannot be the zero address');
        _isPair[_pair] = _status;	
        emit SetPair(_pair , _status);	
    }
    	
    function setTax(uint256 _tax) external onlyDev {	
        require(_tax <= 80 , "Error : MaxTax is 8%");
        uint256 _previousTax = Tax;	
        Tax = _tax;	
        emit TaxUpdated(_previousTax,Tax);	
    }	

    function setFeeAddress(address _feeAddress) external onlyDev {
        require(_feeAddress != address(0), 'ZKH: FeeAddress cannot be the zero address');
        feeAddress = _feeAddress;
        emit FeeAddressUpdated(feeAddress);
    }
   	
    function setMaxTxLimit(uint256 maxTx) external onlyDev {
        require(maxTx >= 10000*1e18 , "Error : Minimum maxTxLimit is 10000 ZKH");
        require(maxTx <= _maxSupply , "Error : Maximum maxTxLimit is 100M ZKH");
        _maxTxAmount = maxTx;
    }
    
    function setDev(address _dev) external onlyDev {
        require(_dev != address(0), 'ZKH: dev cannot be the zero address');

        if(msg.sender == dev1) {dev1 = _dev ;}
        else {dev2 = _dev;}

        _isRExcludedFromFee[_dev] = true;
        _isSExcludedFromFee[_dev] = true;

        emit NewDeveloper(_dev);
    }
    
    function isExcludedFromFee(address account) external view returns(bool Rfee , bool SFee) {	
        return (_isRExcludedFromFee[account] , _isSExcludedFromFee[account] );
    }
    function isPair(address account) external view returns(bool) {	
        return _isPair[account];
    }
    
    //  @notice Destroys `amount` tokens from `account`, reducing the total supply.
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        _moveDelegates(_delegates[msg.sender], address(0), amount);
        emit Burn(amount);
    }
    
    function transferTaxFree(address recipient, uint256 amount) public returns (bool) {
        require(_isPair[_msgSender()] , "ZKH: Only zkHarvest Router or ZKH pair");
        super._transfer(_msgSender(), recipient, amount);
        _moveDelegates(_delegates[msg.sender], _delegates[recipient] , amount);
        return true;
    }
    
    function transferFromTaxFree(address sender, address recipient, uint256 amount) public returns (bool) {
        require(_isPair[_msgSender()] , "ZKH: Only zkHarvest Router or ZKH pair");
        super._transfer(sender, recipient, amount);
        super._approve(
            sender,
            _msgSender(),
            allowance(sender, _msgSender()).sub(amount, 'ERC20: transfer amount exceeds allowance')
        );
        
        _moveDelegates(_delegates[sender], _delegates[recipient] , amount);
        return true;
    }
    
    /// @dev overrides transfer function to meet tokenomics of ZKH
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        
        //if any account belongs to _isExcludedFromFee account then remove the fee	

        if (_isSExcludedFromFee[sender] || _isRExcludedFromFee[recipient]) {
            super._transfer(sender, recipient, amount);
            _moveDelegates(_delegates[sender], _delegates[recipient] , amount);

            return;
        }
        else if (Tax == 0){
            require(amount <= _maxTxAmount , "ZKH Transfer: Transfer amount is above the limit!");
            super._transfer(sender, recipient, amount);
            _moveDelegates(_delegates[sender], _delegates[recipient] , amount);

            return;
        }
        else {
            require(amount <= _maxTxAmount , "ZKH Transfer: Transfer amount is above the limit!");

            // If Tax is turned on, A percentage of every transfer goes to feeVault
            uint256 taxFee = amount.mul(Tax).div(1000);
            
            // Remainder of transfer sent to recipient
            uint256 sendAmount = amount.sub(taxFee);
            require(amount == sendAmount + taxFee , "ZKH Transfer: Fee value invalid");

            super._transfer(sender, feeAddress, taxFee);
            _moveDelegates(_delegates[sender], _delegates[feeAddress] , taxFee);

            super._transfer(sender, recipient, sendAmount);
            _moveDelegates(_delegates[sender], _delegates[recipient] , sendAmount);
        }

        
    }

    function transferOwnership(address newOwner) public override(IZKHToken, OwnableUpgradeable) onlyOwner {
        super.transferOwnership(newOwner);
    }


    // Copied and modified from YAM code:
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernanceStorage.sol
    // https://github.com/yam-finance/yam-protocol/blob/master/contracts/token/YAMGovernance.sol
    // Which is copied and modified from COMPOUND:
    // https://github.com/compound-finance/compound-protocol/blob/master/contracts/Governance/Comp.sol

    /// @dev A record of each accounts delegate
    mapping (address => address) internal _delegates;

    /// @notice A checkpoint for marking number of votes from a given block
    struct Checkpoint {
        uint32 fromBlock;
        uint256 votes;
    }

    /// @notice A record of votes checkpoints for each account, by index
    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account
    mapping (address => uint32) public numCheckpoints;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract
    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");

    /// @notice A record of states for signing / validating signatures
    mapping (address => uint) public nonces;

      /// @notice An event thats emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event thats emitted when a delegate account's vote balance changes
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegator The address to get delegatee for
     */
    function delegates(address delegator)
        external
        view
        returns (address)
    {
        return _delegates[delegator];
    }

   /**
    * @notice Delegate votes from `msg.sender` to `delegatee`
    * @param delegatee The address to delegate votes to
    */
    function delegate(address delegatee) external {
        return _delegate(msg.sender, delegatee);
    }

    /**
     * @notice Delegates votes from signatory to `delegatee`
     * @param delegatee The address to delegate votes to
     * @param nonce The contract state required to match the signature
     * @param expiry The time at which to expire the signature
     * @param v The recovery byte of the signature
     * @param r Half of the ECDSA signature pair
     * @param s Half of the ECDSA signature pair
     */
    function delegateBySig(
        address delegatee,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name())),
                getChainId(),
                address(this)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATION_TYPEHASH,
                delegatee,
                nonce,
                expiry
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                structHash
            )
        );

        address signatory = ecrecover(digest, v, r, s);
        require(signatory != address(0), "ZKH::delegateBySig: invalid signature");
        require(nonce == nonces[signatory]++, "ZKH::delegateBySig: invalid nonce");
        require(block.timestamp <= expiry, "ZKH::delegateBySig: signature expired");
        return _delegate(signatory, delegatee);
    }

    /**
     * @notice Gets the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account)
        external
        view
        returns (uint256)
    {
        uint32 nCheckpoints = numCheckpoints[account];
        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;
    }

    /**
     * @notice Determine the prior number of votes for an account as of a block number
     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.
     * @param account The address of the account to check
     * @param blockNumber The block number to get the vote balance at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber)
        external
        view
        returns (uint256)
    {
        require(blockNumber < block.number, "ZKH::getPriorVotes: not yet determined");

        uint32 nCheckpoints = numCheckpoints[account];
        if (nCheckpoints == 0) {
            return 0;
        }

        // First check most recent balance
        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {
            return checkpoints[account][nCheckpoints - 1].votes;
        }

        // Next check implicit zero balance
        if (checkpoints[account][0].fromBlock > blockNumber) {
            return 0;
        }

        uint32 lower = 0;
        uint32 upper = nCheckpoints - 1;
        while (upper > lower) {
            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow
            Checkpoint memory cp = checkpoints[account][center];
            if (cp.fromBlock == blockNumber) {
                return cp.votes;
            } else if (cp.fromBlock < blockNumber) {
                lower = center;
            } else {
                upper = center - 1;
            }
        }
        return checkpoints[account][lower].votes;
    }

    function _delegate(address delegator, address delegatee)
        internal
    {
        address currentDelegate = _delegates[delegator];
        uint256 delegatorBalance = balanceOf(delegator); // balance of underlying ZKHs (not scaled);
        _delegates[delegator] = delegatee;

        emit DelegateChanged(delegator, currentDelegate, delegatee);

        _moveDelegates(currentDelegate, delegatee, delegatorBalance);
    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
        if (srcRep != dstRep && amount > 0) {
            if (srcRep != address(0)) {
                // decrease old representative
                uint32 srcRepNum = numCheckpoints[srcRep];
                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
                uint256 srcRepNew = srcRepOld.sub(amount);
                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
            }

            if (dstRep != address(0)) {
                // increase new representative
                uint32 dstRepNum = numCheckpoints[dstRep];
                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
                uint256 dstRepNew = dstRepOld.add(amount);
                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
            }
        }
    }

    function _writeCheckpoint(
        address delegatee,
        uint32 nCheckpoints,
        uint256 oldVotes,
        uint256 newVotes
    )
        internal
    {
        uint32 blockNumber = safe32(block.number, "ZKH::_writeCheckpoint: block number exceeds 32 bits");

        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {
            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;
        } else {
            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);
            numCheckpoints[delegatee] = nCheckpoints + 1;
        }

        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);
    }

    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function getChainId() internal view returns (uint) {
        uint256 chainId;
        assembly { chainId := chainid() }
        return chainId;
    }
}