// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {Asserts} from "chimera/Asserts.sol";
import {Setup} from "./Setup.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

/// @notice Properties — three seeded protocol-specific invariants the campaign checks.
///
/// Each property below maps to a common Cantina / Code4rena finding class. The names
/// (`INV-001`/`INV-002`/`INV-003`) are placeholders; rename to protocol-specific names
/// in the fork (e.g. `property_morpho_totalAssets_matches_balance`).
///
/// AI-tagging convention: if an invariant was AI-suggested (vs. hand-authored from a
/// protocol-spec read), prefix with `// AI-SUGGESTED: <model> <date>` per the AI
/// disclosure policy in `docs/ai-disclosure.md`. Reviewers grep for this tag.
abstract contract Properties is Setup, BeforeAfter, Asserts {
    // -------------------------------------------------------------------------
    // INV-001 — solvency / token conservation
    // -------------------------------------------------------------------------
    // Finding class: bookkeeping drift between on-chain accounting and actual
    // token holdings. Canonical bug shape: a withdraw / claim path that
    // decrements the user-side balance but doesn't move (or over-moves) the
    // underlying token, or vice-versa.
    //
    // The invariant: the protocol's reported `totalAssets()` (or equivalent
    // accounting view) equals the underlying ERC20 balance held by the
    // protocol contract.
    function property_solvency_INV001() public view returns (bool) {
        // TODO(protocol): replace with the protocol's accounting view + balance
        // accessor.
        //
        // Example:
        //     uint256 accounted = vault.totalAssets();
        //     uint256 held = asset.balanceOf(address(vault));
        //     return accounted == held;
        return true;
    }

    // -------------------------------------------------------------------------
    // INV-002 — monotonic share price under deposit-only conditions
    // -------------------------------------------------------------------------
    // Finding class: share-price manipulation. Canonical bug shapes: first-
    // depositor donation attack inflating share price; rounding errors that
    // let an attacker withdraw at a better rate than they deposited.
    //
    // The invariant: the share price (assets per share) MAY rise from accrued
    // yield, but MAY NOT fall as a result of a deposit. Withdraw paths are
    // excluded — they legitimately can move the price down in some accounting
    // models. The fork narrows this to the protocol's actual yield model.
    function property_shareprice_monotonic_INV002() public view returns (bool) {
        // TODO(protocol): in the fork, gate this on the snapshot taken at the
        // top of `target_deposit` only. The BeforeAfter helper carries the
        // last-action-kind flag; this is a one-line edit.
        //
        // Example (after wiring _readVars in BeforeAfter.sol):
        //     if (lastActionKind != ActionKind.Deposit) return true;
        //     return _after.sharePriceE18 >= _before.sharePriceE18;
        return _after.sharePriceE18 >= _before.sharePriceE18;
    }

    // -------------------------------------------------------------------------
    // INV-003 — access-control restriction on privileged functions
    // -------------------------------------------------------------------------
    // Finding class: missing modifier on admin / pause / rescue. Canonical bug
    // shape: an admin function lacks `onlyOwner` and is reachable from
    // arbitrary callers; or a multi-role system mis-maps a function to the
    // wrong role.
    //
    // The invariant: if `target_adminAction` succeeded, the caller MUST be the
    // registered admin actor. TargetFunctions.target_adminAction records the
    // last caller + success flag; this property checks the join.
    function property_accesscontrol_INV003() public view returns (bool) {
        if (!lastAdminCallSucceeded) return true;
        // TODO(protocol): replace ACTOR_ALICE with the protocol's actual admin
        // address. Must match the address used in TargetFunctions.actorAdmin.
        return lastAdminCaller == ACTOR_ALICE;
    }

    // -------------------------------------------------------------------------
    // Echidna / Medusa entrypoints — call the above with property_ prefix so
    // both engines pick them up. The Chimera Asserts helper logs the property
    // name on failure.
    // -------------------------------------------------------------------------
    function echidna_INV001_solvency() public view returns (bool) {
        return property_solvency_INV001();
    }

    function echidna_INV002_shareprice_monotonic() public view returns (bool) {
        return property_shareprice_monotonic_INV002();
    }

    function echidna_INV003_access_control() public view returns (bool) {
        return property_accesscontrol_INV003();
    }
}
