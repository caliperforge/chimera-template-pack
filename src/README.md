# src/ — target protocol contracts go here

This directory is empty in the template. The forking step (USAGE.md §2) populates it
with the target protocol's contracts:

- **Pattern A (preferred): git submodule.**
  ```sh
  git submodule add https://github.com/<target>/<repo>.git src/<protocol>
  git -C src/<protocol> checkout <contest-commit-sha>
  ```

- **Pattern B: vendored copy.**
  ```sh
  cp -r <contest-snapshot>/src/* src/
  ```

The Setup, TargetFunctions, and Properties files in `test/recon/` import from this
directory.

The template's CI workflow detects an empty `src/` (no `.sol` files outside of this
README) and degrades the campaign step to a smoke-only run so the green badge stays
honest until the fork wires real contracts.
