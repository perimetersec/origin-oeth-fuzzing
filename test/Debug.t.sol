// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {MockWETH} from "../src/mocks/MockWETH.sol";
import {OUSD} from "../src/token/OUSD.sol";
import {OETHVaultFuzzWrapper} from "../src/fuzz/oethvault/OETHVaultFuzzWrapper.sol";

contract MockOracle {
    mapping(address => uint256) public price;

    function setPrice(address asset, uint256 price_) external {
        price[asset] = price_;
    }
}

contract DebugTest is Test {
    uint256 constant INITIAL_CPS = 1e27 - 1; // utils.parseUnits("1", 27).sub(BigNumber.from(1)),

    MockWETH weth;
    MockOracle oracle;
    OUSD token;
    OETHVaultFuzzWrapper vault;

    function setUp() public {
        weth = new MockWETH();
        oracle = new MockOracle();
        token = new OUSD();
        vault = new OETHVaultFuzzWrapper(address(weth));

        token.initialize(
            "TOETH",
            "OETH Test Token",
            address(vault),
            INITIAL_CPS
        );
        vault.initialize(address(this), address(token));

        // cVault.setAutoAllocateThreshold(utils.parseUnits("10", 18))
        // cVault.connect(sDeployer).setRebaseThreshold(utils.parseUnits("1", 18))
        // cVault.connect(sDeployer).setMaxSupplyDiff(utils.parseUnits("3", 16))
        // cVault.connect(sDeployer).setRedeemFeeBps(50) // 50 BPS = 0.5%
        // cVault.connect(sDeployer).setStrategistAddr(strategistAddr)
        // cVault.connect(sDeployer).setTrusteeAddress(strategistAddr)
        // cVault.connect(sDeployer).setTrusteeFeeBps(2000) // 2000 BPS = 20%
        // cVault.connect(sDeployer).unpauseCapital());
        // cOETHOracleRouter.cacheDecimals(addresses.mainnet.rETH)
        // cOETHOracleRouter.cacheDecimals(addresses.mainnet.stETH)
        // cVault.connect(sDeployer).supportAsset(addresses.mainnet.frxETH, 0)
        // cVault.connect(sDeployer).supportAsset(addresses.mainnet.WETH, 0)
        // cVault.connect(sDeployer).supportAsset(addresses.mainnet.rETH, 1)
        // cVault.connect(sDeployer).supportAsset(addresses.mainnet.stETH, 0)
        // cVaultProxy.connect(sDeployer).transferGovernance(guardianAddr)
        vault.setAutoAllocateThreshold(10e18);
        vault.setRebaseThreshold(1e18);
        vault.setMaxSupplyDiff(3e16);
        vault.setRedeemFeeBps(50);
        vault.setStrategistAddr(address(this));
        vault.setTrusteeAddress(address(this));
        vault.setTrusteeFeeBps(2000);
        vault.unpauseCapital();

        oracle.setPrice(address(weth), 1e18); // should this be 1e18 or 1e6 or 1?
        vault.setPriceProvider(address(oracle));
        vault.supportAsset(address(weth), 0);

        weth.mint(1000e18);
        weth.approve(address(vault), type(uint256).max);
    }

    function testDeploy() public {
        console.log("weth balance before", weth.balanceOf(address(this)));
        console.log("oeth balance before", token.balanceOf(address(this)));

        vault.mint(address(weth), 100, 0);

        console.log("weth balance after", weth.balanceOf(address(this)));
        console.log("oeth balance after", token.balanceOf(address(this)));
    }
}
