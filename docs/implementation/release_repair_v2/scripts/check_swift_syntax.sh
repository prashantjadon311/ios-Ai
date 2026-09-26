#!/usr/bin/env bash
# Linux source parser ONLY. This does NOT build/link a SwiftUI/SwiftData iOS app.
set -uo pipefail
root="${1:-.}"
root="$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)" || {
  printf 'ERROR: supply the real ios-Ai git checkout root as the first argument.\n' >&2
  exit 2
}
command -v swiftc >/dev/null || { echo 'ERROR: install the official Swift toolchain.' >&2; exit 2; }
[[ -d "$root/PersonalAssistant.swiftpm" ]] || { echo 'ERROR: missing PersonalAssistant.swiftpm' >&2; exit 2; }
cd "$root" || exit 2
printf 'PARSER_ONLY | HEAD=%s | SWIFT=%s\n' "$(git rev-parse HEAD)" "$(swiftc --version | head -1)"
count=0
failed=0
while IFS= read -r -d '' f; do
  ((count+=1))
  if ! output="$(swiftc -frontend -parse "$f" 2>&1)"; then
    ((failed+=1))
    printf '\nERROR %s\n%s\n' "${f#./}" "$output" >&2
  fi
done < <(find ./PersonalAssistant.swiftpm -type f -name '*.swift' \
  ! -path '*/.build/*' -print0 | sort -z)
printf '\nPARSER_ONLY files=%d failures=%d\n' "$count" "$failed"
[[ "$count" -gt 0 && "$failed" -eq 0 ]]
