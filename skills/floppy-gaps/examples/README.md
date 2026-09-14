# floppy-gaps examples

Reference material for `/floppy-gaps`. The compact `.gap.json` files are the
canonical shape the skill produces; the `.docx` beside each is what `gapdoc.py
build` renders from it.

| File | What it is |
|---|---|
| `seahub-dnatypewriter-metadata.nd.json` | A real aind-style metadata export — the kind of input `gapdoc.py seed` bootstraps a field inventory from. |
| `SeaHub_DNATypewriter.gap.json` / `.docx` | Full **placeholder-mode** analysis (built from a paper). 7 entities, 49 fields. Shows the Placeholder note, the recurrence framing in Detail cells, and the Cross-Dataset Gap column. |
| `CellScience_AICS.gap.json` / `.docx` | Full **full-mode** analysis. 8 entities, 48 fields. Shows the Classification note (six-way → five-way crosswalk) and a Required-field readiness note after the gap summary. |
| `source-deliverables/` | The original real deliverables these were distilled from: the Milestone 0 Report, the standalone SeaHub and AICS gap analyses (older 10-section form), the cross-dataset comparison, and the SeaHub meeting notes. |

## Try it

```bash
cd ..                                   # skills/floppy-gaps
python3 scripts/gapdoc.py seed  examples/seahub-dnatypewriter-metadata.nd.json -o /tmp/seed.json
python3 scripts/gapdoc.py build examples/SeaHub_DNATypewriter.gap.json
python3 scripts/gapdoc.py build examples/CellScience_AICS.gap.json
```

The `source-deliverables/` `.docx` files are heavy binaries kept for reference;
a lean clone can exclude them.
