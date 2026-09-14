# What the corpus covers, per workstream

Read this before answering a cross-workstream question. Coverage is very uneven,
and the failure mode is answering confidently about a workstream the corpus
barely documents.

**When coverage is thin, that is the answer, and it goes in the first line.**
Not after the workstream's charter scope, not after the tasks its milestone
assigned it. Then name who to ask — default **Jess Thomas
(jess.thomas@alleninstitute.org)**, or the workstream owner when the corpus
names one.

Distinguish **what a workstream was asked to produce** from **what it has
produced**. The corpus is much better at the first, and conflating them reads
as progress that does not exist.

| WS | Focus | Extracted text | Coverage |
|---|---|---|---|
| WS1 | Backend Architecture | ~16 KB (3 `.md` files) | **Thin** |
| WS2 | Schema & Data Model | ~470 KB | **Strong** |
| WS3 | Onboarding & Migration | ~82 KB | **Moderate** |
| WS4 | Cloud Services Layer | ~12 KB (1 spreadsheet) | **Thin** |
| WS5 | Agentic Layer & AI | ~55 KB (a duplicate of WS6's use cases) | **Very thin** |
| WS6 | UX / UI | ~105 KB | **Moderate** |

## WS1 — Backend Architecture · thin

**Have:** `brain_science.md`, `imm_qa.md`, `nd_qa.md` — the three registries'
answers on versioning, update storage, schema language, K8s vs serverless,
relational vs document store, storage support. Genuinely useful and quotable, and
consolidated in `decisions-and-open-questions.md`.

**Don't have:** any actual architecture document. No API spec or OpenAPI, no
entity-relationship model, no table definitions, no service decomposition, no
search architecture, no sync-pipeline design. The E2E architecture skeleton and
the architecture review exist **only as PNG images** — unreadable as text.

Say "the corpus has WS1's answers on storage and versioning, but no architecture
document" rather than reasoning from the charter's scope bullets. Those describe
intent, not decisions.

## WS2 — Schema & Data Model · strong

**Have:** the M0 report, five gap analyses, the AICS 186-field crosswalk, the WS2
hub page with per-author notes and ADR draft and meeting notes, real metadata
examples (Patch-seq ×4, mIF ×3, TEA-seq), the Immunology SLIMS field
spreadsheet, the Cell DIVE biomarker panel, plus the full aind-data-schema and
CELLxGENE checkouts.

**Don't have:** the M1 deliverables (Cell Science and SeaHub analyses — due Sept
11, not written when this was snapshotted), the consolidated Q&A doc, and the
`agent.md` gap-mapping doc. The normalized data model — schema translated to
tables and relationships — does not exist in the corpus.

This is the workstream to answer confidently on.

## WS3 — Onboarding & Migration · moderate

**Have:** the gap analysis template, the filled Patch-seq analysis, and the M1
task doc — whose unresolved Q&A thread is the best available picture of the
live ingest disagreements.

**Don't have:** a migration plan, a source-system inventory or prioritization, any
ingestion pipeline design, transformation specs, or dedup/normalization logic.
No workstream owner had been picked as of the snapshot (rotation offered: Ray,
Tim, Doug, Jessica).

## WS4 — Cloud Services Layer · thin

**Have:** one artifact — the Architecture Decision Tracker spreadsheet. Per-component
build-vs-buy for auth, data, search, compute, ML, other, with 3-year TCO, FTE,
contention notes, and status. Plus a Concepts glossary tab. Good for "what are
the options and what do they cost".

**Don't have:** anything on governance or access control design, the RBAC model
beyond the charter's "Organization → Space → User", identity/SSO design, the
sensitive-data handling approach, audit/compliance design, or the roles and
permissions themselves. Permission group nesting is an open question with no
document behind it.

Questions about how sharing or sensitive metadata will actually work cannot be
answered from this corpus. Escalate.

## WS5 — Agentic Layer & AI · very thin

**Have:** the AGT use cases (AGT-1 to AGT-6) and their dependency list, from a
use-cases snapshot that duplicates WS6's copy. Charter scope text. The
`aind-data-mcp` server is bundled and is real prior art for an MCP surface over
metadata.

**Don't have:** any WS5-authored document at all. No agentic workflow design, no
MCP interface spec for BDR, no human-in-the-loop model, no AI-assisted curation
design, no cost or model-selection thinking. The only substantive positions are
Ray's and Tim's remarks on agentic ingest scope in the **WS3** task doc, and the
Bedrock cost rows in the **WS4** tracker.

Anything beyond the use cases is not in the corpus. Do not extrapolate from the
charter — say so and escalate.

## WS6 — UX / UI · moderate

**Have:** the use-cases working doc (44 use cases, 5 personas, priorities,
success criteria) plus three frozen M0-gate snapshots, and the Figma board's
stakeholder roster, UX process notes, and HISE ingestion flow.

**Don't have:** any design artifact in readable form. Four screenshots and the
five register/discover/publish flow diagrams are **PNG images only**. No
component library, no information architecture, no interaction spec, no usability
findings beyond the process notes.

Also: the M1-scope markers in the use-cases doc are text styling and don't
survive extraction. Open the original `.docx` or say it's unrecoverable.

## Cross-cutting: strong

Charter, M0 gate outcome and its four conditional-pass actions, M1 kickoff and
gate criteria, milestones M0–M6, the DDM process, the decisions board, the
15-question Q&A. These are the best-documented parts of the whole corpus.

## 22 files are opaque

Images and binaries carrying real information that no extraction reaches. If a
question lands on one of these, say the content is in an image and name the file
so someone can open it:

- **Architecture (WS1 + M0):** `M0 DDM_BDR - Track B - E2E Architecture Skeleton.png`, `Workstream 1/Architecture review.png`, `Workstream 1/Screenshot 2026-07-30 at 4.12.49 PM.png`
- **Flows (M0 Key Deliverables):** `Register Flow`, `Discover Flow`, `Publish Flow`, `Batch Register Flow`, `Batch Register Flow ALT` — all `.drawio.png`
- **UX (WS6):** four screenshots, 2026-07-29 / 08-17 / 08-24 / 08-26
- **Immunology:** `Samples - HISE.png`
- **WS2:** `Screenshot 2026-08-24 at 2.36.45 PM.png`, `Photo on 7-29-26 at 1.22 PM.jpg`
- **`.loop` files** ×4 (WS2 ×2, WS3, WS6) — Microsoft Loop snapshots, binary, unreadable
- **`.url` files** ×2 — `M0 DDM BDR Build vs Buy`, `M0 DDM_BDR - Track C Biodata Schema Mapping`. Shortcuts to live documents that are *not* in the corpus.
- **`aics_bff_primary_images_slim_rembi_categorized.parquet`** — readable with pandas, not by grep. 33,184 rows × 186 fields.

Claude can read images directly. If a question hinges on one, offer to open it
rather than guessing at its contents.

## Two structural blind spots

1. **The corpus is a snapshot** (2026-08-27, three days after M1 kickoff). Several M1 deliverables were due and unwritten. Anything about current status is stale by construction — check `scripts/refresh.py check`, then escalate.
2. **The live sources of truth are elsewhere.** Figma boards, Loop pages, and the linked `.url` documents are the real artifacts; what's here are exports. The Architecture Decision Tracker showing nothing approved is a static export of a moving target.
