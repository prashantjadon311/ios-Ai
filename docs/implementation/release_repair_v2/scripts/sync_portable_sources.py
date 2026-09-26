#!/usr/bin/env python3
"""Copy the user's REAL production Foundation-only Swift sources into portable XCTest.
No network and NO editing of production code. Run from anywhere inside repo.
This is a subset compile, not an iOS AppModule build.
"""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

PKG = Path(__file__).resolve().parent.parent / 'portable_core_tests'
FILES = [
    'Domain/Identifiers.swift',
    'Domain/TaskDefinition.swift',
    'AI/Transport/SSEDecoder.swift',
    'Tasks/TaskRecurrence.swift',
]

def main():
    given = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    repo = Path(subprocess.check_output(['git', '-C', str(given), 'rev-parse', '--show-toplevel'], text=True).strip())
    source_root = repo / 'PersonalAssistant.swiftpm'
    dest = PKG / 'Sources' / 'AppCorePortable'
    dest.mkdir(parents=True, exist_ok=True)
    evidence = {'head': subprocess.check_output(['git', '-C', str(repo), 'rev-parse', 'HEAD'], text=True).strip(), 'sources':{}}
    used = set()
    for relative in FILES:
        src = source_root / relative
        if not src.is_file():
            raise SystemExit(f'MISSING REQUIRED PRODUCTION SOURCE: {src}')
        target = dest / Path(relative).name
        if target.name in used:
            raise SystemExit(f'Duplicate source basename: {target.name}')
        used.add(target.name)
        data = src.read_bytes()
        target.write_bytes(data)
        evidence['sources'][relative] = hashlib.sha256(data).hexdigest()
    (PKG / 'SNAPSHOT_SHA256.json').write_text(json.dumps(evidence, indent=2)+'\n')
    print('PORTABLE-SNAPSHOT-ONLY; checked-out source HEAD:', evidence['head'])
    print('Copied',len(FILES),'actual Foundation-only source files; compare hashes before trusting results.')
    print('NEXT: swift test --package-path',PKG)
    print('DOES NOT COMPILE SwiftUI, SwiftData, AppleProductTypes OR THE SHIPPING APP.')

if __name__ == '__main__': main()
