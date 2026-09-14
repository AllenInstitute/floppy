# Cross-Analysis Comparison

**AICS Primary-Image Gap Analysis vs. the Immunology and Brain Science Analyses (Cell DIVE mIF, Patch-seq, TEA-seq)**

**Prepared:** August 27, 2026 · **Status:** Draft for Workstream 2 / 3 review
**Reference schema:** aind-data-schema v2.9.0 (commit `18114d7b`)

---

## 1. Scope

This document compares one gap analysis — AICS primary-image metadata, August 25, 2026 — against the four analyses that preceded it: Cell DIVE mIF and TEA-seq (Immunology), Patch-seq NHP (Brain Science), and the Immunology registry-wide analysis. It reports where findings recur, where they diverge, and where the two families of analysis differ in method rather than in finding.

**Scope boundary.** No new gaps are raised and no open question is resolved. Findings are cited by their number in the accumulated gap register (G#) where one exists.

**Interpretive principle.** Recurrence across independent datasets is the strongest available argument for a schema-level change. Divergence is not disagreement: the analyses examined different biology, and a gap absent from one is usually inapplicable rather than unobserved.

---

## 2. Headline difference

The two families locate the mismatch at different layers.

For Immunology and Brain Science, the aind entity model largely holds — subject, specimen, procedure, acquisition — and the failures are in **vocabulary, human-subject coverage, and temporal structure**. Enums are too narrow, `HumanSubject` is minimal, and cyclic or longitudinal sequences have no representation.

For AICS, the **entity model itself** does not apply. There is no biological subject: the unit of biology is a cell line, and the unit of the source record is one image file, not an acquisition. Both of aind's two required identity anchors — `acquisition.subject_id` and `acquisition.specimen_id` — are unpopulatable without a governed profile that does not yet exist.

**Consequence.** A vocabulary-expansion program addresses most of the Immunology and Brain Science findings, which is what the M0 report predicted would be the majority of remaining work. It does not address AICS, whose principal blockers are structural and require a decision at the gate rather than an enum addition.

---

## 3. What overlaps

Fifteen findings recur between AICS and at least one Immunology or Brain Science analysis. The five below appear in every analysis or in four of five, and carry the strongest cross-dataset argument.

| G# | Finding | Also found in |
|---|---|---|
| 1 | **Asset-to-biology cardinality / unit of registration.** aind assumes a 1:1:1 chain (asset ↔ acquisition ↔ one subject). AICS breaks it with one row per image file; Immunology with `sampleNames[]`; TEA-seq by pooling four donors; Patch-seq with four modality assets per cell. | PS, mIF, TEA, IMM |
| 11 | **`procedure_type = "Other"` swallows meaning.** AICS culture, seeding, replate, differentiation, and fixation; Patch-seq's five core procedures; TEA-seq specimen prep; Immunology cytometry. | PS, mIF, TEA, IMM |
| 13 | **Extension-container overuse.** AICS classified 48 of 186 top-level fields as extension containers and stated the governing principle now used across the corpus: a flexible notes or parameters dictionary is an extension container, not a semantic match. | mIF, IMM |
| 21 | **`source_data[]` and derived-data lineage are empty.** AICS additionally lacks `DataProcess.code.url`, experimenters, and ordering. Null across all four Patch-seq files. | PS, mIF, IMM |
| 2 | **No first-class Cohort / Study / Collection entity.** AICS `collection_name`, `study_title`, `study_type` and Immunology `cohortGuid` all land in `data_description.tags[]`, which is free text. | PS, mIF, IMM |

Also shared, at lower recurrence: `metadata.location` as a single string (G3 — PS, IMM); platform concerns embedded in source entities and correctly classified Unmappable (G4 — PS, IMM); no specimen subtype for the relevant biology (G15 — mIF, IMM); `tags` / `restrictions` without controlled vocabulary (G14 — PS, mIF); investigator identity unresolvable (G23 — PS); `source` / institution without a ROR identifier (G24 — PS, mIF); `data_description.name` collision risk (G26 — PS, mIF); `project_name` semantics undefined (G27 — PS, mIF); `coordinate_system` required where it has no meaning (G29 — PS, mIF); QC flags requiring normalization into `QCMetric` (G32 — TEA).

**Reconciliation note.** G15 recurs as a shape, not as a request. Immunology needs biospecimen types (PBMC, plasma, bone marrow); mIF needs `TissueSection`; AICS needs cell line, parental line, and clone lineage. A single new specimen subtype satisfies none of the three.

---

## 4. What is unique to AICS

| G# | Finding | Why the others did not raise it |
|---|---|---|
| 17 | **Plate, well, layout, colony, and condition have no first-class model.** Named a high-impact gap; core experimental design would become untyped parameters. | No other analyzed dataset is plate-based. |
| 34 | **Instrument referential integrity is demanding.** Named cameras, detectors, lasers, triggers, and coordinate systems are all required and must match `Instrument.get_component_names()`; `DataStream.active_devices` and `Channel.detector` are validation blockers. | The others mapped instruments loosely or from real instances that already carried device names. |
| — | **Biological identity has no subject at all.** *"Treating a cell-line identifier as `subject_id` would be syntactically convenient but semantically misleading."* | Every other dataset has a live animal or human donor. This is the M0 report's "no biological subject" edge case, met in practice. |
| — | **Missing administrative metadata.** Institution, funding, and investigators are absent from the source view entirely, making `DataDescription` unvalidatable. | Present or partially present elsewhere. |
| — | **Timing heterogeneity.** aind requires timezone-aware datetimes; AICS dates are mixed-format and often date-only, so `acquisition_end_time` is derivable only sometimes. | Raised as a granularity note elsewhere, not as a validation blocker. |
| — | **Nineteen search-only derivative fields** that should be regenerated after migration rather than carried into portable JSON. | An artifact of AICS's flattened discovery view; no analog in the others. |

---

## 5. What is unique to Immunology and Brain Science

Absent from AICS, and correctly so — cell lines have no donor, no visits, and no antibody rounds.

**Human subjects and compliance.** HIPAA age capping and reduced-precision dates, including the mechanism to update a subject who crosses the 89 boundary (G6 — IMM, mIF). Missing `race`, `ethnicity`, multiple time-stamped diagnoses, consent, `droppedOut` (G7 — IMM, mIF). `acquisition.subject_details` is mouse-centric and carries no clinical context (G8 — PS, mIF). `ethics_review_id` is mouse-shaped, with no IRB or IACUC path (G9 — PS, mIF). Whether clinical and survey data are data or metadata is unresolved (G10 — IMM).

**Time and sequence.** Longitudinal visit structure — `visitName`, `daysSinceFirstVisit` (G16 — IMM). `DataStream` models simultaneous collection, but Cell DIVE is ten sequential staining rounds; `HCRSeries` exists for cyclic mFISH and has no antibody-based equivalent (G16 — mIF). Non-integer rounds such as "Round 1.5" (G20 — mIF).

**Reagents and probes.** Antibody clone, working concentration in µg/mL — the schema uses mass, not concentration — and institutional barcodes have no home; no field records which panel went to which slide in which round (G18 — mIF, TEA). No deactivation or bleaching step model (G19 — mIF).

**Modality enum.** No mIF or cyclic-imaging modality, no `scATACseq`, no `ADT`. One missing enum value blocks four fields at once and makes TEA-seq's FRIP and TSS-enrichment QC metrics unrecordable (G12 — mIF, TEA, IMM).

**Other.** Database-resident data has no representation (G5 — PS, mIF). No checksum field in the metadata core (G22 — PS, IMM). `protocol_id` provenance is inconsistent between protocols.io DOIs and SLIMS IDs (G25 — PS, mIF). `stimulus_epochs` and `manipulations` are inapplicable to fixed tissue (G31 — PS, mIF). Whether `calibrations` and `maintenance` belong under QC (G33 — mIF).

---

## 6. Methodological differences

These are differences in how the analyses were conducted, and they affect how comparable the findings are.

| Dimension | AICS | Immunology / Brain Science |
|---|---|---|
| **Reference schema** | v2.9.0, pinned, with an explicit statement that migration decisions should not rest on an unpinned 'latest' URL. | Patch-seq used v2.7.2; mIF, TEA-seq, and the Immunology registry analysis used unpinned 'latest'. |
| **Source artifact** | A schema: a 186-field, 33,184-row slim Parquet view. Schema-to-schema comparison. | Real instances — `metadata.nd.json` files, a live registry data model. Instance-to-schema comparison. |
| **Classification set** | Six values: Direct · Partial · Extension container · No first-class analog · Platform or manifest · Derived/search-only. | The house five: Mapped · Gap · Conflict · Unmappable · Needs Review. |
| **Metrics** | Full counts (11 / 75 / 48 / 23 / 10 / 19) plus a 42-check required-field readiness assessment: 28 high-severity, 9 medium, 5 low. | The Immunology analysis has no metrics section — its principal weakness, since the section exists to feed the gate. |
| **Lineage** | Used the Immunology analysis as its reporting template. | Independent formats. |

**Method note.** Because AICS adopted the Immunology document as its template, structural similarity between the two is inheritance, not independent convergence. Only the findings themselves carry cross-dataset weight.

**Scope boundary.** The AICS source is a slim primary-image view, not the governed 282-field class model, and it excludes non-primary assets by design. Its coverage conclusions apply to onboarding this view and should not be generalized to every AICS asset class.

**Version caveat.** Where a gap is reported only by an analysis that used v2.7.2 or an unpinned reference, its persistence in v2.9.0 has not been confirmed by that analysis. The modality-enum gaps (G12) are the most likely candidates to have moved.

---

## 7. Required decisions this comparison surfaces

Neither resolved here. Both belong to the workstreams.

**D1 — Unit of registration.** Every analysis reaches G1 and every analysis presents the same two paths without picking one: (a) enforce one subject per acquisition and decompose at onboarding (WS3), or (b) extend the schema with `subjects[]` / `specimens[]` for pooled and multiplexed assays (WS2). AICS adds a third case the others do not — aggregation *upward* from file rows to an acquisition-level asset, which needs a deterministic grouping key rather than a decomposition rule.

**D2 — Specimen model.** The M0 draft ADR position is procedure + subject as the primary model with a defined exception path. AICS is that exception, arriving with no biological subject. Whether cell lines are served by a governed profile (AICS's R2), by a schema-level specimen entity, or by the Registry relational layer determines whether three teams get one solution or three.

---

## 8. Sources

- `Workstream 2 - Schema and Data Model/AICS_AIND_Data_Schema_Gap_Analysis.docx` (August 25, 2026) and `AICS_AIND_Data_Schema_Field_Crosswalk.xlsx`
- `Workstream 2 - Schema and Data Model/Milestone 0 Report_ Mapping Accelerator-Specific Datasets to biodata-schema.pdf` (Track C, Workstreams 2 & 3)
- `Workstream 3 - Onboarding and Migration/PatchSeq_Gap_Analysis_Filled.docx`
- `Workstream 2 .../Immunology metadata/mIF Example/gap_summary_from_comments.docx` and `mIF Example - Remap/remap gaps details.docx`
- `Workstream 2 .../Immunology_BioData_Registry_Gap_Analysis.docx` (July 24, 2026)
- TEA-seq analysis, in `Workstream 2 - Schema and Data Model/workstream_2_doc.pdf` §TEA-seq
- Reference schema: `aind-data-schema` v2.9.0, commit `18114d7b`
