
    function replayIncreaseStartingBalance() public {
        logBalances();

        // actor 1 weth 1000000000000000000000000000000
        // actor 1 oeth                               0
        // actor 2 weth 1000000000000000000000000000000
        // actor 2 oeth                               0
        // vault weth      2000000000000000000000000000
        // oeth total      2000000000000000000000000000

        vm.prank(ADDRESS_ACTOR1);
        FuzzVault(address(this)).mint(989035089409727266059946856458);

        vm.prank(ADDRESS_ACTOR2);
        FuzzVault(address(this)).mint(886565445402309203889372912984);

        log("MINT");
        logBalances();

        // actor 1 weth  10964910590272733940053143542
        // actor 1 oeth 989035089409727266059946856457
        // actor 2 weth 113434554597690796110627087016
        // actor 2 oeth 886565445402309203889372912983
        // vault weth  1877600534812036469949319769442
        // oeth total  1877600534812036469949319769442

        uint count = 1;
        for (uint256 i = 0; i < count; i++) {
            vm.prank(ADDRESS_ACTOR2);
            FuzzVault(address(this)).donateAndRebase(1);
        }

        log("DONATE & REBASE");
        logBalances();

        // actor 1 weth  10964910590272733940053143542
        // actor 1 oeth 989035089409727266059946857447
        // actor 2 weth 113434554597690796110627087015
        // actor 2 oeth 886565445402309203889372913870
        // vault weth  1877600534812036469949319769443
        // oeth total  1877600534812036469949319771318

        vm.prank(ADDRESS_ACTOR1);
        FuzzVault(address(this)).redeemAll();

        vm.prank(ADDRESS_ACTOR2);
        FuzzVault(address(this)).redeemAll();

        log("REDEEM ALL");
        logBalances();

        // actor 1 weth  1000000000000000000000000000989
        // actor 1 oeth 0
        // actor 2 weth 1000000000000000000000000000885
        // actor 2 oeth 0
        // vault weth  1999999999999999999999998126
        // oeth total  2000000000000000000000000001

        uint totalStarting = STARTING_BALANCE * ACTORS.length;

        uint256 totalWeth;
        for (uint256 i = 0; i < ACTORS.length; i++) {
            totalWeth += weth.balanceOf(ACTORS[i]);
        }

        log("totalStarting", totalStarting);
        log("totalWeth", totalWeth);
        log("vault weth", weth.balanceOf(address(vault)));
        log("this balance", oeth.balanceOf(address(this)));
        log("deployer balance", oeth.balanceOf(ADDRESS_DEPLOYER));

        // total starting 2000000000000000000000000000000
        // total weth     2000000000000000000000000001874
        // vault weth        1999999999999999999999998126

        try vault.redeemAll(0) {
            log("REDEEM ALL SUCCESS");
        } catch {
            t(false, "REDEEM ALL FAILED");
        }

        vm.prank(ADDRESS_DEPLOYER);
        try vault.redeemAll(0) {
            log("REDEEM ALL SUCCESS");
        } catch {
            t(false, "REDEEM ALL FAILED");
        }

        assert(totalWeth <= totalStarting);
    }
