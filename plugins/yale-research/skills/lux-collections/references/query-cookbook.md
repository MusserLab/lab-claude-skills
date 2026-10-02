# Lux query cookbook — filters, combos, and verbatim landmine reproductions

Dated public-catalog observations from 2026-07. Recheck important structure/filter behavior and
current query counts at use; coverage observations are not a current completeness claim.

Companion to `SKILL.md` §4–§7. All examples are `search("objects", <filters>)` unless noted.
`IZ = https://lux.collections.yale.edu/data/set/ef0600bb-ce93-4435-8fa4-d4ea6586a181`.

## Object filter surface (from `list_filters("objects")`)

Specimen-relevant: `memberOf` (set), `encounteredAt` (place), `encounteredBy` (agent),
`encounteredDate` (date), `classification` (concept), `identifier`/`name`/`id`/`text` (text),
`recordType` (Physical/Digital), `hasDigitalImage`/`isOnline` (boolean).
Art-oriented (rarely useful for specimens): `producedAt/By/Date`, `material`, `producedUsing`,
`height/width/depth/dimension`, `carries`, `subjectOf*`.

## Filter-combination behavior (tested)

| Combo | Works? | Example |
|---|---|---|
| memberOf + classification | ✅ any order | IZ + HOLOTYPE = 800 |
| memberOf + text | ✅ | IZ + "sponge" = 16,752 |
| memberOf + hasDigitalImage / isOnline | ✅ (identical) | IZ = 24,062 / 24,062 |
| memberOf + classification + text | ✅ | IZ + HOLOTYPE + "sponge" = 197 |
| memberOf + encounteredAt (name) | ✅ | IZ + {name:"Bermuda"} = 5,421 |
| **memberOf + encounteredDate** | ⚠️ **order-dependent** | see below |

## LANDMINE — `encounteredDate` drops earlier filters (verbatim repro)

```
# date filter LAST → memberOf silently dropped
{"memberOf":{"id":IZ}, "encounteredDate":["1900-01-01T00:00:00.000Z","<"]}
  → total_results 68,077   (WRONG — all of Lux; page 1 = Botany YU.* + VP.*)
  → emitted q: {"AND":[{"encounteredDate":"1900-01-01T00:00:00.000Z","_comp":"<"}]}   # memberOf gone

# date filter FIRST → both kept
{"encounteredDate":["1900-01-01T00:00:00.000Z","<"], "memberOf":{"id":IZ}}
  → total_results 233   (correct — all Invertebrate Zoology)

# hand-built AND → both kept
{"AND":[{"memberOf":{"id":IZ}}, {"encounteredDate":"1900-01-01T00:00:00.000Z","_comp":"<"}]}
  → total_results 233
```

Root cause: a comparison `entity.filter(key=(value, op))` resets the accumulated query in `luxy`;
`_build_filters` applies filters in dict order, so whatever precedes the date filter is wiped. Silent.
Reported to `caseywdunn/luxmcp`. **Date ranges:** `{"AND":[{memberOf}, {encounteredDate,_comp:">="},
{encounteredDate,_comp:"<"}]}` — works for most Sets; Ichthyology rejected ranges → use cumulative
`<year` thresholds only (do NOT subtract to make bins).

**Coverage (bins vs memberOf baseline):** ENT ~94%, ORN ~88%, HERP ~83%, MAM ~65%, ICH ~33% (<2000),
**IZ ~0.4%**. Undated records are invisible to every date filter.

## `encounteredAt` — name vs id

```
{"memberOf":{"id":IZ}, "encounteredAt":{"name":"Bermuda"}}   → 5,421  (robust)
{"memberOf":{"id":IZ}, "encounteredAt":{"id":"…/place/<gazetteer>"}}   → 0  (specimens link
    per-event "Location" places, not the gazetteer node — id-match needs the exact linked place URI)
```
No "has ANY place" operator exists (no exists/not-null). To gauge georeferencing you must sample
records and inspect linked Places, or count by a specific named place.

## Type specimens — resolve & count

Resolve a concept: `search("concepts", {"name":"<lowercase term>"})` → take the concept whose object
`classified_as` `_label` is the UPPERCASE term. **Concept URIs live in `SKILL.md` §5** (single source
of truth — don't copy them here). Point-in-time hit counts for reference:

| Term | Lux hits (2026-07) | Note |
|---|---|---|
| HOLOTYPE | 5,073 | incl. "HOLOTYPE?" |
| PARATYPE | 5,194 | incl. "PARATYPE?" |
| SYNTYPE | 6,182 | |
| LECTOTYPE | 265 | |
| HYPOTYPE | 24,500 | **figured/referred, NOT name-bearing** |

Per-Set = `{"classification":{"id":"<concept>"}, "memberOf":{"id":"<set>"}}`. Use `classification`,
never `text` (`text:"holotype"` returns library books about holotypes and misses VP types).
Concept records' own `_label` is **lowercase**; object `classified_as` is UPPERCASE.

## Georeferencing extraction

1. `get_item_details("<object>", full=True)` → read `encountered_by[].took_place_at[].id` (the Place URI).
2. `get_item_details("<place>", full=True)` → extract `_label`, `part_of`, `defined_by` (WKT bbox).
   Beware aggregate Places (huge responses). Classify granularity: fine (<~0.1°) / coarse / aggregate / absent.
Coordinates never live on the object; the object `_label` may show "LatLon x y" as free text (not structured).

## Reminders

Landmine recap lives in `SKILL.md` §3–§5 (nested-`{id}` requirement, "Lux object hits" labeling,
`hasDigitalImage` == `isOnline`, VZ-parent Set = 0 hits). This cookbook holds the verbatim
reproductions above — not a second copy of the rules.