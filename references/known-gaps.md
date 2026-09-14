# Known gaps — the accumulated corpus

Every gap already found across five analyses (Patch-seq, Cell DIVE mIF, TEA-seq,
Immunology registry, AICS primary images). Ordered roughly by how often it
recurs, which is a decent proxy for how structural it is.

**Use this before writing a new gap analysis.** If a gap here shows up in the new
dataset, say so and reuse the existing framing and recommendation — cross-dataset
recurrence is the strongest argument for a schema change, and inventing a fresh
name for gap #1 hides that. If a gap here does *not* apply, don't pad the doc
with it.

Datasets are abbreviated: **PS** Patch-seq · **mIF** Cell DIVE mIF · **TEA**
TEA-seq · **IMM** Immunology registry · **AICS** Cell Science primary images.

## Structural — these are the ones that force a design decision

**1. Asset-to-biology cardinality / unit of registration.** PS, mIF, TEA, IMM, AICS.
Named "the core structural mismatch" in three separate docs. aind assumes a clean
1:1:1 chain (asset ↔ acquisition ↔ one subject), with specimens as
subject-derived tissue. Reality: one Immunology `DataAsset` references many
samples (`sampleNames[]`); one AICS Parquet row is one *image file* while an aind
asset is acquisition-level; one Patch-seq cell yields four modality assets with
nothing tying them together; TEA-seq pools 4 donors into one library
(`VRd-T24-Pool-01`) demultiplexed by HTO. `Acquisition.subject_id` is a single
required string. The two paths, always presented as options rather than a verdict:
(a) enforce 1-per-acquisition and decompose at onboarding (WS3), or (b) extend the
schema with `subjects[]` / `specimens[]` for multiplexed and pooled assays (WS2).

**2. No first-class Cohort / Study / Collection entity.** PS, mIF, IMM, AICS.
Immunology has `cohortGuid` + name + description; AICS has `collection_name`,
`study_title`, `study_type`. All of them land in `data_description.tags[]`, which
is free text — lossy and unsearchable. Open sub-question: does cohort attach to
the subject or the sample? Options: schema-level Cohort entity (WS2) or a
formalized platform Collection with stable IDs (WS1).

**3. `metadata.location` is a single string — multi-file, multi-directory, and
moved data don't fit.** PS, IMM, AICS. Patch-seq has SWC + marker file in a shared
directory, and 63x image layers spread across directories with no unifying parent;
fastq files sit in a shared directory with no cell-level file identity. Immunology
tracks `bucket` plus an ordered `previousBuckets[]` move history — no analog.
AICS needs per-file paths under one asset root. Fix shape: derive a root, retain
relative file paths in a manifest.

**4. Platform concerns embedded in source entities.** IMM, AICS, PS. Tenancy
(`accountGuid`), visibility (public/private/protected), soft delete + cascade
(`availability`, `isDeleted`), `auditInfo.*`, `revisionHistory[]`, thumbnails,
cold-storage flags, `uploaded_by`, UI category labels. These are **Unmappable**
by design — they belong in the registry platform layer (Organization → Space →
User, RBAC, lifecycle), not in the portable JSON schema. Classify them, don't
try to force them in.

**5. Database-resident data has no representation.** PS, mIF. Patch-seq
reconstruction annotations live in a database, not a file. Generalizes: scientists
want to track clinical characteristics in a database and have the registry refer
to them. Immunology's whole MongoDB-vs-sidecar framing is the architectural
version of the same problem.

## Human subjects and compliance

**6. HIPAA — age capping and reduced-precision dates.** IMM, mIF. `ageAtEnrollment`
must be able to say `"90+"`; collection dates need month/year granularity. The
schema uses full `year_of_birth`. Note the nuance the Immunology doc missed and
the mIF comments caught: you also need **a mechanism to update this over time**,
because subjects cross the 89 boundary. Patch-seq flagged it prospectively (NHP,
so not applicable, but review if human subjects are added).

**7. Missing human demographic and clinical fields.** IMM, mIF. `race`,
`ethnicity`, multiple diagnoses with time-based updates, consent, `droppedOut`.
`HumanSubject` is minimal.

**8. `acquisition.subject_details` is mouse-centric.** PS, mIF. For human tissue,
"subject at acquisition" should carry clinical context — the recurring example is
smoking history at time of collection — and it needs to be searchable. Immunology's
requirement for CBC / EMR / survey data is the same need at a different layer.

**9. `ethics_review_id` is null everywhere and mouse-shaped.** PS, mIF. NHP work
needs IACUC; human work needs IRB. Noted as mouse-schema-specific.

**10. Clinical and survey data — data or metadata?** IMM. Unresolved whether CBC
panels, EMR extracts, and survey instruments belong in the registry at all.

## Vocabulary and extensibility

**11. `procedure_type = "Other"` / `OTHER` fallback swallows meaning.** PS, mIF,
TEA, IMM, AICS. Five Patch-seq procedures fall to `"Other"`: nucleated patch
extraction, SMARTer v4 amplification, Nextera library prep, biocytin filling, DAB
detection. `SpecimenProcedureType` has no entry for human donor tissue block
acquisition. TEA-seq: all specimen prep falls to `"Other"`, and there's no
`SubjectProcedure` for venipuncture. Immunology needs cytometry vocabulary
(`panelId`, `totalViableCellCount`, `batchId`). The standard line: *these need
controlled vocabulary additions, not free-text workarounds, in order to be
searchable across datasets.*

**12. Missing modality entries.** mIF, TEA, IMM. `modalities` has no mIF or any
cyclic/multiplexed imaging modality; no `scATACseq`, no `ADT`. This is a registry
gap, not a naming question, and it blocks four fields at once:
`data_description.modalities`, `acquisition.data_streams`,
`instrument.modalities`, `QCMetric.modality` — so FRIP and TSS-enrichment QC
become unrecordable. Open sub-question: should "Cell DIVE" be its own modality or
a platform detail within mIF?

**13. Extension-container overuse.** mIF, AICS, IMM. `protocol_parameters`,
`notes`, `output_parameters`, `code.parameters`, `additional_settings`. The AICS
doc classified **48 of 186 fields** as extension containers and named the
principle: *"A flexible notes or parameters dictionary is classified as an
extension container, not a true semantic match."* Technically valid, weakly
interoperable. Immunology's per-account data-steward-managed dictionaries
(MetadataSchemes) are the governed alternative to aind's schema-change model.

**14. `tags` and `restrictions` have no controlled vocabulary or defined
semantics.** PS, mIF, AICS. Specifically: does a legal contract / data-use
agreement ID belong in `restrictions`, and how does it overlap with consent?

**15. No specimen subtype for the relevant biology.** IMM, mIF, AICS. Immunology
needs biospecimen (PBMC, plasma, bone marrow) with `sampleType`,
`timeToProcessingOnset`, `sampleKitName`, `status`. mIF needs a `TissueSection`
subject type with tissue/slide IDs, fixation method, embedding medium, section
thickness, antigen retrieval. AICS needs cell line / parental line / clone lineage
— and the doc's sharpest line: *"Treating a cell-line identifier as `subject_id`
would be syntactically convenient but semantically misleading."*

## Time, sequence, and structure

**16. Longitudinal and sequential structure unsupported.** IMM, mIF. Immunology
needs `visitName`, `visitDetails`, `daysSinceFirstVisit`. `DataStream` models
*simultaneous* collection, but Cell DIVE is inherently *sequential* — 10 staining
rounds. Same shape of gap: the schema assumes one point in time. `HCRSeries`
exists for cyclic mFISH; there is no equivalent for antibody-based cyclic IF.
Proposed models from the mIF work: **`CyclicIFSeries`**, **`StainingRound`**,
**`AntibodyChannel`**, **`DeactivationStep`**, **`TissueSection`**.

**17. Plate / well / experimental design has no first-class model.** AICS. Plate,
well, layout, colony, condition. Connects to the open ingest question about
propagating metadata through nested relationships (Plate → Well).

**18. Antibody / panel metadata has no home.** mIF, TEA, and generalizes.
`FluorescentStain` / `ProteinProbe` lack antibody **clone**, working
**concentration in µg/mL** (the schema uses mass, not concentration), and
institutional barcodes (expected / scanned / match). RRID is the only formal
identifier. No field says which panel (A vs B) went to which slide in which
round. The mIF doc notes this **generalizes beyond mIF: Xenium gene panels and
Flex scRNA have the same problem.**

**19. No deactivation / bleaching step model.** mIF. H₂O₂ between rounds is
currently a custom object in `protocol_parameters`.

**20. Non-integer rounds.** mIF. "Round 1.5" — a second antibody pass between
rounds 1 and 2 — has no representation. Three options were named: fold into round
1, own acquisition with a non-integer ID, or add a protocol-deviation field.

## Provenance, identity, integrity

**21. `source_data[]` and derived-data lineage are empty.** PS, mIF, AICS, IMM.
Null across all four Patch-seq files. `DataProcess.code.url` missing on the AICS
side — no code URLs, no experimenters, no dependency graph. Immunology tracks
lineage implicitly via `fileTypeName` + `revisionHistory` and would need it
re-expressed as `data_level` / `source_data[]` / `processing.json`.

**22. No checksum field in the metadata core.** PS, IMM. File integrity cannot be
verified from the registry alone. Fix: algorithm + value (e.g. MD5), core or
platform layer.

**23. Investigator / experimenter identity doesn't resolve.** PS, AICS. Team names
instead of people ("Ephys Core", "RNA-seq Core"), `registry_identifier` null
throughout, `acquisition.experimenters` an empty list. AICS also lacks
institution, funding, and investigators entirely — a validation blocker.

**24. `source` / institution not registry-resolvable.** PS, mIF, AICS.
`"Unknown/UNKNOWN"` with no ROR identifier; the data predates the ROR
requirement. The field is designed around animal acquisition and doesn't
translate to a human collaborator or collection site.

**25. `protocol_id` provenance is inconsistent.** PS, mIF. The field expects a
protocols.io DOI; some procedures have one, others are null, and AIFI uses SLIMS
IDs.

## Naming and identity

**26. `data_description.name` collision risk.** PS, mIF, AICS. Auto-built from
`subject_id` + `creation_time`; with date-only precision, two datasets created the
same day collide.

**27. `project_name` semantics undefined.** PS, mIF, AICS. Is it a project code
(`IVSCC`), an experiment ID (`EXP-01367`), a human-readable name, or both?

**28. Naming-convention question, raised and never captured.** PS. From the
original mapping observations: *"whether it was more important to be consistent
with names within the metadata for a given data asset vs being consistent across
data assets."* Still open, still unassigned.

## Coordinate systems

**29. `coordinate_system` required where it has no meaning.** PS, mIF, AICS. An
Illumina sequencer forced to declare `IMAGE_XYZ`. AICS has to supply
`instrument.global_coordinate_system` from a `camera_alignment_matrix` —
insufficient. Related and unresolved from the original notes: slicing distances
that move in semi-arbitrary increments until a landmark is seen, and unknown
orientation of neurosurgical tissue.

**30. Cell depth in slice and reporter positivity have no field.** PS. Low impact,
still unmapped.

**31. `stimulus_epochs` and `manipulations` are inapplicable to fixed tissue and
in-vitro work.** PS, mIF. Classified **Unmappable**. Root cause: the vocabulary
was designed around in-vivo mouse workflows.

## QC and calibration

**32. QC flags need normalizing into `QCMetric`.** AICS, TEA. AICS has boolean
quality flags; the fix is to normalize them into `QCMetric` objects. TEA-seq's
FRIP and TSS-enrichment are blocked by the modality enum (see #12).

**33. `calibrations` and `maintenance` may belong under QC, not acquisition.** mIF.
Raised as a question, not resolved.

## Instrument

**34. Instrument referential integrity is demanding.** AICS. Named cameras,
detectors, lasers, triggers, and coordinate systems are all required and must
match `Instrument.get_component_names()`. Generic image-file metadata (format,
TCZYX shape, axis order, byte size, previews) exceeds aind's acquisition-level
image model.

**35. Custom vs off-the-shelf instrument schema.** Cross-dataset, from the M0
report's 13-row table. Unresolved.

## Omics datasets: check CELLxGENE before recommending

`references/czi-schema-map.md` maps these gap numbers onto CZI's CELLxGENE
Discover schema v7.1.0. Short version — it answers **#15** (cell line / tissue
type, via Cellosaurus), **#7** (ethnicity, via HANCESTRO), **#6** (age, by having
no numeric age field at all), and gives a strong *pattern* for **#12** (bind
assay to an EFO subtree instead of a closed enum). It answers **#1** and **#8**
only partially, and has nothing at all on **#14**, **#16**, **#18**, **#22**,
**#29**, or anything about instruments and procedures. It also reveals five gaps
these analyses never looked for — suspension type, pinned reference genome
version, perturbation metadata, obsolete-term policy, and the discriminator
pattern for extensibility.

## What people liked (worth keeping in mind — not everything is a gap)

From the TEA-seq analysis, "AIND Nice things", verbatim on one item: *"QC
documents: omg LOVE."* Also praised: the multi-file structure, explicit
`data_level`, and the coordinate-system rigor where it applies.
