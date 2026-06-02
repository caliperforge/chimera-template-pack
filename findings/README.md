# findings/

This directory is the contract surface between the campaign and the public artifact.
On every CI run (and every local `make scorecard`), `scripts/capture_scorecard.sh`
writes `scorecard.json` + `scorecard.md` into a per-invariant subdirectory:

```
findings/
├── INV-001-solvency/
│   ├── scorecard.expected.json    # authored reference (committed)
│   ├── scorecard.expected.md      # authored reference (committed)
│   ├── scorecard.json             # CI capture (committed by workflow on green)
│   └── scorecard.md               # CI capture (committed by workflow on green)
├── INV-002-shareprice-monotonic/
│   └── (same shape)
└── INV-003-access-control/
    └── (same shape)
```

The `.expected.{json,md}` siblings are the authored reference. The unsuffixed files are
the real captures. Reviewers diff one against the other to detect drift.

## Scorecard shape (matches cf-invariants-anchor convention)

`scorecard.json`:

```json
{
  "invariant": "INV-001-solvency",
  "campaign": "echidna",
  "campaign_version": "2.2.5",
  "captured_at": "2026-06-02T00:00:00Z",
  "invariants_total": 3,
  "invariants_violated": 0,
  "ai_suggestions_included": 0,
  "counterexamples": []
}
```

`scorecard.md`:

```
# chimera-template-pack scorecard

- Invariant: `INV-001-solvency`
- Campaign: `echidna` (2.2.5)
- Captured at: 2026-06-02T00:00:00Z
- Invariants total: **3**
- Invariants violated: **0**
- AI-suggested invariants in this run: **0**

## Raw output (ANSI-stripped)

```
<echidna stdout, ansi-stripped>
```
```

When a violation is found, the JSON gains a `counterexamples` entry with the failing
sequence text, and the markdown gets a `## Counterexample` section above the raw output.

## ANSI-stripping

Echidna and Medusa both colorize stdout by default. `capture_scorecard.sh` strips with
`sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g'` before writing the scorecard. This matches the
cf-invariants-anchor convention and keeps the committed file reviewable in plain text.
