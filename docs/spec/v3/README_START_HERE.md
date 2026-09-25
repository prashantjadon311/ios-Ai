# Personal Assistant: V3 final implementation handoff
**Intended executor:** Claude Sonnet in Antigravity / VS Code. **Package type:** audited design, exact implementation instructions, manifest and tests; it is NOT the coded iOS app and has NOT been device-tested.

## Start here
1. Extract the entire archive into an Antigravity workspace and keep its directory intact.
2. Paste `06_SONNET_ANTIGRAVITY_MASTER_PROMPT.md` as the implementation instruction.
3. Sonnet must read the authoritative V3 documents 00, 12, 13, 14 and 15 first, then canonical contracts 02 and core methods 11, then 16 file index and V2 detailed 04 reference. Use tree 07 and manifest 08 as the 266-path canonical ledger.
4. W00 obtains the real blank exported iPad `.swiftpm` template. If unavailable, portable source development continues, while direct Playground import remains BLOCKED until that artifact exists.
5. Five independent document audit passes are recorded in 18. PASS there means *this handoff's stated structural checks*, **not** source compilation, provider integration, device acceptance or independent third-party peer review.

## What is inside
- `00`: audit findings and conflict precedence.
- `01`–`05`, `07`–`09`, `11`: retained checked V2 execution, type contracts, algorithms, full 266-item per-file recipes, tests, tree, manifest and integration patterns.
- `06`: **replaced** V3 master execution prompt.
- `12`: frozen corrected architecture/scope.
- `13`: exact gate sequencing and 18 supplemental acceptance tests.
- `14`: detailed failure-sensitive algorithms, idempotency, SSE parsing, context and recovery.
- `15`: full data egress, client security, future multi-user/Firestore/Drive boundary.
- `16`: canonical 266-file cross-reference index with unique paths and category-specific contract links.
- `17`: SDK/platform verification matrix and what cannot be claimed without device evidence.
- `18`: reproducible five-pass static audit with measured results and remaining blockers.
- `19`: SHA256 package-file hashes, generated last.

**Never paste personal API keys in Sonnet chat, project source or commit history.** Device-only Keychain items do not automatically synchronize to another device. iPhone installation requires its own distribution path. Do not promise autonomous iOS background jobs when only notifications exist.
