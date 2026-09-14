# SeaHub Discovery Meeting — Notes for the V Team

**BioData Registry, M1 Track C (SeaHub gap analysis) · Prepared by Aishwarya Chander**

## Summary

We met with SeaHub (Seattle Hub for Synthetic Biology, the CZI / Allen / UW joint org) to scope a representative dataset for the M1 Track C gap analysis. Their work is sequencing-first: amplicon, single-cell and bulk RNA, ATAC, Hi-C and high-throughput library screening all read out as sequencing, tracked in Benchling with compute and storage on AWS through Code Ocean. The two decisions we need from the project team are what counts as registerable data for a group still doing mostly pilot and technology-development work, and how to handle datasets co-produced with UW.

## Gaps and open questions

1. **Registration scope and granularity.** Much of their current output is pilot work, plasmid-confirmation sequencing, and barcode-distribution checks, and some of it gets discarded when an experiment fails. They need clear guidance on what belongs in the registry. Proposal from the meeting: register at the study or experiment level and link small runs to a parent record rather than registering each one. This is the open "continuous registration vs file noise" question, now with a concrete case attached.
2. **Prospective vs retrospective registration.** SeaHub asked that the registration path exist before their data volume arrives. Retrofitting once the datasets exist is expensive and is where gaps get baked in. Worth treating as a scheduling input, not just a scope question.
3. **Allen / UW co-owned data.** Their lineage-tracing single-cell dataset had Allen doing the injections and UW doing the analysis and publication, and the data is already public through NCBI. Who registers it, and how ownership and provenance get recorded, is unresolved. This overlaps the existing open question on ingesting from externally managed public locations with no internal copy.
4. **Library design metadata.** For HTS library screening, FASTQ files alone are not interpretable. Barcode count tables only mean something if you know the oligo library design and its members. The schema has no home for this today.
5. **Mouse model metadata.** Founder lines established by pronuclear injection and breeding, versus transient pronuclear or piggyBac injections used to make embryos for lineage tracing without carrying the animals forward. Also developmental stage (e.g. E9.5), CRE status, transgene present vs transgene activated, and lineage. Some of this may be tags on existing fields, some needs new fields. Determining which is part of the Track C work.
6. **Missing modalities.** Amplicon-seq, Hi-C and scATAC-seq have no modality entries. This extends known gap #12, which already flags scATAC-seq as missing.
7. **Vendor-generated data.** Some prep and sequencing is done by outside vendors such as Phase Genomics and long-read providers. The data is still part of Allen's holdings, and the provenance needs to say so.

**Confirmed and consistent with prior decisions:** the registry points to where data lives rather than storing the files, and future single-cell lineage-tracing datasets were named as the highest-value candidates for registration.

## Actions

| Action | Owner |
| --- | --- |
| Define which pilot, confirmatory, library-screening and discarded datasets enter the registry | Registry team |
| Take Allen–UW ownership and provenance question to the broader project team | Registry team |
| Assess schema fit for mouse subjects, developmental stage, transgene activation, founder-line vs embryo arms | WS2 / Track C |
| Determine what oligo-library design and barcode-count metadata must accompany sequencing files | Registry team |
| Get the Benchling information model (protocols, designs, data types) from Kenny | Aishwarya |
| Review the DNA Typewriter preprint and its public dataset as the reference example | Aishwarya |

## Work and data types

**Platforms:** Illumina NextSeq, PacBio Vega, Oxford Nanopore MinION and PromethION.

**Assays:** single-cell RNA-seq, bulk RNA-seq, scATAC-seq, amplicon-seq, Hi-C, high-throughput oligo and sequence library screening, MPRA, and Perturb-seq (UW side only).

**Analysis outputs:** raw FASTQ through established pipelines into count matrices and derived outputs. Depending on the experiment that means prime-editor edit calls, barcode enrichment before and after treatment, ATAC-seq or Hi-C peaks, single-cell population quantification, or per-locus editing status.

**Specimens:** mouse, including founder lines and staged embryos, plus in vitro work in mouse and human cell lines.

**Group:** the team we met (DY) is about 20 people plus 3 computational staff. SeaHub overall spans 5 PIs across CZI, Allen and UW, including a lineage-tracing effort annotating signaling events with Marion Pepper's group, and MPRA work with Jesse Gray.

## Systems and workflow

**Benchling** is the primary LIMS and holds protocols, experimental design and data types. Results are linked from experiment records rather than stored in Benchling. Kenny built the configuration and is the contact for the details.

**Google Sheets** tracks analyses, linking out to Google Drive documents with high-level result summaries.

**Code Ocean** holds computational code and runs most compute on AWS. A GitHub org exists but is used lightly, mainly for outside collaborators.

**Storage** is moving to AWS. Some data still sits on local Isilon storage.

**Reference dataset:** no public dataset exists for their current work, so they pointed us at the DNA Typewriter mouse lineage preprint (Yu, Kim, Seidel et al., bioRxiv 2026) as the closest model for what the registry will need to support. Raw data at GEO GSE341627, code at github.com/seidels/dtt-mouse-analysis, plus the NextCell browser. Note: the AI meeting notes call this the "Chander paper," which is a transcription error.

## General meeting notes

Registration scope took up most of the discussion. The group worked through study, experiment and acquisition as candidate minimum units, and landed on the view that small pilot and QC runs should be linked to a broader record rather than registered individually. SeaHub raised that a good share of current work is technology development, where datasets are sometimes discarded because the experiment failed or did not answer the question, and asked for guidance on where the line sits. Characterization data for founder mouse lines was flagged as potentially worth keeping even though it looks like pilot work.

On collaborative data, the specific case is a lineage-tracing single-cell dataset with Allen injections and UW analysis and publication, already public on NCBI. The suggestion from the meeting was to add metadata tags when collaborative single-cell analyses are brought into Code Ocean so those records line up with the registry's metadata model. Nathan noted that collaborative data from other parts of the institute will raise the same question, and that for now we should capture enough about how externally generated data was collected for institute researchers to use it.

On the schema side, we walked through the mouse experimental arms and the metadata that goes with them, and agreed that some of it will map to existing concepts with added tags while other parts will need new fields or new recording structures. Sorting that out is the Track C deliverable.

## Attendees

- Aishwarya Chander, BioData Registry, WS2
- Nathan, BioData Registry
- SeaHub: [names to confirm]

Referenced but not present: Kenny (Benchling configuration)
