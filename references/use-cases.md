# Use cases

From `BDR - Use Cases - working doc.docx` (the live version). Header caveat,
verbatim: *"This is a snapshot of the first iterations beyond Jess' original
primer… This is not yet a prescribed approach or locked in design."*

IDs are `<PERSONA>-<n>`. Priorities: **P0** foundational, needed for a usable
product · **P1** core value, fast-follow · **P2** important, later. Most P0 entries
carry a `Success criteria:` list with measurable targets ("80% of searches return
a useful dataset", "≥1,000 entities per bulk operation", "in under 2 minutes").
P1/P2 usually have prose only.

44 use cases in the body. Counts: **P0 = 13, P1 = 15, P2 = 14** (the matrix says
42 because it collapses CUR-9a/9b).

## Personas

| Code | Persona | In one line |
|---|---|---|
| SCI | Scientist / Researcher | Consumes the registry to find, evaluate, access data. "Rarely writes metadata." Cares about discovery, fitness, provenance, getting to the bytes. |
| CUR | Data Curator | "The primary writer into the Registry and the main beneficiary of AI assistance." |
| ADM | Organization & Space Administrator | Governs who can see and do what; gates sensitive publishing; monitors holdings health. |
| AGT | AI Agent | Capabilities defined independently of surface (API / MCP / chat). |
| PRT | Partner Organization | External consumer of published or privately shared data. |

## All use cases

| ID | Title | Pri |
|---|---|---|
| SCI-1 | Structured, faceted search | P0 |
| SCI-4 | Evaluate DataAsset fitness before use | P0 |
| SCI-5 | Locate & access underlying files | P0 |
| SCI-6 | Trace up & downstream provenance | P0 |
| SCI-10 | Documentation & User Support | P0 |
| SCI-11 | Sharing selections of DataAssets and metadata quickly | P0 |
| SCI-0 | Meaningful front doors | P1 |
| SCI-2 | Natural-language cross-modal discovery | P1 |
| SCI-8 | "At a glance" Data Summary | P1 |
| SCI-7 | Related data recommendations | P2 |
| SCI-9 | Reporting and viewing inaccuracies | P2 |
| CUR-0 | (Pre-ingest) metadata validation | P0 |
| CUR-2 | Correct and enrich metadata | P0 |
| CUR-4 | Manage change history & roll backs | P0 |
| CUR-9a | Access Glossary | P0 |
| CUR-9b | Maintain Glossary | P1 |
| CUR-10 | Archive or retract | P1 |
| CUR-3 | Ensure provenance linkage | P1 |
| CUR-5 | Publish (manuscript) Collections | P1 |
| CUR-1 | Register entities (single and bulk) | P1 |
| CUR-7 | Review queue | P1 |
| CUR-6 | Consolidate entity duplicates | P2 |
| CUR-8 | Submission feed | P2 |
| ADM-0 | Manage organizing units, users, and roles | P0 |
| ADM-1 | Data sharing | P0 |
| ADM-2 | Flag and govern sensitive data | P0 |
| ADM-3 | Monitor holdings and quality | P1 |
| ADM-5 | Configurable Workspace Personalization | P1 |
| ADM-4 | AI cost monitoring | P2 |
| AGT-1 | Discover the Registry's schema, vocabularies, and capabilities | P0 |
| AGT-2 | Metadata query, filtering, and processing | P0 |
| AGT-3 | Natural-language querying and model-backed reasoning over results | P1 |
| AGT-4 | Assemble a reproducible dataset for a computational experiment | P1 |
| AGT-5 | Machine-assisted ingestion, curation, and harmonization | P1 |
| AGT-6 | Orchestrate multi-step plans | P2 |
| PRT-4 | Receive a private cross-org share | P1 |
| PRT-1 | Discover and access published data without an account | P2 |
| PRT-2 | Cite and resolve a Collection by DOI | P2 |
| PRT-3 | Consume metadata programmatically | P2 |
| PRT-5 | Interoperate with external archives | P2 |
| PRT-6 | Collaborators contribute to BioData Registry | P2 |
| PRT-7 | Validate data in published Collection | P2 |
| PRT-8 | Ask for data | P2 |

## Traps — the doc has real inconsistencies

Answer these correctly rather than reading the table naively:

- **`SCI-3` does not exist.** Gap in the numbering.
- **PRT has zero P0s, deliberately.** Verbatim: *"This is due to us focusing MVP of BDR on internal use cases first. Once BDR is also used as a publication platform with external sharing & browsing at scale, many of the P2s below will increase in relative priority."*
- **AGT-6 / AGT-7 conflict.** The body and the "by actor" table define `AGT-6: Orchestrate multi-step plans`. The "by priority" table invents `AGT-6 Integrate and invoke external tools` *and* `AGT-7 Orchestrate multi-step plans`. There is no AGT-7 in the body; "external tools" is referenced inside AGT-6's text. Treat the body as correct.
- **CUR-7** is printed in the P2 block of the "by priority" table but labelled P1.
- **CUR-9** appears as P0 in the body (as CUR-9a) and P1 in the matrix.
- **CUR-0 is typo'd "CUR-O"** (letter O) in cross-references inside CUR-1 and CUR-2.
- **M1 scope markers are lost.** The doc marks M1-focus items with text styling ("*Text = M1 focus for ingest & pre-validation*"). Formatting doesn't survive text extraction — if someone asks which use cases are in M1 scope, open the original .docx or say the marking isn't recoverable from the extraction.

## Dependencies

The AGT section is the only one with a formal `Dependencies:` declaration. It
names SCI-1/2/4/5/6/10/11, CUR-0/1/2/3/4/7/9, ADM-0/2/3/4.

## Domain nouns used as entities

DataAsset · Collection · Space · Organization · organizing unit (bracketed in the
doc — the term is not settled).

## Not in the working doc

Two things live only on the Figma use-cases board
(`resources/_text/Figma Boards__BDR- Use Cases.pdf.txt`):

1. **The HISE general data-ingestion flow** — watch folder → file received →
   filetype assigned by type + source → metadata record created → pipeline
   process (pub/sub decorator pipeline service, ingest agent service, ingest data
   service, ledger data service) → validate against data dictionary/schema →
   errors returned to user in UI, or accepted and made findable. Optional manual
   QC step. Raw data stays in various storages throughout. Useful as prior art
   for the M1 ingest design.
2. **UX process notes** — user interviews, participatory design for information
   hierarchy, design reviews every 1–2 weeks even when unfinished, Crazy 8's
   ideation, "Avoid Unnecessary Frontend Microservices" (with the HISE retro:
   splitting into NPM libraries and separate frontend apps "only created friction"
   for a team that size). Risks noted: *"Scientists will log data elsewhere that
   isn't tracked within the system and eventually gets lost"*, *"Too strict of
   ontology"*, *"Providing only high level data availability statuses"*.
