# resources/schema

Reference schemas floppy reads. Two kinds:

| Directory | Role |
|---|---|
| `aind-data-schema/` | **The target.** Snapshot at v2.9.0, commit `18114d7b`. `.git` stripped to keep the plugin small. |
| `aind-data-mcp/` | The MCP server over AIND metadata, commit `c636990a`. |
| `cellxgene/` | **Comparison only.** CZI CELLxGENE Discover schema — consulted for omics gaps, never a mapping target. |

## Adding the CELLxGENE clone

```bash
cd resources/schema
git clone --depth 1 https://github.com/chanzuckerberg/single-cell-curation.git cellxgene
python3 ../../scripts/refresh.py schema     # records the commit
```

Optional, for the ontology term lists:

```bash
git clone --depth 1 https://github.com/chanzuckerberg/cellxgene-ontology-guide.git
```

`--depth 1` keeps it to a few MB. Full history is not useful here — what matters
is which version you cited, and `refresh.py schema` records that.

## Why the pinned commits matter

The gap-analysis house style requires citing a pinned schema version: *"migration
decisions should not be based on an unpinned 'latest' URL."* Each clone gets a
`<name>.GITREF.txt` recording its commit. Re-run `refresh.py schema` after any
`git pull`, or the version cited in a gap analysis stops matching the files it
was derived from.

Snapshots without a `.git` directory (the two aind repos, as bundled) keep their
GITREF as written at build time; `refresh.py schema` reports them and leaves them
alone.
