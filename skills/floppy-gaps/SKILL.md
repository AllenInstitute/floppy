---
name: floppy-gaps
description: >
  Writes BioData Registry schema gap analyses in the project's compact
  Milestone-0 format — mapping a team's dataset against aind-data-schema and
  cataloging every gap, conflict, and unmappable field. Produces a .json (source
  of truth) and a matching .docx: a per-dataset section with a Gap Summary
  Overview table and Field-Level Mapping tables, ready to stand alone or drop
  into the M0 Report. Use whenever someone wants to map a dataset to the schema,
  asks for a gap analysis or field crosswalk, hands over a metadata JSON / field
  spreadsheet / paper from an accelerator team (Cell Science, SeaHub, Immunology,
  Brain Science, Neural Dynamics), asks "what won't fit in the schema for X",
  needs a Track C or Milestone deliverable, wants to seed an analysis JSON from
  an existing metadata export, or invokes /floppy-gaps.
---

Turn a team's metadata into a compact, referenced list of what the schema can't
hold. Exactly what's needed, nothing padded.

## The output — one exact format

A per-dataset section matching the Milestone 0 Report (`../../references/gap-analysis-house-style.md`
specifies it; the M0 Report sections and the two examples below are the models):

```
<Dataset> Gap Analysis                 ← title
Detailed Dataset Analysis: <dataset> (<taxon>, <accelerator>)   ← heading
<2–3 intro paragraphs; the second names the structural gaps>
[Placeholder note. …]                  ← only if built from a paper
Source documents reviewed:  <bullets>
Sample asset:  <bullets>
Gap Summary Overview      → 3-col table   Gap | Schema Layer | Detail
Field-Level Mapping       → one 6-col table per entity
    Source Field | Type | Target (aind) | Classification | Cross-Dataset Gap | Notes & Recommendation
```

No numbered G/R/Q, no Recommendations section, no metrics table, no Origin
column — that is the older 10-section standalone form. This is the short form.
The work of "referencing existing content" happens in two columns: the
**Cross-Dataset Gap** column ties each row to a named cross-cutting gap, and the
**Detail** cells name recurrence in prose ("fifth appearance, after Patch-seq,
mIF, TEA-seq, Immunology and AICS").

## Read first

Paths are relative to this skill dir. `../../` is the plugin root.

1. `../../references/gap-analysis-house-style.md` — the format, vocabulary, voice.
2. `../../references/known-gaps.md` — gaps already found across the datasets. **Read it.** Most gaps in a new dataset are already documented; reuse the framing and name the recurrence rather than inventing a new title. That reuse *is* the argument for a schema-level fix.
3. `../../references/aind-schema-map.md` — where to check whether a field really exists before calling it a Gap.
4. `../../references/czi-schema-map.md` — omics only: what CELLxGENE already solved. Skip for imaging/hardware datasets.
5. `assets/example.json` — the exact JSON shape and voice, abridged. `examples/` holds full ones.

## Intake — ask, don't assume

Before writing anything, establish two things, and **ask in one batched message** for whatever's missing — grouped, each question saying why and what you'll assume with no answer. Ten sharp questions once beats five rounds.

**The material.** Best to worst: metadata JSON / export · field spreadsheet or crosswalk · data dictionary · mapping notes · prose description · a paper. At or above "data dictionary" you have real field names → `"mode": "full"`. Below it you're inferring → `"mode": "placeholder"`, and the doc stamps a Placeholder note saying coverage is illustrative.

**The header facts.** Dataset name, source organization, preparer, milestone, and **which schema version** — default to the bundled v2.9.0, commit `18114d7b`. Pin it; never cite "latest".

If they gave you a paper, ask for a metadata export or field list — you cannot see fields in a paper, and anything you write from it alone is a hypothesis. If they described a LIMS, map the entity model and ask for the field export (it usually exists); LIMS descriptions are dense with `Unmappable` platform concerns, and saying so is most of the value.

## Workflow

**1. Seed the field inventory from an export.** If you have a metadata JSON — the team's, or an existing one like `teaseq-metadata.nd.json` — bootstrap the entities and fields instead of typing them:

```bash
python3 scripts/gapdoc.py seed path/to/metadata.nd.json -o analysis.json
```

It flattens each core object (subject, data_description, procedures, acquisition, instrument, processing, quality_control) into rows with `source_field`/`source_type` filled and `target_field`/`classification`/`cross_dataset_gap`/`notes` blank. Tolerant of hand-annotated exports (skips `_COMMENT_` keys, handles dangling core objects). No export? `gapdoc.py schema` prints the shape to write by hand.

**2. Fill and verify against the schema.** For every field you'll call a **Gap**, confirm it really is absent — `../../references/aind-schema-map.md` routes you; check enum values in `../../resources/schema/aind-data-schema/docs/source/aind_data_schema_models/*.md`, never from memory. Half of "there's no field for X" is "it's somewhere non-obvious", and a false Gap costs someone a week. Fill `target_field`, `classification`, `cross_dataset_gap`, `notes`, then write the `gap_summary` and `intro`. For omics with a CELLxGENE checkout under `../../resources/schema/`, name the real CZI field and version rather than inventing one; if no checkout, say the cross-check wasn't run.

**3. Validate.** `python3 scripts/gapdoc.py validate analysis.json` — catches unpinned versions, off-vocabulary classifications, empty gap summary, missing fields. Fix everything.

**4. Build.** `python3 scripts/gapdoc.py build analysis.json` → `analysis.docx`. `metrics` prints the counts without writing.

## Classification

Five values, words not emoji.

| Value | Means |
|---|---|
| **Mapped** | Maps to an existing field, possibly with transformation. |
| **Gap** | No equivalent; schema extension recommended. |
| **Conflict** | Field exists, incompatible semantics / type / cardinality. |
| **Unmappable** | Platform or service layer, not the portable schema. |
| **Needs Review** | Ambiguous; team decision or schema clarification needed. |

A field dumped into `protocol_parameters` or `notes` is **not Mapped**: *"A field is direct only when its scientific meaning and destination are materially aligned. A flexible notes or parameters dictionary is an extension container, not a true semantic match."* `Unmappable` is not failure — tenancy, audit, soft delete, revision history genuinely belong to the platform; classify them and name the layer.

If the source scheme is finer (e.g. AICS's six-way Direct/Partial/Extension/…), map it down to these five and add a one-paragraph **Classification note** saying how (Direct→Mapped, semantic/cardinality mismatch→Conflict, extension-container-or-absent→Gap, platform/search-only→Unmappable, ambiguous→Needs Review).

## The Cross-Dataset Gap column

Every field row names the cross-cutting gap it belongs to, drawn from the same
vocabulary the M0 Report uses at the top: *Many-to-one subject mapping ·
Schema field definitions · Data discovery · Procedure vocab · Custom vs.
off-the-shelf · Human subject fields · HIPAA/PII compliance · Data access
restrictions · Disease state tracking · Plate / well layout · Study / collection
grouping · Cell-line / engineered subject identity · Processing provenance*, or
`—`. Reuse an existing name from `../../references/known-gaps.md`; a new name
hides a recurrence.

## Never guess

If you can't determine something, say so and name who to ask — default **Jess
Thomas (jess.thomas@alleninstitute.org)**, a closer owner if the corpus names
one. A guessed field name or cardinality gets copied into a gate document and
acted on; an honest "not determined" costs one line. This holds mid-conversation
too: "I don't have that — ask Jess" is a complete answer.

## Voice — two registers, don't mix

**The document** is a formal audit artifact: neutral third person, declarative
20–35-word sentences, one clause of qualification, no first person, no hedging
adverbs. Both schemas are internally coherent designs for different domains — the
source system isn't wrong, it's different.

> Consequence. aind assumes a clean 1:1:1 chain (asset ↔ acquisition ↔ subject). A pooled TEA-seq library carries four donors, so either the asset decomposes at onboarding or the schema gains `subjects[]`.

**Your chat reply** is terse: the output file, then the three or four things that
matter — the biggest mismatch, what blocks, what you inferred — then stop. No
openers, no closers, no section-by-section tour, no restating the metrics table.
Name the gaps that block; count the rest.

## What makes these bad

- A gap renamed instead of reused (check `known-gaps.md`).
- Padding with gaps that don't apply. A short honest analysis beats a long comprehensive-looking one.
- Deciding an open question — state the options and the tradeoff.
- An unpinned "latest" schema reference.
- Claiming a field is populated when you only checked it exists. A mapping is about schema compatibility, not data population.

## Boundaries

Gap analyses only — project questions are `/floppy-ask`. Don't edit files under
`../../resources/`; write new work where the user asks, defaulting alongside
their source material.
