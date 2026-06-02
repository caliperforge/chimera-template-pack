# USAGE — stamp out a contest entry in 6 steps

This template stamps out a CaliperForge contest-entry scaffold. The full cycle is ~2 days
of focused work versus the ~5-day ad-hoc baseline. The 6 steps below are the contract.

**Before you start:** Foundry, Echidna 2.2.5+, and Medusa 0.1.7+ must be on `$PATH`.

---

## Step 1 — Fork the template

```sh
# Pick a fork name that encodes the protocol + contest, e.g. chimera-morpho-cantina-2026q3
gh repo create caliperforge/chimera-<protocol>-<contest-slug> \
    --template caliperforge/chimera-template-pack \
    --public
git clone https://github.com/caliperforge/chimera-<protocol>-<contest-slug>
cd chimera-<protocol>-<contest-slug>
```

If `--template` is unavailable in your `gh` version, click **Use this template** on the
template repo's GitHub page.

## Step 2 — Wire the target protocol's contracts into `src/`

Two patterns, pick one. **Prefer git submodule** when the target ships its source publicly
and the contest scope cites a specific commit; **vendor** when the contest publishes a
zipped snapshot.

```sh
# Pattern A — git submodule (recommended)
git submodule add https://github.com/<target>/<repo>.git src/<protocol>
git -C src/<protocol> checkout <contest-commit-sha>

# Pattern B — vendored copy
cp -r ~/Downloads/<contest-snapshot>/src/* src/
```

Update `remappings.txt` to point at whatever import paths the target's contracts expect
(e.g. `@openzeppelin/=lib/openzeppelin-contracts/`).

## Step 3 — Edit the three `TODO(protocol)` blocks in `test/recon/`

Open each file, find the `TODO(protocol)` markers, and fill in the protocol-specific
binding. The seeded shape is intentional — keep the finding-class names (solvency,
monotonicity, access-control) unless the protocol has no surface for one.

- **`test/recon/Setup.sol`** — deploy the protocol's contracts, register actors, seed
  initial state.
- **`test/recon/TargetFunctions.sol`** — expose each public/external protocol function
  the fuzzer should call (wrap in `actor*` modifiers so Echidna/Medusa rotate callers).
- **`test/recon/Properties.sol`** — rename `property_solvency_INV001` etc. to
  protocol-specific names (e.g. `property_<protocol>_totalAssets_matches_balance`).
  Tag any AI-suggested invariants with the `// AI-SUGGESTED` source comment per the
  disclosure policy.

## Step 4 — Confirm the campaign builds locally

```sh
forge install         # forge-std + chimera
forge build           # must succeed before fuzzing
forge test --match-path test/recon/CryticToFoundry.sol    # forge-side sanity replay
make echidna          # short echidna campaign (default: 5min)
make medusa           # short medusa campaign (default: 5min)
make scorecard        # ANSI-strip campaign stdout → findings/<invariant>/scorecard.{json,md}
```

If any step fails, fix it locally before pushing — the bundled CI runs the same campaign
and a red badge is more embarrassing than a delayed push.

## Step 5 — Push and let CI write the public scorecards

```sh
git add .
git commit -m "Initial scaffold for <protocol> <contest>"
git push origin main
```

The bundled `.github/workflows/ci.yml` runs the campaigns on GitHub-hosted runners,
captures ANSI-stripped output into `findings/<invariant>/scorecard.{json,md}`, uploads
the raw output as a CI artifact, and on green commits the scorecards back to the branch.
The CI badge in the README is what reviewers and contest sponsors see — it is the public
proof.

## Step 6 — Hand the public repo URL to the target protocol

Per build-to-win roadmap §1
(`agents/build_squad_lead/outbox/build_to_win_roadmap_2026-06-01.md`), the artifact ships
**with a protocol hand-off within 48 hours of public push**. Two paths, pick whichever
fits the protocol's contribution norm:

- **Issue.**  Open an issue on the target protocol's main repo, link the
  `chimera-<protocol>-<contest-slug>` repo, summarize the seeded invariants and the
  reproduce-from-clone command. Calm professional register (Trail of Bits engineering-blog
  voice), not marketing.
- **PR.**  If the protocol is MIT-licensed and you're proposing upstream merge into
  `test/invariant/`, apply the MIT carve-out (`LICENSE-MIT-CARVEOUT.md`) to the
  merged subset and open the PR with the same body.

Then log the entry in `agents/build_squad_lead/proof_register.md` — that's the Axis-B /
Axis-C evidence row the Grant Team consumes regardless of contest placement.

---

## Done check

- [ ] CI badge green on `main`.
- [ ] `findings/<invariant>/scorecard.{json,md}` committed for each invariant.
- [ ] Protocol hand-off (issue or PR) link in the fork's `README.md`.
- [ ] `proof_register.md` row added.

If any box is unchecked, the entry is incomplete regardless of contest result.
