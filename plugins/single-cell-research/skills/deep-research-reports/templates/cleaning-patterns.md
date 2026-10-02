# Known Deep Research Platform Artifacts

Reference document for the `deep-research-reports` skill. Documents all known artifact
patterns from each platform to guide the cleaning logic.

## ChatGPT (o3, o1, etc.)

### PUA Character Wrapping
- U+E200 (start delimiter), U+E202 (internal separator), U+E201 (end delimiter)
- Wrap entity tags and citation markers
- Pattern: `\ue200<content>\ue201`, with `\ue202` as internal delimiters
- These are invisible in most renderers but break regex matching — must be stripped FIRST

### Entity Tags
- Format: `entity["type","name","description"]` (wrapped in PUA)
- Types seen: `"people"`, `"organization"`
- Replacement: extract the "name" field (second quoted string)
- Example: `entity["people","Detlev Arendt","evo-devo neuroscientist"]` → `Detlev Arendt`

### Citation Markers
- Format: `citeturnXviewY` or `citeturnXsearchY` (wrapped in PUA)
- Multiple can chain: `citeturn8view0turn7view0`
- Redundant with the `[N]` inline citations already in the text
- Replacement: delete entirely

### Image Group Blocks
- Format: `image_group{JSON}` on its own line (may have PUA prefix)
- Contains layout, aspect_ratio, query arrays
- No actual images — just a request ChatGPT made during generation
- Replacement: delete entire line

### YAML Indentation and Structured Metadata
- ChatGPT may drop or reduce YAML indentation. Flat or misplaced fields can parse successfully
  while losing their intended nesting; syntax success alone is insufficient.
- Use the parsing/cleaning code in `SKILL.md`: validate the required nested schema before writing.
- Preserve the complete YAML header exactly and apply artifact cleanup only to the report body.
- Do not guess indentation repairs, fill missing identity fields, or discard conflicting keys.
  Retain raw input and obtain a corrected header or an explicitly reviewed correction.

## Claude (Deep Research)

### No known artifacts (as of 2026-03-04)
- Tested on clade6sub25 report: zero PUA chars, zero entity tags, zero citation markers
- References are clean `[N]` format with standard author-year citations
- Monitor for future patterns: `<antThinking>`, `[source_id]`, footnote markers

## Confirming Platform Provenance

Known PUA, entity or citation artifacts in the **body** identify the known ChatGPT export format.
Artifact-free output may be Claude or ChatGPT Pro; ask the generating platform unless supplied.
Do not assign Claude by default or infer a model from artifact absence. Conflicting provenance
and signatures require resolution. Keep `chatgpt`, `chatgpt_pro` or `claude` in filenames and
summary rows. The supplied file and archived raw bytes remain unchanged on every platform.

This is a dated artifact inventory, not proof that future exports use the same formats. Record
new observed patterns; do not silently broaden cleanup over metadata or remove source references.
