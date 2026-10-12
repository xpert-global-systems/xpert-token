// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title CrossChainAggregator
 * @notice A single EVM wallet contract that can receive ETH, Base assets, ERC-20s,
 *         and Bitcoin represented as wrapped BTC tokens (wBTC, cbBTC, tBTC, etc.)
 *         across supported chains.
 *
 * @dev This is designed for a unified receiving address on EVM-compatible networks.
 *      BTC itself is not directly native to EVM, so BTC support is via wrapped BTC
 *      assets or bridge-produced BTC representations on Ethereum/Base/etc.
 */
contract CrossChainAggregator is Ownable, ReentrancyGuard, Pausable {
    uint256 public constant BASIS_POINTS = 10000;

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

    uint256 public feeBps = 50; // 0.5%
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

    constructor(address _feeRecipient) {
        require(_feeRecipient != address(0), "invalid fee recipient");
        feeRecipient = _feeRecipient;

        // Common EVM chain configuration
        chainInfo[1] = ChainInfo({ chainId: 1, name: "Ethereum", active: true });
        chainInfo[8453] = ChainInfo({ chainId: 8453, name: "Base", active: true });
        chainInfo[137] = ChainInfo({ chainId: 137, name: "Polygon", active: true });
        chainInfo[42161] = ChainInfo({ chainId: 42161, name: "Arbitrum", active: true });
        chainInfo[10] = ChainInfo({ chainId: 10, name: "Optimism", active: true });
    }

    receive() external payable {
        nativeBalances[msg.sender] += msg.value;
        depositHistory[msg.sender].push(
            DepositRecord({
                token: address(0),
                amount: msg.value,
                chainId: block.chainid,
                txHash: "native-transfer",
                timestamp: block.timestamp,
                isNative: true
            })
        );

        emit Deposit(
            msg.sender,
            address(0),
            msg.value,
            block.chainid,
            "native-transfer",
            block.timestamp,
            true
        );
    }

    function whitelistToken(address token, string calldata label) external onlyOwner {
        require(token != address(0), "invalid token");
        supportedTokens[token] = true;
        emit TokenWhitelisted(token, label);
    }

    function removeToken(address token) external onlyOwner {
        supportedTokens[token] = false;
        emit TokenRemoved(token);
    }

    function configureChain(uint256 chainId, string calldata name, bool active) external onlyOwner {
        chainInfo[chainId] = ChainInfo({ chainId: chainId, name: name, active: active });
        emit ChainConfigured(chainId, name, active);
    }

    function setFeeBps(uint256 _feeBps) external onlyOwner {
        require(_feeBps <= 1000, "fee too high"); // max 10%
        feeBps = _feeBps;
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {
        require(_feeRecipient != address(0), "invalid fee recipient");
        feeRecipient = _feeRecipient;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function depositERC20(
        address token,
        uint256 amount,
        uint256 chainId,
        string calldata txHash
    ) external whenNotPaused nonReentrant {
        require(supportedTokens[token], "token not allowed");
        require(amount > 0, "amount must be > 0");
        require(chainInfo[chainId].active, "chain not active");

        uint256 fee = (amount * feeBps) / BASIS_POINTS;
        uint256 netAmount = amount - fee;

        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "transferFrom failed");

        balances[msg.sender][token] += netAmount;
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
            require(IERC20(token).transfer(feeRecipient, fee), "fee transfer failed");
            emit FeeCollected(token, fee);
        }

        emit Deposit(msg.sender, token, netAmount, chainId, txHash, block.timestamp, false);
    }

    function withdrawERC20(address token, uint256 amount) external whenNotPaused nonReentrant {
        require(supportedTokens[token], "token not allowed");
        require(amount > 0, "amount must be > 0");
        require(balances[msg.sender][token] >= amount, "insufficient balance");

        balances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount), "withdraw failed");

        emit Withdraw(msg.sender, token, amount, block.timestamp, false);
    }

    function withdrawNative(uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "amount must be > 0");
        require(nativeBalances[msg.sender] >= amount, "insufficient native balance");

        nativeBalances[msg.sender] -= amount;
        (bool ok, ) = payable(msg.sender).call{ value: amount }("");
        require(ok, "native withdraw failed");

        emit Withdraw(msg.sender, address(0), amount, block.timestamp, true);
    }

    function getBalance(address user, address token) external view returns (uint256) {
        return balances[user][token];
    }

    function getNativeBalance(address user) external view returns (uint256) {
        return nativeBalances[user];
    }

    function getDepositHistory(address user) external view returns (DepositRecord[] memory) {
        return depositHistory[user];
    }

    function emergencyWithdrawERC20(address token, uint256 amount) external onlyOwner {
        require(supportedTokens[token], "token not allowed");
        require(IERC20(token).transfer(owner(), amount), "emergency transfer failed");
    }

    function emergencyWithdrawNative(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "insufficient contract balance");
        (bool ok, ) = payable(owner()).call{ value: amount }("");
        require(ok, "native emergency transfer failed");
    }
}

// NOTE ON BTC SUPPORT:
// BTC is not natively supported on EVM chains. To support BTC in this contract, add the
// wrapped BTC token address for the relevant network, such as:
// - Ethereum: wBTC (0x2260FAC5E5542a773Aa44fBCfeDd86b8040F6e4C)
// - Base: cbBTC or bridge-wrapped BTC tokens as deployed on Base
// - Other chains: tBTC, wBTC, or equivalent bridge-backed BTC representations
//
// This contract supports receiving BTC-equivalent value on EVM-compatible networks by
// whitelisting the wrapped BTC token address and then depositing via depositERC20().
