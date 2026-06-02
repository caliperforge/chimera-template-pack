// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Setup} from "./Setup.sol";

/// @notice BeforeAfter — snapshots protocol state before/after each TargetFunctions call.
///
/// This is the helper the Chimera pattern uses to make monotonicity / "field-X never
/// decreased" properties cheap to express. TargetFunctions calls `__snapshot()` at the
/// top of each `target_*` and `__after()` at the bottom; Properties.sol reads `_before`
/// and `_after` to compare.
abstract contract BeforeAfter is Setup {
    struct Vars {
        // TODO(protocol): add the protocol-state fields the monotonicity / accounting
        // invariants need to compare. Three placeholders below — extend / replace.
        uint256 totalAssets;     // INV-001 conservation
        uint256 sharePriceE18;   // INV-002 monotonicity (scaled to 18 decimals)
        uint256 totalSupply;     // ancillary
    }

    Vars internal _before;
    Vars internal _after;

    // Shared state read by Properties.sol for the access-control invariant.
    // TargetFunctions.target_adminAction writes these.
    bool internal lastAdminCallSucceeded;
    address internal lastAdminCaller;

    function __snapshot() internal {
        _before = _readVars();
    }

    function __after() internal {
        _after = _readVars();
    }

    function _readVars() internal view returns (Vars memory v) {
        // TODO(protocol): populate from the protocol's accessors.
        // Example:
        //     v.totalAssets = vault.totalAssets();
        //     v.totalSupply = vault.totalSupply();
        //     v.sharePriceE18 = v.totalSupply == 0
        //         ? 1e18
        //         : (v.totalAssets * 1e18) / v.totalSupply;
        v;
    }
}
