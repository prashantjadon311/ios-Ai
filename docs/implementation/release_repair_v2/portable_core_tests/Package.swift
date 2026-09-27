// swift-tools-version: 5.9
// Optional Linux-eligible tests against real copied production source.
// Run ../scripts/sync_portable_sources.py FROM THE USER'S ACTUAL CHECKOUT first.
import PackageDescription

let package = Package(
    name: "AppCorePortable",
    platforms: [
        .macOS(.v13)
    ],
    products: [.library(name: "AppCorePortable", targets: ["AppCorePortable"])],
    targets: [
        .target(
            name: "AppCorePortable",
            path: "Sources/AppCorePortable",
            swiftSettings: [.define("PORTABLE_CORE")]
        ),
        .testTarget(name: "AppCorePortableTests", dependencies: ["AppCorePortable"])
    ]
)
