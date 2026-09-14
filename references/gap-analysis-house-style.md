# Gap analysis house style

Distilled from the existing analyses. Follow it so a new doc sits beside the old
ones without reading like a different team wrote it.

## Current format: the compact M0-Report section

`/floppy-gaps` now produces the **compact per-dataset section** used in the
Milestone 0 Report — the form the SeaHub and Cell Science sections take. It is
the short form and the default. Shape:

```
<Dataset> Gap Analysis                 ← title (e.g. "SeaHub DNA Typewriter Gap Analysis")
Detailed Dataset Analysis: <dataset> (<taxon>, <accelerator>)
<2–3 intro paragraphs; second names the structural gaps that drive the rest>
[Placeholder note. …]                  ← only when built from a paper, not an export
Source documents reviewed:  <bullets, with pinned schema version>
Sample asset:  <bullets>
Gap Summary Overview       → 3-col table:  Gap | Schema Layer | Detail
Field-Level Mapping        → one 6-col table per entity, entity name as a merged title row:
    Source Field | Type | Target (aind) | Classification | Cross-Dataset Gap | Notes & Recommendation
```

Two columns do the cross-referencing that keeps a new doc honest against the old
ones: **Cross-Dataset Gap** ties each row to a named cross-cutting gap (reuse the
names in `known-gaps.md`), and **Detail** cells name recurrence in prose ("fifth
appearance, after Patch-seq, mIF, TEA-seq, Immunology and AICS"). Classification
vocabulary, voice, and what-to-avoid are unchanged and specified below.

`scripts/gapdoc.py` (in the floppy-gaps skill) renders this from a JSON twin and
computes metrics from the field rows; `gapdoc.py schema` prints the shape.

The **10-section standalone template** below is the older long form (Purpose,
Executive Summary with numbered G/R/Q, Terminology, Metrics, Sources & Method).
Keep it as reference; use it only when someone explicitly needs the full audit
artifact rather than the compact section.

## Section skeleton (long form — reference)

The template (`resources/Workstream 3 - Onboarding and Migration/BioData_Registry_Gap_Analysis_Template.docx`)
is canonical. Ten sections:

1. Purpose & Scope
2. Executive Summary of Key Gaps
3. Terminology Reconciliation
4. Classification Legend
5. Field-Level Mapping by Entity
6. Cross-Cutting Concerns
7. Proposed Schema Adjustments
8. Open Questions
9. Milestone Metrics
10. Sources & Method

Above section 1 sits a header table: Dataset/System · Source Organization ·
Prepared by · Reference Schema · Milestone · Status · Date · Version.

The Patch-seq doc follows this exactly and is the cleanest worked example. The
AICS doc adds a section 6, "AIND Required-Field Readiness", keyed by core object
— worth copying when the dataset has to pass validation. The Immunology doc
predates the template and renumbers; don't imitate it structurally.

## Classification vocabulary

Five values, words not emoji, capitalized:

| Value | Means |
|---|---|
| **Mapped** | Maps to an existing schema field, possibly with transformation. |
| **Gap** | No equivalent in the target schema; extension recommended. |
| **Conflict** | Field exists but with incompatible semantics, type, or cardinality. |
| **Unmappable** | Belongs to the platform/service layer, not the portable schema. |
| **Needs Review** | Mapping ambiguous; team decision or schema clarification required. |

Impact is **High / Medium / Low** (Medium-High allowed). Never numeric scores.

The AICS doc used a finer six-way scheme (Direct / Partial / Extension container /
No first-class analog / Platform or manifest / Derived-search-only) because it was
classifying 186 fields quantitatively. Use the five-way scheme unless the dataset
is large enough that "Partial" vs "Mapped" is a real distinction — and if you
switch, define it explicitly.

**The interpretive principle, worth quoting when you classify:** *"A field is
considered direct only when its scientific meaning and destination are materially
aligned. A flexible notes or parameters dictionary is classified as an extension
container, not a true semantic match."* A field dumped into `protocol_parameters`
is not Mapped.

## Numbering

- **G1, G2, …** gaps, in the Executive Summary table. Columns: `# | Gap / Issue Title | Impact | Recommended Action | Workstream Owner`.
- **R1, R2, …** recommendations, in section 7. Columns: `Rec. | Addresses | Layer | Description | Workstream`. Ordered by dependency where possible. `Addresses` cites G-numbers; use `G— (topic)` when a recommendation answers something that wasn't numbered.
- **Q1, Q2, …** open questions, in section 8. Columns: `# | Question | Blocking? | Owner / Target Date`.
- Every G should reach an R or a Q. A gap with neither is an unfinished thought.
- `Layer` values in use: Schema · Platform · Schema or Platform · Schema/WS1 · WS3 onboarding · Schema governance.

## Field-level tables

One table block per entity, section 5.1, 5.2, … Each opens with **2–4 sentences of
prose** describing how the entity is modeled in the source system and the key
structural difference — then the table. Columns:

`Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation`

Use `— (no analog)` or `— (platform)` in the target column when nothing fits.
Name real field paths: `subject_details.species`, `data_description.data_level`,
`acquisition.subject_details`, not "the species field".

## Voice

Neutral, audit-like, and deliberately non-blaming about the source system. Both
models get treated as internally coherent designs for different domains. Sentences
run 20–35 words, declarative, one clause of qualification, no first person, no
hedging adverbs.

Standalone labeled paragraphs carry the weight. In use across the corpus:
**Consequence.** · **Required decision.** · **Reconciliation note.** ·
**Scope boundary.** · **Version boundary.** · **Interpretive principle.** ·
**Method note.** · **Note on layers.** Use them instead of burying the point in a
table cell.

Recommendation titles are imperative and verb-first, then 2–5 sentences that
always name the layer and usually offer lettered options **(a)** / **(b)** with
the tradeoff stated. **Present options; do not pick for the team.** That is a
deliberate house convention — these documents feed a DDM gate where the choice
belongs to the workstreams.

Representative lines, verbatim from the corpus:

> Consequence. aind assumes a clean 1:1:1 chain (asset ↔ acquisition ↔ subject), with specimens as subject-derived tissue.

> Treating a cell-line identifier as subject_id would be syntactically convenient but semantically misleading.

> These need controlled vocabulary additions, not free-text workarounds, in order for Patch-seq procedures to be searchable across datasets.

> The concepts share a name but not a domain.

## What to avoid

- Emoji in classifications. The template's legend shows 🟢🟡🔴⚪❓; **no finished doc uses them.** Words only.
- Inventing a new name for a gap that already has one. Check `known-gaps.md` first.
- Padding with gaps that don't apply to this dataset.
- Deciding the open question. State the options and the tradeoff.
- Quoting an unpinned "latest" schema. The AICS doc's version boundary paragraph is explicit: *"migration decisions should not be based on an unpinned 'latest' URL."* Cite the pinned version and commit.
- Claiming a field is populated when you only checked that it exists. The corpus has a repeated defensive note that a mapping is not a claim of population or validity.

## Metrics

Section 9 exists to feed the gate. Populate it — the Immunology doc's lack of any
metrics is its main weakness. Patch-seq is the model:

| Metric | Value |
|---|---|
| Total fields examined | 46 |
| Mapped | 18 (39%) |
| Gap | 11 (24%) |
| Conflict | 14 (30%) |
| Unmappable | 2 (4%) |
| Needs Review | 1 (2%) |
| Entities covered | 5 |
| Recommendations raised | 12 |
| Open questions (blocking) | 3 |

Percentages come from the field table, so the table has to be complete before the
metrics mean anything. `scripts/gapdoc.py` computes them from the JSON so they
can't drift from the table.

## The transformation this skill performs

The informal inputs (a scientist's bulleted mapping notes, doc comments, a
crosswalk spreadsheet) and the formal outputs are consistently related:

| Informal input | Becomes |
|---|---|
| "There's no field for X" | a **G**-number with Impact and Workstream Owner |
| "This would fall under OTHER, losing specificity" | a **G** + an **R** naming the vocabulary addition |
| "I'm not sure whether A or B" | a **Q**-number with Blocking? = Yes and an owner/date |
| First-person uncertainty | neutral third-person statement of the mismatch |
| A field that only exists to serve the source platform | a row classified **Unmappable** with the platform layer named |

`resources/Workstream 2 …/Patch-seq metadata example/mapping observations.docx` →
`resources/Workstream 3 …/PatchSeq_Gap_Analysis_Filled.docx` is the cleanest
before/after pair in the corpus. Read both if you want to see the transformation.
