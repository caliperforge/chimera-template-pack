# chimera-template-pack — campaign + scorecard runner
#
# `make echidna`  — run echidna campaign + capture scorecard
# `make medusa`   — run medusa campaign + capture scorecard
# `make foundry`  — run the forge-side replay harness (CryticToFoundry)
# `make scorecard` — re-render scorecards from the most recent capture
# `make clean`    — wipe corpus + capture dirs

.PHONY: install build foundry echidna medusa scorecard clean help

INVARIANT ?= INV-001-solvency
FINDINGS_DIR := findings/$(INVARIANT)
CAPTURE_DIR := .campaign-out

help:
	@echo "chimera-template-pack make targets:"
	@echo "  install     forge install deps"
	@echo "  build       forge build"
	@echo "  foundry     forge test --match-path test/recon/CryticToFoundry.sol"
	@echo "  echidna     echidna campaign (default INVARIANT=$(INVARIANT))"
	@echo "  medusa      medusa campaign (default INVARIANT=$(INVARIANT))"
	@echo "  scorecard   ANSI-strip + render scorecard.{json,md} into $(FINDINGS_DIR)/"
	@echo "  clean       wipe corpus + .campaign-out"

install:
	forge install --no-commit foundry-rs/forge-std@v1.9.4 || true
	forge install --no-commit Recon-Fuzz/chimera || true

build:
	forge build

foundry:
	forge test --match-path test/recon/CryticToFoundry.sol -vvv

echidna: build
	@mkdir -p $(CAPTURE_DIR)
	echidna . --contract CryticTester --config echidna.yaml \
		2>&1 | tee $(CAPTURE_DIR)/echidna.out
	$(MAKE) scorecard CAMPAIGN=echidna

medusa: build
	@mkdir -p $(CAPTURE_DIR)
	medusa fuzz --config medusa.json \
		2>&1 | tee $(CAPTURE_DIR)/medusa.out
	$(MAKE) scorecard CAMPAIGN=medusa

CAMPAIGN ?= echidna
scorecard:
	@mkdir -p $(FINDINGS_DIR)
	./scripts/capture_scorecard.sh \
		--campaign $(CAMPAIGN) \
		--invariant $(INVARIANT) \
		--input $(CAPTURE_DIR)/$(CAMPAIGN).out \
		--out-dir $(FINDINGS_DIR)

clean:
	rm -rf $(CAPTURE_DIR) echidna-corpus medusa-corpus crytic-export out cache
