// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title CrossChainAggregator
 * @notice Unified EVM receiving wallet supporting native assets and wrapped cross-chain tokens.
 * @dev Compatible with OpenZeppelin v5.x. Supports ETH, Base, Polygon, Arbitrum, Optimism,
 *      and any ERC-20 token including wrapped Bitcoin (wBTC, cbBTC, tBTC).
 */
contract CrossChainAggregator is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    uint256 public constant BASIS_POINTS = 10000;
    uint256 public constant MAX_HISTORY_BATCH = 50; // Pagination limit

    struct DepositRecord {
        address token;
        uint256 amount;
        uint256 chainId;
        string txHash;
        uint256 timestamp;
        bool isNative;
    }

    struct ChainInfo {
        uint256 chainId;
        string name;
        bool active;
    }

    mapping(address => bool) public supportedTokens;
    mapping(uint256 => ChainInfo) public chainInfo;
    mapping(address => mapping(address => uint256)) public balances; // user => token => amount
    mapping(address => uint256) public nativeBalances; // user => ETH/native amount
    mapping(address => DepositRecord[]) public depositHistory;
    mapping(address => uint256) public depositCount; // Track count for pagination

    uint256 public feeBps = 50; // 0.5% default
    uint256 public nativeFeeBps = 50; // 0.5% for native ETH (matches ERC-20 fee)
    address public feeRecipient;

    event TokenWhitelisted(address indexed token, string label);
    event TokenRemoved(address indexed token);
    event ChainConfigured(uint256 indexed chainId, string name, bool active);
    event Deposit(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 chainId,
        string txHash,
        uint256 timestamp,
        bool isNative
    );
    event Withdraw(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 timestamp,
        bool isNative
    );
    event FeeCollected(address indexed token, uint256 amount);
    event FeeRateUpdated(uint256 newErcFeeBps, uint256 newNativeFeeBps);

    /**
     * @dev Constructor initializes the contract with default chains and fee recipient.
     * @param _feeRecipient Address to receive protocol fees
     */
    constructor(address _feeRecipient) Ownable(msg.sender) {
        require(_feeRecipient != address(0), "invalid fee recipient");
        feeRecipient = _feeRecipient;

        // Initialize common EVM chains
        chainInfo[1] = ChainInfo({ chainId: 1, name: "Ethereum", active: true });
        chainInfo[8453] = ChainInfo({ chainId: 8453, name: "Base", active: true });
        chainInfo[137] = ChainInfo({ chainId: 137, name: "Polygon", active: true });
        chainInfo[42161] = ChainInfo({ chainId: 42161, name: "Arbitrum", active: true });
        chainInfo[10] = ChainInfo({ chainId: 10, name: "Optimism", active: true });
    }

    /**
     * @dev Receive native ETH with fee deduction and event logging.
     */
    receive() external payable whenNotPaused {
        require(msg.value > 0, "amount must be > 0");

        uint256 fee = (msg.value * nativeFeeBps) / BASIS_POINTS;
        uint256 netAmount = msg.value - fee;

        nativeBalances[msg.sender] += netAmount;
        depositCount[msg.sender]++;

        depositHistory[msg.sender].push(
            DepositRecord({
                token: address(0),
                amount: netAmount,
                chainId: block.chainid,
                txHash: "native-transfer",
                timestamp: block.timestamp,
                isNative: true
            })
        );

        if (fee > 0) {
            (bool ok, ) = payable(feeRecipient).call{ value: fee }("");
            require(ok, "fee transfer failed");
            emit FeeCollected(address(0), fee);
        }

        emit Deposit(msg.sender, address(0), netAmount, block.chainid, "native-transfer", block.timestamp, true);
    }

    /**
     * @dev Whitelist an ERC-20 token for deposits.
     */
    function whitelistToken(address token, string calldata label) external onlyOwner {
        require(token != address(0), "invalid token");
        supportedTokens[token] = true;
        emit TokenWhitelisted(token, label);
    }

    /**
     * @dev Remove a token from whitelist.
     */
    function removeToken(address token) external onlyOwner {
        supportedTokens[token] = false;
        emit TokenRemoved(token);
    }

    /**
     * @dev Configure a blockchain network.
     */
    function configureChain(uint256 chainId, string calldata name, bool active) external onlyOwner {
        require(chainId != 0, "invalid chain id");
        chainInfo[chainId] = ChainInfo({ chainId: chainId, name: name, active: active });
        emit ChainConfigured(chainId, name, active);
    }

    /**
     * @dev Set ERC-20 and native fee rates (in basis points).
     */
    function setFeeBps(uint256 _ercFeeBps, uint256 _nativeFeeBps) external onlyOwner {
        require(_ercFeeBps <= 1000, "erc fee too high"); // max 10%
        require(_nativeFeeBps <= 1000, "native fee too high"); // max 10%
        feeBps = _ercFeeBps;
        nativeFeeBps = _nativeFeeBps;
        emit FeeRateUpdated(_ercFeeBps, _nativeFeeBps);
    }

    /**
     * @dev Update fee recipient address.
     */
    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "invalid fee recipient");
        feeRecipient = _feeRecipient;
    }

    /**
     * @dev Pause all deposits and withdrawals.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Resume deposits and withdrawals.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Deposit ERC-20 tokens with fee deduction.
     * @param token ERC-20 token address (supports non-standard tokens via SafeERC20)
     * @param amount Amount to deposit
     * @param chainId Source chain ID
     * @param txHash Transaction hash for cross-chain verification
     */
    function depositERC20(
        address token,
        uint256 amount,
        uint256 chainId,
        string calldata txHash
    ) external whenNotPaused nonReentrant {
        require(supportedTokens[token], "token not allowed");
        require(amount > 0, "amount must be > 0");
        require(chainInfo[chainId].active, "chain not active");
        require(bytes(txHash).length > 0, "tx hash required");

        uint256 fee = (amount * feeBps) / BASIS_POINTS;
        uint256 netAmount = amount - fee;

        // SafeERC20 handles non-standard tokens like USDT
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        balances[msg.sender][token] += netAmount;
        depositCount[msg.sender]++;

        depositHistory[msg.sender].push(
            DepositRecord({
                token: token,
                amount: netAmount,
                chainId: chainId,
                txHash: txHash,
                timestamp: block.timestamp,
                isNative: false
            })
        );

        if (fee > 0) {
            IERC20(token).safeTransfer(feeRecipient, fee);
            emit FeeCollected(token, fee);
        }

        emit Deposit(msg.sender, token, netAmount, chainId, txHash, block.timestamp, false);
    }

    /**
     * @dev Withdraw ERC-20 tokens.
     */
    function withdrawERC20(address token, uint256 amount) external whenNotPaused nonReentrant {
        require(supportedTokens[token], "token not allowed");
        require(amount > 0, "amount must be > 0");
        require(balances[msg.sender][token] >= amount, "insufficient balance");

        balances[msg.sender][token] -= amount;
        IERC20(token).safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, token, amount, block.timestamp, false);
    }

    /**
     * @dev Withdraw native ETH.
     */
    function withdrawNative(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "amount must be > 0");
        require(nativeBalances[msg.sender] >= amount, "insufficient native balance");

        nativeBalances[msg.sender] -= amount;
        (bool ok, ) = payable(msg.sender).call{ value: amount }("");
        require(ok, "native withdraw failed");

        emit Withdraw(msg.sender, address(0), amount, block.timestamp, true);
    }

    /**
     * @dev Get ERC-20 token balance for user.
     */
    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    /**
     * @dev Get native ETH balance for user.
     */
    function getNativeBalance(address user) external view returns (uint256) {
        return nativeBalances[user];
    }

    /**
     * @dev Get total deposit count for user (for pagination).
     */
    function getDepositCount(address user) external view returns (uint256) {
        return depositCount[user];
    }

    /**
     * @dev Get paginated deposit history to prevent gas limits.
     * @param user User address
     * @param offset Starting index
     * @param limit Number of records to return (capped at MAX_HISTORY_BATCH)
     */
    function getDepositHistoryPaginated(
        address user,
        uint256 offset,
        uint256 limit
    ) external view returns (DepositRecord[] memory) {
        require(limit <= MAX_HISTORY_BATCH, "limit exceeds max batch size");
        require(offset < depositHistory[user].length, "offset out of range");

        uint256 end = offset + limit;
        if (end > depositHistory[user].length) {
            end = depositHistory[user].length;
        }

        DepositRecord[] memory result = new DepositRecord[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = depositHistory[user][i];
        }
        return result;
    }

    /**
     * @dev Get all deposit history (caution: may hit gas limits for large histories).
     * @param user User address
     */
    function getDepositHistory(address user) external view returns (DepositRecord[] memory) {
        return depositHistory[user];
    }

    /**
     * @dev Emergency ERC-20 token withdrawal by owner.
     */
    function emergencyWithdrawERC20(address token, uint256 amount) external onlyOwner {
        require(supportedTokens[token], "token not allowed");
        IERC20(token).safeTransfer(owner(), amount);
    }

    /**
     * @dev Emergency native ETH withdrawal by owner.
     */
    function emergencyWithdrawNative(uint256 amount) external onlyOwner {
        require(amount > 0, "amount must be > 0");
        require(address(this).balance >= amount, "insufficient contract balance");
        (bool ok, ) = payable(owner()).call{ value: amount }("");
        require(ok, "native emergency transfer failed");
    }
}
