# chimera-template-pack

[![ci](https://github.com/caliperforge/chimera-template-pack/actions/workflows/ci.yml/badge.svg)](https://github.com/caliperforge/chimera-template-pack/actions/workflows/ci.yml)

**Reusable Foundry + Recon Chimera scaffold for CaliperForge contest entries.**

This template stamps out the standard CaliperForge public-OSS artifact attached to every
Cantina / Code4rena / equivalent contest entry: a forkable Foundry project pre-wired for
[Recon's Chimera](https://github.com/Recon-Fuzz/create-chimera-app) stateful-fuzz pattern
(Echidna + Medusa), with three seeded protocol-specific invariants, a fuzz-campaign
runner, and a GitHub Actions CI job that runs the campaign and writes scorecards into
`findings/` on every push.

Derived from:
- [`Recon-Fuzz/create-chimera-app`](https://github.com/Recon-Fuzz/create-chimera-app) (the
  upstream pattern this template tracks).
- The CaliperForge scorecard convention used in
  [`cf-invariants-anchor`](https://github.com/caliperforge/cf-invariants-anchor) (ANSI-stripped
  captures committed to `findings/<invariant>/scorecard.{json,md}`).

This is a **template**, not a project. Use the **Use this template** button on GitHub
(or `gh repo create --template`) to stamp out a contest entry. The first action in a
forked repo is to follow [`USAGE.md`](./USAGE.md).

---

## What the scaffold tests

The pattern: **fork a target protocol's contracts into `src/`, then run a stateful fuzz
campaign that hammers the protocol's public surface looking for invariant violations.**
Three seed invariants ship in `test/recon/Properties.sol`, each marked with a
`TODO(protocol)` comment indicating the protocol-specific binding the fork-owner must
supply:

1. **`INV-001 — solvency / token conservation.**  Sum of user-side balances equals the
   contract-side accounting. Common failure class: bookkeeping drift on withdraw / claim
   paths.
2. **`INV-002 — monotonic share price (or equivalent index).**  Under deposit-only or
   non-rebasing conditions, the share/index price never decreases. Common failure class:
   donation attacks, share-price manipulation on first deposit.
3. **`INV-003 — access-control restriction.**  Privileged functions revert when called by
   non-privileged actors. Common failure class: missing modifier on admin / pause / rescue
   functions.

Forks are expected to **rename, replace, or extend** these — they are seeds shaped after
common Cantina/Code4rena finding classes, not protocol-specific assertions. The
`TODO(protocol)` markers in source are the explicit edit points.

The findings directory ships with one example pre-computed scorecard
(`findings/INV-001-solvency/scorecard.expected.{json,md}`) showing the shape CI captures
into `findings/<invariant>/scorecard.{json,md}` on every push.

## Reproduce from a fresh clone

```sh
git clone https://github.com/caliperforge/chimera-template-pack.git
cd chimera-template-pack

# 1. Install Foundry (https://book.getfoundry.sh/getting-started/installation).
curl -L https://foundry.paradigm.xyz | bash && foundryup

# 2. Install Echidna + Medusa.
#    Echidna:  https://github.com/crytic/echidna/releases
#    Medusa:   https://github.com/crytic/medusa/releases

# 3. Install forge deps (forge-std + recon-cyfrin/chimera).
forge install

# 4. Build.
forge build

# 5. Run the foundry-side sanity test (CryticToFoundry replays the campaign harness
#    under forge for fast local debug).
forge test --match-path test/recon/CryticToFoundry.sol

# 6. Run a short Echidna campaign + capture the scorecard.
make echidna

# 7. (Optional) Run a Medusa campaign.
make medusa
```

The bundled CI workflow does exactly steps 3–6 on every push — green badge = clean run on
the as-shipped scaffold.

## Pinned toolchain

These versions are the contract that CI builds against. Forks should bump in lockstep,
not silently drift.

| Tool | Pinned | Why |
|------|--------|-----|
| Foundry | `nightly` (CI uses `foundry-rs/foundry-toolchain@v1`, latest nightly on each run) | Recon's create-chimera-app tracks Foundry nightly; pinning further down risks divergence from the upstream pattern. |
| Solidity | `0.8.28` (declared in `foundry.toml`) | Recent stable; ABI-compatible with most current protocol targets. Forks override this if the target protocol pins a specific Solidity version. |
| `forge-std` | `v1.9.4` | Stable forge std-lib. |
| `chimera` ([Recon-Fuzz/chimera](https://github.com/Recon-Fuzz/chimera)) | `main` (the upstream lib does not tag releases; CI re-installs on every run) | Tracks Recon's harness wrapper. |
| Echidna | `2.2.5` | Crytic's stable line as of 2026-06. |
| Medusa | `0.1.7` | Crytic's stable line as of 2026-06. |

See [`foundry.toml`](./foundry.toml), [`Makefile`](./Makefile), and
[`.github/workflows/ci.yml`](./.github/workflows/ci.yml) for the binding references.

## Layout

```
chimera-template-pack/
├── foundry.toml                  # solc / remappings / fuzz config
├── remappings.txt                # explicit remappings (echidna + medusa read these)
├── echidna.yaml                  # echidna campaign config
├── medusa.json                   # medusa campaign config
├── Makefile                      # make echidna / make medusa / make scorecard
├── src/                          # TODO(protocol): drop target contracts here
├── lib/                          # forge deps (forge-std, chimera)
├── test/
│   └── recon/                    # Chimera-pattern harness
│       ├── Setup.sol             # TODO(protocol): wire deploys / actors
│       ├── TargetFunctions.sol   # TODO(protocol): expose protocol fns to fuzzer
│       ├── Properties.sol        # 3 seeded invariants — rename / extend
│       ├── BeforeAfter.sol       # snapshot helpers for monotonicity checks
│       └── CryticToFoundry.sol   # forge-runnable replay harness
├── findings/                     # CI writes scorecard.{json,md} per invariant
│   └── INV-001-solvency/         # example pre-computed expected scorecard
├── scripts/
│   ├── run_campaign.sh           # echidna / medusa runner + scorecard capture
│   └── capture_scorecard.sh      # ANSI-strip + scorecard.{json,md} renderer
├── prompts/
│   └── invariant_suggestion_v1.txt   # optional AI-suggestion prompt (mirrors cf-invariants)
├── docs/
│   └── ai-disclosure.md          # what AI does in this scaffold, how to disable
├── .github/workflows/ci.yml      # build + sample campaign + scorecard capture
├── LICENSE                       # Apache-2.0
├── LICENSE-MIT-CARVEOUT.md       # MIT note for upstream-merge subset
├── README.md                     # this file (forks edit)
└── USAGE.md                      # 6-step "stamp out a contest entry" checklist
```

## License

Apache-2.0. See [`LICENSE`](./LICENSE).

When a fork is intended for upstream merge into a target protocol's MIT-licensed
codebase, an MIT carve-out applies to the merged subset — see
[`LICENSE-MIT-CARVEOUT.md`](./LICENSE-MIT-CARVEOUT.md).

---

Built with AI assistance; AI-suggested invariants are tagged in source. Full policy at
[caliperforge.com/ai-disclosure](https://caliperforge.com/ai-disclosure). See
[`docs/ai-disclosure.md`](./docs/ai-disclosure.md) for in-repo detail.

chimera-template-pack is operated by Michael Moffett under the CaliperForge banner.
Contact: michael@caliperforge.com (founder), team@caliperforge.com (org).
