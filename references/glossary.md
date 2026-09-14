# Glossary

Project terms as actually used in the corpus. `?` marks an expansion or meaning
inferred rather than stated — say so if you pass it on.

## Project machinery

| Term | Meaning |
|---|---|
| **BDR / BioData Registry** | This project. Cross-accelerator Allen Institute metadata registry for registration and search of data assets. Inventory system, not an archive, not a LIMS. |
| **DDM** | Deliberative Decision Making — the structured milestone gate meeting. Outcomes: Pass / Conditional pass / Rework. |
| **Horizontal (H1–H3)** | Cross-cutting strategic roles: H1 design spec & program mgmt, H2 strategy & execution, H3 integrations. |
| **Workstream (WS1–WS6)** | WS1 backend, WS2 schema & data model, WS3 onboarding & migration, WS4 cloud services, WS5 agentic/AI, WS6 UX/UI. |
| **Track A / B / C** | Parallel deliverable tracks within a milestone. A = use cases / workflows, B = architecture, C = schema & gap analysis. |
| **M0 … M6** | Milestones. M0 closed Aug 14 2026 on a conditional pass; M1 gate Sept 11 2026. |
| **ADR** | Architecture Decision Record. |
| **v-team** | The cross-accelerator virtual team structure. |
| **One Institute** | The framing for cross-accelerator shared infrastructure. |
| **FAIR** | Findable, Accessible, Interoperable, Reusable. Used both as a principle and as a metadata-completeness score in use case SCI-4. |
| **CSC** | Central Scientific Computing — the department BDR sits under. `?` |

## Schemas and standards

| Term | Meaning |
|---|---|
| **aind-data-schema** | AIND's existing Pydantic metadata schema. Bundled here at v2.9.0 (commit `18114d7b`). Multi-file: `subject.json`, `data_description.json`, `procedures.json`, `instrument.json`, `acquisition.json`, `processing.json`, `quality_control.json`, `model.json`, combined into `metadata.nd.json`. |
| **biodata-schema** | The target cross-accelerator schema: **an expansion of aind-data-schema**. Same lineage, widened to cover every accelerator's modalities rather than only Neural Dynamics'. At M0 it is materially aind-data-schema — v2.9.0 is the final aind-data-schema release, with `biodata-schema` as its successor — so a gap found against aind-data-schema is a gap biodata-schema is meant to close. The corpus itself never states this; confirmed by Aishwarya Chander, 2026-08-27. |
| **aind-data-schema-models** | Separate pip package (`>=6.1.0,<7`) holding the controlled vocabularies: species, organizations, modalities, units, brain atlas, registries, licenses. Not vendored — enum *values* must be read from `resources/schema/aind-data-schema/docs/source/aind_data_schema_models/*.md`. |
| **`.nd.json`** | The file extension convention for a combined metadata record (`Metadata._FILE_EXTENSION`). "nd" for Neural Dynamics. |
| **REMBI** | Recommended Metadata for Biological Images — the categorization scheme on the AICS side. |
| **NWB** | Neurodata Without Borders — file format for the Patch-seq ephys asset. |
| **SWC** | Standard neuron-morphology reconstruction format (with a companion marker file). |
| **ROR / ORCID / RRID** | Research Organization Registry (institutions) / researcher IDs / research resource IDs (currently the only formal antibody identifier in the schema). |
| **OLS4** | EMBL-EBI Ontology Lookup Service v4. The agreed way to reach large ontologies rather than packaging them. |
| **EMAPA / FMA / CCFv3** | Mouse developmental anatomy ontology / Foundational Model of Anatomy / Allen Common Coordinate Framework v3. |

## Accelerators, teams, systems

| Term | Meaning |
|---|---|
| **AIND / ND** | Allen Institute for Neural Dynamics. Source of aind-data-schema. |
| **AIBS / Brain Science / BKP** | Allen Institute for Brain Science. Its registry is "BKP Registry v2" (Brain Knowledge Platform `?`) — PostgreSQL + jsonb, GraphQL via HotChocolate, C#/EntityFramework, OpenSearch. |
| **AIFI / Immunology** | Allen Institute for Immunology. Appears as a subject-ID prefix (`AIFI20178`). |
| **AICS / Cell Science** | Allen Institute for Cell Science. Has its own candidate schema v0.6.0. |
| **HISE** | Immunology's data platform (storage + ledger DB + microservices). MongoDB for metadata, MySQL for accounts, Google Cloud K8s, GCP storage. Expansion not given in the corpus. |
| **SLIMS** | The LIMS product used as metadata source of record for Immunology (Cell DIVE, TEA-seq) and partly ND. |
| **LIMS2** | Brain Science's LIMS; source for Patch-seq. |
| **AMDS** | The Immunology dictionary/metadata-scheme service. |
| **SeaHub** | An Allen Institute organization, peer to Immunology and Brain Science. Second M1 Track C dataset source (with Cell Science); collaborator TBD in the corpus. Confirmed by Aishwarya Chander, 2026-08-27. |
| **Code Ocean** | Compute/scratch workspace where AIND intermediate artifacts live. |
| **docb** | AIND's existing document database; noted as going out of sync with Code Ocean. |
| **Dataverse** | Post-migration metadata destination for Brain Science / ND. `?` |
| **VAST / Isilon** | Allen Institute on-prem storage. |
| **Malbek** | Contract-lifecycle vendor; open question whether BDR interfaces with it for data-use-agreement verification. |
| **Metaxy** | External metadata-store tool under evaluation. |
| **DANDI / BIL / NeMO / NIMP / OpenNeuro / GEO / dbGaP** | External archives BDR should interoperate with (use case PRT-5). |

## Assays and modalities

| Term | Meaning |
|---|---|
| **Patch-seq** | Ephys + transcriptomics + morphology from one cell. The M0 stress-test dataset; one cell produces four modality assets. |
| **mIF** | Multiplexed immunofluorescence. Cyclic, antibody-based. **Absent from the Modality enum.** |
| **Cell DIVE** | The mIF platform Immunology uses. 10+ sequential staining rounds with H₂O₂ bleaching between them. |
| **TEA-seq** | Simultaneous scRNA-seq + scATAC-seq + ADT from permeabilized PBMCs. Report expands it as "Transposase-Accessible Chromatin with RNA and Epitope sequencing". |
| **ADT** | Antibody-Derived Tag — the surface-protein readout (28-plex panel in the TEA-seq example). |
| **HTO** | Hashtag oligo — pools donors per lane, demultiplexed after. |
| **CITE-seq** | Cellular Indexing of Transcriptomes and Epitopes by sequencing. |
| **scATAC / scRNA / Flex / Xenium / OLINK / FLOW** | Assays cited as missing or under-covered in the modality vocabulary. |
| **Ecephys** | Extracellular electrophysiology. |
| **SPIM / exaSPIM / SmartSPIM** | Light-sheet imaging platforms with worked examples in the schema repo. |
| **IVSCC** | An Allen project code appearing in Patch-seq `data_description.project_name`. The doc calls it "a project code, not a human-readable name". Expansion not given. `?` |
| **NHP** | Non-human primate (`Macaca mulatta` in the Patch-seq example). |
| **PBMC** | Peripheral blood mononuclear cell. |

## BDR domain vocabulary (from the use cases and decisions board)

| Term | Meaning |
|---|---|
| **Data Asset** | The unit of registration. Decided: "a persistently-identified single data file or organized set of files that carries metadata and provenance, resolves to one or more physical distributions, and references the subjects and samples it describes." For raw data, **one raw asset ≈ one acquisition**. |
| **Collection** | A grouping of data assets, e.g. for a manuscript. Candidate stand-in for a Cohort. |
| **Organization → Space → User** | The RBAC hierarchy (M2 deliverable). "Organizing unit" appears in brackets in the use cases — the term is not settled. |
| **Observation** | Tim's proposed name for a whole canonical-model instance. Open whether the registry tracks at this level or only at constituent-entity level. |
| **data hopper** | Ray's term for a staging tier where users submit messy, not-yet-conformant data. The registry surfaces it but marks it provisional. |
| **Lifecycle states** | draft → registered → published → archived. Archive ≠ delete (open: what archive actually means). |
| **Personas** | SCI scientist · CUR curator · ADM org/space admin · AGT AI agent · PRT partner org. |
