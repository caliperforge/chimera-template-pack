// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.28;

import {CryticAsserts} from "chimera/CryticAsserts.sol";
import {TargetFunctions} from "./TargetFunctions.sol";
import {Properties} from "./Properties.sol";

/// @notice CryticTester — the single contract Echidna and Medusa deploy.
///
/// Composes TargetFunctions (callable surface) + Properties (invariants) +
/// CryticAsserts (concrete implementation of the Asserts abstract surface from
/// BaseTargetFunctions). Both fuzzers point at this contract via echidna.yaml
/// + medusa.json.
contract CryticTester is TargetFunctions, Properties, CryticAsserts {
    constructor() payable {
        setup();
    }
}
