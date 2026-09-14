# Decisions and open questions

The corpus scatters this across a FigJam board, the WS2 hub page, the M0 report
Q&A 1–15, and the M1 task thread. This is the cleaned synthesis. When someone
asks "did we decide X?", answer from here and name the source.

Nothing here is a substitute for asking the owner. If a question is listed as
open, say it's open — do not manufacture a resolution.

## Decided

Attributed to Jess Thomas unless noted. Source: the Figma "Documented
Answers/Decisions" column, plus the WS2 ADR draft.

| # | Decision |
|---|---|
| D1 | **Data Asset is the unit of registration.** "A persistently-identified single data file or organized set of files that carries metadata and provenance, resolves to one or more physical distributions, and references the subjects and samples it describes." |
| D2 | **One raw asset ≈ one acquisition.** Raw assets are registered as acquisitions, or instrument- and time-bound collections of data. One data asset for files produced during a single acquisition; one for files produced by a single automated computation. |
| D3 | **Both raw and derived assets are in scope**, but raw is mapped first. (Strategy, not a hard decision.) |
| D4 | **BDR is not a LIMS.** It captures metadata about data assets, not workflow state management. |
| D5 | **Everything in BDR applies to an existing data asset.** |
| D6 | **Default boundary policy on storage:** BDR supports registration and search of data assets on any cloud (Azure, AWS, GCP) and Allen on-prem (VAST, Isilon). Ingestion, registration, and search only. |
| D7 | **Owned vs unowned data.** Owned (Allen-governed): BDR facilitates authorized access and retrieval. Unowned: BDR provides a file path and facilitates an authorization request to the owner; if granted, BDR facilitates retrieval. Priority: owned — 1. AWS, 2. GCP, 3. on-prem VAST/Isilon. Non-owned: TBD. |
| D8 | **BDR is an inventory system, not an archival reference system.** It will not be capable of reproducing raw data from a prior publication. |
| D9 | **Revision history will be maintained** for each core component table in the BioData Schema, for assets that are validated and stored in the persistence layer. |
| D10 | **Semantic versioning for the schema.** |
| D11 | **A file path is sufficient storage-system support** — the registry stores references, not data. |
| D12 | **Large ontologies are reached via public API (OLS4), not packaged.** |
| D13 | **Schema storage format is inconsequential** provided it is human-readable. |
| D14 | **ETL boundary is a per-submitter schema contract**, not logic inside each LIMS / Airtable / Smartsheet. |

## Open — architecture

| Question | State |
|---|---|
| **Relational DB vs document store.** PostgreSQL + JSONB, or MongoDB/DocDB? | Open. Two explicit votes relational, two neutral/API-first. All three existing registries differ: ND → PostgreSQL + JSONB, Brain Science → PostgreSQL + jsonb hybrid + OpenSearch, Immunology → MongoDB + MySQL. Decision tracker has Mongo at $28k / 1.1 FTE, contested on referential integrity. |
| **Kubernetes vs serverless.** | Open. ND and Brain Science both went serverless/managed (Fargate, RDS, Aurora); Immunology runs Google Cloud K8s. Decision tracker: Lambda **Approved** for core services with ECS/EKS for long-running workloads. |
| **Search stack.** | Contested. Self-managed Elasticsearch $38k / 1.2 FTE flagged high-FTE. |
| **Auth.** | Pending. AWS Verified Permissions "struggles to handle permission-filtered search." |
| **API style** — REST (FastAPI) vs GraphQL for create/update/delete? | Open. |
| **Permission group nesting depth.** Candidates from 2 levels (org, individual) to 5 (+team). At what level are constraints applied — institute, team, modality? | Open. |
| **Arbitrary per-person, per-dataset sharing** — or can every access decision resolve through group membership? | Open. |
| **How much auth lives in BDR vs in accelerator-specific tooling.** | Open. |
| **Inference-time compute** for complex search, curation, transforms needing GPU/AI — who owns it? | Open. |
| **What archiving means.** Asserted archive ≠ delete. Is there a level-of-access layer (archive = deep glacier)? Tombstones for old versions with redirects to latest? | Open. |
| **Performance benchmark for search.** | Open. |

## Open — data model and semantics

| Question | State |
|---|---|
| **What is a specimen? Sample vs specimen?** What information does "specimen" capture and could it be captured otherwise? | Open, and repeatedly raised. Drives multiple gaps. |
| **Data granularity** — strict (acquisitions and collections) vs loose (files). Individual files? Directories? Compressed archives? Databases? | Partly decided by D1/D2, but the strict/loose sticky is still marked open. |
| **How much provenance does the registry hold** — code, environment, input data? | Open. |
| **Continuous registration vs file noise.** How to balance registering everything against scientists registering only milestone artifacts. | Open. Three existing approaches on record: ND registers only when a result is deemed useful; Immunology uses filetyping + archival + provenance tracking + user cleanup; Brain Science treats it as an integration guideline ("register files that are shared or represent a meaningful step"). |
| **Record-level update history** — additive with no history, vs immutable revision chain. | Contested. |
| **Minimum searchable fields.** | Open. |
| **What a search returns.** | Open. |
| **Does BDR replace existing registries or sit as a layer on top?** What does the transition look like? | Open. |
| **Sensitive metadata** — does "sensitive metadata handling" extend to arbitrary redaction of fields under some circumstances? | Open. |
| **Data use agreement verification loop** — do we interface with Malbek? | Open. |

## Open — ingest and pre-registration (M1 focus)

From the WS3 M1 task doc. Questions attributed; Ray Sanchez answers most.

| Question | Asked by | State |
|---|---|---|
| Can metadata in the registry be updated or deleted? | Tim | Open. |
| **Point-in-time reads** — "git allows you to reference the state of the repo at a given commit; do our users need to be able to reference the state of the registry at the point they published?" | Tim | Open. |
| **Scope of agentic involvement in ingest** — mapping-only (agent produces submitter schema + transformation, ingest is a separate workflow) vs mapping-and-ingest in one agentic workflow. | Tim | Ray: "my sense is that this is what we're after" — one combined workflow. Not ratified. |
| Does a submission have a single ID? Does the registry track at the **Observation** level or only at constituent-entity level? | Tim | Open. |
| If metadata is edited in BDR, must changes **propagate back to source registries**? | Jess Thomas | Ray: "a tall order for a v1." Effectively deferred. |
| Ingest from externally managed public locations (`s3://allencell`, AWS Open Data) with no internal copy? | Jess Thomas | Open. |
| **Propagating metadata through nested schema relationships** — metadata on a "Plate" becoming available at the "Well" level. | Jess Thomas | Open. Directly relevant to the AICS gap on plate/well modeling. |
| Automated ETL submitters with no human in the loop (e.g. PowerApps). | Ray | Open. Brain Science mitigations cited: (1) a contract with the lab team's interface before ingest, (2) an ingest service upstream of the registry that validates before ingest. |
| Provisional tier — the **data hopper** for messy submissions. | Ray | Proposed, not decided. |

## Open — the meta-complaint

The largest sticky on the board, from abhe rajagopal, is worth surfacing because
it recurs:

> "Who is making this document and where does it live? I think we need this
> before we build anything. The use cases do not seem sufficient. We need specs
> and requirements and diagrams that cover all the workstreams."

## How the three existing registries answer the same questions

Full text in `resources/General/1. Milestone 0/Key Deliverables/M0 DDM_BDR - Workstream1 Answers.md`.

| | Neural Dynamics | Immunology (HISE) | Brain Science (BKP v2) |
|---|---|---|---|
| Metadata store | PostgreSQL, search columns + JSONB, schema def in separate table | MongoDB (metadata) + MySQL (accounts) | PostgreSQL relational, heavy jsonb for user-defined schemas |
| Search | — | interested in Mongo Atlas text + vector | OpenSearch (property) + PostgreSQL (relationship) |
| Schema language | SQLModel (Python) dumped to .sql for Aurora | go/mongo, go/mysql, Swagger, `hise-data-contracts` | C# + EntityFramework Core ORM; GraphQL via HotChocolate; user schemas in JSON Schema |
| Versioning | audit table, AWS SNS notifications | `revisionHistory` on some entities, semver on services and SDKs, **APIs not versioned — named as a mistake to avoid** | assets immutable (hash); latest-only for provenance entities with audit fields; **versioned per-entity schemas** ("HumanDonor v1.2.0") |
| Compute | AWS serverless, extensively | Google Cloud K8s | ECS Fargate + AWS RDS |
| Storage | a few curated AWS buckets; references only, so agnostic | GCP + Google Workspace | agnostic; "filepath" and "keyvalue" providers, admins register S3/Isilon/archives |
| Updates | audit tables allow reversal | atomic yes; reversible/deltas only for tracked fields; patches yes | splits *system* schema changes (SQL migration by the software team) from *user* schema changes (user-owned, rarely backfilled) |
