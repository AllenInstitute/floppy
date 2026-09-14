# BioData Registry — project brief

Condensed from the charter (`BioData Registry Project Overview.docx`, DRAFT v1)
and the M0/M1 decks. The charter says it is "an inform doc only… not
prescriptive" and will change. When a detail matters, check the source.

## North star

> The BioData (Metadata) Registry will make all biological data collected by the
> Allen Institute findable and accessible by our human scientists and agentic
> tooling.

API-first platform for metadata registration, validation, curation, schema
governance, auditability, and collection-level publishing. Cross-modal discovery
independent of where the underlying data sits.

**What it is not:** an archival or reproduction system. From the decisions board:
"The BDR is designed as an inventory system NOT an archival reference system…
the BDR will NOT be capable of reproducing raw data from a prior publication."
It is also explicitly **not a LIMS** — it holds metadata about data assets, not
workflow state.

## Core features

1. Unified Metadata Architecture & Access — normalized architecture, APIs, developer clients, agentic interfaces.
2. Metadata Quality & Lifecycle Management — validation, versioning, audit history, draft → published.
3. Metadata Discovery & Data Access — structured, semantic, and natural-language search.
4. AI-Assisted Metadata Workflows — agents generate/enrich/correct, human validates.
5. Governance, Sharing & Publishing — RBAC, sensitive metadata, collections.
6. User Experience — UX/UI for search, curation, management.

## Operating model

A **v-team**: six Workstreams with owners, plus three Horizontals that cut across.
Workstreams are explicitly not siloed; Horizontals lead shared decision-making.

| Horizontal | Focus |
|---|---|
| H1 | Design Spec & Program Management |
| H2 | Strategy & Execution |
| H3 | Integrations |

Named Horizontals in the decks: Jess (Thomas), David, Paul.

Each milestone runs a repeatable **3-week loop**: week 1 align on purpose /
deliverables / success criteria and assign tasks; week 2 decide what to build and
build it; week 3 integrate and run the DDM gate.

### Workstreams

| WS | Focus | Scope in one line |
|---|---|---|
| WS1 | Backend Architecture | System of record (relational DB, core entity model, referential integrity), read/search architecture, sync pipelines, API layer. |
| WS2 | Schema & Data Model | Define the unified metadata schema and normalized data model; extensibility and interoperability across modalities; govern schema evolution with WS3. |
| WS3 | Metadata Onboarding & Migration | Inventory and prioritize sources, define mapping/transformation to canonical schema, ingest and migrate, dedupe, validate readiness. |
| WS4 | Cloud Services Layer | Governance and access control to cloud storage, identity/SSO, security/audit/compliance, integration surfaces for external systems and agents. |
| WS5 | Agentic Layer & AI Interaction | Registry-specific agentic workflows, agent↔API/MCP integration, AI-assisted curation, AI apps for cross-modal analysis. |
| WS6 | UX / UI | API-first product experience; every UI workflow maps to a documented registry API; front end as reference client; sharing/publishing workflows. |

People seen in the corpus, by area (not an org chart — inferred from authorship):

- **Horizontals / program:** Jess Thomas, David Stark, Paul.
- **WS1 / backend:** Sven Otto, Aldan Beaubien, Sawyer Hood, abhe rajagopal.
- **WS2 / schema:** Alina Ott, Aishwarya Chander, Nathan Gouwens, Daniel Birman, Saskia de Vries, Nathalie Gaudreault.
- **WS3 / onboarding:** Ray Sanchez, Tim, Doug, Jessica, Mekhla.
- **WS4:** Alina Ott, Anish Chakka appear on decision-tracker material.
- **WS6 / UX:** Travis Kroeker, Sean Meharry, Jessica Liang.
- **Interviewed stakeholders** (Figma roster): Jack Waters, Sam Hastings (curator/admin, cross-species imaging), Chelsea Pagan, Bargavi Thyagarajan (admin/SciPM), Madeleine Hewitt (NHP spatial TX), Meghan Turner (human spatial TX), Zizhen Yao, Changkyu Lee (mouse MolBio, taxonomy), Yoav Ben-Simon (mouse MolGen & imaging), Anish Chakka (MolBio BI core).

## Decision making — DDM

A **Deliberative Decision Making** meeting is the structured milestone gate.
Workstream and Horizontal leaders assess progress against predefined success
criteria and gate prompts. Outcomes: ✅ Pass · ⚠️ Conditional pass (with actions)
· ❌ Rework required.

Within a milestone, Workstreams are empowered to decide and document on their
own; blockers escalate to Horizontals early.

## Milestones

| # | Name | Target | Key deliverables |
|---|---|---|---|
| M0 | Alignment, Scope & Success Definition | Aug 14, 2026 | **Track A** prioritized use cases across all users · **Track B** E2E architecture proposal with build-vs-rent · **Track C** diagnostic report applying biodata-schema to 3 datasets, cataloging every gap, conflict, unmappable field |
| M1 | Foundation: Unified Metadata Architecture & System of Record | gate Sept 11, 2026 | **Track A** reviewed ingest + pre-registration workflows and requirements for humans and agents · **Track B** ratified architecture requirements and backend ADRs for storage, search, DB access · **Track C** extend gap analysis to 2 more datasets (Cell Science, SeaHub) |
| M2 | Metadata Quality, Lifecycle & Governance | Sept 30, 2026 | Validation engine, versioning + audit trail, RBAC (Org → Space → User), lifecycle state machine (draft → registered → published → archived) |
| M3 | Discovery, Search & Access Experience | — | Structured + semantic + NL search, cross-modal discovery layer, web UI, public + authenticated access |
| M4 | AI-Assisted Metadata & Agentic Workflows | — | Agent for generation/enrichment/correction, human-in-the-loop validation, NL interaction layer |
| M5 | Scale, Performance & Cross-Org Sharing | — | Infra for 100M+ data assets, cross-org sharing/publishing, performance tuning |
| M6 | Productization & Continuous Improvement | — | Observability dashboards, feedback loops, docs/onboarding/support model |

### M0 outcome — ⚠️ Conditional pass (Aug 14)

Four required actions from the gate deck:

1. **Review M0 materials** — workstreams review the M0 key deliverables and build cross-workstream understanding.
2. **Answer blocking questions** — build consensus on open questions blocking M1. Note: M1 focuses on pre-ingestion validation and registration of a *single* dataset to the current BioData Schema.
3. **Revisit and refine deliverables** — update M0 deliverables with input from other workstreams.
4. **Document ADRs and decisions.**

### M1 success criteria

- Workstream owners identified
- Blocking architecture questions resolved
- Prototyping work on ingest + pre-registration unblocked
- Schema extensibility and evolution work unblocked

**WS3 M1 tasks** are only two: pick a workstream owner (rotation offered: Ray,
Tim, Doug, Jessica) and align on architecture requirements for ingest and
pre-registration. The rest of that doc is an open Q&A thread — see
`decisions-and-open-questions.md` §Ingest.

**WS2 M1 homework, due 09/11:** (1) gap analysis template + an `agent.md` doc for
future gap mapping, (2) Cell Science + SeaHub gap analyses, (3) consolidated Q&A
doc.

## Milestone metrics (M0/M1, for gate reporting)

M0: 6/6 workstreams with owners · % of open questions answered · % of prioritized
use cases with testable acceptance criteria per user · % of P0 architectural
decisions answered and documented · % of fields examined and classified per
dataset (mapped / gap / conflict / unmappable).

M1: % of core entities modeled and operational · validation pass rate on ingested
metadata · API success/error rate · time to register a new metadata entity.
