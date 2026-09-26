# 06. What Gemini can actually build in VS Code: Ubuntu, Mac, GitHub Actions and iPad

**Hard rule:** a VS Code extension is not an iOS SDK. On Ubuntu it cannot type-check, link, run or simulate Apple SwiftUI/SwiftData/UIKit/AVFoundation/iOS app code as an iPad application. It CAN edit Swift, provide SourceKit-LSP diagnostics for eligible projects, parse arbitrary Swift grammar with `swiftc -frontend -parse`, build pure Foundation-compatible SwiftPM packages, run their XCTest tests and orchestrate an **authorized actual Mac build** via Remote SSH or GitHub Actions. See [Swift.org official extension setup](https://www.swift.org/documentation/articles/getting-started-with-vscode-swift.html), [the official extension source](https://github.com/swiftlang/vscode-swift) and [Apple's Playgrounds/Xcode Cloud limitations](https://developer.apple.com/documentation/xcode/building-swift-packages-or-swift-playground-app-projects-with-xcode-cloud).

## Track 1: Ubuntu + VS Code + official Swift (NOW, on your actual laptop)

1. Open the **real `ios-Ai` repository root** in your existing VS Code / Antigravity project, not `PersonalAssistant.swiftpm` as a separate Git repo. Open Terminal in VS Code.
2. Check tools; do not overwrite an existing working Swift installation merely to match a sample version:

   ```bash
   pwd
   git rev-parse --show-toplevel
   git rev-parse HEAD
   git status --short
   swift --version
   which swiftc
   code --version
   ```

3. If Swift is absent, install through the [official Ubuntu installer](https://www.swift.org/install/linux/ubuntu/) (Swiftly is the official version manager); use your actual distro's documented commands. Verify `swift --version` and `sourcekit-lsp --version` where supported. Do not `sudo curl | bash` an arbitrary unofficial installer.
4. Install the **official Swift VS Code extension** maintained by the Swift team (publisher `swiftlang`, extension identifier `swiftlang.swift-vscode`):

   ```bash
   code --install-extension swiftlang.swift-vscode
   ```

   Alternatively VS Code → Extensions (`Ctrl+Shift+X`) → search **Swift** → verify the **Swift team** publisher → Install. If the deprecated old Swift extension is also installed, disable the legacy extension to avoid competing language servers. The official extension offers completions, source navigation, package/debug tasks and XCTest/Swift Testing support **for supported SwiftPM projects**. Apple imports in this app will still be unresolved under Linux. Don't waste engineering cycles fixing them through fake Linux stubs.
5. From this ZIP, copy `vscode_templates/extensions.json` to the repository `.vscode/extensions.json` and `vscode_templates/tasks.json` to `.vscode/tasks.json` **only after checking existing workspace settings and merging**. No auto overwrite. `ms-vscode-remote.remote-ssh` is an optional, Microsoft-published companion extension **only if you have a real Mac**.
6. Run `Terminal → Run Task → iOS Swift syntax parse on Linux (NOT iOS build)` or directly:

   ```bash
   bash docs/implementation/release_repair_v2/scripts/check_swift_syntax.sh .
   ```

   This parses each of the actual 187 Swift files. Syntax errors, unterminated strings and malformed interpolation are genuine failures; this is NOT Swift typechecking, link or resource validation. Record actual tested SHA, failing filename/line, command and exit code. Re-run after source edits.
7. Sync portable **actual production** source and run compiled Linux XCTest:

   ```bash
   python3 docs/implementation/release_repair_v2/scripts/sync_portable_sources.py .
   swift test --package-path docs/implementation/release_repair_v2/portable_core_tests
   ```

   The snapshot copies `Identifiers.swift`, `TaskDefinition.swift`, `SSEDecoder.swift` and `TaskRecurrence.swift` verbatim and records SHA-256 per file. Only Foundation-only functionality is eligible. The harness intentionally includes regression tests which should **fail on the known fifth-commit** SSE unbounded-undelimited-line and weekly weekday behavior; fix the REAL source, resync and rerun rather than deleting tests. Do not call this an AppModule build.
8. `swift build` **inside the original `PersonalAssistant.swiftpm` on Linux is expected to fail** because its manifest imports `AppleProductTypes` and its source needs unavailable Apple SDK frameworks. Do NOT add unofficial `AppleProductTypes` stubs or strip SwiftUI imports to manufacture a Linux-green app. Do not label VS Code's red Apple imports as new production bugs unless an actual Mac compiler confirms them.

## Track 2: An available Mac through VS Code Remote SSH (only if one actually exists)

1. Install the official Microsoft **Remote - SSH** extension `ms-vscode-remote.remote-ssh`, connect to a real SSH-enabled Mac under your control and open **the same Git checkout/revision** there. Do not assume the Ubuntu workspace changes magically synchronize. Push an explicitly authorized repair branch and check it out on the Mac, or use an approved secure transfer.
2. In the remote VS Code terminal on macOS:

   ```bash
   git rev-parse HEAD
   git status --porcelain=v1
   xcode-select -p
   xcodebuild -version
   xcodebuild -showsdks
   xcrun --sdk iphonesimulator --show-sdk-version
   cd PersonalAssistant.swiftpm
   xcodebuild -list
   ```

3. Validate the actual generated package and scheme from the output. If the package appears as a buildable Xcode scheme, run the **real discovered scheme** with `xcodebuild -scheme <REAL_SCHEME> -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`. If the package is not directly buildable as a standalone Xcode scheme, create a reproducible minimal Xcode host/wrapper that compiles the exact existing `AppModule` source graph and resources; preserve the original `.swiftpm`, do not substitute toy code. Apple documents that Xcode Cloud cannot build a standalone Swift Playgrounds app without an Xcode project wrapper.
4. The original `.swiftpm` and the final artifact MUST share the tested commit SHA and effective package/resource declarations. The wrapper build is a complementary integration check, **not proof of actual iPad import**. For a real simulator run and UI tests, the Mac requires a compatible installed iOS simulator runtime; a `generic/platform=iOS Simulator` build does not itself launch the app.

## Track 3: No Mac? Use authorized GitHub Actions macOS as the real compiler loop

You **do not need to buy a Mac** to obtain genuine compiler diagnostics if your GitHub repository supports eligible macOS Actions minutes. However the source must reach GitHub: a local unpushed VS Code edit cannot be compiled by an Actions job using an older remote SHA. Get explicit authorization before Gemini pushes.

1. Inspect current CI and published failure: [fifth-commit run 36222465812](https://github.com/prashantjadon311/ios-Ai/actions/runs/36222465812). The prior Apple job failed on localized resources before target typechecking. It is not a list of all compiler errors.
2. Review this package's `vscode_templates/ios-real-compiler-probe.yml`. Install it as `.github/workflows/ios-real-compiler-probe.yml` **only after reconciling the existing workflow**; it is a discovery/build **template**, not a claimed pre-executed pipeline. Its Apple build job runs independently of the Linux Python job, selects an installed Xcode 26 toolchain when available, checks the original manifest and locale/avatar resources; when that manifest is invalid, creates a disposable **diagnostic-only shadow copy** with `defaultLocalization` to reveal the NEXT real compiler errors while keeping the shipping gate RED; when the original is repaired, builds the actual package; logs `xcodebuild -list` and the actual compiler output and uploads `.xcresult`+raw logs on failures. If scheme discovery fails, debug the package/wrapper rather than running unrelated tests. A green diagnostic shadow compile is **never** shipping PASS.
3. Work on an explicit `repair/...` branch, preserve local changes and review `git diff --check`. After approved push, trigger CI via browser **Actions → ios-real-compiler-probe → Run workflow** or with the official GitHub CLI `gh workflow run ios-real-compiler-probe.yml --ref YOUR_REPAIR_BRANCH` if installed/authenticated. Fetch raw failure logs and fix ONE coherent dependency slice at a time.
4. On a red run, record the exact Git SHA and compiler output. On green, confirm that the **actual AppModule and packaged resources** built, not merely package dependency resolution. Then implement/run executable Swift tests and (where supported) simulator integration before iPad transfer.

**If Actions macOS minutes/quota or push permission is missing**, label `BLOCKED_EXTERNAL_APPLE_TOOLCHAIN` and continue only safe independent work. Do not claim Apple compilation, invent a Mac endpoint or ask the Swift extension to provide Apple's proprietary SDK.

## Track 4: Physical iPad Swift Playgrounds, the only device PASS

Once a candidate **genuinely builds using an Apple SDK** and required compiled security tests pass, transfer the exact versioned `PersonalAssistant.swiftpm` directory to Files on the iPad (ZIP extraction is okay if the directory/package is preserved); open it with compatible Swift Playgrounds and tap **Run App**. If the `.swiftpm` is rejected or the generated manifest reverts localization, record the iPad's **first compiler/import error** and the exact package hash, then correct the export/candidate. Do not pretend a Mac CI wrapper pass is equivalent to successful physical import. With a no-key diagnostic build, initial iPad import can be attempted early solely to collect diagnostics; never enter your personal BYOK keys or private data in a known-unsafe build.

Device acceptance order: actual onboarding, five screens, Maya/Saar and bundled avatars, saved settings/relaunch, disposable BYOK streaming two turns, explicit Private Only zero outbound, voice mic/speech permissions and stop/restart, local task 5-minute actual notification, read-only search/memory, owner isolation and only **after** durable authorization tests, disposable calendar/test tool. Capture screenshots or redacted logs and first failure without exposing API keys.

## One-line workstation truth for Gemini to preserve in every checkpoint

`UBUNTU_SWIFT_PARSE: PASS/FAIL; PORTABLE_REAL_SOURCE_TESTS: PASS/FAIL/BLOCKED; MAC_APP_BUILD: PASS/FAIL/NOT_RUN; MAC_EXECUTABLE_SECURITY_TESTS: PASS/FAIL/NOT_RUN; IPAD_IMPORT_RUN: PASS/FAIL/NOT_RUN; SOURCE_SHA: ...` **No substitution between these fields.**
