#!/usr/bin/env python3
"""Audit this generated HANDOFF PACKET'S internal consistency only.
Does not claim app compilation or empirical correctness.
"""
from pathlib import Path
import json, re, sys, subprocess
from collections import Counter
ROOT=Path(__file__).resolve().parent.parent
EXPECTED=[
'README_START_HERE.md',
'00_SELF_AUDIT_AND_FAILURE_ROOT_CAUSES.md',
'01_FULL_REPOSITORY_ENGINEERING_AUDIT.md',
'02_COMPILER_FIRST_EXACT_CODE_REPAIR_BLUEPRINT.md',
'03_GEMINI_GATED_EXECUTION_CONTRACT.md',
'04_EXECUTABLE_TEST_MATRIX_AND_IPAD_GATES.md',
'05_EXACT_SWIFT_CODE_AND_CALLER_PATCHES.md',
'06_VSCODE_LINUX_MAC_CI_AND_IPAD.md'
]
def main():
 errors=[]
 text={}
 for name in EXPECTED:
  p=ROOT/name
  if not p.exists() or p.stat().st_size<400: errors.append('Missing/too short '+name)
  else:
   text[name]=p.read_text()
   if len(re.findall(r'^```',text[name],re.M))%2:errors.append('Unbalanced code fences: '+name)
 readme=text.get(EXPECTED[0],'')
 for name in EXPECTED:
  if name not in readme:errors.append('README lacks '+name)
 audit=text.get(EXPECTED[2],'')
 ids=re.findall(r'^\*\*([CATSVUM]\d\d)\s*·',audit,re.M)
 expected_counts={'C':11,'A':14,'S':16,'T':5,'V':3,'U':5,'M':4}
 cnt=Counter(x[0] for x in ids)
 if cnt!=expected_counts:errors.append('Finding inventory '+str(cnt))
 if len(ids)!=len(set(ids)):errors.append('Duplicate defect ids')
 for n in ('G0','G1','G2','G3','G4','G5'):
  if n not in text.get(EXPECTED[3],''):errors.append('Missing blueprint gate '+n)
  if n not in text.get(EXPECTED[4],''):errors.append('Missing prompt gate '+n)
 c=text.get(EXPECTED[6],'')
 for term in ['CODE-G0-01','CODE-G1-01','CODE-G2-01','CODE-G3-01','CODE-G4-01']:
  if term not in c:errors.append('Missing code section '+term)
 for s in ['"swiftlang.swift-vscode"','"ms-vscode-remote.remote-ssh"']:
  if s not in (ROOT/'vscode_templates/extensions.json').read_text():errors.append('Missing official extension '+s)
 for name in ['extensions.json','tasks.json']:
  try: json.loads((ROOT/'vscode_templates'/name).read_text())
  except Exception as e: errors.append('Invalid JSON '+name+str(e))
 scripts=['scripts/check_swift_syntax.sh','scripts/sync_portable_sources.py','portable_core_tests/Package.swift','portable_core_tests/Tests/AppCorePortableTests/ProductionSubsetTests.swift','vscode_templates/ios-real-compiler-probe.yml']
 for name in scripts:
  if not (ROOT/name).exists():errors.append('Missing tool '+name)
 if 'fatalError(' in c:errors.append('Reference code contains fatalError; remove even as example')
 for x in [ROOT/'portable_core_tests/Package.swift',ROOT/'portable_core_tests/Tests/AppCorePortableTests/ProductionSubsetTests.swift']:
  r=subprocess.run(['swiftc','-frontend','-parse',str(x)],capture_output=True,text=True)
  if r.returncode:errors.append('Swift syntax error in '+str(x)+': '+r.stderr[:300])
 print('HANDOFF_QA:', 'PASS' if not errors else 'FAIL', '| 8 MD | 58 defect IDs | 6 stage labels | copy-ready tools')
 print('DEFECT_TYPES:',dict(sorted(cnt.items())))
 for e in errors: print('ERROR:',e)
 return 1 if errors else 0
if __name__=='__main__':sys.exit(main())
