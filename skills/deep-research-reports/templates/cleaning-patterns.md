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

### YAML Indentation
- ChatGPT sometimes drops or reduces indentation in YAML output
- The YAML parser should handle this, but watch for parse errors

## Claude (Deep Research)

### No known artifacts (as of 2026-03-04)
- Tested on clade6sub25 report: zero PUA chars, zero entity tags, zero citation markers
- References are clean `[N]` format with standard author-year citations
- Monitor for future patterns: `<antThinking>`, `[source_id]`, footnote markers

## Detection Heuristic

```python
with open(filepath, 'rb') as f:
    raw = f.read()
text = raw.decode('utf-8')
pua_count = sum(1 for c in text if '\ue000' <= c <= '\uf8ff')
if pua_count > 0:
    platform = 'chatgpt'
else:
    platform = 'claude'
```
