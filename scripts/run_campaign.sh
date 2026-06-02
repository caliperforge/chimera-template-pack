#!/usr/bin/env bash
# run_campaign.sh — convenience wrapper around `make echidna` / `make medusa`
# that also handles the post-run scorecard render.
#
# Usage:
#   ./scripts/run_campaign.sh echidna [INV-001-solvency]
#   ./scripts/run_campaign.sh medusa  [INV-001-solvency]
#   ./scripts/run_campaign.sh both
#
# Forks generally don't need to edit this — it dispatches to the Makefile.

set -euo pipefail

CAMPAIGN="${1:-echidna}"
INVARIANT="${2:-INV-001-solvency}"

case "$CAMPAIGN" in
  echidna|medusa)
    make "$CAMPAIGN" INVARIANT="$INVARIANT"
    ;;
  both)
    make echidna INVARIANT="$INVARIANT"
    make medusa INVARIANT="$INVARIANT"
    ;;
  *)
    echo "unknown campaign: $CAMPAIGN" >&2
    echo "usage: $0 <echidna|medusa|both> [INVARIANT]" >&2
    exit 2
    ;;
esac
