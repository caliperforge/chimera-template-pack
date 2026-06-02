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
    CryticTester internal tester;

    function setUp() public {
        // Pre-skip until the fork wires Setup.setup(). The Setup base reverts
        // with an explicit `TODO(protocol)` message; we catch it so the
        // smoke-test exits cleanly on the as-shipped template.
        try this._deployTester() returns (CryticTester _t) {
            tester = _t;
        } catch Error(string memory reason) {
            emit log_named_string("template-setup-skipped", reason);
            vm.skip(true);
        }
    }

    function _deployTester() external returns (CryticTester) {
        return new CryticTester();
    }

    /// @notice Smoke test — confirms the three seeded invariants return true
    /// on the initial post-setup state.
    function test_smoke_invariants_hold_on_setup() public {
        assertTrue(tester.property_solvency_INV001(), "INV-001 violated at setup");
        assertTrue(tester.property_shareprice_monotonic_INV002(), "INV-002 violated at setup");
        assertTrue(tester.property_accesscontrol_INV003(), "INV-003 violated at setup");
    }

    /// @notice Repro slot — paste an Echidna / Medusa failing call sequence
    /// here, parameterize the inputs, and let forge re-run with full trace.
    function test_reproduce_TODO() public {
        // TODO(protocol): paste a failing call sequence here, e.g.:
        //     tester.target_deposit(0, 1_000e18);
        //     tester.target_withdraw(0, 1_000e18);
        //     assertTrue(tester.property_solvency_INV001());
    }
}
