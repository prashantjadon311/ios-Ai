#!/usr/bin/env bash
# Swift-only, genuine original-source, temporary Foundation package; no Python or production edits.
set -euo pipefail
REPO="${1:-.}"
REPO="$(cd "$REPO" && pwd -P)"
SOURCE="$REPO/PersonalAssistant.swiftpm"
PKG="$REPO/docs/implementation/release_repair_v2/portable_core_tests"
if ! command -v swift >/dev/null 2>&1; then
    printf '%s\n' 'ERROR: Swift executable missing. No tests run.' >&2
    exit 2
fi
if [[ ! -f "$PKG/Package.swift" || ! -d "$PKG/Tests" ]]; then
    printf '%s\n' 'ERROR: Existing portable SwiftPM test package not found; no fallback mock tests.' >&2
    exit 3
fi
FILES=(
    'Domain/Identifiers.swift'
    'Domain/TaskDefinition.swift'
    'AI/Transport/SSEDecoder.swift'
    'Tasks/TaskRecurrence.swift'
    'Domain/Errors.swift'
    'Domain/PrivacyAndConsent.swift'
    'Domain/ProviderConfiguration.swift'
    'Security/PrivacyPolicyEngine.swift'
    'Domain/ApprovalRequest.swift'
    'Tools/ToolReceiptStore.swift'
    'Tools/ToolInvocationCoordinator.swift'
    'Security/SessionGuard.swift'
    'Security/ApprovalCoordinator.swift'
    'Security/KeychainVault.swift'
)
for file in "${FILES[@]}"; do
    [[ -f "$SOURCE/$file" ]] || { printf 'ERROR: Missing original source: %s\n' "$file" >&2; exit 4; }
done
TMP="$(mktemp -d)"
trap 'rm -rf -- "$TMP"' EXIT
mkdir -p "$TMP/Sources/AppCorePortable" "$TMP/Tests"
cp "$PKG/Package.swift" "$TMP/Package.swift"
cp -R "$PKG/Tests/." "$TMP/Tests/"
printf '%s\n' 'Foundation-only ORIGINAL source files copied into a throwaway test package:'
for file in "${FILES[@]}"; do
    cp "$SOURCE/$file" "$TMP/Sources/AppCorePortable/$(basename "$file")"
    printf ' - %s\n' "$file"
done
printf '\n%s\n' 'Running ACTUAL swift test; no app SwiftUI/SwiftData or AppleProductTypes compilation occurs.'
swift test --package-path "$TMP" --jobs 2
