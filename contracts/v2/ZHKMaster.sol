
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

// website: https://zkharvest.io

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "../interface/ITreasurer.sol";
import "../interface/IZKHToken.sol";


contract ZKHMaster is Ownable, IERC721Receiver  {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 baseAmount; // amount without nft boost
        uint256 rewardDebt; // Reward debt. See explanation below.
		uint256 depositTime;
        uint256[5] nftIDs;
        uint256 nftcount;
        uint256 lockedReward; // Locked reward until next unlock time.
        //
        // We do some fancy math here. Basically, any point in time, the amount of Reward Token
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accZkhPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accZkhPerShare` (and `lastRewardTimestamp`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. Reward to distribute per second.
        uint256 depositFee; // LP Deposit fee.
        uint256 withdrawalFee; // LP Withdrawal fee
        uint256 lastRewardTimestamp; // Last Timestamp that Reward distribution occurs.
        uint256 accZkhPerShare; // Accumulated Reward per share, times 1e18. See below.
        uint256 lpSupply; // Total Lp tokens Staked in farm.
        uint256 baseLpSupply; // Total Lp Tokens in farm without boost.
        uint256 rewardEndTimestamp; // Reward ending Timestamp.
        uint256 harvestInterval; // Harvest interval for this pool, in seconds
    }

    // struct to input nft boost values
    struct nftDataIn{
        uint256 tokenId;
        uint256 multiplier; // boost value (denominator 10000)
    }

    // Reward TOKEN!
    IZKHToken public rewardToken; 
    // reference to the NFT contract
    IERC721Enumerable public nft;
    // The Treasurer. Handles rewards.
    ITreasurer public immutable treasurer;
    // NFT can be set status
    bool public canSetNFT;
    // Dev address.
    address public devaddr;
    //Deposit fee collecting Address.
    address public feeAddress;
    // reward tokens distributed per Second.
    uint256 public rewardPerSecond ;
    // Bonus muliplier for early Reward makers.
    uint256 public BONUS_MULTIPLIER = 1;  
    //Max uint256
    uint256 constant MAX_INT = type(uint256).max ;
    // Seconds per burn cycle.
    uint256 public SECONDS_PER_CYCLE =  170 days ; 
    // Max ZKH Supply.
    uint256 public constant MAX_SUPPLY = 100 * 10**6 * 1e18;
    // Next minting cycle start timestamp.
    uint256 public nextCycleTimestamp;

    bool public setMasterEnabled;
  

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // nft bonus data
    mapping(uint256 => uint256) public nftBonus; 
    // nft owner data
    mapping(uint256 => address) public nftOwners; 
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The timestamp when Reward mining starts.
    uint256 public startTimestamp;
    

    event feeAddressUpdated(address);
    event UpdateEmissionRate(uint256 rewardPerSec);
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event NFTStaked(address owner, uint256 tokenId, uint256 value);
    event NFTUnstaked(address owner, uint256 tokenId, uint256 value);
    event Claimed(address owner, uint256 amount);
    
    event addPool(
        uint256 indexed pid, 
        address lpToken, 
        uint256 allocPoint,
        uint256 depositFee, 
        uint256 withdrawalFee, 
        uint256 rewardEndTimestamp,
        uint256 harvestInterval);
    
    event setPool(
        uint256 indexed pid, 
        uint256 allocPoint,
        uint256 depositFee, 
        uint256 withdrawalFee,
        uint256 rewardEndTimestamp,
        uint256 harvestInterval);
        
    event UpdateStartTimestamp(uint256 newStartTimestamp);
    
    modifier onlyDev() {
        require(msg.sender == owner() || msg.sender == devaddr , "Error: Require developer or Owner");
        _;
    }

    constructor(
        IZKHToken _rewardToken,
        address _devaddr,
        address _feeAddress,
        ITreasurer _treasurer,
        uint256 _startTimestamp
    ) {
        require(_rewardToken != IERC20(address(0)), 'ZKH: Reward Token cannot be the zero address');
        require(_devaddr != address(0), 'ZKH: dev cannot be the zero address');
        require(_feeAddress != address(0), 'ZKH: FeeAddress cannot be the zero address');
        require(address(_treasurer) != address(0), 'ZKH: Treasurer cannot be the zero address');
        require(_startTimestamp >= block.timestamp , 'ZKH: Invalid Start time');
        
        rewardToken = _rewardToken;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        treasurer = _treasurer;
        startTimestamp = _startTimestamp;
        rewardPerSecond = (MAX_SUPPLY.sub(rewardToken.totalSupply())).mul(9).div(10).div(SECONDS_PER_CYCLE);
        nextCycleTimestamp = startTimestamp.add(SECONDS_PER_CYCLE);
        setMasterEnabled = true;
        canSetNFT = true;

        // staking pool
        poolInfo.push(
            PoolInfo({
                lpToken: rewardToken,
                allocPoint: 100,
                depositFee: 0,
                withdrawalFee: 0,
                lastRewardTimestamp: startTimestamp,
                accZkhPerShare: 0,
                lpSupply: 0,
                baseLpSupply: 0,
                rewardEndTimestamp: MAX_INT,
                harvestInterval: 1 hours
                
            })
        );

        totalAllocPoint = 100;

    }
	
    function setFeeAddress(address _feeAddress)public onlyDev returns (bool){
        require(_feeAddress != address(0), 'ZKH: FeeAddress cannot be the zero address');
        feeAddress = _feeAddress;
        emit feeAddressUpdated(_feeAddress);
        return true;
    }
    
    function setNftAddress(IERC721Enumerable _nft) external onlyDev {
        require(address(_nft) != address(0) , "NFT address cannot be the zero address");
        require(canSetNFT , "NFT cannot be changed");
        nft = _nft;
    }

    function setNFTOff() external onlyDev {
        canSetNFT = false;
    }

    function updateEmissionRate(uint256 endTimestamp , bool withUpdate) external  onlyDev{
        require(endTimestamp > ((block.timestamp).add(18 days)), "Minimum duration is 18 days");
        if (withUpdate) { massUpdatePools(); }
        SECONDS_PER_CYCLE = endTimestamp.sub(block.timestamp);
        rewardPerSecond = (MAX_SUPPLY.sub(rewardToken.totalSupply())).mul(9).div(10).div(SECONDS_PER_CYCLE);
        nextCycleTimestamp = endTimestamp;
        
        emit UpdateEmissionRate(rewardPerSecond);
        
    } 
    
    function updateReward() internal {
        rewardPerSecond = (MAX_SUPPLY.sub(rewardToken.totalSupply())).mul(9).div(10).div(SECONDS_PER_CYCLE);
        
        emit UpdateEmissionRate(rewardPerSecond);
    }
    
    function setStartTimestamp(uint256 sTimestamp) public onlyDev{
        require(startTimestamp > block.timestamp, "already started");
        require(sTimestamp > block.timestamp, "Invalid Timestamp");
        massUpdatePools();
        startTimestamp = sTimestamp;
        
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            PoolInfo storage pool = poolInfo[pid];
            pool.lastRewardTimestamp = sTimestamp;
        }
        emit UpdateStartTimestamp(sTimestamp);

    }

    function updateMultiplier(uint256 multiplierNumber) public onlyDev {
        require(multiplierNumber != 0, " multiplierNumber should not be null");
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function emissionPerSec() external view returns (uint256){
        return(rewardPerSecond.mul(10).div(9));
    }

    function setNFTBonusData(nftDataIn[] calldata nftData)external onlyDev{
        uint256 length = nftData.length;
        for (uint i = 0; i < length; i++) {
            nftBonus[nftData[i].tokenId] = nftData[i].multiplier;
        }
    }

    // Add a new lp to the pool. Can only be called by the owner or dev.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(
        uint256 _allocPoint,
        uint256 _depositFee,
        uint256 _withdrawalFee,
        uint256 _harvestInterval,
        IERC20 _lpToken,
        uint256 _rewardEndTimestamp
    ) public onlyDev {
        
        require(_depositFee <= 600 , "ADD : Max Deposit fee is 6%");
        require(_withdrawalFee <= 600 , "ADD : Max Withdrawal fee is 6%");
        require(_rewardEndTimestamp > block.timestamp , "ADD : invalid rewardEndTimestamp");
        require(_harvestInterval <= 5 days , "max harvest interval is 5 days");

        massUpdatePools();

		uint256 lastRewardTimestamp =
            block.timestamp > startTimestamp ? block.timestamp : startTimestamp;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                depositFee: _depositFee,
                withdrawalFee: _withdrawalFee,
                lastRewardTimestamp: lastRewardTimestamp,
                accZkhPerShare: 0,
                lpSupply: 0,
                baseLpSupply: 0,
                rewardEndTimestamp: _rewardEndTimestamp,
                harvestInterval: _harvestInterval
                
            })
        );
        emit addPool(poolInfo.length - 1, address(_lpToken), _allocPoint,  _depositFee, _withdrawalFee, _rewardEndTimestamp, _harvestInterval);

    }

    // Update the given pool's Reward allocation point. Can only be called by the owner or Dev.
    function set(
        uint256 _pid,
        uint256 _allocPoint,
        uint256 _depositFee,
        uint256 _withdrawalFee,
        uint256 _harvestInterval,
        uint256 _rewardEndTimestamp
    ) public onlyDev {
        
        require(_depositFee <= 600 , "SET : Max Deposit fee is 6%");
        require(_withdrawalFee <= 600 , "SET : Max Withdrawal fee is 6%");
        require(_rewardEndTimestamp > block.timestamp , "SET : invalid rewardEndTimestamp");
        require(_harvestInterval <= 5 days , "max harvest interval is 5 days");
        
        massUpdatePools();
		
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFee = _depositFee;
        poolInfo[_pid].withdrawalFee = _withdrawalFee;
        poolInfo[_pid].rewardEndTimestamp = _rewardEndTimestamp;
        poolInfo[_pid].harvestInterval = _harvestInterval;
        emit setPool(_pid , _allocPoint, _depositFee, _withdrawalFee, _rewardEndTimestamp, _harvestInterval);
    
    }

    // Return reward multiplier over the given _from to _to timestamp.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        view
        returns (uint256)
    {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

      // View function to check if user can harvest pool
    function canHarvest(
        uint256 _poolId,
        address _user
        ) public view returns (bool) {
        return block.timestamp >= (userInfo[_poolId][_user].depositTime).add(poolInfo[_poolId].harvestInterval);
    }


    // View function to see pending ZKH on frontend.
    function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accZkhPerShare = pool.accZkhPerShare;
        uint256 lpSupply = pool.lpSupply;
        if (block.timestamp  > pool.lastRewardTimestamp && lpSupply != 0 && totalAllocPoint != 0) {
            
            uint256 blockTimestamp;
        
            if(block.timestamp  < nextCycleTimestamp){
                blockTimestamp = block.timestamp < pool.rewardEndTimestamp ? block.timestamp : pool.rewardEndTimestamp;
            }
            else{
                blockTimestamp = nextCycleTimestamp;
            }
            uint256 multiplier = getMultiplier(pool.lastRewardTimestamp, blockTimestamp);
            uint256 reward = multiplier.mul(rewardPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
            accZkhPerShare = accZkhPerShare.add(reward.mul(1e18).div(lpSupply));
        }
        return user.amount.mul(accZkhPerShare).div(1e18).add(user.lockedReward).sub(user.rewardDebt);
    }
    
    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
        if (block.timestamp > nextCycleTimestamp){
            nextCycleTimestamp = (block.timestamp).add(SECONDS_PER_CYCLE);
            rewardPerSecond = 0;
            
            for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
             }
            updateReward();
        }
    }
 
    // Update reward variables of the given pool to be up-to-date.
    function updatePoolPb(uint256 _pid) public {
        if (block.timestamp > nextCycleTimestamp){
            massUpdatePools();
        }
        else {
            updatePool(_pid);
        }
    }   
    
    // Update reward variables of the given pool to be up-to-date.
    
    function updatePool(uint256 _pid) internal {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp  <= pool.lastRewardTimestamp) {
            return;
        }
        
        uint256 lpSupply = pool.lpSupply;
        
        uint256 blockTimestamp;
        
            if(block.timestamp  < nextCycleTimestamp){
                blockTimestamp = block.timestamp < pool.rewardEndTimestamp ? block.timestamp : pool.rewardEndTimestamp;
            }
            else{
                blockTimestamp = nextCycleTimestamp;
            }
        
        if (lpSupply == 0) {
            pool.lastRewardTimestamp = blockTimestamp;
            return;
        }
        
        if (pool.allocPoint == 0) {
            pool.lastRewardTimestamp = blockTimestamp;
            return;
        }

        uint256 reward = 0 ;

        if(totalAllocPoint != 0){
            uint256 multiplier = getMultiplier(pool.lastRewardTimestamp, blockTimestamp);
            reward = multiplier.mul(rewardPerSecond).mul(pool.allocPoint).div(totalAllocPoint);
        }
        
        if(reward > 0 ){
            rewardToken.mint(feeAddress, reward.div(9));
            rewardToken.mint(address(treasurer), reward);
        }
        pool.accZkhPerShare = pool.accZkhPerShare.add(reward.mul(1e18).div(lpSupply));
        
        pool.lastRewardTimestamp = blockTimestamp;
        
    }


    function stakeNFT(uint256 _pid, uint256[] calldata tokenIds) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

		require(user.amount > 0, "Nothing deposited.");
        require((tokenIds.length).add(user.nftcount) <= 5 ,"maximum stake 5 NFTs");

        updatePoolPb(_pid);
		uint256 pending;
        if(user.amount > 0) {
            pending = user.amount.mul(pool.accZkhPerShare).div(1e18).sub(user.rewardDebt);
        }

		if ((pending > 0 || user.lockedReward > 0) && block.timestamp >= user.depositTime.add(pool.harvestInterval)){
            treasurer.rewardUser(msg.sender, pending.add(user.lockedReward));
            user.lockedReward = 0;
        }
        else if (pending > 0) {
            user.lockedReward = pending.add(user.lockedReward);
        }

        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nft.ownerOf(tokenId) == msg.sender, "not your token");

            nft.transferFrom(msg.sender, address(this), tokenId);
            user.nftIDs[user.nftcount]= tokenId;
            user.nftcount++ ;
            //x(1 + a/100)(1 + b/100)(1 + c/100)(1 + d/100)(1 + e/100)
            nftOwners[tokenId] = msg.sender;
            emit NFTStaked(msg.sender, tokenId, block.timestamp);
        }
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        user.amount = user.baseAmount ; 
        for(uint i = 0 ; i < user.nftcount ; i++){
                user.amount = user.amount.mul(10000 + nftBonus[user.nftIDs[i]]).div(10000);
            }
        pool.lpSupply = pool.lpSupply.add(user.amount);

        updatePoolPb(_pid);
		user.depositTime = block.timestamp;
        user.rewardDebt = user.amount.mul(pool.accZkhPerShare).div(1e18);

      
    
    }


    function getUserNfts(uint256 pid, address user) public view returns(uint256[5] memory){
        UserInfo storage userData = userInfo[pid][user];
        return(userData.nftIDs);
    }

    function getNftIndex(uint256 pid, address user, uint256 id) internal view returns(uint256 index)
    {
        uint256[5] memory tokens = userInfo[pid][user].nftIDs;
        for(uint i = 0 ; i < 5 ; i++)
        {
            if(tokens[i] == id){return(i);}
        }
    }


    function unstakeNFT(uint256 _pid, uint256[] calldata tokenIds) external {

        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.nftcount > 0, 'no nft staked!');

        updatePoolPb(_pid);
		uint256 pending;
        if(user.amount > 0) {
            pending = user.amount.mul(pool.accZkhPerShare).div(1e18).sub(user.rewardDebt);
        }

		if ((pending > 0 || user.lockedReward > 0) && block.timestamp >= user.depositTime.add(pool.harvestInterval)){
            treasurer.rewardUser(msg.sender, pending.add(user.lockedReward));
            user.lockedReward = 0;
        }
        else if (pending > 0) {
            user.lockedReward = pending.add(user.lockedReward);
        }
            
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(nftOwners[tokenId] == msg.sender, "not the nft owner");
            uint256 index = getNftIndex(_pid, msg.sender, tokenId);
            for (uint j = index; j < user.nftcount - 1; j++){
            user.nftIDs[j] = user.nftIDs[j+1];
            }
            user.nftIDs[user.nftcount - 1] = 0 ;
            user.nftcount-- ;

            nftOwners[tokenId] = address(0);

            emit NFTUnstaked(msg.sender, tokenId, block.timestamp);
            nft.transferFrom(address(this), msg.sender, tokenId);
        }
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        user.amount = user.baseAmount ; 
        if (user.nftcount > 0){
        for(uint i = 0 ; i < user.nftcount ; i++){
                user.amount = user.amount.mul(10000 + nftBonus[user.nftIDs[i]]).div(10000);
            }
        }
        pool.lpSupply = pool.lpSupply.add(user.amount);

        updatePoolPb(_pid);
		user.depositTime = block.timestamp;
        user.rewardDebt = user.amount.mul(pool.accZkhPerShare).div(1e18);

    
    }

    // Deposit LP tokens to zkhMaster for Reward allocation.
    function deposit(uint256 _pid, uint256 amount) 
	public 
	{
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        updatePoolPb(_pid);
        
		uint256 pending;
        if(user.amount > 0) {
            pending = user.amount.mul(pool.accZkhPerShare).div(1e18).sub(user.rewardDebt);
        }

		if ((pending > 0 || user.lockedReward > 0) && block.timestamp >= user.depositTime.add(pool.harvestInterval)){
            treasurer.rewardUser(msg.sender, pending.add(user.lockedReward));
            user.lockedReward = 0;
        }
        else if (pending > 0) {
            user.lockedReward = pending.add(user.lockedReward);
        }
        
        if(amount > 0) {
            
            uint256 before = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
            uint256 _after = pool.lpToken.balanceOf(address(this));
            amount = _after.sub(before); // Real amount of LP transfer to this address
            
             if (pool.depositFee > 0) {
                uint256 depositFee = amount.mul(pool.depositFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, depositFee);
                uint256 boostRatio = user.baseAmount > 0 ? (user.amount).mul(1e12).div(user.baseAmount) : 1e12;
                user.baseAmount = user.baseAmount.add(amount).sub(depositFee);
                uint256 oAmt = user.amount;
                user.amount = (user.baseAmount).mul(boostRatio).div(1e12);
                pool.baseLpSupply = pool.baseLpSupply.add(amount).sub(depositFee);
                pool.lpSupply = pool.lpSupply.sub(oAmt).add(user.amount);
            } else {

                uint256 boostRatio = user.baseAmount > 0 ? (user.amount).mul(1e12).div(user.baseAmount) : 1e12;
                user.baseAmount = user.baseAmount.add(amount);
                uint256 oAmt = user.amount;
                user.amount = (user.baseAmount).mul(boostRatio).div(1e12);
                pool.baseLpSupply = pool.baseLpSupply.add(amount);
                pool.lpSupply = pool.lpSupply.sub(oAmt).add(user.amount);
            }
            
            
        }
		
        updatePoolPb(_pid);
		user.depositTime = block.timestamp;
        user.rewardDebt = user.amount.mul(pool.accZkhPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, amount);
    }

    // Withdraw LP tokens from zkhMaster.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
		require(user.amount > 0, "Nothing deposited.");
		
        updatePoolPb(_pid);
		
		uint256 amount = _amount;
		if(amount > user.baseAmount){
			amount = user.baseAmount;
        }

		
		uint256 pending = user.amount.mul(pool.accZkhPerShare).div(1e18).sub(user.rewardDebt);

		if ((pending > 0 || user.lockedReward > 0) && block.timestamp >= user.depositTime.add(pool.harvestInterval)){
            treasurer.rewardUser(msg.sender, pending.add(user.lockedReward));
            user.lockedReward = 0;
        }
        else if (pending > 0) {
            user.lockedReward = pending.add(user.lockedReward);
        }
			
			
        if(amount > 0) {
            uint256 boostRatio = (user.amount).mul(1e12).div(user.baseAmount);
            user.baseAmount = user.baseAmount.sub(amount);
            uint256 oAmt = user.amount;
            user.amount = (user.baseAmount).mul(boostRatio).div(1e12);
            pool.baseLpSupply = pool.baseLpSupply.sub(amount);
            pool.lpSupply = pool.lpSupply.sub(oAmt).add(user.amount);
            
            if (pool.withdrawalFee > 0) {
                uint256 withdrawalFee = amount.mul(pool.withdrawalFee).div(10000);
                pool.lpToken.safeTransfer(feeAddress, withdrawalFee);
                pool.lpToken.safeTransfer(address(msg.sender), amount.sub(withdrawalFee));
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), amount);
            }
        }
		
        updatePoolPb(_pid);
		user.depositTime = block.timestamp;
        user.rewardDebt = user.amount.mul(pool.accZkhPerShare).div(1e18);
        emit Withdraw(msg.sender, _pid, amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.baseAmount);
        pool.baseLpSupply = pool.baseLpSupply.sub(user.baseAmount);
        pool.lpSupply = pool.lpSupply.sub(user.amount);
        user.amount = 0;
        user.baseAmount = 0;
        user.rewardDebt = 0;
        user.lockedReward = 0;
		user.depositTime = block.timestamp;
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }

    function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) pure external override returns (bytes4) {
      require(from == address(0x0), "Cannot send nfts to Vault directly");
      return IERC721Receiver.onERC721Received.selector;
    }

    function safeZkhTransfer(address _to, uint256 _amount) internal {
        uint256 rewardBal = rewardToken.balanceOf(address(this));
        bool successfulTansfer = false;
        if (_amount > rewardBal) {
            successfulTansfer =  rewardToken.transfer(_to, rewardBal);
        } else {
            successfulTansfer = rewardToken.transfer(_to, _amount);
        }
        require(successfulTansfer, "safeZKHTransfer: transfer failed");
    }

    function setMasterDisable() external onlyOwner {
        require(setMasterEnabled , "set master disabled!");
        setMasterEnabled = false;
    }
  
	function setOwnership(address mc) external onlyOwner {
        require(setMasterEnabled , "set master disabled!");
        rewardToken.transferOwnership(mc);
    }

}