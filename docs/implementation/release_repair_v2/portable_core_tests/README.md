# Optional real-source Linux Swift XCTest slice

From the ios-Ai checkout after copying this campaign folder into `docs/implementation/release_repair_v2/`:

```bash
python3 docs/implementation/release_repair_v2/scripts/sync_portable_sources.py .
swift test --package-path docs/implementation/release_repair_v2/portable_core_tests
```

The sync script copies **actual current production bytes** from `Identifiers.swift`, `TaskDefinition.swift`, `SSEDecoder.swift`, `TaskRecurrence.swift` and records SHA-256 hashes with the checkout HEAD. These sources import Foundation and are suitable for a narrow SwiftPM Linux build. XCTest includes **intentionally failing regression cases** for fifth-commit SSE frame-cap enforcement and weekly weekday recurrence; do not delete or weaken them to obtain a green check. The first test also checks UTF-8 fragmentation. Fix the production source before rerunning and resync the snapshot after every source edit.

A passing run compiles ONLY this four-file subset. It does not build any iPad UI, SwiftData, UIKit, AppleProductTypes, voice or security. These remain separate Apple test/build/device gates. Never commit generated `Sources/AppCorePortable/*.swift` or `SNAPSHOT_SHA256.json` as a source of truth; they are disposable test snapshots.
