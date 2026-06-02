// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {CryticTester} from "./CryticTester.sol";

/// @notice CryticToFoundry — replays the Chimera harness under forge for fast
/// local debug.
///
/// Use this when an Echidna/Medusa campaign surfaces a violation and you want
/// to step through the failing sequence with `forge test -vvvv` traces. Paste
/// the reproducing call sequence into `test_reproduce_<name>` and let forge
/// re-execute it with full debug output.
///
/// Forks also use this for the smoke test that CI runs before the slower fuzz
/// campaigns — it confirms the harness compiles and the deploys succeed.
contract CryticToFoundryTest is Test {
    /// @notice Expected revert reason on the as-shipped template. Forks delete
    /// this constant + the _SKIPPED branch below once Setup.setup() is wired.
    string internal constant TEMPLATE_SKIP_MARKER =
        "TODO(protocol): Setup.setup() - wire the target protocol's deploys";

    CryticTester internal tester;

    function _deployTester() external returns (CryticTester) {
        return new CryticTester();
    }

    /// @notice Smoke test — confirms the three seeded invariants return true
    /// on the initial post-setup state.
    ///
    /// On the as-shipped template, Setup.setup() reverts with TEMPLATE_SKIP_MARKER.
    /// We catch that exact revert and pass trivially — the CI green badge on the
    /// bare template means "compiles + revert-stub fires as documented". A fork
    /// that wires Setup gets the real assertions automatically. Any OTHER revert
    /// reason is a real failure (likely a broken Setup) and surfaces normally.
    function test_smoke_invariants_hold_on_setup() public {
        try this._deployTester() returns (CryticTester _t) {
            tester = _t;
            assertTrue(tester.property_solvency_INV001(), "INV-001 violated at setup");
            assertTrue(tester.property_shareprice_monotonic_INV002(), "INV-002 violated at setup");
            assertTrue(tester.property_accesscontrol_INV003(), "INV-003 violated at setup");
        } catch Error(string memory reason) {
            assertEq(
                reason,
                TEMPLATE_SKIP_MARKER,
                "Setup reverted but not with the template's TODO marker - real failure"
            );
            emit log_named_string("template-setup-skipped", reason);
        }
    }

    /// @notice Repro slot — paste an Echidna / Medusa failing call sequence
    /// here, parameterize the inputs, and let forge re-run with full trace.
    /// No-op on the as-shipped template (nothing to repro yet); forks add the
    /// failing sequence once a campaign surfaces one.
    function test_reproduce_TODO() public pure {
        // TODO(protocol): paste a failing call sequence here, e.g.:
        //     tester.target_deposit(0, 1_000e18);
        //     tester.target_withdraw(0, 1_000e18);
        //     assertTrue(tester.property_solvency_INV001());
    }
}
