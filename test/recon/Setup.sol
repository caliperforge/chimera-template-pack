// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BaseSetup} from "chimera/BaseSetup.sol";
import {vm} from "chimera/Hevm.sol";

/// @notice Setup — deploys the target protocol's contracts + registers fuzzer actors.
///
/// This is one of the three `TODO(protocol)` files in the Chimera scaffold. The
/// fork-owner is expected to:
///   1. Import the target protocol's contracts (from `src/<protocol>/`).
///   2. Deploy them in `setup()` with realistic initial state.
///   3. Optionally seed mock oracles / tokens / collaterals.
///
/// Actors are exposed via the `actor*` modifiers in TargetFunctions.sol — they read
/// the addresses registered here.
abstract contract Setup is BaseSetup {
    // -------------------------------------------------------------------------
    // Actor registry — keep these as-is; TargetFunctions.sol's modifiers cycle
    // through them. Forks add protocol-specific actors (e.g. liquidators,
    // admins) below.
    // -------------------------------------------------------------------------
    address internal constant ACTOR_ALICE = address(0x10000);
    address internal constant ACTOR_BOB = address(0x20000);
    address internal constant ACTOR_CAROL = address(0x30000);

    // TODO(protocol): declare addresses of the protocol's deployed contracts here.
    // Example:
    //     IVault internal vault;
    //     MockERC20 internal asset;
    //     IPriceOracle internal oracle;

    /// @notice Called once per fuzzer campaign before any TargetFunctions are invoked.
    function setup() internal virtual override {
        // TODO(protocol): deploy the protocol's contracts.
        //
        // Example:
        //     asset = new MockERC20("Test Asset", "TA", 18);
        //     vault = new Vault(address(asset), "Test Vault", "TV");
        //     oracle = new MockPriceOracle();
        //
        //     // Seed each actor with starting balance.
        //     asset.mint(ACTOR_ALICE, 1_000e18);
        //     asset.mint(ACTOR_BOB, 1_000e18);
        //     asset.mint(ACTOR_CAROL, 1_000e18);
        //
        //     // Optional: set deterministic block / timestamp.
        //     vm.warp(1_700_000_000);
        //     vm.roll(18_000_000);
        revert("TODO(protocol): Setup.setup() - wire the target protocol's deploys");
    }

    /// @notice List of actors the TargetFunctions modifiers cycle through.
    function _actors() internal pure returns (address[3] memory) {
        return [ACTOR_ALICE, ACTOR_BOB, ACTOR_CAROL];
    }
}
