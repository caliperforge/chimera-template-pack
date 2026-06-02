# AI disclosure — chimera-template-pack

This scaffold was built with AI assistance. The full CaliperForge AI-disclosure policy
lives at [caliperforge.com/ai-disclosure](https://caliperforge.com/ai-disclosure); this
file is the in-repo detail.

## What AI does in this scaffold (today)

The template itself ships **no live AI calls**. The structure, harness shape, seeded
invariant placeholders, and CI workflow were drafted with AI assistance under operator
review (Anthropic Claude, Sonnet / Opus tier), but the committed artifact runs
deterministically on every clone — no API keys, no model calls during a campaign.

## Where AI may enter in a fork

Forks of this template often have an AI-suggestion step during the invariant-authoring
phase (`test/recon/Properties.sol`). The convention:

- Invariants written by hand from a protocol-spec read carry no tag.
- Invariants suggested by an AI model carry an inline source comment of the form:
  ```solidity
  // AI-SUGGESTED: anthropic/claude-sonnet-4.6 2026-06-02
  function property_<protocol>_<name>() public view returns (bool) {
      // ...
  }
  ```
- The accompanying `findings/<invariant>/scorecard.json` records the count in
  `ai_suggestions_included`. When that count is non-zero, the scorecard markdown emits
  an AI-disclosure banner above the summary section (matching the cf-invariants-anchor
  convention).

This makes the AI footprint mechanically auditable: a reviewer can `grep -r
"AI-SUGGESTED" test/` and get the exact list.

## Audit log

Forks that use AI to draft invariants are expected to retain the conversation log (or a
sanitized excerpt) in a private operator note, **not** committed to the public repo.
The public commitment is the in-source tag + the scorecard count.

## How to disable AI involvement entirely in a fork

The template has no AI integration to disable — it's a pure scaffold. A fork that chooses
to author invariants without AI suggestion simply doesn't tag any property with
`AI-SUGGESTED`, and the scorecard count stays at zero. The disclosure banner stays
dormant.

## Contact

Disclosure questions: [michael@caliperforge.com](mailto:michael@caliperforge.com).
