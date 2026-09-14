# floppy

BioData Registry project assistant. Two commands, one shared corpus.

<img src="floppy.png" alt="floppy" width="200">

| Command | Does |
|---|---|
| `/floppy-ask` | Answers questions about the BDR project and the aind-data-schema, from the bundled corpus. Cites its source. Says when something is open rather than inventing a resolution. |
| `/floppy-gaps` | Writes a schema gap analysis in the compact Milestone-0 format — a `.json` source of truth plus a matching `.docx` (Gap Summary Overview + Field-Level Mapping tables). Can seed the JSON from an existing metadata export, and computes metrics from the field rows. |

## Install

This repo is both a **plugin** (`.claude-plugin/plugin.json`) and its own
**marketplace** (`.claude-plugin/marketplace.json`, named `allen-bdr`). In Claude
Code (CLI or the Desktop Code tab):

```
/plugin marketplace add AllenInstitute/floppy
/plugin install floppy@allen-bdr
```

Then clone the reference schemas once — they aren't committed (see [Sharing](#sharing)):

```bash
bash scripts/setup.sh
```

Check it worked by asking `/floppy-ask` *"what is a data asset?"*. Update later
with `/plugin update floppy` (re-run `setup.sh` if the pinned schema commits moved).

**Requirements.** Python 3.9+ with `python-docx` for `/floppy-gaps`; `git` for
`setup.sh`; `pandoc` + `pdftotext` (Poppler) only if you refresh the corpus.
`/floppy-ask` needs nothing extra.

## Cowork and claude.ai chat

**Cowork** uses whatever is installed in the **Code tab** — no separate install.
Install as above, switch to Cowork, and `/floppy-ask` / `/floppy-gaps` are there.
Pick **User** scope to have it everywhere, **Project** to share it via a repo's
`.claude/settings.json`. `/reload-plugins` if a command doesn't show up.

**claude.ai web chat** has no plugin/marketplace flow. Two workarounds:

- *Per-user:* paste a `SKILL.md` body (minus frontmatter) into a Claude
  **Project's** custom instructions. Static copy, and it can't run `gapdoc.py`,
  so the `/floppy-gaps` docx build isn't available this way.
- *Org-wide:* a Team/Enterprise admin distributes it from **Settings → Directory
  → Plugins** (GitHub entry, or a `.plugin` built by `bash scripts/package.sh`).
  This flow is still rolling out — check the in-app admin screen for current steps.

## Layout

```
floppy/
├── references/          digests floppy reads to answer fast
│   ├── INDEX.md         routing table — start here
│   ├── project-brief.md charter, milestones, workstreams, people
│   ├── glossary.md      every acronym, with `?` on the inferred ones
│   ├── decisions-and-open-questions.md
│   ├── known-gaps.md    gaps already found across the datasets
│   ├── use-cases.md     44 use cases + the doc's real contradictions
│   └── aind-schema-map.md
├── resources/           THE CORPUS — yours to edit and add to
│   ├── General/ Workstream 1-6/   the original project files
│   ├── _text/           plain-text extraction of every doc (floppy greps here)
│   └── schema/          aind-data-schema v2.9.0 + aind-data-mcp (cloned by setup.sh)
├── scripts/             refresh.py, setup.sh, package.sh
└── skills/
    ├── floppy-ask/SKILL.md
    └── floppy-gaps/
        ├── SKILL.md
        ├── scripts/gapdoc.py     seed / validate / build the .docx
        ├── assets/example.json   abridged compact analysis, shows the shape
        └── examples/             full worked examples + the source deliverables
```

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
them against the pinned schema. `skills/floppy-gaps/examples/` has full worked
inputs and outputs.

## Keeping the corpus current

Drop files into `resources/`, then:

```bash
python3 scripts/refresh.py check   # what's new, changed, or gone
python3 scripts/refresh.py run     # re-extract into resources/_text/
```

`refresh.py` only ever writes `resources/_text/`; your originals are untouched.
The `references/` digests are hand-written and do **not** auto-update — when a
decision lands or an analysis finishes, edit the relevant digest (or ask Claude
to). A stale digest is the one thing that makes `/floppy-ask` confidently wrong.

## Sharing

Committed vs. left out, to keep the repo ~2 MB:

| Commit | Leave out (git-ignored) |
|---|---|
| `skills/`, `references/`, `scripts/`, `.claude-plugin/` | the `.docx`/`.pdf`/`.pptx` corpus originals (~46 MB, churny) |
| `resources/_text/` — the ~940 KB of extractions floppy actually reads | `resources/schema/*` clones (cloned locally by `setup.sh`) |

The extractions are what answer questions; the binaries live wherever your team
keeps them, and `git diff` on a `.md` extraction shows exactly what changed in a
document between versions. Teammates install per [Install](#install) and get your
updates with `/plugin update floppy`.

**Snapshot as bundled** (2026-08-27): aind-data-schema at `18114d7b`
(`v2.9.0-1-g18114d7b`), aind-data-mcp at `c636990a`. Two Figma board PDFs are
text-only; their image originals aren't bundled.
