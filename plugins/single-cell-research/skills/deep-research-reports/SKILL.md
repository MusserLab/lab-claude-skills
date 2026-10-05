---
name: deep-research-reports
description: >
  Process deep research report outputs for scRNAseq cell type annotation and non-metazoan
  gene characterization. Use when the user invokes /process-deep-research or asks to clean,
  convert to PDF/HTML, parse, or compile deep research reports from ChatGPT or Claude.
  Handles artifact removal, PDF/HTML generation, YAML header extraction, and summary table
  maintenance. Supports cluster cell-type annotation, ordinary family annotation,
  and nonmetazoan characterization, detected from query.report_type. Works locally
  and on an HPC cluster
  (auto-detects quarto path and LaTeX availability).
---

# Deep Research Report Processor

Processes structured reports generated using `deep-research-genelist` or a compatible project prompt. Cleans known platform artifacts, renders PDF/HTML, and copies validated metadata into summary tables. These operations preserve the report's scientific claims; they do not validate or accept them. This package supports only the three ordinary schemas below. An unsupported report type stops before writes; use its owning project procedure rather than reclassifying it as an ordinary report.

---

## Workflow

### Step 1: Identify Input

Accept one of:
- **A specific file path** provided by the user
- **"all"** — glob `outs/deep_research*/**/*.md` (note the `*` after `deep_research` — catches `deep_research/`, `deep_research_platynereis/`, etc.), skip files ending in `_clean.md`, `_raw.md`, or `_prompt.md`
- **"new"** — glob `outs/deep_research*/**/*.md`, same exclusions, then resolve canonical identities in Step 2 and skip reports with a corresponding `_clean.md`

For `all` or `new`, stop if the requested batch search finds no eligible reports. For an
explicit input file, validate its identity and supported report type before choosing
destinations; a separate `outs/deep_research*/` input directory is not required.

#### Directory structure

Each module gets its own subdirectory under `outs/deep_research/`:

```
outs/deep_research/
├── annotation_summary.tsv          ← cross-cluster summary (top level)
├── clade6sub25/                    ← per-module subdirectory
│   ├── clade6sub25_prompt.md       ← shared prompt (no date/platform prefix)
│   ├── 260304_chatgpt_clade6sub25_raw.md
│   ├── 260304_chatgpt_clade6sub25_clean.md
│   ├── 260304_chatgpt_clade6sub25_report.pdf
│   ├── 260304_chatgpt_clade6sub25_report.html
│   ├── 260304_claude_clade6sub25_raw.md
│   ├── 260304_claude_clade6sub25_clean.md
│   ├── 260304_claude_clade6sub25_report.pdf
│   └── 260304_claude_clade6sub25_report.html
└── another_cluster/
    └── ...
```

After Step 2 validates the identity and destinations, create the module's subdirectory if
needed. All output files for that module go inside it; family and nonmetazoan destinations
follow their report-specific rules below.

### Step 2: Read Metadata, Confirm Platform, and Clean the Body

Retain the input as **raw bytes** and decode a working copy as UTF-8. Do not modify or rename
it. Parse its YAML header before constructing filenames or writing outputs. Clean only the body;
preserve the data header exactly, including indentation, lists, identifiers and dates.

Known PUA characters (U+E000–U+F8FF), `entity[` or `citeturn` in the body identify the known
ChatGPT artifact format. Artifact-free output could be Claude or ChatGPT Pro: ask its generating
platform unless that provenance was supplied. Use `chatgpt`, `chatgpt_pro` or `claude` in names
and summaries. Conflicting provenance/signatures require resolution, not an automatic override.

Use this parsing/cleaning path. It validates nested fields even when YAML syntax parses. Flat,
misplaced, duplicate-key or malformed metadata is an error: report the specific problem and keep
the raw input. Obtain a corrected header/report or an explicitly reviewed correction before
creating a clean file or summary row. Do not guess a hierarchy or missing identity.

```python
import re
import yaml


class ReportLoader(yaml.SafeLoader):
    """Safe parsing that refuses duplicate keys instead of losing values."""
    def construct_mapping(self, node, deep=False):
        mapping = super().construct_mapping(node, deep=deep)
        keys = [self.construct_object(key, deep=deep) for key, _ in node.value]
        if len(keys) != len(set(keys)):
            raise ValueError("YAML contains duplicate keys; review the original header")
        return mapping


REQUIRED_FIELDS = {
    "cluster": (
        "query.module_id", "query.organism", "query.n_genes",
        "annotation.proposed_name", "annotation.confidence", "annotation.one_line",
    ),
    "family": (
        "query.organism", "annotation.confidence", "annotation.one_line",
    ),
    "nonmetazoan_characterization": (
        "query.kingdom", "query.organism", "query.n_genes", "query.n_expressed",
        "classification.assessment_confidence",
    ),
}
REQUIRED_LISTS = {
    "cluster": ("markers.top_diagnostic",),
}


def nested_value(metadata, path):
    value = metadata
    for key in path.split("."):
        if not isinstance(value, dict) or key not in value:
            raise ValueError(f"Missing or misplaced metadata field: {path}")
        value = value[key]
    if value is None or value == "":
        raise ValueError(f"Empty metadata field: {path}")
    return value


def family_schema(metadata):
    """Distinguish the two existing ordinary family shapes without rewriting them."""
    query = metadata["query"]
    annotation = metadata.get("annotation")
    if not isinstance(annotation, dict):
        raise ValueError("Missing or misplaced metadata field: annotation")
    genelist = "module_id" in query or "proposed_name" in annotation
    legacy = ("family" in query or "proposed_family_name" in annotation
              or "per_cluster" in annotation)
    if genelist == legacy:
        raise ValueError("Ambiguous family metadata shape; confirm the original report schema")
    return "genelist" if genelist else "legacy"


def validate_report_metadata(metadata):
    if not isinstance(metadata, dict) or not isinstance(metadata.get("query"), dict):
        raise ValueError("Metadata must contain a nested query mapping")
    report_type = metadata["query"].get("report_type", "cluster")
    if not isinstance(report_type, str) or report_type not in REQUIRED_FIELDS:
        raise ValueError(f"Unsupported query.report_type: {report_type!r}")
    variant = family_schema(metadata) if report_type == "family" else None
    fields = REQUIRED_FIELDS[report_type]
    lists = REQUIRED_LISTS.get(report_type, ())
    if variant == "genelist":
        fields += ("query.module_id", "query.n_genes", "query.n_member_clusters", "annotation.proposed_name")
        lists += ("markers.top_diagnostic",)
    elif variant == "legacy":
        fields += ("query.family", "annotation.proposed_family_name")
        lists += ("annotation.per_cluster",)
    for path in fields:
        if isinstance(nested_value(metadata, path), (dict, list)):
            raise ValueError(f"Expected a scalar metadata field: {path}")
    for path in lists:
        value = nested_value(metadata, path)
        if not isinstance(value, list):
            raise ValueError(f"Expected a metadata list: {path}")
        if path == "annotation.per_cluster" and not value:
            raise ValueError(f"Expected a non-empty metadata list: {path}")
    if variant == "legacy":
        query = metadata["query"]
        if query.get("n_modules") is None and query.get("n_member_clusters") is None:
            raise ValueError("Missing query.n_modules or query.n_member_clusters")
    if variant == "legacy":
        fields = ("cluster", "proposed_name")
        for entry in metadata["annotation"]["per_cluster"]:
            for field in fields:
                nested_value(entry, field)
    if report_type == "cluster" or variant == "genelist":
        if any(not isinstance(entry, dict) for entry in metadata["markers"]["top_diagnostic"]):
            raise ValueError("markers.top_diagnostic entries must be mappings")
    if report_type == "nonmetazoan_characterization":
        categories = nested_value(metadata, "functional_categories")
        if not isinstance(categories, (dict, list)) or not categories:
            raise ValueError("functional_categories must contain at least one entry")
        classification = metadata["classification"]
        prokaryote = "n_candidate_hgt" in classification
        eukaryote = "n_database_bias" in classification
        if prokaryote == eukaryote:
            raise ValueError("Ambiguous nonmetazoan template variant; confirm from the report source")
        fields = ("n_symbiont_transcript", "n_conserved", "n_ambiguous")
        fields += ("n_candidate_hgt",) if prokaryote else ("n_database_bias", "n_lateral_transfer")
        for field in fields:
            nested_value(metadata, "classification." + field)


def prepare_report(raw_text, platform=None):
    """Validate metadata, preserve its header, and clean only known body artifacts."""
    lines = raw_text.splitlines(keepends=True)
    if not lines or lines[0].rstrip("\r\n") != "---":
        raise ValueError("Report has no opening YAML front matter delimiter")
    closing = next((i for i in range(1, len(lines))
                    if lines[i].rstrip("\r\n") == "---"), None)
    if closing is None:
        raise ValueError("Report has no closing YAML front matter delimiter")
    header = "".join(lines[:closing + 1])
    body = "".join(lines[closing + 1:])
    try:
        metadata = yaml.load("".join(lines[1:closing]), Loader=ReportLoader)
    except yaml.YAMLError as error:
        raise ValueError(f"Invalid report YAML; preserve the original input: {error}") from error
    validate_report_metadata(metadata)

    has_artifacts = bool(re.search(r'[\ue000-\uf8ff]|entity\[|citeturn', body))
    if platform is None and has_artifacts:
        platform = "chatgpt"
    if platform not in ("chatgpt", "chatgpt_pro", "claude"):
        raise ValueError("Confirm the generating platform for artifact-free input")
    if has_artifacts and platform not in ("chatgpt", "chatgpt_pro"):
        raise ValueError("Supplied platform conflicts with known ChatGPT artifacts")
    if has_artifacts:
        body = re.sub(r'[\ue000-\uf8ff]', '', body)
        body = re.sub(r'entity\["[^"]*","([^"]*)","[^"]*"\]', r'\1', body)
        body = re.sub(r'\s*citeturn\S+', '', body)
        body = re.sub(r'^.*image_group\{.*\}.*$', '', body, flags=re.MULTILINE)
    body = re.sub(r' +$', '', body, flags=re.MULTILINE)
    body = re.sub(r'\n{3,}', '\n\n', body)
    return metadata, header + body
```

Call `prepare_report(raw_bytes.decode("utf-8"), platform)` before writing; ask first when
artifact-free input has no supplied platform. Report the platform, report type and artifact counts.
The function returns metadata and clean text; it does not write or rename files.

#### Construct canonical base name

- Cluster: `YYMMDD_platform_moduleID`
- Ordinary family: `YYMMDD_platform_family_FAMILYID` (resolve the variant's identity in Step 3c)
- Nonmetazoan: `YYMMDD_platform_kingdom`

Use `query.date_generated`, `query.module_id`, `query.family` or `query.kingdom` from validated
metadata. Obtain a missing generation date from report provenance; do not substitute the processing
date. Keep identity values unchanged in YAML and summary fields. Reject path separators/traversal
before using an identifier as a filename; resolve naming conflicts explicitly.

#### Preserve raw input and write outputs

- Keep the supplied file unchanged. Copy its original bytes to `{base}_raw.md` for **all** platforms,
  including artifact-free reports; write the working result to `{base}_clean.md`.
- Preview destinations. Reuse an existing raw file only if its bytes match. Different bytes under
  the same identity are a collision: stop and resolve them before writing.
- Preserve clean/rendered outputs that are retained, edited or under review. Follow project output
  ownership and the confirmed rerun scope; a matching filename alone does not permit replacement.
- In `new` mode, skip only after validated identity and confirmed platform resolve to the matching
  existing clean output; do not infer processed status from the supplied basename.

### Step 3: Validate the Report Schema

The supplied parsing path checks required nested fields and list structure. Perform the existing
report-specific checks below too. Parsing and formatting do not establish scientific support for
an annotation, classification or comparative match.

**Report type detection:** `query.report_type` selects the existing schema:
- `"cluster"` (or absent) → cluster cell-type-annotation
- `"family"` → legacy family cell-type-annotation (Step 3c)
- `"nonmetazoan_characterization"` → nonmetazoan characterization (Step 3b)

**Required for cluster reports:**
- `query.module_id`, `query.organism`, `query.n_genes`
- `annotation.proposed_name`, `annotation.confidence`, `annotation.one_line`
- `markers.top_diagnostic` (list; may be empty for an inconclusive report)

**Optional but checked:**
- `query.source_object`, `query.clustering_column`, `query.marker_file` — warn if missing (older
  prompts may not include these provenance fields).
- `query.comparison_mode`, `query.clade_family` — preserve when merged marker mode was used;
  default to empty strings when absent.
- `query.member_clusters`, `query.n_member_clusters` — family reports only; default to empty list
  and zero when absent from an older report.

If validation fails, report the exact field/problem and stop processing that file. Do not repair
indentation, infer missing identity fields, or create a summary row from malformed metadata.

### Step 3b: Nonmetazoan Report Validation

When `query.report_type == "nonmetazoan_characterization"`, use this validation instead:

**Detect template variant** from which classification fields are present:
- Has `classification.n_candidate_hgt` → **prokaryote variant** (Bacteria, Archaea, combined)
- Has `classification.n_database_bias` → **eukaryote variant** (Fungi, Viridiplantae, etc.)
- Has both or neither → stop and confirm the template variant from its report/prompt source

**Required fields (both variants):**
- `query.kingdom`, `query.organism`, `query.n_genes`, `query.n_expressed`
- `classification.assessment_confidence`
- At least one entry in `functional_categories`

**Prokaryote-specific required:**
- `classification.n_symbiont_transcript`, `classification.n_candidate_hgt`, `classification.n_conserved`, `classification.n_ambiguous` (can be 0)

**Eukaryote-specific required:**
- `classification.n_database_bias`, `classification.n_conserved`, `classification.n_symbiont_transcript`, `classification.n_lateral_transfer`, `classification.n_ambiguous` (can be 0)

**Optional but checked:**
- `hgt_candidates` — warn if absent for prokaryote reports
- `expression_patterns.cell_type_enriched_genes` — warn if empty
- `biology.symbiosis_relevant` — prokaryote only
- `biology.evolutionary_insight` — eukaryote only

**Canonical base name for nonmetazoan reports:**
Pattern: `YYMMDD_platform_kingdom` (e.g., `260315_chatgpt_prokaryote`, `260315_claude_fungi`)
- `kingdom` from `query.kingdom`, lowercased, spaces replaced with underscores

**Directory:** Reports go in `outs/deep_research/nonmetazoan/{kingdom}/` (note: under `deep_research/nonmetazoan/`, not the script-04 `outs/scmicrobiome/` directory — the processed reports live alongside cell-type-annotation reports).

### Step 3c: Family Report Validation

When `query.report_type == "family"`, preserve the two established ordinary schemas. The
`family_schema()` function distinguishes them before validation; it does not add, rename or
infer metadata fields. Mixed identity/name fields or a conflicting per-cluster block are ambiguous:
stop and confirm the original report shape rather than selecting a preferred interpretation.

**Family-marker report from the genelist template:**
- `query.module_id`, `query.organism`, `query.n_genes`, `query.n_member_clusters`
- `annotation.proposed_name`, `annotation.confidence`, `annotation.one_line`
- `markers.top_diagnostic` (list; may be empty)
- This report describes the shared family program. It supplies no per-cluster claims; do not
  require or synthesize `annotation.per_cluster`.

**Legacy family annotation report:**
- `query.family`, `query.organism`, `query.n_modules` or `query.n_member_clusters`
- `annotation.proposed_family_name`, `annotation.confidence`, `annotation.one_line`
- `annotation.per_cluster` (non-empty list with at least `cluster` and `proposed_name` per entry)

**Optional but checked:**
- `query.subfamilies` — subfamily structure. Default empty.
- `annotation.best_matches` — comparative matches. Default empty list.
- `annotation.family_conservation` — conservation level. Default empty.
- `markers.family_defining` — family marker list. Warn if empty.
- `markers.family_specifying_tfs`, `markers.cluster_specifying_tfs` — TF annotations.

**Canonical base name:** `YYMMDD_platform_family_FAMILYID`. Use `query.module_id` as `FAMILYID`
for the genelist shape and `query.family` for the legacy shape. Keep that original value unchanged
in the YAML; the filename's `family_` prefix is a report-type label. Use the same resolved identity
for the render title's `Family {family_identity}`.

**Directory:** Reports go in the same directory as the input file (family reports already live in their own subdirectory, e.g., `outs/deep_research_platynereis/family_C/`).

### Step 4: Ask Output Format

Use the current client's structured-input tool when available, or ask in conversation:
- **Both** (Recommended) — PDF for sharing, HTML for browsing with clickable DOIs
- **PDF only** — LaTeX-rendered, good for sharing/printing
- **HTML only** — Standalone, nice table styling, clickable links

### Step 5: Generate Outputs

Create a temporary `_report_for_render.md` from `{base}_clean.md`:

1. **Strip the data YAML header** — the large `query:`/`annotation:`/`markers:` (or `classification:`/`functional_categories:`) block is for programmatic parsing only, not for display
2. **Insert a pandoc formatting YAML.** The title format depends on report type:
   - Cell-type annotation: `"Gene Module Interpretation: *{organism}* {module_id}"`
   - Ordinary family annotation: `"Cell Type Family Report: *{organism}* Family {family_identity}"` (identity from Step 3c)
   - Nonmetazoan: `"Non-Metazoan Gene Characterization: *{organism}* — {kingdom}"`
   ```yaml
   ---
   title: "<title per report type>"
   subtitle: "Deep Research Report — {Platform} ({date_generated})"
   geometry: margin=1in
   fontsize: 11pt
   header-includes:
     - \renewcommand{\arraystretch}{1.4}
     - \usepackage{booktabs}
     - \usepackage{longtable}
   ---
   ```
   The `\arraystretch{1.4}` adds 40% vertical padding to every table row — critical for readability.

3. **Remove the H1 title** from the body (it's now in the YAML `title:` field)

4. **Normalize heading levels** — ChatGPT reports nest headings too deep, producing tiny headers at H4/H5 in PDFs. Apply these fixes in order:

   a. **Remove redundant heading pairs.** ChatGPT often outputs a generic `##` heading immediately followed by the lettered `###` section (e.g., `## Comparative biological analysis` then `### H. Comparative Biological Analysis`). Remove the redundant `##` line:
   ```python
   body = re.sub(r'^##\s+[^\n]+\n\n(###\s+[A-L]\.)', r'\1', body, flags=re.MULTILINE)
   ```

   b. **Shift all headings up one level.** Since the H1 title was removed, the remaining hierarchy is too deep (`##`→`####`). Shift `##`→`#`, `###`→`##`, `####`→`###`, etc. (never shift H1):
   ```python
   def shift_heading(m):
       hashes = m.group(1)
       rest = m.group(2)
       if len(hashes) > 1:
           return '#' * (len(hashes) - 1) + rest
       return m.group(0)
   body = re.sub(r'^(#{2,})([ \t].*)$', shift_heading, body, flags=re.MULTILINE)
   ```

   After normalization, the typical hierarchy is: `#` (sections A–K), `##` (subsections like "Core identity modules"), `###` (sub-subsections).

5. **Escape backslashes in gene names for LaTeX.** ChatGPT reports sometimes include gene names with literal backslashes (e.g., `Dmel\cg5579`), which LaTeX interprets as control sequences. Escape them in the body only:
   ```python
   body = re.sub(r'\\(?=[a-zA-Z])', r'\\\\', body)
   ```

**Detect rendering tools:** Find `quarto` on PATH or common locations (`~/.local/bin/quarto`, `/usr/local/bin/quarto`). Check for `xelatex` availability — if not on PATH, try `module load texlive` (HPC cluster). If no LaTeX available, skip PDF and inform user. On cluster, shell commands for PDF rendering must include `module load texlive &&` prefix.

**Important:** When writing the pandoc YAML header from Python, write the LaTeX commands directly to the file (not through Python f-strings). The backslashes in `\renewcommand`, `\arraystretch`, `\usepackage` must appear literally in the markdown file — do NOT double-escape them in Python. Use `f.write()` with raw strings or explicit line writes.

**Generate PDF:**
```bash
{quarto_path} pandoc \
  "{base}_report_for_render.md" \
  -o "{base}_report.pdf" \
  --pdf-engine=xelatex \
  -V colorlinks=true -V linkcolor=blue -V urlcolor=blue
```
On cluster, prepend `module load texlive &&` before the quarto command.

**Generate HTML:**
```bash
{quarto_path} pandoc \
  "{base}_report_for_render.md" \
  -o "{base}_report.html" \
  --standalone \
  --css="{resolved_skill_directory}/templates/report-style.css" \
  --embed-resources
```
Resolve `resolved_skill_directory` from the installed skill's actual location, not a personal home path. The `--embed-resources` flag inlines the bundled CSS so HTML is self-contained.

**Delete** `_report_for_render.md` after successful conversion.

If pandoc fails (e.g., LaTeX error), fall back to HTML only and notify the user.

### Step 6: Update Summary Table

Extract fields from validated YAML and update `outs/deep_research/annotation_summary.tsv`.

**Composite key:** `module_id + platform + date_generated`. This allows the table to hold both ChatGPT and Claude annotations for the same cluster side by side.

**Logic:**
1. Read existing TSV if it exists (using Python `csv` with `delimiter='\t'`)
2. Check if a row with matching composite key exists
3. If yes: show old vs new proposed_name, ask to update or skip
4. If no: append new row
5. Sort by module_id, then platform
6. Write back TSV

**Columns — parse ALL YAML fields into the summary table:**

`module_id`, `organism`, `common_name`, `clade`, `dataset`, `module_type`, `report_type`, `source_object`, `clustering_column`, `marker_file`, `comparison_mode`, `clade_family`, `member_clusters`, `n_member_clusters`, `biological_context`, `n_genes`, `proposed_name`, `alternative_names`, `confidence`, `confidence_rationale`, `one_line`, `summary`, `cell_type_family`, `family_conservation`, `top_tfs`, `top_markers`, `top_diagnostic_ids`, `top_diagnostic_roles`, `receptors_channels`, `signaling_ligands`, `adhesion_molecules`, `secreted_products`, `key_pathways`, `metabolic_signature`, `n_uncharacterized`, `best_match_1`, `best_match_2`, `best_match_3`, `date_generated`, `platform`, `report_file`, `date_processed`

**Field mapping from YAML:**

| Summary column | YAML source | Format |
|---------------|-------------|--------|
| `module_id` | `query.module_id` | verbatim |
| `organism` | `query.organism` | verbatim |
| `common_name` | `query.common_name` | verbatim |
| `clade` | `query.clade` | verbatim |
| `dataset` | `query.dataset` | verbatim |
| `module_type` | `query.module_type` | verbatim |
| `report_type` | `query.report_type` | verbatim; default `"cluster"` |
| `source_object` | `query.source_object` | verbatim |
| `clustering_column` | `query.clustering_column` | verbatim |
| `marker_file` | `query.marker_file` | verbatim |
| `comparison_mode` | `query.comparison_mode` | verbatim; default empty |
| `clade_family` | `query.clade_family` | verbatim; default empty |
| `member_clusters` | `query.member_clusters` | join with `; `; default empty (family reports only) |
| `n_member_clusters` | `query.n_member_clusters` | integer; default 0 (family reports only) |
| `biological_context` | `query.biological_context` | verbatim |
| `n_genes` | `query.n_genes` | integer |
| `proposed_name` | `annotation.proposed_name` | verbatim |
| `alternative_names` | `annotation.alternative_names` | join with `; ` |
| `confidence` | `annotation.confidence` | verbatim |
| `confidence_rationale` | `annotation.confidence_rationale` | verbatim |
| `one_line` | `annotation.one_line` | verbatim |
| `summary` | `annotation.summary` | verbatim (may be multi-line — flatten to single line) |
| `cell_type_family` | `annotation.cell_type_family` | verbatim |
| `family_conservation` | `annotation.family_conservation` | verbatim |
| `top_tfs` | `markers.transcription_factors` | join with `; ` |
| `top_markers` | `markers.top_diagnostic[].name` | top 5, join with `; ` |
| `top_diagnostic_ids` | `markers.top_diagnostic[].gene_id` | top 5, join with `; ` |
| `top_diagnostic_roles` | `markers.top_diagnostic[].role` | top 5, join with `; ` |
| `receptors_channels` | `markers.receptors_channels` | join with `; ` |
| `signaling_ligands` | `markers.signaling_ligands` | join with `; ` |
| `adhesion_molecules` | `markers.adhesion_molecules` | join with `; ` |
| `secreted_products` | `markers.secreted_products` | join with `; ` |
| `key_pathways` | `markers.key_pathways` | join with `; ` |
| `metabolic_signature` | `markers.metabolic_signature` | verbatim |
| `n_uncharacterized` | `markers.n_uncharacterized_notable` | integer |
| `best_match_1` | `annotation.best_matches[0]` | `cell_type (organism) [conservation]` |
| `best_match_2` | `annotation.best_matches[1]` | `cell_type (organism) [conservation]` |
| `best_match_3` | `annotation.best_matches[2]` | `cell_type (organism) [conservation]` |
| `date_generated` | `query.date_generated` | verbatim |
| `platform` | confirmed platform | `chatgpt`, `chatgpt_pro` or `claude` |
| `report_file` | computed path | `{base}_clean.md` |
| `date_processed` | current date | YYYY-MM-DD |

Fields may be absent in older reports — default to empty string.

**Ordinary family report field mappings:** Both shapes use `annotation_summary.tsv`. Preserve
the genelist report's existing module identifier; retain the legacy report's established derived
family key. Do not add per-cluster claims to a family-marker report.

| Summary column | Genelist family-marker shape | Legacy family annotation shape |
|---|---|---|
| `module_id` | `query.module_id` verbatim | `query.family` prefixed with `family_`, e.g., `family_C` |
| `proposed_name` | `annotation.proposed_name` | `annotation.proposed_family_name` |
| `member_clusters` | `query.member_clusters` joined with `; ` | same source; empty if absent |
| `n_member_clusters` | `query.n_member_clusters` | same source; zero if absent |

All other columns map as for cluster reports. Legacy `per_cluster` annotations remain in the
clean markdown for detailed parsing and are not expanded into this family-level summary row.

### Step 6b: Nonmetazoan Summary Table

For nonmetazoan reports (`report_type == "nonmetazoan_characterization"`), update a **separate** summary table at `outs/deep_research/nonmetazoan_summary.tsv`. Do NOT mix with `annotation_summary.tsv` — the column semantics are fundamentally different.

**Composite key:** `kingdom + platform + date_generated`

**Columns:**

| Column | Source | Format |
|--------|--------|--------|
| `kingdom` | `query.kingdom` | verbatim |
| `phylum` | `query.phylum` | verbatim |
| `organism` | `query.organism` | verbatim |
| `common_name` | `query.common_name` | verbatim |
| `n_genes` | `query.n_genes` | int |
| `n_expressed` | `query.n_expressed` | int |
| `template_variant` | detected from fields | "prokaryote" or "eukaryote" |
| `n_symbiont_transcript` | `classification.n_symbiont_transcript` | int; 0 if absent |
| `n_candidate_hgt` | `classification.n_candidate_hgt` | int; 0 if absent |
| `n_database_bias` | `classification.n_database_bias` | int; 0 if absent |
| `n_lateral_transfer` | `classification.n_lateral_transfer` | int; 0 if absent |
| `n_conserved` | `classification.n_conserved` | int |
| `n_ambiguous` | `classification.n_ambiguous` | int |
| `assessment_confidence` | `classification.assessment_confidence` | str |
| `confidence_rationale` | `classification.confidence_rationale` | str |
| `n_functional_categories` | len(`functional_categories`) | int |
| `top_categories` | top 5 category names by n_genes | join "; " |
| `top_category_origins` | matching likely_origin for top 5 | join "; " |
| `symbiosis_relevant` | `biology.symbiosis_relevant` | bool; empty for eukaryote |
| `evolutionary_insight` | `biology.evolutionary_insight` | str; empty for prokaryote |
| `key_functions` | `biology.key_functions` | join "; " |
| `recommended_followup` | `biology.recommended_followup` | join "; " |
| `n_hgt_candidates` | len(`hgt_candidates.top_candidates`) | int; 0 for eukaryote |
| `top_hgt_genes` | top 3 candidate gene_ids | join "; " |
| `n_cell_type_enriched` | len(`expression_patterns.cell_type_enriched_genes`) | int |
| `top_enriched_genes` | top 5 gene_id values | join "; " |
| `notable_associations` | `expression_patterns.notable_associations` | join "; " |
| `date_generated` | `query.date_generated` | str |
| `platform` | confirmed | "chatgpt", "chatgpt_pro" or "claude" |
| `report_file` | computed path | str |
| `date_processed` | current date | YYYY-MM-DD |

### Step 7: Report Results

**Cell-type-annotation reports:**
```
Processed: clade6sub25_annotation_report.md
  Platform: Claude
  Raw copy: clade6sub25/260304_claude_clade6sub25_raw.md
  Cleaned: clade6sub25/260304_claude_clade6sub25_clean.md
  PDF: outs/deep_research/clade6sub25/260304_claude_clade6sub25_report.pdf
  HTML: outs/deep_research/clade6sub25/260304_claude_clade6sub25_report.html
  Summary: annotation_summary.tsv (new row added)

  Annotation: "hemocyte-like immune/scavenger cells (GCM+ phagocytes)"
  Confidence: medium
  Cell type family: immune/scavenger (hemocyte-like)
```

**Nonmetazoan characterization reports:**
```
Processed: deep-research-report (24).md
  Platform: ChatGPT
  Report type: nonmetazoan_characterization (prokaryote variant)
  Cleaned: prokaryote/260315_chatgpt_prokaryote_clean.md
  PDF: prokaryote/260315_chatgpt_prokaryote_report.pdf
  HTML: prokaryote/260315_chatgpt_prokaryote_report.html
  Summary: nonmetazoan_summary.tsv (new row added)

  Kingdom: Prokaryote (369 genes, 178 expressed)
  Classification: 310 symbiont, 12 HGT, 25 conserved, 22 ambiguous
  Confidence: low
  Top HGT candidates: c102759-g4 (Protein-ADP-ribose hydrolase), c101192-g1 (Deubiquitinase)
```

---

## Batch Mode

When processing multiple reports (via "all" or "new"), the skill:
1. Processes each report sequentially through Steps 2–6
2. Asks the output format question **once** (applies to all reports)
3. At the end, shows a summary table of all processed reports
4. Rebuilds the summary TSV from all clean files to ensure consistency

---

## Notes

- The `_clean.md` files are the archival versions — they retain the YAML header for parsing and are the source of truth for the summary table.
- The prompt file (`{module_id}_prompt.md`) is shared across platforms and dates — it doesn't get the date/platform prefix.
- If a report has no YAML front matter at all, report the error clearly and skip that file.
- Platform signatures identify a known artifact format, not a universal platform identity. Confirm artifact-free provenance; record new observed patterns without guessing metadata repairs.

---

## References

Use the bundled [artifact inventory](templates/cleaning-patterns.md) and [HTML stylesheet](templates/report-style.css). Project records retain authority for report inputs, scientific interpretation and acceptance.
