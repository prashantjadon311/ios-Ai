# ios-Ai — Double Audit, Exact Code Blueprint, Gemini One-Go Handoff

Pinned baseline: fourth commit `b34423ec90f705f129d567300a3cbc534f7559e7` (2026-09-26). GitHub Actions run 36218871425 failed at 42/46 static checks and skipped both chat static script and Mac build. Prior Gemini's text report is not compiler/device evidence. No source code in your repository has been changed by producing these docs.

## Put these five deliverables plus README here

```text
ios-Ai/
  docs/
    spec/v3/                       # Existing canonical specs: preserve unchanged
    implementation/
      final_execution/             # NEW folder
        README_START_HERE.md
        00_DOUBLE_PASS_ENGINEERING_AUDIT.md
        01_FILE_BY_FILE_CODE_AND_ALGORITHM_BLUEPRINT.md
        02_GEMINI_ONE_GO_IMPLEMENTATION_PROMPT.md
        03_IPAD_IMPORT_AND_ACCEPTANCE_GUIDE.md
        04_PINNED_CODE_REFERENCE_MAP.md
```

**Read order for Gemini:** `CLAUDE.md` → V3 authority docs (`00`,`12`,`13`,`14`,`15`,`02`) → double-pass audit `00` → full file-by-file engineering blueprint `01` → implementation campaign `02` → device guide `03`. The 266-entry V3 file contract index and per-file guide remain authoritative references when editing each subsystem. If actual local code already fixes a published defect, verify and preserve that fix.

**Important distinctions:** The first audit scanned the complete 187-file published Swift tree for structural risks and reviewed changed files; the second independently cross-referenced critical contracts, user journeys, privacy/security invariants and actual CI logs. Neither can substitute for actual iOS compilation or tests; Gemini must run **two fresh audits on the new final code** before calling it completed. An Apple Mac build and the physical user's iPad are separate gates. The intended result after Gemini alone, if its Mac CI/test access works, is a real compiled candidate with `AWAITING_USER_IPAD`, not a fabricated claim of physical device success.

## Short launcher (paste into Gemini with existing workspace open)

```text
You are taking over the EXISTING ios-Ai V1 implementation. This is a direct code-execution campaign, not a new project or a planning exercise.

FIRST: Verify actual local Git HEAD/status against audited b34423ec and preserve newer work. Read CLAUDE.md and canonical V3 authority docs. Read completely the five numbered documents inside docs/implementation/final_execution/, especially 01_FILE_BY_FILE_CODE_AND_ALGORITHM_BLUEPRINT.md and 02_GEMINI_ONE_GO_IMPLEMENTATION_PROMPT.md. Execute the complete master prompt exactly.

Begin at the verified first unfinished source repair; fix coordinated compiler contracts before more features, complete genuine streaming chat and durable/policy-safe tools, all mandatory V1 screens/tasks/voice/memory/media, independent real Swift tests, Mac CI and TWO post-code independent audits. Do not claim a test or iPad run without real evidence. If Apple hardware is unavailable, deliver real compiled and test-verified source plus exact iPad diagnostic handoff, then continue when device logs arrive. Maintain durable checkpoints on quota exhaustion. Start editing actual code now.
```

**Before sensitive personal use:** demand a green **real Mac compile**, executable security/functional tests and physical iPad confirmation. The current published fourth commit is appropriate only for no-key/no-personal-data diagnostic import.
