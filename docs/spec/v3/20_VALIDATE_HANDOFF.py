#!/usr/bin/env python3
"""Five deterministic STATIC handoff audit passes, not application/device testing.
Run: python3 20_VALIDATE_HANDOFF.py
"""
from pathlib import Path
import csv, collections, hashlib, json, sys
p=Path(__file__).resolve().parent
read=lambda name:(p/name).read_text(encoding='utf8')
rows=list(csv.DictReader((p/'08_CANONICAL_MANIFEST.tsv').open(),delimiter='\t'))
idx=list(csv.DictReader((p/'16_FILE_CONTRACT_INDEX.tsv').open(),delimiter='\t'))
checks=[
('P1 manifest unique',len(rows)==266 and len({r['logical_path'] for r in rows})==266),
('P1 gate split',dict(collections.Counter(r['gate'] for r in rows))=={'V1':221,'COND':4,'NEXT':13,'TEST':28}),
('P1 tree present',(p/'07_CANONICAL_FILE_TREE.txt').is_file()),
('P2 contracts present',all(s in read('02_CANONICAL_CONTRACTS.md') for s in ('SessionToken','ToolReceipt','TaskRun','StoreModels.swift','SchemaV1.swift'))),
('P2 five-screen product+identities',all(s in read('12_FINAL_ENGINEERING_DECISIONS.md') for s in ('Dashboard','Tasks','History','Configuration','Settings','Maya','Saar'))),
('P2 index coverage',len(idx)==266 and {r['logical_path'] for r in idx}=={r['logical_path'] for r in rows}),
('P3 algorithms',all('B%02d'%i in read('14_CRITICAL_ALGORITHMS_AND_RECOVERY.md') for i in range(1,13))),
('P3 ledger and no ambiguous retry',all(s in read('14_CRITICAL_ALGORITHMS_AND_RECOVERY.md') for s in ('PREPARED','AMBIGUOUS','no automatic replay'))),
('P3 privacy and future backend',all(s in read('15_SECURITY_PRIVACY_BACKEND.md') for s in ('Keychain','Firestore','Google Drive','Private-only','BYOK'))),
('P4 fifteen gates',all('W%02d'%i in read('13_EXACT_EXECUTION_AND_ACCEPTANCE.md') for i in range(15))),
('P4 test definitions',all('T%03d'%i in read('05_TEST_AND_SECURITY_MATRIX.md') for i in range(1,29)) and all('S%03d'%i in read('13_EXACT_EXECUTION_AND_ACCEPTANCE.md') for i in range(1,19))),
('P4 test trace per file',all(r['required_test'] and r['authoritative_algorithm'] for r in idx)),
('P5 agent prompt and status',all(s in read('06_SONNET_ANTIGRAVITY_MASTER_PROMPT.md') for s in ('W00','PASS | FAIL | BLOCKED | NOT_RUN','privacy'))),
('P5 device limitations',all(s in read('17_PLATFORM_AND_EXTERNAL_EVIDENCE.md') for s in ('NOT_RUN','REAL TEMPLATE NOT PROVIDED','DEVICE NOT_RUN'))),
('P5 tree coverage',all(r['logical_path'] in read('07_CANONICAL_FILE_TREE.txt') or r['logical_path']=='PersonalAssistant.swiftpm/[generated app manifest]' for r in rows))]
hashes=json.loads(read('19_SHA256_MANIFEST.json'))['sha256_files']
# Validate all checksums only when manifest was generated last (as this packet was).
checks.append(('P5 checksums',all((p/n).is_file() and hashlib.sha256((p/n).read_bytes()).hexdigest()==h for n,h in hashes.items())))
for name,ok in checks:print(('PASS' if ok else 'FAIL')+' '+name)
print(f'STATIC AUDIT: {sum(ok for _,ok in checks)}/{len(checks)} PASS')
print('APP COMPILE: NOT_RUN; IPAD/IPHONE DEVICES: NOT_RUN; PROVIDER LIVE TESTS: NOT_RUN')
sys.exit(0 if all(ok for _,ok in checks) else 1)
