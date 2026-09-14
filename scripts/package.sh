#!/usr/bin/env bash
# Build floppy.plugin. Run from anywhere: bash scripts/package.sh [outdir]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/..}"
ZIP=/tmp/floppy.plugin

# macOS screenshot filenames carry U+202F (narrow no-break space), which some
# zip readers reject. Normalise before packaging, not after.
python3 - "$ROOT" <<'PY'
import pathlib, sys, unicodedata
n = 0
for p in sorted(pathlib.Path(sys.argv[1], "resources").rglob("*")):
    if not p.is_file():
        continue
    clean = "".join(" " if unicodedata.category(c) == "Zs" else c for c in p.name)
    clean = "".join(c if 32 <= ord(c) < 127 else "_" for c in clean)
    if clean != p.name:
        p.rename(p.with_name(clean)); n += 1
if n:
    print(f"  normalised {n} filename(s)")
PY

python3 "$ROOT/scripts/refresh.py" schema || true

rm -f "$ZIP"
cd "$ROOT"
# .git of any bundled clone is the bulk of the size and buys nothing at answer
# time; the pinned commit lives in <name>.GITREF.txt instead.
zip -qrX "$ZIP" . \
  -x '*.DS_Store' '*__pycache__*' '*._*' \
     'resources/schema/*/.git/*' \
     'resources/schema/single-cell-curation/cellxgene_schema_cli/cellxgene_schema/ontology_files/*' \
     'resources/schema/single-cell-curation/cellxgene_schema_cli/cellxgene_schema/gencode_files/*' \
     'resources/schema/single-cell-curation/cellxgene_schema_cli/tests/*' \
     'resources/schema/single-cell-curation/notebooks/*'

python3 - "$ZIP" <<'PY'
import sys, zipfile
n = zipfile.ZipFile(sys.argv[1]).namelist()
bad = [x for x in n
       if any(ord(c) < 32 or ord(c) > 126 for c in x) or any(c in ':*?"<>|\\' for c in x)]
assert ".claude-plugin/plugin.json" in n, "plugin.json not at zip root"
assert not bad, f"unsafe filenames: {bad[:3]}"
assert sum(1 for x in n if x.endswith("SKILL.md")) == 2, "expected 2 skills"
print(f"  {len(n)} entries, plugin.json at root, 2 skills, 0 unsafe names")
PY

cp "$ZIP" "$OUT/floppy.plugin"
echo "wrote $OUT/floppy.plugin ($(du -h "$ZIP" | cut -f1))"
