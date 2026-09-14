# floppy index — where every answer lives

Routing table. Find the row, open the file, answer. Paths are relative to the
plugin root unless marked `[user]`.

`resources/_text/` holds plain-text extractions of every .docx / .pdf / .pptx /
.xlsx in the corpus, named `<original path with __ separators>.txt`.
Each starts with a `# source:` line naming the original. Grep these, not the
binaries — binaries are slow and lossy. Originals under 3 MB are bundled
alongside at their real paths; larger ones are text-only (say so if asked for
the original).

## By question type

| The question is about | Go to |
|---|---|
| What is the BioData Registry? scope, north star, core features | `references/project-brief.md` |
| Milestones, dates, gate criteria, DDM process | `references/project-brief.md` §Milestones |
| A question about **another workstream's** work | `references/coverage.md` **first** — check whether the corpus documents it at all |
| Which workstream owns X? who is on it? | `references/project-brief.md` §Workstreams |
| An acronym or project-specific term | `references/glossary.md` |
| "Was this decided?" / "is this still open?" | `references/decisions-and-open-questions.md` |
| A known schema gap, any dataset | `references/known-gaps.md` |
| Use cases, personas, priorities, acceptance criteria | `references/use-cases.md` |
| An aind-data-schema field, class, enum, or validator | `references/aind-schema-map.md` → then the repo |
| How to write a gap analysis | `references/gap-analysis-house-style.md` |
| Build vs buy, cost, infra options | `resources/_text/…Architecture Decision Tracker.xlsx.txt` |

## Primary source documents

| Document | Text extraction | What it is authoritative for |
|---|---|---|
| BioData Registry Project Overview.docx | `…General__0. Documentation__BioData Registry Project Overview.docx.txt` | **Charter.** Scope, core features, all 6 workstream scopes, Milestones 0–6 with success criteria and metrics. Marked DRAFT v1. |
| Milestone 0 Report (Track C) | `…Workstream 2 …__Milestone 0 Report_ Mapping Accelerator-Specific Datasets to biodata-schema.pdf.txt` | **The citable rollup for gaps.** 13-row cross-dataset gap table + three per-dataset deep dives (Patch-seq, Cell DIVE mIF, TEA-seq) + Q&A 1–15. |
| BDR - Use Cases - working doc.docx | `…Workstream 6 …__BDR - Use Cases - working doc.docx.txt` | **Newest use cases.** 44 use cases, 5 personas, P0/P1/P2, success criteria. |
| workstream_2_doc.pdf | `…Workstream 2 …__workstream_2_doc.pdf.txt` | WS2 hub page: datasets table, raw gap notes, per-author gap analyses, Q&A with named responses, ADR draft, meeting notes. |
| BDR M1 Kickoff.pptx | `…General__2. Milestone 1__BDR M1 Kickoff.pptx.txt` | **Current milestone.** M1 tracks A/B/C, gate Sept 11. |
| BDR M0 Gate.pptx | `…General__1. Milestone 0__Key Deliverables__BDR M0 Gate.pptx.txt` | M0 gate outcome: ⚠️ Conditional pass + the four required actions. |
| M0 DDM_BDR - Workstream1 Answers.md | `resources/General/1. Milestone 0/Key Deliverables/M0 DDM_BDR - Workstream1 Answers.md` | Side-by-side ND / Immunology / Brain Science answers on versioning, storage, DB choice, K8s vs serverless. Read the original, it's already markdown. |
| Figma: BDR-Open Questions | `…Figma Boards__BDR-Open Questions.pdf.txt` | Open-questions board. **Warning: FigJam export, columns are spatially shredded.** Prefer `references/decisions-and-open-questions.md`, which is the cleaned synthesis. |
| Figma: BDR- Use Cases | `…Figma Boards__BDR- Use Cases.pdf.txt` | Mostly duplicates the use-cases doc. Two things only here: the HISE ingestion flow diagram, and the stakeholder/interviewee roster. |
| Architecture Decision Tracker.xlsx | `…Workstream 4 …__BioData Registry Architecture Decision Tracker.xlsx.txt` | Build-vs-buy per component (auth, data, search, compute, ML, other) with 3-yr TCO, FTE, status. |

## Gap analyses (the existing corpus)

| Dataset | Author / date | Text extraction | Reference schema |
|---|---|---|---|
| Patch-seq (NHP) | WS2 mapping by Nathan Gouwens; doc filled with Claude | `…Workstream 3 …__PatchSeq_Gap_Analysis_Filled.docx.txt` | v2.7.2 |
| Cell DIVE mIF | Alina Ott | `…mIF Example__gap_summary_from_comments.docx.txt` and `…mIF Example - Remap__remap gaps details.docx.txt` | latest (unpinned) |
| TEA-seq | Aishwarya Chander, 2026-08-10 | inside `…workstream_2_doc.pdf.txt` §TEA-seq, and the M0 Report | latest (unpinned) |
| Immunology (whole registry) | 2026-07-24 | `…Immunology_BioData_Registry_Gap_Analysis.docx.txt` | latest (unpinned) |
| AICS primary images | 2026-08-25 | `…AICS_AIND_Data_Schema_Gap_Analysis.docx.txt` + `…AICS_AIND_Data_Schema_Field_Crosswalk.xlsx.txt` | **v2.9.0 pinned** |

**The template** is `resources/Workstream 3 - Onboarding and Migration/BioData_Registry_Gap_Analysis_Template.docx` — bundled as a real .docx because `floppy-gaps` fills it.

## Sample metadata (real, validated-ish examples)

- `resources/Workstream 2 …/Patch-seq metadata example/` — four assets (`nwb/`, `image/` 20x+63x, `reconstruction/`, `transcriptomics/`), each with `metadata.nd.json` and the `nhp_example_*.py` that built it. Best worked example of the schema applied to a hard multi-modal case.
- `resources/Workstream 2 …/Immunology metadata/mIF Example/` — `mIF-subject.json`, `mIF-acquisition.json`, `mIF-data_description.json`.
- `resources/Workstream 2 …/Immunology metadata/TEA-seq Example/teaseq-metadata.nd.json`.
- `resources/Workstream 2 …/Cell Science Metadata/aics_bff_*.csv` / `.parquet` — 186-field AICS image view.

## The schema itself

`resources/schema/aind-data-schema/` — checked out at commit `18114d7b`, tag
`v2.9.0-1-g18114d7b`, branch `dev`, `__version__ = "2.9.0"`. `.git`, tests
fixtures, and the diagram app are stripped; source, docs, examples, and
`schemas/*.json` are all present. See `references/aind-schema-map.md` before
grepping.

`resources/schema/aind-data-mcp/` — the MCP server over the AIND metadata
database, commit `c636990a`. Tool inventory in `aind-schema-map.md` §MCP.

`resources/schema/cellxgene/` (or `single-cell-curation/`) — CZI's CELLxGENE
Discover schema, a **comparison reference for omics datasets only**. Used by
`/floppy-gaps` to recommend an existing specification when aind has no field for
something CELLxGENE already settled. BDR maps to biodata-schema, never to
CELLxGENE. Navigation map: `references/czi-schema-map.md` once the clone lands.
`python3 scripts/refresh.py schema` re-records the pinned commit of every clone
under `resources/schema/`.

## Known duplicates and version traps

- The use-cases doc exists in four places. **`Workstream 6 …working doc.docx` is
  the live one.** The three `08_13_2026 snapshot` copies (WS5 pdf, WS6 docx,
  M0 Track A docx) are the frozen M0-gate state — use only for "what changed
  since the gate?".
- `HISE Ledger Database Diagram.pdf` was byte-identical in two folders; one copy
  kept.
- `brain_science.md` in WS1 is verbatim the Brain Science section of
  `M0 DDM_BDR - Workstream1 Answers.md`. `imm_qa.md` and `nd_qa.md` are the
  Immunology and ND sections.
- The Q&A 1–15 block is byte-duplicated between `workstream_2_doc.pdf` and the
  M0 Report. Cite the M0 Report.
