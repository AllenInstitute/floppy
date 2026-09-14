# CELLxGENE cross-reference — for omics gaps only

CZI's CELLxGENE Discover schema, bundled at
`resources/schema/single-cell-curation/`, v**7.1.0**, commit `1cb494af`
(2026-06-25). Field contract: `schema/7.1.0/schema.md`. Machine-readable twin:
`cellxgene_schema_cli/cellxgene_schema/schema_definitions/schema_definition.yaml`.
Every prior version is retained under `schema/<version>/`.

**What this file is for.** When a field in an omics dataset has no aind home,
check whether CELLxGENE already settled it. Recommending an adopted
specification is stronger than inventing a field — it carries evidence instead
of preference. CELLxGENE is a mature standard with real submitters and a
validator.

**What this file is not.** A mapping target. BDR maps to biodata-schema. Never
write a recommendation that says "use CELLxGENE"; write one that says "adopt the
pattern CELLxGENE uses for X, which is `<field>` bound to `<ontology>`".

## The shape difference, which constrains every borrowing

| | aind-data-schema | CELLxGENE |
|---|---|---|
| Container | multi-file JSON sidecars (`metadata.nd.json`) | one AnnData/H5AD file |
| Metadata lives in | typed Pydantic models | `obs` columns (per cell), `uns` keys (per dataset) |
| Unit | one acquisition of one subject | one dataset in a collection; for Visium, one tissue section |
| Scope | all modalities incl. instruments and procedures | single-cell omics + Visium/bead spatial, **minimum** search-and-integrate metadata |
| Extensibility | schema change | extra author `obs` columns, unvalidated |
| Vocabulary | closed Python enums in `aind-data-schema-models` | OBO CURIEs validated against pinned ontology releases |

The second row is the one that bites: a CELLxGENE `obs` field is a per-cell
annotation. aind has no per-cell layer at all. Borrowing `suspension_type` means
deciding *where* it lands — `Acquisition`, `SpecimenProcedure`, or a new
per-observation level. Say so in the recommendation; don't paper over it.

## Where CELLxGENE answers a known gap

Numbers are `known-gaps.md` gap numbers. Verdict is honest — three of these are
partial and two are non-answers people assume are answers.

| Gap | CELLxGENE field | Verdict |
|---|---|---|
| **#12** missing modality entries (mIF, scATAC, ADT) | `obs['assay_ontology_term_id']` — EFO, most accurate descendant of `EFO:0002772` *assay by molecule* or `EFO:0010183` *single cell library construction* | **Strong pattern, partial coverage.** The pattern is the answer: bind assay to an ontology subtree instead of a closed enum, and the vocabulary grows without a schema release. Covers scATAC-seq `EFO:0010891`, 10x multiome `EFO:0030059`, methylation `EFO:0002761`, MERFISH `EFO:0008992`, Patch-seq `EFO:0008853`, Visium `EFO:0022857/0022859/0022860`. **Does not cover ADT / CITE-seq or spatial proteomics — actively removed in 5.2.0.** So TEA-seq's ADT gap and mIF are *not* solved here. |
| **#15** no specimen subtype for the relevant biology | `obs['tissue_type']` — enum `"tissue"` / `"organoid"` / `"primary cell culture"` / `"cell line"`, which *switches* which ontology `obs['tissue_ontology_term_id']` is validated against | **Strong.** Directly answers the AICS cell-line problem. A cell line gets a **Cellosaurus** term (`CVCL_1P02` — underscore, not colon), not a subject ID, which is exactly the AICS doc's point that "treating a cell-line identifier as `subject_id` would be syntactically convenient but semantically misleading". Note the discriminator pattern: one enum field decides the vocabulary for another. |
| **#7** missing race / ethnicity | `obs['self_reported_ethnicity_ontology_term_id']` — **HANCESTRO** / **AfPO**, descendants of `HANCESTRO:0601` *ethnicity category* or `HANCESTRO:0602` *geography-based population category*; multi-valued, `" || "`-joined, ascending lexical order; `"na"` for non-human, `"unknown"` if unavailable | **Strong.** A named ontology, an explicit multi-value convention, and separate sentinels for not-applicable vs not-known. Better specified than anything the corpus proposed. |
| **#6** HIPAA age capping | `obs['development_stage_ontology_term_id']` — **HsapDv** for human, MmusDv for mouse, UBERON life-cycle-stage otherwise | **Strong, by a different route.** CELLxGENE has **no numeric age field at all** — no age, no unit, no range. Age is only ever an ontology stage term, so the 90+ problem cannot arise. Privacy is a submission-policy attestation ("No PII"), not a field. Worth raising as an option against aind's `year_of_birth`: coarsen by construction rather than special-case above 89. |
| **#8** disease / diagnosis over time | `obs['disease_ontology_term_id']` — `"PATO:0000461"` *normal*, or ≥1 **MONDO** terms (descendants of `MONDO:0000001` *disease* or `MONDO:0021178` *injury*), `" || "`-joined | **Partial.** Solves *multiple* diagnoses cleanly. Does **not** solve time-varying — no timepoint, onset, duration, or stage field. The mIF requirement for "multiple diagnoses with time-based updates" is only half answered. |
| **#1** asset-to-biology cardinality / pooled donors | `obs['donor_id']` — free-text categorical; conventions `"pooled"` (multi-individual sample not confidently demultiplexed) and `"unknown"` | **Weak — do not oversell this.** It gives you a *label* for the pooled state, not a model of the pool. There is no pool ID, no pool size, no `multiplexing_method`, no HTO/hashtag field, no demultiplexing-confidence field, and no home for unassigned cells. TEA-seq's `VRd-T24-Pool-01` still has nowhere to go. What is borrowable is the sentinel discipline: a reserved value meaning "genuinely pooled" is better than a null. |
| **#21** raw vs derived provenance | `obs['is_primary_data']` (bool) — canonical instance vs secondary/meta-analysis reuse | **Weak.** One boolean. No `source_data[]` equivalent, no lineage graph, no code reference. aind's `data_level` + `source_data[]` + `processing.json` is already richer. Don't recommend downgrading. |

## Where CELLxGENE has nothing — confirmed absent, not assumed

Grepped across the full 7.1.0 spec. Do not go looking:

- **#14 consent, licence, data-use restrictions** — entirely absent. No licence, consent, IRB, embargo, or restriction field. Only a No-PII policy attestation and a generated `uns['citation']`.
- **#16 sequential / multi-round assays** — nothing. No round, cycle, panel, or iteration field. Spatial proteomics was removed, so there is no cyclic-staining analogue.
- **#18 antibody / panel metadata** — nothing. `var` accepts only Ensembl gene IDs and ERCC spike-ins; there is no protein feature space at all.
- **#22 checksums**, **#25 protocol IDs**, **#23 investigators**, **#24 institution/ROR** — all absent. No integrity, protocol, personnel, institution, or funding fields.
- **#29 coordinate systems** — nothing transferable. Spatial carries pixel scalefactors (`spot_diameter_fullres`, `tissue_hires_scalef`) in full-resolution image space only. No physical units, no CRS, no registration transforms.
- **#17 plate / well / experimental design** — no `sample_id`, `library_id`, `plate`, `well`, `lane`, or `run` in `obs`. `uns['batch_condition']` is only a list of `obs` column names, advisory to integration algorithms.
- **Instruments, hardware, acquisition parameters, procedures, reagents, calibration, dissociation/fixation method, timestamps** — all out of scope by design.

The spec says so itself, in **Background**: the requirements are "just the
**minimum** required information… readily available from data submitters",
enough to search, filter, and integrate on Discover. Anything else is preserved
as unvalidated author metadata. Cite that sentence when you decline to recommend
from CELLxGENE — its silence is deliberate, not an oversight.

## Gaps CELLxGENE reveals that our analyses have not raised

Reading a mature omics schema surfaces things the aind-first analyses did not
look for. Raise these as candidate gaps when the dataset is omics — flag them as
new, and verify against the bundled aind repo before asserting absence.

1. **Suspension type — cell vs nucleus.** `obs['suspension_type']` ∈ `"cell"` / `"nucleus"` / `"na"`, and CELLxGENE *forces* the value per assay via a lookup table (ATAC → `"nucleus"`, MARS-seq and Patch-seq → `"cell"`, MERFISH → `"na"`, 10x → either). aind has no equivalent. This is a first-order analytical fact for any single-cell dataset and it currently has nowhere to live.
2. **Pinned reference genome / annotation version.** CELLxGENE pins a GTF per organism — human GENCODE v48 / GRCh38.p14, mouse vM37 / GRCm39, rat GRCr8 — and validates gene IDs against it. aind has no field for reference genome or annotation version. Two transcriptomics datasets aligned to different GENCODE releases are not comparable, and nothing in the registry records which was used.
3. **Perturbation metadata as first-class.** `obs['experimental_condition_ontology_term_id']` (UniProt for protein, CHEBI descendants of `CHEBI:24431` for chemical, `EFO:0002755` *diet*, `EFO:0001702` *temperature*) and `obs['genetic_perturbation_id']` + `obs['genetic_perturbation_strategy']` (enum: `"no perturbations"`, `"control"`, `"CRISPR activation screen"`, `"CRISPR interference screen"`, `"CRISPR knockout mutant"`, `"CRISPR knockout screen"`) with `uns['genetic_perturbations']` carrying protospacer sequence and PAM. Relevant the moment any Allen team registers a screen.
4. **Obsolete-term prohibition as a schema rule.** CELLxGENE bans obsolete ontology terms outright and ships `migrate.py` with automated replacement maps seeded from each ontology's "Replaced By". aind pins ontology releases but has no stated policy on what happens when a term is retired. That is a WS2 schema-governance question, and it is the same shape as the corpus's own open question about who governs vocabulary additions.
5. **The discriminator pattern for extensibility.** `tissue_type` decides which ontology validates `tissue_ontology_term_id`; assay decides the legal `suspension_type`. One typed field switching another field's vocabulary is a lighter-weight extensibility mechanism than either a new subclass or an untyped `protocol_parameters` dict — worth naming as an option in extensibility recommendations.

## Borrowing rules

1. **Pin and cite.** "CELLxGENE Discover schema v7.1.0, `obs['suspension_type']`". Same discipline as aind — never "the CELLxGENE schema" unversioned.
2. **Recommend the shape, not adoption.** Say what pattern to adopt and where it would land in aind's model. A CELLxGENE `obs` column is per-cell; aind has no per-cell layer, so every borrowing needs a stated home.
3. **Ontology commitments are governance decisions, not field decisions.** Borrowing `disease_ontology_term_id` means adopting MONDO. aind currently uses NCBI Taxonomy, ROR, and CCFv3 brain structures. Raise the ontology as a **Q** with WS2 as owner; do not assume it in an **R**.
4. **Check the changelog before citing a field.** Several things were removed, not just added: CITE-seq left `suspension_type` in 5.2.0, `obs['ethnicity']` was renamed, `obs['organism_ontology_term_id']` moved to `uns` in 6.0.0, `tissue_type` `"cell culture"` became `"primary cell culture"` in 7.0.0. Appendix A marks breaking changes. Citing a field that was withdrawn is worse than citing none.
5. **Don't force it.** Two-thirds of a BDR gap analysis — instruments, procedures, coordinate systems, governance — is outside CELLxGENE's scope entirely. Say a CZI cross-check found nothing and recommend from first principles.

## Known errata in the bundled copy

- The `organism_ontology_term_id` table lists `NCBITaxon:6293` for *C. elegans* in both the `uns` and `feature_reference` tables. The correct ID is `NCBITaxon:6239`, which the same document uses elsewhere. Typo in the spec, not in our copy.
- `__init__.py` in the CLI declares `__schema_version__ = "7.1.1"` — the validator is one patch ahead of the 7.1.0 document. Cite the document version.
- `gencode.py` notes its `SupportedOrganisms` set differs from the valid `organism_ontology_term_id` set.
