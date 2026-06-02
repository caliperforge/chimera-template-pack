#!/usr/bin/env bash
# capture_scorecard.sh — render scorecard.{json,md} from a campaign stdout dump.
#
# Mirrors the cf-invariants-anchor scorecard shape: a JSON file with summary
# stats + a counterexamples array, and a markdown file with the same data
# formatted for the README badge readers. ANSI escape sequences are stripped
# from the markdown raw-output block so the committed file is reviewable.
#
# Usage:
#   ./scripts/capture_scorecard.sh \
#       --campaign echidna \
#       --invariant INV-001-solvency \
#       --input .campaign-out/echidna.out \
#       --out-dir findings/INV-001-solvency

set -euo pipefail

CAMPAIGN=""
INVARIANT=""
INPUT=""
OUT_DIR=""

while [ $# -gt 0 ]; do
  case "$1" in
    --campaign) CAMPAIGN="$2"; shift 2 ;;
    --invariant) INVARIANT="$2"; shift 2 ;;
    --input) INPUT="$2"; shift 2 ;;
    --out-dir) OUT_DIR="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$CAMPAIGN" ] || [ -z "$INVARIANT" ] || [ -z "$INPUT" ] || [ -z "$OUT_DIR" ]; then
  echo "usage: $0 --campaign <echidna|medusa> --invariant <name> --input <path> --out-dir <dir>" >&2
  exit 2
fi

if [ ! -f "$INPUT" ]; then
  echo "input not found: $INPUT" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Strip ANSI sequences for the committed artifact.
STRIPPED="$(mktemp)"
trap 'rm -f "$STRIPPED"' EXIT
# shellcheck disable=SC2016
sed -E 's/\x1B\[[0-9;]*[A-Za-z]//g; s/\x1B\][^\x07]*\x07//g' "$INPUT" > "$STRIPPED"

# Heuristic detection — both echidna and medusa report violations distinctly,
# but a generic regex catches the common surface.
VIOLATED=0
if grep -E -i -q 'FAIL|VIOLATION|FUZZ_FINDING|failed!' "$STRIPPED"; then
  VIOLATED=1
fi

# Counterexample text — the lines surrounding the first violation marker.
COUNTEREX_FILE="$(mktemp)"
trap 'rm -f "$STRIPPED" "$COUNTEREX_FILE"' EXIT
if [ "$VIOLATED" -eq 1 ]; then
  grep -E -i -A 30 'FAIL|VIOLATION|FUZZ_FINDING|failed!' "$STRIPPED" \
    | head -80 > "$COUNTEREX_FILE" || true
fi

# Timestamp + tool versions (best-effort; CI overrides via env).
TIMESTAMP="${SOURCE_DATE_EPOCH:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"
if [ "${SOURCE_DATE_EPOCH:-}" != "" ]; then
  TIMESTAMP="$(date -u -r "$SOURCE_DATE_EPOCH" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u +%Y-%m-%dT%H:%M:%SZ)"
fi
CAMPAIGN_VERSION="$($CAMPAIGN --version 2>/dev/null | head -1 || echo unknown)"

# --- scorecard.json -----------------------------------------------------------
{
  printf '{\n'
  printf '  "invariant": "%s",\n' "$INVARIANT"
  printf '  "campaign": "%s",\n' "$CAMPAIGN"
  printf '  "campaign_version": "%s",\n' "$CAMPAIGN_VERSION"
  printf '  "captured_at": "%s",\n' "$TIMESTAMP"
  printf '  "invariants_total": 3,\n'
  printf '  "invariants_violated": %d,\n' "$VIOLATED"
  printf '  "ai_suggestions_included": 0,\n'
  printf '  "counterexamples": '
  if [ "$VIOLATED" -eq 1 ]; then
    printf '[{ "invariant_name": "%s", "raw": ' "$INVARIANT"
    # JSON-escape the counterexample text.
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))' < "$COUNTEREX_FILE"
    printf ' }]\n'
  else
    printf '[]\n'
  fi
  printf '}\n'
} > "$OUT_DIR/scorecard.json"

# --- scorecard.md -------------------------------------------------------------
{
  echo "# chimera-template-pack scorecard"
  echo
  echo "- Invariant: \`$INVARIANT\`"
  echo "- Campaign: \`$CAMPAIGN\` ($CAMPAIGN_VERSION)"
  echo "- Captured at: $TIMESTAMP"
  echo "- Invariants total: **3**"
  echo "- Invariants violated: **$VIOLATED**"
  echo "- AI-suggested invariants in this run: **0**"
  echo
  if [ "$VIOLATED" -eq 1 ]; then
    echo "## Counterexample"
    echo
    echo '```'
    cat "$COUNTEREX_FILE"
    echo '```'
    echo
  fi
  echo "## Raw output (ANSI-stripped)"
  echo
  echo '```'
  cat "$STRIPPED"
  echo '```'
  echo
  echo "---"
  echo
  echo "chimera-template-pack — Apache-2.0. Operated by Michael Moffett — michael@caliperforge.com — team@caliperforge.com."
} > "$OUT_DIR/scorecard.md"

echo "scorecard written: $OUT_DIR/scorecard.{json,md}"
