# MIT carve-out — upstream-merge subset

This template repository is **Apache-2.0** by default. See [`LICENSE`](./LICENSE).

Per the CaliperForge build-to-win roadmap §1 (`agents/build_squad_lead/outbox/build_to_win_roadmap_2026-06-01.md`),
when a forked entry's scaffold is intended for **upstream merge** into a target protocol's
existing MIT-licensed codebase (as a `test/invariant/` directory or equivalent), the
scaffold's merged subset should be dual-licensed:

- **Standalone repo under `caliperforge/`** — Apache-2.0 (this file's default).
- **Upstream-merged subset** — MIT, to avoid the (real, frequent) maintainer pushback
  against accepting Apache-2.0 into a MIT codebase.

## When this applies

The carve-out applies only when **all** of the following hold:

1. The target protocol's primary repository ships under MIT (verify in their `LICENSE`).
2. The CaliperForge fork's owner intends to open a PR proposing upstream merge of the
   scaffold (not just publish a standalone artifact + cross-link).
3. The protocol maintainers have signaled (issue thread, public roadmap, or direct
   coordination) that they will consider merging contributed test infrastructure.

## How to apply the carve-out (in a fork)

In the forked contest-entry repo, add `LICENSE-MIT` alongside the Apache-2.0 `LICENSE`,
and document the dual-license shape in that fork's `README.md`:

```
## License

This scaffold is dual-licensed:
- **Apache-2.0** for use as a standalone artifact (this repository).
- **MIT** for the `test/invariant/` subtree, intended for upstream merge into
  <protocol-name>'s MIT-licensed codebase.

See `LICENSE` (Apache-2.0) and `LICENSE-MIT` (MIT).
```

If the upstream-merge intent does not apply, **delete this file and `LICENSE-MIT`** in the
fork — single-license Apache-2.0 is the default.

## Standard MIT text (for `LICENSE-MIT` in the fork, when carve-out applies)

```
MIT License

Copyright (c) 2026 Michael Moffett — CaliperForge

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
