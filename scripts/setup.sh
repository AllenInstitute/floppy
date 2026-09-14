#!/usr/bin/env bash
# Clone the reference schemas. Run once after installing floppy from git.
# They are not committed: aind-data-schema is 106 MB and CELLxGENE is 509 MB,
# and neither belongs in a plugin repo.
set -euo pipefail
D="$(cd "$(dirname "$0")/.." && pwd)/resources/schema"
mkdir -p "$D" && cd "$D"

clone() {  # url dir pin
  [ -d "$2/.git" ] && { echo "  $2 present, skipping"; return; }
  echo "  cloning $2..."
  git clone --quiet --depth 1 "$1" "$2"
  [ -n "${3:-}" ] && git -C "$2" fetch --quiet --depth 1 origin "$3" && git -C "$2" checkout --quiet "$3"
}

# Pinned to the commits the references/ digests were written against. Bump them
# deliberately, then re-read the digests — a version bump can invalidate a cited
# field.
clone https://github.com/AllenNeuralDynamics/aind-data-schema.git   aind-data-schema        18114d7b1d849cef9ccda57f85d90153e08b4eae
clone https://github.com/AllenNeuralDynamics/aind-data-mcp.git      aind-data-mcp           c636990a2676edba5dffc7553728168e0627bd4b
clone https://github.com/chanzuckerberg/single-cell-curation.git    single-cell-curation    1cb494afd94cf5cd42dddf9d9a0f6ac98809bbd0

python3 "$D/../../scripts/refresh.py" schema
echo "done. try /floppy-ask"
