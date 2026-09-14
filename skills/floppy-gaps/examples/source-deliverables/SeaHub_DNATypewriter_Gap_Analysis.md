# SeaHub Gap Analysis

**Dataset/System:** DNA Typewriter in vivo lineage recording (Yu, Kim, Seidel et al. 2026 preprint) — representative SeaHub dataset
**Source Organization:** Seattle Hub for Synthetic Biology (SeaHub) · Allen Institute · University of Washington
**Prepared by:** Aishwarya Chander · Workstream 2
**Reference Schema:** aind-data-schema v2.9.0 (commit 18114d7b), models >=6.1.0,<7. CELLxGENE Discover v7.1.0 (commit 1cb494af) consulted for omics cross-reference.
**Milestone:** Milestone 1 — Track C · DDM Gate: Sept 11, 2026
**Status:** Draft — placeholder mode
**Date:** 2026-09-14 · **Version:** v0.3

> **Placeholder mode.** This analysis was prepared from a preprint and a scoping conversation, not from a metadata export. Source field names below are descriptive labels for quantities the paper reports, not real keys from a SeaHub system. Classifications are verified statements about what aind-data-schema v2.9.0 does and does not contain; they are not statements about what SeaHub records. Metrics are not comparable to the Patch-seq, Cell DIVE mIF, TEA-seq, Immunology or AICS analyses, all of which were prepared from real field inventories.

## Detailed Dataset Analysis: DNA Typewriter lineage recording (Mouse, SeaHub)

This section provides a field-level breakdown for the dataset SeaHub nominated as representative of the work the registry will need to support. DNA Typewriter is a genomic recording system: a prime editor and an engineered target array are delivered to a mouse zygote by pronuclear injection, and each cell division writes an ordered insertion into a six-position register, so that a single destructive readout at E13.5 recovers the cell's division history rather than only its present state.

Two structural features drive most of the gaps. First, cardinality breaks in both directions at once — one embryo produces a bulk amplicon library, a single-cell transcriptome library, a single-cell recorder library and a ddPCR assay, while one combinatorial-indexing run carries nuclei from two embryos across twenty-five plates. Second, the biological subject is a transgenic embryo produced by injection into a donor zygote and gestated by an unrelated surrogate, a configuration that the required fields on `MouseSubject` cannot express at all.

**Source documents reviewed:**

- Yu Q, Kim H, Seidel S, et al. *In vivo reconstruction of the cell lineage history of a developing mouse with DNA Typewriter, from zygote to late organogenesis.* bioRxiv 2026.07.29.741625, posted 2026-07-30 — Methods, Computational Methods, Data/Code availability
- `seahub-dnatypewriter-metadata.nd.json` — annotated aind-format metadata example built for embryo #3. Attempting to populate a complete record is what surfaced the last four gaps below
- SeaHub scoping meeting, 2026-09 — assays, source systems, registration-scope questions
- aind-data-schema v2.9.0, commit 18114d7b — `core/`, `components/`, `docs/source/aind_data_schema_models/`
- CELLxGENE Discover schema v7.1.0, commit 1cb494af — `schema/7.1.0/schema.md`
- `teaseq-metadata.nd.json` (Immunology TEA-seq Example) — format and granularity reference

**Sample asset:**

- Embryo #3 (*Mus musculus*, C57BL/6J, E13.5, sex not determined), 1 of 10 transferred, 1 of 3 carrying detectable recorder integrations
- Recorder: piggyBac-delivered PEmax-P2A-dTomato and epegRNA-circTAPE, 11 TAPE integration barcodes, ~7 PEmax copies by ddPCR
- Four acquisitions from one embryo: bulk TAPE amplicon-seq (NextSeq 2000), sci-RNA-seq3, single-cell TAPE, duplex ddPCR (QX600 AutoDG)
- Pooling: nuclei from embryos #2 (~24M) and #3 (~10M) co-processed across 6 RT plates → 6 ligation plates → 25 PCR plates at ~400,000 nuclei per plate; cDNA split one third transcriptome / two thirds recorder, sequenced 80:20
- Derived: 1,340,794-cell dated phylogeny, 640,012-cell backbone, imputed node annotations, NextCell browser
- Source: GEO GSE341627; code at github.com/seidels/dtt-mouse-analysis; intermediates hosted on the NextCell site

## Gap Summary Overview

| Gap | Schema Layer | Detail |
| --- | --- | --- |
| Cardinality breaks in both directions within one study | Acquisition / DataDescription | One embryo yields four assay-level assets and one sci-RNA-seq3 run carries nuclei from two embryos. `Acquisition.subject_id` is a single required `str`; `specimen_id` may be a list but `check_subject_specimen_id` requires the subject ID to appear in each entry, so it cannot carry a second animal. Pool ID, pool size, member subjects and demultiplexing method are all unrepresentable. Sixth appearance of this gap — same as TEA-seq pooled lanes and Patch-seq four-modality cells, but the first dataset exhibiting both directions together. Populating the metadata example located the branch point precisely at genomic DNA extraction, where one specimen divides into the amplicon, ddPCR and single-cell assets with nothing recording the shared origin. Either decompose at onboarding or extend with `subjects[]`. |
| No Study or Cohort entity for the injection cohort | DataDescription | Ten embryos were transferred from one injection session, three carried integrations, one was pursued, and two separate indexing experiments produced the libraries. None of these groupings has a home above `data_description.tags[]`, which is free text and unsearchable. This is also the container SeaHub asked for, under which pilot runs, plasmid confirmations and barcode-distribution checks would be linked rather than registered individually. Same gap as Patch-seq, mIF, Immunology `cohortGuid` and AICS `collection_name`. |
| Modality closed enum missing amplicon-seq, bulk RNA-seq and digital PCR | DataDescription / Acquisition / Instrument / QC | Three of the four acquisitions have no modality term. The 22-value `Modality` enum contains `SCRNASEQ` but nothing for targeted amplicon sequencing, bulk transcriptomic sequencing, chromatin accessibility, chromatin conformation or quantitative PCR. `BARSEQ` and `MAPSEQ` exist but denote anatomical projection mapping, not a genomic recorder readout, and using either would be semantically wrong. Blocks `data_description.modalities`, `acquisition.data_streams`, `instrument.modalities` and `QCMetric.modality` simultaneously, as it did for scATACseq and ADT in TEA-seq. CELLxGENE resolves sci-RNA-seq3 exactly as `EFO:0030028` by binding assay identity to an ontology subtree rather than a closed enum. |
| Engineered recorder construct, barcode library and integration inventory have no schema home | Subject / Procedures | `subject_details.genotype` is a free-text string designed for inherited alleles. The recorder is delivered somatically at E0.5, mosaic, and present at variable copy number, so a single string cannot carry it. `NonViralMaterial` inherits from `Reagent` and offers name, source, lot and concentration — no construct map, cassette composition, vector backbone, or designed identifier space. Nothing holds the per-animal measured state: 11 integration barcodes in embryo #3 versus ~35 in embryo #2, ~7 versus ~2 PEmax copies, and the resulting difference between high, modest and absent recorder activity. Needs a subject-level genetic-modification record, not an extension container. |
| `date_of_birth` is required and meaningless for an embryo; no developmental stage field | Subject | `MouseSubject.date_of_birth` is required and typed as a date with BEFORE time validation. An embryo harvested at E13.5 has a conception date and a harvest date but no birth date, so any value entered is a fabrication. Developmental stage is the primary temporal anchor of the entire experiment — it determines how many divisions the recorder had time to write — and there is no field for it. CELLxGENE handles this by binding stage to MmusDv, under which E13.5 is an exact validated term. Make `date_of_birth` conditional and add an ontology-bound stage field. |
| `Sex` enum admits only Female and Male; the embryos were not sexed | Subject | `Sex` is a required enum with exactly two values and no sentinel for not determined or not applicable. E13.5 embryos processed whole for nuclei were never sexed, so the record cannot be completed honestly and the field cannot be left null. An embryo that was never sexed and an assay for which sex is meaningless are different records and need distinguishable sentinels. Sex is in principle recoverable from the sci-RNA-seq3 data after the fact, which makes it a derived annotation rather than a subject fact — a second reason a required enum is the wrong shape. |
| `BreedingInfo` cannot express a zygote donor plus an unrelated gestational surrogate | Subject / Procedures | `BreedingInfo` requires `maternal_id`, `maternal_genotype`, `paternal_id` and `paternal_genotype` and models two genetic parents. This dataset has three contributing animals: a superovulated C57BL/6J donor female, a sperm donor, and a pseudopregnant CD-1 surrogate of a different strain who contributes no genetic material. The concepts share a name but not a domain — `maternal_id` is defined as a genetic parent. The donor and surrogate also undergo procedures (hormone injection, transfer surgery) while producing no data asset of their own, which leaves it undecided whether they are registered subjects at all. |
| All molecular preparation steps fall to `SpecimenProcedureType.OTHER` | Procedures | Harvest and flash freezing, nuclei isolation, two-step fixation (methanol then BS3), genomic DNA extraction (Qiagen AllPrep 80204), reverse transcription, Tn5 tagmentation and two-step indexed library preparation — every step between the animal and the sequencer. The closed vocabulary (Sectioning, Immunolabeling, Fixation, Clearing, HCR, BARseq, Storage, Other and eight more) has no nucleic-acid or library-construction entry. `FIXATION` exists but nuclei isolation does not, so one source procedure splits across one mapped concept and one catch-all. Fifth independent appearance, after Patch-seq, mIF, TEA-seq, Immunology and AICS. These need controlled vocabulary additions, not free-text workarounds, to be searchable across datasets. |
| Three-level combinatorial index hierarchy has no representation | Acquisition | Cell identity in sci-RNA-seq3 is the composition of a reverse-transcription index, a ligation index and a PCR index across 6, 6 and 25 plates respectively. The first index is the only record of which embryo a nucleus came from, so without a plate and well model the demultiplexing provenance lives solely in analysis code and cannot be audited. Loading density (~400,000 nuclei per plate) drives collision and doublet rate and has no field. AICS raised the same absence for plate and well; this dataset nests it three deep and adds a pooling dimension on top. |
| Library design and per-embryo parsing references are required to read the raw data and cannot be registered | DataDescription / Procedures | The amplicon FASTQ is uninterpretable without two per-embryo reference sets derived by `tape/reference.py`: a whitelist of 12-base integration barcodes (`NNNNNAANNNNN`, admitted above 0.2% frequency and ≥3 mismatches apart) and an insertion vocabulary of admitted edit symbols. For embryo #3 the same sets are reused across the bulk and single-cell datasets. These are simultaneously derived outputs and required inputs, which the linear `source_data[]` model cannot express. The oligo library design has the same property and SeaHub raised it independently: barcode count tables are meaningless without the library membership list. A file required to parse the raw data is part of the registered asset, not an annotation about it. |
| `ProcessName` vocabulary omits every step in the pipeline, and the lineage tree has no asset shape | Processing | `ProcessName` has no entry for demultiplexing (bcl2fastq 2.20, deML), read alignment (STAR 2.6.1d against mm39 with GENCODE vM37), duplicate removal, count-matrix generation, or phylogenetic inference — so the entire pipeline registers as `OTHER` or `ANALYSIS`. Reference genome and annotation build have no dedicated fields despite being load-bearing for reuse. Separately, the principal product is a single dated tree spanning 1,340,794 cells with node-level ages and imputed annotations, and whether that registers as one derived asset, a family of assets, or a database-resident object the registry references is undecided — the same unresolved question raised for Patch-seq reconstruction annotations. `code.url` is populated here, which is unusual against the corpus baseline. |
| `metadata.location` is a single string; raw data sits at GEO and intermediates on a project website | DataDescription / Metadata | Raw data is deposited at GEO under GSE341627, intermediate files (lineage trees, metadata, scRNA-seq matrices) are hosted on the NextCell site, and neither is an Allen-managed path. Decision D11 states a file path is sufficient storage-system support and D7 covers unowned data, but the single-string field cannot hold a repository accession, a project-site URL and a bucket simultaneously. Same shape as the Patch-seq multi-directory gap and the TEA-seq CellRanger directory tree, with the added complication that the authoritative copy is external. |
| `other_identifiers` and institution fields cannot express five contributing institutions and two external accessions | Metadata / DataDescription | The dataset carries a GEO accession, a bioRxiv DOI, a GitHub repository, and two IACUC protocol numbers (#2530, #2401), with contributions from SeaHub, the Allen Institute, the University of Washington, HHMI and Fred Hutch. `other_identifiers` is a freeform object with no structure for distinguishing internal from external identifiers or typing them by registry, and `data_description.institution` expects one registry-resolvable organization. `acquisition.ethics_review_id` is `Optional[List[str]]` and does accept both protocols, but the procedure-level field is a scalar `str`, so a surgery governed by two protocols forces a choice. Same `other_identifiers` gap as TEA-seq, same institution gap as Patch-seq and AICS. |
| No checksum field anywhere in the metadata core | Metadata / Platform | A grep for checksum, md5 and sha256 across `src/` at commit 18114d7b returns nothing. File integrity cannot be verified from the registry alone, which matters more than usual here because the authoritative copy is held externally at GEO and could change without the registry knowing. Recorded for Patch-seq and Immunology; belongs in the platform layer alongside the storage reference, or in the manifest if integrity should travel with exported metadata. |
| `coordinate_system` is required where a sequencing run has no spatial frame | Instrument | `Instrument.global_coordinate_system` is required and every transform is checked against it by `recursive_coord_system_check`. None of the four acquisitions in this dataset has a spatial frame, so all four would be obliged to declare a fiction. Patch-seq recorded an Illumina sequencer forced to declare `IMAGE_XYZ`; this dataset would do the same four times over. Exempt non-spatial modalities, or add an explicit not-applicable coordinate system the validator accepts. |
| `specimen_id` substring validator conflicts with real specimen identifiers | Acquisition | `check_subject_specimen_id` requires `subject_id` to appear inside each `specimen_id`. The identifier `DTTembryo03-nuclei01` in the metadata example was constructed purely to satisfy the rule, exactly as TEA-seq constructed `AIFI00042_PBMC01` because SLIMS barcode `MS00000417` is not a substring of subject `AIFI20178`. The validator encodes an identifier convention as a structural constraint, so any source system whose barcodes predate the rule must mint synthetic IDs. Relax to an explicit subject-specimen relationship validated for existence rather than string containment. |
| `Procedures.subject_id` is scalar, so a reproductive chain spanning four animals cannot be filed | Procedures | Superovulation is performed on the donor female and transfer surgery on the surrogate, but `Procedures.subject_id` is a single string and the document belongs to the embryo. Neither procedure can be recorded against the asset they produced. The schema assumes procedures act on the subject that produced the data, which holds for every dataset analysed so far and fails the moment reproduction is part of the experiment. Either add a `performed_on` reference at procedure level, or register contributing animals as subjects and link them — Q3 asks which. |
| No sequencer or digital PCR device class, and `acquisition.instrument_id` is scalar | Instrument / Acquisition | `components/devices.py` has no sequencer or PCR class, so the NextSeq 2000, NovaSeq X and QX600 all register as generic `Device` and read structure, chemistry, flow cell type and run configuration have no home. Separately, one library pool here was sequenced across two instrument models while `instrument_id` holds one. This forces the `ExternalDataStream` workaround that both this dataset and TEA-seq adopted to dodge the requirement — a workaround that suppresses instrument metadata which is actually available. |
| `acquisition_type` is free text with no controlled vocabulary | Acquisition | `acquisition.acquisition_type` is an unconstrained `str`. "sci-RNA-seq3" would sit alongside the capitalisation problem TEA-seq recorded for its own assay name ("TEA-seq" / "teaseq" / "TEA-Seq"), which prevents search. Third dataset to raise it after Patch-seq and TEA-seq. Assay identity is currently stated in two places — `modalities` and `acquisition_type` — with different rules; it should be stated once, bound to whatever vocabulary the modality decision settles on. |

## Field Level Mappings

These tables document field-level mappings for the core schemas. Source field names are descriptive labels, not keys from a SeaHub system — see the placeholder note above.

### Subject — transgenic embryo

The source system tracks a transgenic C57BL/6J embryo generated by pronuclear injection at E0.5 and harvested at E13.5. The schema models a mouse subject as a born animal with a birth date, a recorded sex, a strain and two genetic parents. Neither the gestational timing nor the post-fertilisation genome modification has a place in that model, and the required fields are the ones that fail.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `embryo_id` | str ("embryo #3") | `subject.subject_id` | Mapped | Direct correspondence once a durable identifier replaces the manuscript's ordinal label. | Use as-is; require a persistent ID at onboarding. |
| `strain` | str (C57BL/6J, JAX 000664) | `subject_details.strain` | Mapped | Required `Strain.ONE_OF`; standard entry. | Use as-is. |
| `species` | str (*Mus musculus*) | `subject_details.species` | Mapped | Required `Species.ONE_OF`. | Use as-is. |
| `developmental_stage` | str (E13.5; injected E0.5) | — (no analog) | Gap | Primary temporal anchor of the experiment; determines how much history the recorder could write. | Add ontology-bound stage field (MmusDv pattern). |
| `date_of_birth` | not applicable | `subject_details.date_of_birth` | Conflict | Required, typed date with BEFORE validation. Embryo has conception and harvest dates, no birth date. | Make conditional; require an alternative temporal anchor. |
| `sex` | not determined | `subject_details.sex` | Conflict | Required enum, Female/Male only, no sentinel. | Add not-determined and not-applicable values. |
| `zygote_donor_female` | str (superovulated C57BL/6J) | `subject_details.breeding_info.maternal_id` | Needs Review | Genetic mother and a subject in her own right, having undergone hormonal treatment. | Decide whether contributing animals are registered subjects. |
| `surrogate_dam` | str (pseudopregnant CD-1, Charles River 022) | — (no analog) | Gap | Different strain, no genetic contribution; `BreedingInfo` has no slot for a non-genetic contributing animal. | Add surrogate reference with strain and role. |
| `genotype` | str (piggyBac PEmax + epegRNA-circTAPE, mosaic) | `subject_details.genotype` | Conflict | Free-text string for inherited alleles; cannot carry a somatically delivered, mosaic, variable-copy construct. | Add a genetic-modification record. |
| `iacuc_protocol` | list[str] ("#2530", "#2401") | `acquisition.ethics_review_id` | Mapped | `Optional[List[str]]` accepts both. Procedure-level field is scalar `str`. | Use as-is at acquisition; flag the procedure-level scalar. |

### Genetic modification — the recorder construct

The source system tracks an engineered recording system delivered as piggyBac transposon mRNA plus a plasmid library carrying a prime editor, an epegRNA, a degenerate insertion sequence and a barcoded six-unit target array. The schema models injected material as either a viral preparation or a generic reagent, neither of which carries construct architecture, library diversity, or the resulting per-animal integration inventory. This is the entity with the least schema surface and the most scientific weight.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `delivery_method` | str (pronuclear injection at E0.5) | `procedures.subject_procedures[].Injection` | Needs Review | `Injection.targeted_structure` is a `MouseAnatomyModel`; a zygote pronucleus is not an anatomical structure in that vocabulary. | Clarify target vocabulary for subcellular and embryonic injection. |
| `construct_identity` | str (PEmax-P2A-dTomato-WPRE-bGHpA, piggyBac vector) | — (no analog) | Gap | `NonViralMaterial` carries name, source, lot, concentration only. No construct map, cassette, promoter, insulator or backbone. | Genetic-modification record. |
| `barcode_library_design` | str (TAPE-BC `NNNNNAANNNNN`; insertion `NNNGGA`; 6-unit circTAPE) | — (no analog) | Gap | Defines the identifier space every lineage call depends on. Free text would make it unsearchable and unvalidatable. | Register as a referenced design artifact. |
| `integration_barcodes_detected` | list[str] (17 / 11 / 5 in embryos #2 / #3 / #6) | — (no analog) | Gap | Per-animal, measured not designed, and the partition key for all recorder analysis. | Genetic-modification record. |
| `transgene_copy_number` | float (~2 and ~7 PEmax copies, ddPCR) | — (no analog) | Gap | Explains the order-of-magnitude difference in recorder activity between embryos; determines dataset usability. | Genetic-modification record with measurement method. |
| `transgene_activation_state` | str (absent / modest / high editing) | — (no analog) | Gap | SeaHub raised transgene present versus activated as a distinction the registry must carry. | Genetic-modification record. |

### Procedures — animal and specimen preparation

The chain runs from hormonal superovulation through zygote collection, pronuclear injection, embryo transfer surgery, harvest and flash freezing, to nuclei isolation, two-step fixation and genomic DNA extraction. The animal side maps reasonably well. The molecular side falls almost entirely to the `OTHER` fallback.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `superovulation` | str (hCG and PMSG, intraperitoneal) | `subject_procedures[].NonSurgicalInjection` | Mapped | Fits the type, but is performed on the donor female rather than the registered subject. | Resolve which animal the procedure attaches to. |
| `embryo_transfer_surgery` | str (transfer into ampulla) | `subject_procedures[].Surgery` | Needs Review | Surgery is performed on the surrogate; the subject is the transferred embryo. | Surrogate role in `BreedingInfo`. |
| `harvest_and_flash_freeze` | str (PBS rinse, liquid nitrogen) | `SpecimenProcedure` (type OTHER) | Gap | No entry for harvest or cryopreservation; `STORAGE` describes conditions, not the freezing step. | Vocabulary addition. |
| `nuclei_isolation_and_fixation` | str (methanol then BS3 crosslink) | `SpecimenProcedure` | Conflict | `FIXATION` exists, nuclei isolation does not; one source procedure splits across two target concepts. | Vocabulary addition. |
| `gdna_extraction` | str (Qiagen AllPrep 80204) | — (no analog) | Gap | Produces the input to every amplicon library; recordable only as OTHER. | Vocabulary addition. |
| `library_preparation` | str (two-step indexed PCR; Tn5/Nextera N7) | — (no analog) | Gap | The most consequential ex-vivo step for a sequencing dataset has no type. Same absence Patch-seq recorded for SMARTer v4 and Nextera. | Vocabulary addition. |
| `protocol_reference` | str (textbook 4th ed.; sci-RNA-seq3 methods citation) | `procedures.*.protocol_id` | Conflict | `ProtocolMixin` expects a protocols.io DOI; a textbook chapter is legitimate provenance the field cannot express. | Clarify accepted protocol identifier types. |

### Acquisition — bulk amplicon sequencing of TAPE

One amplicon library per TAPE-bearing embryo, from 5 ng of genomic DNA by two-step PCR, sequenced on a NextSeq 2000. Read structure differs between embryos, with two single-end and one paired-end, which changes downstream parsing. The schema has no modality under which to register this acquisition at all.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `assay` | str (bulk amplicon-seq of TAPE) | `data_description.modalities` | Gap | No amplicon or targeted-DNA-sequencing entry. `BARSEQ`/`MAPSEQ` denote projection mapping. | Modality addition or ontology binding. |
| `sequencer` | str (Illumina NextSeq 2000) | `instrument.components[]` | Needs Review | No dedicated device class for a sequencer. | Clarify which device class applies. |
| `read_structure` | str (318/10/10 or 70/10/200; SE or PE) | — (no analog) | Gap | Determines whether the amplicon is recoverable from read 1 or must be reverse complemented from read 2. Acquisition configuration, not a processing parameter. | Add read-structure field. |
| `gdna_input_mass` | float (5 ng) | — (no analog) | Gap | Bounds library complexity and therefore the interpretability of barcode counts. | Add library-preparation input fields. |
| `pcr_cycles` | int (25–28, then 6–8) | `*.additional_settings` | Gap | Drives duplicate rate; expressible only through an extension container, which is not a semantic match. | Add library-preparation fields. |
| `coordinate_system` | not applicable | `instrument.global_coordinate_system` | Conflict | Required and recursively validated; a sequencing run has no spatial frame. | Exempt non-spatial modalities. |

### Acquisition — sci-RNA-seq3 with paired single-cell TAPE readout

Nuclei from two embryos are distributed across 6 reverse-transcription plates, pooled, redistributed across 6 ligation plates, pooled again, then distributed across 25 PCR plates at ~400,000 nuclei per plate. The cDNA is split, one third continuing as transcriptome library and two thirds amplified for the recorder array, and the two pools are sequenced together at 80:20. Every structural feature of this design is invisible to the schema.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `assay` | str (sci-RNA-seq3) | `data_description.modalities = SCRNASEQ` | Mapped | Applies. CELLxGENE identifies it precisely as `EFO:0030028`, which a closed enum cannot express. | Use as-is; consider ontology binding. |
| `subject_ids` | list[str] (embryos #2 and #3 in one run) | `acquisition.subject_id` | Conflict | Single required string; `specimen_id` list cannot carry a second animal because of the substring validator. | Decompose at onboarding or add `subjects[]`. |
| `rt_plate` / `rt_well` | str (6 plates, 96 wells) | — (no analog) | Gap | The first index is the only record of which embryo a nucleus came from. | Container hierarchy model. |
| `ligation_plate` / `pcr_plate` | str (6 plates; 23 + 2 plates) | — (no analog) | Gap | Cell identity is the composition of three indices across three plate levels. | Container hierarchy model. |
| `nuclei_per_plate` | int (~400,000) | — (no analog) | Gap | Determines collision and doublet rate, handled in the paper by a dedicated doublet-removal stage. | Container hierarchy model. |
| `suspension_type` | str (nucleus) | — (no analog) | Gap | Changes the expected expression profile; CELLxGENE requires it as a controlled field for this reason. | Add controlled cell/nucleus field. |
| `library_split_ratio` | str (1/3 transcriptome, 2/3 TAPE; sequenced 80:20) | — (no analog) | Gap | Two libraries from one cDNA pool sequenced in one run; neither one acquisition nor two independent acquisitions describes this. | Resolve with the cardinality decision. |
| `sequencer` | str (NextSeq 2000 or NovaSeq X) | `instrument.components[]` | Needs Review | One logical pool may be sequenced across two instrument models. | Clarify instrument cardinality. |

### Acquisition — droplet digital PCR

A duplex ddPCR assay quantifying prime-editor copy number against a GAPDH reference, reported as (Cas9 / GAPDH) × 2. This is a measurement about the subject rather than a dataset about the biology, and it is the assay that decided which embryo the study pursued.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `assay` | str (duplex ddPCR, QX600 AutoDG) | — (no analog) | Gap | No PCR or quantification modality; registering as OTHER makes the measurement undiscoverable. | Modality addition or ontology binding. |
| `target_probe` / `reference_probe` | str (Cas9 FAM; GAPDH Cy5.5, dMmuCNS559838272) | `components.reagent.*` (partial) | Conflict | Fluorophore and probe classes exist for imaging and in-situ work; a qPCR probe pair with a reference assay reuses the names but not the domain. | Clarify probe modelling for quantification assays. |
| `derived_copy_number` | float ((Cas9 / GAPDH) × 2) | — (no analog) | Gap | Per-subject quantitative result with a stated formula; gates whether a dataset is worth registering. | Genetic-modification record. |

### Processing and derived data

The pipeline runs from base calls through demultiplexing, trimming, alignment, deduplication and count-matrix generation, then through recorder-specific parsing, denoising, tree building and ancestral-state imputation, ending in a dated phylogeny and an interactive browser. The processing model accommodates the shape of this pipeline but names almost none of its steps.

| Source Field | Source Type | Target Field (aind) | Classification | Notes / Mismatch Detail | Recommendation |
| --- | --- | --- | --- | --- | --- |
| `demultiplexing` | str (bcl2fastq 2.20; deML) | `processing.data_processes[].process_name` | Gap | No entry; the step assigning reads to plates and therefore to embryos records as OTHER. | `ProcessName` additions. |
| `read_alignment` | str (STAR 2.6.1d, mm39, GENCODE vM37) | `processing.data_processes[].process_name` | Gap | No alignment entry; reference genome and annotation build have no dedicated fields. | `ProcessName` additions plus reference fields. |
| `count_matrix_generation` | str (UMI dedup, gene count matrix) | `processing.data_processes[].process_name` | Gap | The principal derived artifact of every transcriptomic dataset has no process name. | `ProcessName` additions. |
| `barcode_whitelist` / `insertion_vocabulary` | file (per-embryo, from `tape/reference.py`) | — (no analog) | Gap | Derived from the data and then required to parse it; reused across the bulk and single-cell datasets for embryo #3. Both an output and an input, which linear `source_data[]` cannot express — and the metadata example showed the dependency cannot be recorded on the raw asset at all, because `source_data_when_raw` raises if `source_data` is set on a RAW asset. | Register as referenced reference-set assets. |
| `lineage_tree` | file (1,340,794-cell dated phylogeny; 640,012-cell backbone) | `data_description.data_level = derived` | Needs Review | Spans all cells of one embryo with node-level ages and imputed annotations. One asset, a family, or a database-resident object is undecided. | Define registration shape for graph products. |
| `code_repository` | url (github.com/seidels/dtt-mouse-analysis) | `processing.data_processes[].code.url` | Mapped | Populated here, which is unusual against the corpus baseline where code URLs are absent. | Use as-is. |
| `raw_data_location` | str (GEO GSE341627; NextCell site) | `metadata.location` | Conflict | Single string; raw data at a public repository, intermediates at a project site, neither Allen-managed. | Asset root plus manifest; resolve external-ingest policy. |
| `file_checksum` | not recorded | — (platform) | Unmappable | No checksum field exists in the metadata core. | Platform-layer integrity record. |
| `institution` / `investigators` | list[str] (SeaHub, Allen, UW, HHMI, Fred Hutch) | `data_description.institution`, `investigators` | Conflict | Fields expect one registry-resolvable institution; this dataset has five and a publication led outside the Allen Institute. | Structured multi-institution provenance. |

## What the schema handles well

1. **Processing lineage, where it is populated.** `data_level` plus `source_data[]` plus `processing.json` is a clear raw-to-derived chain, and this dataset would populate `code.url` and container references properly — better than the corpus baseline, where code URLs are null throughout.
2. **Ethics review at acquisition level.** `ethics_review_id` is `Optional[List[str]]`, so two IACUC protocols fit without a workaround. Worth noting because the procedure-level field is not.
3. **Modular, independently versioned documents.** Splitting subject, procedures, instrument, acquisition and QC lets the well-understood parts of this dataset validate while the recorder modelling is still open.
4. **Institutional and investigator metadata exists at all.** ROR organizations, ORCID investigators and funding records are supported, which is more than the omics standards offer — CELLxGENE has no institution, funding or personnel fields.
5. **QC documents.** `QCMetric` with status history and tag-based failure rules would carry recorder-specific quality measures (barcode read depth, ordering-violation rate, doublet rate) cleanly, once the modality blocker is lifted.

## Open Questions

| # | Question | Blocking? | Owner / Target Date |
| --- | --- | --- | --- |
| Q1 | Is the unit of registration the study, the embryo, or the sequencing library? D1 names the data asset and D2 equates one raw asset with one acquisition, but a run pooling two embryos and two libraries from one cDNA pool satisfy neither cleanly. | Yes | WS2 · Sept 11 |
| Q2 | Will the schema commit to external ontology releases for assay identity and developmental stage, accepting their versioning cadence, or keep closed enums with a schema release per addition? | Yes | WS2 · Sept 11 |
| Q3 | Which animals in a reproductive chain are registered subjects? The zygote donor, the sperm donor and the surrogate all undergo procedures and none produces a data asset. | No | WS2 · Sept |
| Q4 | Does the registry acknowledge any level below the data asset? A per-cell, per-well or per-node layer is implied by both the plate hierarchy and the tree. | Yes | WS1 / WS2 · Sept 11 |
| Q5 | Who registers a dataset produced jointly by the Allen Institute and an external collaborator, published externally and deposited in a public repository? | Yes | WS1 / WS3 · Sept 11 |

## Milestone Metrics

| Metric | Value |
| --- | --- |
| Total fields examined | 54 |
| Mapped | 7 (13%) |
| Gap | 27 (50%) |
| Conflict | 13 (24%) |
| Unmappable | 1 (2%) |
| Needs Review | 6 (11%) |
| Entities covered | 7 |
| Gaps raised | 19 |
| Open questions (blocking) | 5 (4 blocking) |

**Placeholder caveat.** These counts are over a hypothesised field table derived from a publication, not over a real field inventory. They are not comparable to the Patch-seq, Cell DIVE mIF, TEA-seq, Immunology or AICS metrics and should not be pooled with them for gate reporting.

## Sources & Method

Classifications are verified statements about aind-data-schema v2.9.0 at commit 18114d7b. Each Gap was confirmed absent by reading the relevant module or generated vocabulary table; each Conflict by reading the field definition and its validators. No claim is made that any field is populated in any existing SeaHub record.

The CELLxGENE cross-check at v7.1.0 was run because the dataset is transcriptomic. It returned usable patterns for assay identity (`EFO:0030028` for sci-RNA-seq3), suspension type and developmental stage (MmusDv), and nothing for instruments, procedures, coordinate systems, provenance or integrity, which that schema declares out of scope by design. Patterns are borrowable; the fields are not, since a CELLxGENE annotation is a per-cell column and aind has no per-observation layer.

An annotated metadata example was then built for embryo #3 in the style of `teaseq-metadata.nd.json`, because attempting to populate a complete record tests the schema in a way that reading it does not. That exercise produced the last four gaps in the summary table and sharpened three others. Two defects were found in the TEA-seq example used as the format reference: a stray closing brace at line 259 terminates the root object, so the file does not parse, and its first `specimen_procedures` entry merges two procedures into one object with ten duplicated keys, silently discarding PBMC isolation under last-wins parsing. Neither defect was reproduced in the SeaHub example, and both are worth fixing in the corpus, since the M0 Report cites that file as the source document for the TEA-seq field-level mapping.

Where a gap recurs from an earlier analysis, the earlier finding may have been made against a different schema version — Patch-seq against v2.7.2, and Immunology, mIF and TEA-seq against an unpinned latest. Each recurrence recorded here was re-verified against the pinned commit rather than carried forward.

**Outstanding before this can leave placeholder mode:** the Benchling field export and a metadata example from a live SeaHub experiment (contact: Kenny, via Aishwarya Chander); confirmation of which SeaHub dataset is the actual Track C subject; and a decision on whether vendor-prepared sequencing and the NextCell browser are in registry scope.
