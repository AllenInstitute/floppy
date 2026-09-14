# floppy

BioData Registry project assistant. Two commands, one shared corpus.

| Command | Does |
|---|---|
| `/floppy-ask` | Answers questions about the BDR project and the aind-data-schema, from the bundled corpus. Cites its source. Says when something is open rather than inventing a resolution. |
| `/floppy-gaps` | Writes a schema gap analysis in the compact Milestone-0 format — a `.json` source of truth plus a matching `.docx` (a per-dataset section: Gap Summary Overview + Field-Level Mapping tables). Can seed the analysis JSON from an existing metadata export, and computes metrics from the field rows. |

## Install

This repo is both a **plugin** (`.claude-plugin/plugin.json`) and its own
**marketplace** (`.claude-plugin/marketplace.json`, named `allen-bdr`), so
installing is two commands.

**From GitHub (recommended).** In Claude Code:

```
/plugin marketplace add AllenInstitute/floppy
/plugin install floppy@allen-bdr
```

Then clone the reference schemas once (they aren't committed — see below):

```bash
bash scripts/setup.sh
```

Check it worked by asking `/floppy-ask` a question, e.g. *"what is a data asset?"*

**From a local checkout.** Clone the repo and register the folder as a marketplace:

```bash
git clone https://github.com/AllenInstitute/floppy.git
cd floppy && bash scripts/setup.sh
/plugin marketplace add .            # registers the allen-bdr marketplace
/plugin install floppy@allen-bdr
```

**Requirements.** Python 3.9+ with `python-docx` (`pip install python-docx`) for
`/floppy-gaps`. `scripts/setup.sh` needs `git`. Refreshing the corpus
(`scripts/refresh.py`) also needs `pandoc` and `pdftotext` (Poppler). Nothing
else — `/floppy-ask` runs on the bundled text with no extra setup.

**Updating.** `/plugin update floppy`, then re-run `bash scripts/setup.sh` if the
pinned schema commits changed.

## Using it in Cowork and claude.ai chat

**Claude Desktop — Cowork.** Cowork uses whatever is installed in the **Code
tab**; there's no separate install in Cowork. So install once in Code and it's
there in Cowork:

```
/plugin marketplace add AllenInstitute/floppy
/plugin install floppy@allen-bdr
bash scripts/setup.sh
```

Then switch to the Cowork tab — `/floppy-ask` and `/floppy-gaps` are available.
(Install scope matters: choose **User** to have it in every session, **Project**
to share it with a repo via `.claude/settings.json`.) Run `/reload-plugins` if a
command doesn't appear right after install.

**claude.ai web chat.** The plugin/marketplace flow is a Claude Code / Desktop
feature and is **not** available in the plain web chat. Two ways to get the
behavior there:

- *Per-user (manual).* Make a Claude **Project**, open its settings, and paste
  the body of a `SKILL.md` (e.g. `skills/floppy-ask/SKILL.md`, minus the
  frontmatter) into the Project's custom instructions. Every chat in that
  Project then follows it. This is a static copy — it won't track skill updates,
  and it can't run `gapdoc.py`, so `/floppy-gaps`'s docx build isn't available
  this way.
- *Org-wide (admin).* On Team/Enterprise plans an admin can distribute the
  plugin from **Settings → Directory → Plugins** (GitHub marketplace entry, or a
  `.plugin` upload). Build the upload artifact with `bash scripts/package.sh`,
  which writes `floppy.plugin`. This flow is still rolling out and its exact
  requirements can change — check the in-app admin screen for the current steps.

## Layout

```
floppy/
├── references/          digests floppy reads to answer fast
│   ├── INDEX.md         routing table — start here
│   ├── project-brief.md charter, milestones, workstreams, people
│   ├── glossary.md      every acronym, with `?` on the inferred ones
│   ├── decisions-and-open-questions.md
│   ├── known-gaps.md    35 gaps already found across five datasets
│   ├── use-cases.md     44 use cases + the doc's real contradictions
│   └── aind-schema-map.md
├── resources/           THE CORPUS — yours to edit and add to
│   ├── General/ Workstream 1-6/   the original project files
│   ├── _text/           plain-text extraction of every doc (floppy greps here)
│   └── schema/          aind-data-schema v2.9.0 + aind-data-mcp
├── scripts/refresh.py   keeps _text/ in step with your edits
└── skills/
    ├── floppy-ask/SKILL.md
    └── floppy-gaps/
        ├── SKILL.md
        ├── scripts/gapdoc.py     seed / validate / build the .docx
        ├── assets/example.json   abridged compact analysis, shows the shape
        └── examples/             full worked examples + the source deliverables
            ├── *.gap.json + .docx     SeaHub & Cell Science, compact format
            ├── *-metadata.nd.json     a seed input example
            └── source-deliverables/   the original real docs
```

## Adding to the corpus

Drop files into `resources/` wherever they belong, then:

```bash
python3 scripts/refresh.py check   # what's new or changed
python3 scripts/refresh.py run     # re-extract it
```

`refresh.py` only ever writes to `resources/_text/`. Your originals are never
touched.

The `references/` digests are hand-written and don't auto-update. When something
substantial changes — a decision lands, a gap analysis is finished, a milestone
closes — edit the relevant digest, or ask Claude to. A digest that's a month
stale is the one thing that will make `/floppy-ask` confidently wrong.

## Writing a gap analysis

```bash
cd skills/floppy-gaps
python3 scripts/gapdoc.py schema                              # the JSON shape
python3 scripts/gapdoc.py seed  metadata.nd.json -o a.json    # bootstrap fields from an export
python3 scripts/gapdoc.py validate a.json                     # check it
python3 scripts/gapdoc.py build    a.json                     # -> a.docx (compact section)
python3 scripts/gapdoc.py metrics  a.json                     # counts, writes nothing
```

`seed` flattens an aind-style metadata export (e.g. `teaseq-metadata.nd.json`)
into a field skeleton with classifications left as `Needs Review`; you complete
them against the pinned schema. See `skills/floppy-gaps/examples/` for full
worked inputs and outputs.

Needs `python-docx`; `refresh.py` also needs `pandoc` and `pdftotext` for .docx
and .pdf.

## Corpus as bundled

Snapshot of `bdr_skill/` as of 2026-08-27. aind-data-schema at commit
`18114d7b`, tag `v2.9.0-1-g18114d7b`. aind-data-mcp at `c636990a`. Two Figma
board PDFs (169 MB of images) are text-only — their originals aren't bundled.

## Keeping it current, and sharing it

Two problems: floppy noticing your edits, and teammates getting them.

**Locally** — `python3 scripts/refresh.py check` compares every source file's
mtime against the extraction and reports what's new, changed, or gone;
`run` re-extracts. `refresh.py schema` re-records the commit of any bundled
clone. The `references/` digests are hand-written and do **not** auto-update —
when a decision lands or an analysis finishes, edit the digest or ask Claude to.
A stale digest is the one thing that makes `/floppy-ask` confidently wrong.

**For a team — put it on GitHub as a plugin marketplace.** Recommended split:

| Commit | Leave out |
|---|---|
| `skills/`, `references/`, `scripts/`, `.claude-plugin/` | the `.docx`/`.pdf`/`.pptx` originals (~46 MB, and they churn) |
| `resources/_text/` — the extractions, ~940 KB of plain text | `resources/schema/*` clones (8 MB and 509 MB) |

The extractions are what answers questions; the binaries are for humans and
already live wherever your team keeps them. Committing text instead of binaries
keeps the repo ~2 MB, and `git diff` on a `.md` extraction shows exactly what
changed in a document between versions — which is its own answer to "what moved
since the gate?"

```bash
# once, by you
cd floppy && git init && git add -A && git commit -m "floppy v0.1"
gh repo create AllenInstitute/floppy --private --source=. --push

# each teammate, once
/plugin marketplace add AllenInstitute/floppy
/plugin install floppy@allen-bdr
bash scripts/setup.sh        # clones the schemas locally

# thereafter
/plugin update floppy
```

Your loop stays: drop files in `resources/`, `refresh.py run`, update the
affected digest, commit. Teammates get it on `/plugin update`.
