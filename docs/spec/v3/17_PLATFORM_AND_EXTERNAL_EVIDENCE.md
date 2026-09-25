# Platform facts, official documentation and exact W00 probes

| Topic | Supported by public reference | Required local proof | Status in this handoff |
|---|---|---|---|
| Swift Playgrounds app projects and packages | https://developer.apple.com/documentation/swift-playgrounds ; https://developer.apple.com/documentation/swift-playgrounds/add-a-swift-package | exported actual blank `.swiftpm`, target/resource tree, imports, run | PUBLIC DOC VERIFIED; REAL TEMPLATE NOT PROVIDED |
| Protected capabilities | https://developer.apple.com/documentation/swift-playgrounds/project-capabilities | inspect App Settings, permission strings, ask on first action, test deny/grant | PUBLIC DOC VERIFIED; DEVICE NOT_RUN |
| SwiftData schema and isolated actor | https://developer.apple.com/documentation/swiftdata/schema ; https://developer.apple.com/documentation/swiftdata/modelactor | Xcode Swift 6 compile, versioned migration fixture and no cross-actor @Model | PUBLIC DOC VERIFIED; CODE NOT_RUN |
| Apple Foundation Models | https://developer.apple.com/documentation/FoundationModels/ | compile availability and runtime model/hardware/locale, no unguarded import | PUBLIC DOC VERIFIED; DEVICE/SKD NOT_RUN |
| Continued processing | https://developer.apple.com/documentation/backgroundtasks/bgcontinuedprocessingtask | verify API availability on actual target and foreground user-start; termination recovery | PUBLIC DOC VERIFIED; DEVICE NOT_RUN |
| Xcode Cloud | https://developer.apple.com/documentation/xcode/building-swift-packages-or-swift-playground-app-projects-with-xcode-cloud | wrap Playground source in Xcode app project; do not claim standalone cloud support | PUBLIC DOC VERIFIED; BUILD NOT_RUN |
| Live provider catalog/cost | official provider docs at implementation time | model discovery, provider tool/vision/stream probe, actual BYOK credential | DYNAMIC; NOT TESTED |
| Speech locale quality | Apple Speech availability methods / installed assets | actual selected iPad and iPhone test in English/Hindi/Hinglish samples | DEVICE NOT_RUN |
| iPhone signed install | Apple provisioning/TestFlight/App Store rules for chosen method | actual iPhone installation and real network/microphone/notification smoke | NOT_RUN |

## W00 evidence packet expected from Sonnet
`source-template-tree.txt`, `template-manifest-original`, `device-model-and-iPadOS.txt`, `Playgrounds-version.txt`, `swift-and-Xcode-version.txt` if Mac, `capability-probe-report.md`, `feature-availability-swift.txt`, `actual-compiled-screenshots/` with private content redacted, `W00_RESULT.md` containing PASS/BLOCKED/NOT_RUN per item. Avoid attaching provisioning tokens/passwords or any API key.

## Compilation strategy when Sonnet uses VS Code on non-Mac
Pure protocol/domain algorithms may be compiled by available Swift toolchain and fixture tests run. Any SwiftData, SwiftUI, Speech, Apple FoundationModels, UserNotifications, App Intents, iOS Keychain or signed iPhone claims need Apple SDK/macOS or actual iPad Playgrounds. Use macOS agent/remote Mac if available; otherwise leave framework and device gates NOT_RUN. Do not convert source-only review to PASS. New SDK symbol names must be checked locally, never fabricated.
