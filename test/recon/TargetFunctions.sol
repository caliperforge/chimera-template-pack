// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {BaseTargetFunctions} from "chimera/BaseTargetFunctions.sol";
import {vm} from "chimera/Hevm.sol";
import {Setup} from "./Setup.sol";
import {BeforeAfter} from "./BeforeAfter.sol";

/// @notice TargetFunctions — public surface the fuzzer is allowed to mutate.
///
/// This is one of the three `TODO(protocol)` files. Each protocol-side function the
/// fuzzer should call is wrapped here as a `target_<fnName>` external function. The
/// `actor*` modifiers rotate the `msg.sender` across the registered actors so
/// access-control properties get real coverage.
///
/// The Chimera convention: `target_*` functions wrap one protocol call each, optionally
/// followed by `__snapshot()` / `__after()` calls that Properties.sol reads.
abstract contract TargetFunctions is BaseTargetFunctions, BeforeAfter {
    // -------------------------------------------------------------------------
    // Actor modifiers — rotate msg.sender. Forks shouldn't need to edit these.
    // -------------------------------------------------------------------------
    modifier actor(uint8 actorIdx) {
        address a = _actors()[actorIdx % _actors().length];
        vm.prank(a);
        _;
    }

    modifier actorAdmin() {
        // TODO(protocol): replace ACTOR_ALICE with the protocol's admin address.
        vm.prank(ACTOR_ALICE);
        _;
    }

    // -------------------------------------------------------------------------
    // Protocol surface — TODO(protocol): expose each public/external function
    // the fuzzer should mutate. Three illustrative seeds below; rename / replace
    // to match the target protocol.
    // -------------------------------------------------------------------------

    /// @notice TODO(protocol): example deposit-style entrypoint.
    function target_deposit(uint8 actorIdx, uint256 amount) external actor(actorIdx) {
        __snapshot();
        // TODO(protocol):
        //     uint256 bounded = amount % asset.balanceOf(msg.sender) + 1;
        //     asset.approve(address(vault), bounded);
        //     vault.deposit(bounded, msg.sender);
        __after();
    }

    /// @notice TODO(protocol): example withdraw-style entrypoint.
    function target_withdraw(uint8 actorIdx, uint256 sharesOrAmount) external actor(actorIdx) {
        __snapshot();
        // TODO(protocol):
        //     uint256 bounded = sharesOrAmount % vault.balanceOf(msg.sender) + 1;
        //     vault.withdraw(bounded, msg.sender, msg.sender);
        __after();
    }

    /// @notice TODO(protocol): example admin-only entrypoint. Used by INV-003 access-control
    /// invariant — the fuzzer calls this from a non-admin actor and the property asserts
    /// the call reverted.
    function target_adminAction(uint8 actorIdx, uint256 arg) external actor(actorIdx) {
        // TODO(protocol):
        //     try vault.pause() {
        //         lastAdminCallSucceeded = true;
        //     } catch {
        //         lastAdminCallSucceeded = false;
        //     }
        //     lastAdminCaller = msg.sender;
    }

    /// @notice Helper: explicit admin-acting variant so we can prove the privileged
    /// path is reachable from the right caller. Not part of the access-control violation
    /// surface — used in Setup soak.
    function helper_adminAction(uint256 arg) external actorAdmin {
        // TODO(protocol):
        //     vault.pause();
    }

    // (lastAdminCallSucceeded + lastAdminCaller live in BeforeAfter.sol so
    // Properties.sol can read them without inheriting TargetFunctions.)
}
