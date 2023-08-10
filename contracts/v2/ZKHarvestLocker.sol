// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract zkHarvestLocker is Ownable  {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each lock.
    struct LockInfo {
        IERC20 token;
        uint256 amount;
        uint256 depositTime;
        uint256 unlockTime;
        address owner;
        string logoUrl;
        bool withdrawn;
    }

    // Dev address.
    address public devaddr;
    // Locker Fee address
    address public feeAddress;
    // locker fee
    uint256 public fee = 100 ;
    // Info of each locker.
    LockInfo[] public lockInfo;
    // Info of each user that locks tokens.
    mapping(address => uint256[]) public userInfo;

    
    modifier onlyDev() {
        require(msg.sender == owner() || msg.sender == devaddr , "Error: Require developer or Owner");
        _;
    }
    
    event SetFeeAddress(address newAddress);
    event Lock(address Owner , address Token , uint256 Amount , uint256 UnlockTime);
    event Unlock(address Owner , uint256 LockerID);
    event ExtendLock(uint256 LockerID , uint256 NewUnlockTime);
    

    constructor(
        address _devaddr,
        address _feeAddress
    ) {
        
        require(_devaddr != address(0), 'ZKH: dev cannot be the zero address');
        require(_feeAddress != address(0), 'ZKH: FeeAddress cannot be the zero address');
       
        devaddr = _devaddr;
        feeAddress = _feeAddress;
    }

    function setFeeAddress(address _feeAddress)public onlyDev returns (bool){        
        require(_feeAddress != address(0), 'ZKH: FeeAddress cannot be the zero address');
        feeAddress = _feeAddress;
        emit SetFeeAddress(_feeAddress);
        return true;
    }

    function setFee(uint256 _newFee)external onlyDev{
        require(_newFee <= 2000, "max fee 20%");
        fee = _newFee;
    }

    function totalLockers() external view returns (uint256) {
        return lockInfo.length;
    }

    function getUserInfo(address user) external view returns(uint256[] memory){
        return(userInfo[user]);
    }

    // lock tokens 
    function lock(
    IERC20 _token,
    uint256 _amount,
    uint256 _unlockTimestamp,
    string calldata _logoUrl
    
    ) external returns(bool){
        bool lockSuccess = lockFor(msg.sender , _token , _amount, _unlockTimestamp, _logoUrl);
        require(lockSuccess , "Locker: lockByZkh failed");
        return(lockSuccess);
    }
    // lock tokens for someone else
    function lockFor(
        address _owner,
        IERC20 _token,
        uint256 _amount,
        uint256 _unlockTimestamp,
        string calldata _logoUrl)public returns(bool){
        require(_token != IERC20(address(0)), "Token cannot be the zero address");
        require(_amount > 0, "nothing to lock");
        require(_token.balanceOf(msg.sender) >= _amount , "not enough token balance");
        require(_unlockTimestamp > block.timestamp, "invalid unlock time");

        uint256 before = _token.balanceOf(address(this));
        _token.safeTransferFrom(address(msg.sender), address(this), _amount);
        uint256 _after = _token.balanceOf(address(this));
        uint256 amount_ = _after.sub(before); // Real amount of token transfer to this address
        
        uint256 feeAmount = amount_.mul(fee).div(10000);
        _token.safeTransfer(feeAddress , feeAmount);
        amount_ = amount_.sub(feeAmount);

        
        lockInfo.push(LockInfo({
            token:_token,
            amount:amount_,
            depositTime:block.timestamp,
            unlockTime:_unlockTimestamp,
            owner:_owner,
            logoUrl:_logoUrl,
            withdrawn:false
        }));

        userInfo[msg.sender].push(lockInfo.length - 1) ;
        
        emit Lock(msg.sender , address(_token) , amount_ , _unlockTimestamp);
        
        return(true);
    }

    // Unlock & withdraw.
    function unlock(uint256 _lockerId) external {
        LockInfo storage locker = lockInfo[_lockerId];
        require(locker.owner == msg.sender , "Error: Locker owner required");
        require(locker.unlockTime <= block.timestamp , "Error: Unlock Time not reached");
        require(!locker.withdrawn , "Error: Already withdrawn");

        locker.token.safeTransfer(address(msg.sender), locker.amount);
        locker.withdrawn = true;
        emit Unlock(msg.sender, _lockerId);
    }

    // extend lock time.
    function extendLock(uint256 _lockerId, uint256 _newUnlockTime) external {
        LockInfo storage locker = lockInfo[_lockerId];
        require(locker.owner == msg.sender || devaddr == msg.sender, "Error: Locker owner required");
        require(!locker.withdrawn , "Error: Already withdrawn");
        require(block.timestamp < _newUnlockTime , "Error: New Unlock not in future");
        require(locker.unlockTime < _newUnlockTime , "Error: Older than current unlocktime");

        locker.unlockTime = _newUnlockTime;
        emit ExtendLock(_lockerId, _newUnlockTime);
    }


    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(_devaddr != address(0), 'ZKH: dev cannot be the zero address');
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
    }
}