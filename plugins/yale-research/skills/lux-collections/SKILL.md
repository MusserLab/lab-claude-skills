---
name: lux-collections
description: >
  Query Yale Lux (the Linked Art / CIDOC-CRM federated catalog covering the Yale Peabody Museum,
  Art Gallery, YCBA, and Library) through the `lux` MCP server (Casey Dunn's luxmcp / luxy wrapper).
  Use when searching Lux; counting or listing Peabody or Yale specimens/objects; building Lux
  `search` filters (memberOf, classification, encounteredDate, encounteredAt, text, hasDigitalImage,
  isOnline); resolving type specimens, taxa, collectors, localities, dates, images, or coordinates
  from Lux records; interpreting Linked Art object/Place JSON; or assembling evidence about Peabody
  collections. Also use before trusting any Lux count or filter combination — it documents silent
  landmines. Do NOT load for querying EMu / Darwin Core / GBIF directly (Lux is a lossy downstream
  layer — this skill says when to fall back to those), or for unrelated MCP servers.
---

# Yale Lux Collections (luxmcp)

How to get **correct, auditable** answers out of Yale **Lux** via the `lux` MCP server, and how to
avoid its silent landmines. Lux is a knowledge graph, not a specimen database — treating it like a
relational table produces confidently wrong answers. This is a **living reference**: record verified
findings with dates and source context through reviewed authoring; never save private observations in installed package files.

Deep detail lives in [data model](references/data-model.md) and
[query cookbook](references/query-cookbook.md). Their collection/filter observations are dated
2026-07 evidence, not current counts or a guarantee that upstream behavior is unchanged. Recheck
important queries and inspect emitted filters before relying on them.

## Availability and local output

This package supplies guidance, not the external `luxmcp` server or its dependencies. Confirm that
`search`, `get_item_details` and `list_filters` are callable. If they are missing, use the public
[Lux search site](https://lux.collections.yale.edu/) for manual searches and record its query/view
URL; report that wrapper-level filters, raw records and the documented reproductions could not be
checked. Do not claim API-equivalent coverage or silently install a server. See the maintained
[LuxY source/examples](https://github.com/project-lux/luxy) for the wrapper.

Remote catalog queries are read-only. `fetch_document` writes a chosen local destination and may
overwrite it: resolve a new or explicitly disposable path, check ownership/existing content and
obtain any required write authority before calling it. Never overwrite inputs or retained files.
User/project writing, reporting and style instructions take precedence over report defaults that
an external Dunn-lab MCP server may inject. Do not adopt another lab's reporting style implicitly.

---

## 1. What Lux is — and is not

- **Lux** (`lux.collections.yale.edu`) is a **Linked Art / CIDOC-CRM knowledge graph** (~41M records)
  that **federates** the Yale Peabody Museum, Art Gallery, Center for British Art, and University
  Library into one generic model. Accessed read-only via `luxmcp` → the `luxy` Python wrapper → the
  public Lux API. Public catalog queries require no account in the documented route; current availability is checked at use. Local downloads write files as explained above.
- **It is NOT a relational specimen database.** There are no tables/columns/null-counts. The nearest
  analogs are **7 entity types**: `objects`, `works`, `people`, `places`, `concepts`, `events`,
  `collections`. **Natural-history specimens are `objects`** (typed `HumanMadeObject` — a Linked Art
  quirk; `recordType` only distinguishes Physical vs Digital Object).
- **Underlying Peabody source = EMu.** Every record carries a `ypm:ecatalogue:irn:…` ("YPM EMu IRN")
  identifier. Lux is a **downstream, lossy aggregation** of EMu — many granular Darwin-Core fields
  are flattened into free text or dropped (see §6).

**MCP tools:** `search`, `get_item_details`, `list_filters`, `summarize_collection`,
`search_by_place`, `explore_by_person`, `fetch_finding_aid`, `fetch_document`. Remote catalog access is read-only; local downloads write files.
Most work uses **`search` + `get_item_details` + `list_filters`** (recipes in §7). The rest are
situational: `summarize_collection` (quick aggregate over a filter — totals, top types/makers/places,
date range, sample labels; the same landmines apply); `search_by_place` / `explore_by_person`
(resolve a place/person name → linked objects in one call); `fetch_finding_aid` (parse a Yale
Manuscripts & Archives finding aid — its title parse is currently flaky); `fetch_document` (download
a record's best PDF/image surrogate to a local file).

---

## 2. The record model (objects) — structured vs free-text

Full walkthrough in `references/data-model.md`. The essentials:

| Datum | Where it lives | Structured & filterable? |
|---|---|---|
| Catalog / field / accession / EMu numbers | `identified_by[]` typed Identifiers | ✅ (`identifier`, `name`, `id`) |
| Collection / department | `member_of[]` Set | ✅ (`memberOf`) |
| Determined taxon **+ rank** | `classified_as[]` Type (nested rank concept: Kingdom…Species) | ✅ (`classification`) |
| **Type status** (holotype…) | `classified_as[]` Type concept (§5) | ✅ (`classification`) |
| Specimen/part count | `dimension[]` "Number of Parts" (integer) | ⚠️ present, but not a clean filter; = lot/part count, **not specimens** |
| Collection date | `encountered_by[].timespan` **if present** | ⚠️ `encounteredDate` — **but see LANDMINE §4** and sparse coverage |
| Locality | `encountered_by[].took_place_at[]` → Place (code label `IZS.*`) | ⚠️ `encounteredAt` (needs a value) |
| Coordinates | on the **linked Place** `defined_by` WKT **bbox polygon** — NOT on the object, NOT a point | via linked Place only (§4 landmine 6, §7) |
| Collector | `encountered_by[].carried_out_by[]` Person/Group (often "Collector", anonymized, or absent) | ✅ `encounteredBy` (agent) |
| Image / IIIF | `representation[]` + `subject_of[]` IIIF manifest | ✅ `hasDigitalImage`/`isOnline` |
| Higher taxonomy | free-text Note "Latinized/Common Name Hierarchy" | ❌ note only |
| **Preservation / fixative** | free-text Note "Preservation Notes: …" | ❌ note only |
| Sex / life stage / captive | free-text Note "Biological Notes: sex = … / lifestage = …" | ❌ note only |
| Anatomical part / prep | free-text Note "Anatomical Notes: whole mount / shell / …" | ❌ note only |
| Access/loan status | free-text Note "Access Statement" ("in collection"/"on exhibit"/"on loan") | ❌ note only; **not** a sensitivity flag |
| Provenance / acquisition | free-text Note "Accession …, rcvd. via donation, YYYY" | ❌ note only |

**Rule of thumb:** taxonomy (species+rank), collection membership, identifiers, part-count, images,
and type status are **structured**. Preservation, fixative, sex, life stage, anatomy, higher-taxonomy
ladder, and precise coordinates are **free-text or one-hop-away** — read them per record, never filter
or aggregate on them. Use `get_item_details(uri, full=True)` to see the real structure.

---

## 3. Counts are "Lux object hits" — never "specimens"

Every `search` returns `total_results`. **Always label it "Lux object hits"** = indexed catalog
records. It is **not** a specimen / lot / individual count: `Number of Parts` runs 1 → 135 (a
tissue lot can be n=93). And Lux indexes only a **subset** of the physical collection. Report the
`view_url` alongside any count so the query is auditable.

---

## 4. LANDMINES (read before trusting any result)

1. **All entity references must be nested `{"id": "<full-URI>"}`.** A bare UUID returns **0**; a bare
   string returns **HTTP 400**. Applies to `memberOf`, `classification`, `encounteredAt` (id form), etc.
   `text` is the exception — a plain string.

2. **`encounteredDate` silently drops any filter listed *before* it (order-dependent).** A
   `[value, operator]` date-comparison filter **resets the accumulated query** (root cause in `luxy`),
   so anything applied earlier vanishes — **with no error**. Verified:
   - `{"memberOf":{"id":IZ}, "encounteredDate":["1900-01-01T00:00:00.000Z","<"]}` → **68,077** (wrong;
     memberOf gone, returns Botany + VP).
   - `{"encounteredDate":["1900-01-01T00:00:00.000Z","<"], "memberOf":{"id":IZ}}` → **233** (correct, IZ).
   **Two working forms:** (a) list the date filter **first**, or (b) hand-author the raw AND:
   `{"AND":[{"memberOf":{"id":IZ}},{"encounteredDate":"1900-01-01T00:00:00.000Z","_comp":"<"}]}`.
   **Ranges:** two `encounteredDate` clauses inside `AND` (works for most Sets; a few reject it → fall
   back to cumulative `<year` thresholds and do **not** subtract to derive bins).
   Date filters only see records with a **structured** `encounteredDate`; coverage varies wildly
   (Entomology ~94%, **Invertebrate Zoology ~0.4%** — its dates live only in `_label`).

3. **`encounteredAt` needs a specific Place value; there is no "has-any-place" count.** Name-match is
   robust: `{"encounteredAt":{"name":"Bermuda"}}`. **Id-match often returns 0** — specimens link to
   per-collecting-event "Location" places (`IZS.*`/`HER.*` codes), not the hierarchical gazetteer node.
   You **cannot** ask "how many objects have any georeferenced place" in one filter.

4. **`text` spans ALL of Lux → heavy Yale-Library contamination.** Generic words (formaldehyde,
   alcohol, ethanol, fluid, wet, slide, skeletal, shell) return mostly library books/prints, not
   specimens. **Constrain with `memberOf` or `classification` (e.g. the "Animals" concept).** Some
   terms are **stemmed** (`pinned` → `pin`, matching "pin feather"). `text` matches the whole record,
   including titles and free-text notes.

5. **`hasDigitalImage` == `isOnline`** (identical count *and* item set, at least for IZ). Boolean
   `true` serializes to `1`. Use either.

6. **Coordinates are Place bounding boxes, not points, and vary in precision.** `defined_by` is a WKT
   **POLYGON** (fine ~0.03–0.05° ≈ 3–5 km; coarse whole-county/region/country; or **absent**). No
   uncertainty field. Some objects link to **coarse aggregate Places** (e.g. "Bermuda Islands"
   aggregating hundreds of localities). Place responses can be **huge** (an aggregate Place hit 385 KB)
   — extract only `_label`, `part_of`, and `defined_by`.

7. **Type status is structured, but use `classification`, not `text`.** `text:"holotype"` returns
   library books *about* holotypes and misses VP types (VP objects don't echo the term in `_label`).
   The `classification` concept catches them. See §5 for URIs. **HYPOTYPE is a *figured/referred*
   specimen, not a name-bearing primary type** — never table it beside holotype/paratype without that
   flag. "PARATYPE?" is **not** a distinct concept — it folds into the PARATYPE concept.

Combinations that **do** work cleanly (any order): `memberOf` + `classification` + `text` +
`hasDigitalImage`/`isOnline`, in any 2- or 3-way mix. Only the `encounteredDate` comparison is order-fragile.

---

## 5. Quick-reference: Peabody Sets + type concepts

**Set URIs** — prefix `https://lux.collections.yale.edu/data/set/`. Query as
`{"memberOf":{"id":"<full set URI>"}}`.

| Collection | Set id | Note |
|---|---|---|
| Invertebrate Zoology | `ef0600bb-ce93-4435-8fa4-d4ea6586a181` | dates ~0.4% structured |
| Entomology | `9b3042fc-dbcc-44ac-b0a9-88369803b0bb` | |
| Vertebrate Zoology **(Ornithology)** | `6b66437e-d5ad-40da-b70e-821edb47eb7b` | |
| Vertebrate Zoology **(Herpetology)** | `af5f3b46-7e58-4df9-b3bf-f3a258c93b25` | |
| Vertebrate Zoology **(Ichthyology)** | `a9ac59e7-178f-4f25-9bae-a0d27661f241` | date ranges rejected → cumulative |
| Vertebrate Zoology **(Mammalogy)** | `37ca7b12-c19b-48f1-b0fb-8e4dd2c46b7b` | |
| Vertebrate Zoology (general parent) | `4ce3e7f8-2c7d-4fdf-9e75-9e816d6a2dd3` | **0 hits — do not query** |
| Vertebrate Paleontology *(fossil)* | `1c73bc57-c1e1-4797-9e82-3ffadf51bdb0` | animal fossils; `classified_as` Fossils |
| Invertebrate Paleontology *(fossil)* | `3eeb2ec0-cd90-4ccc-b7bf-2672bdfbc442` | **mixed** — Foraminifera are protists |
| Umbrella "Yale Peabody Museum" | `2a4df0b9-9eac-45ab-b67c-b0bc13a89df7` | 42 sub-Sets incl. non-animal + Archives |

Non-animal Peabody Sets also exist (Botany, Mineralogy & Meteoritics, Anthropology, Paleobotany,
Babylonian, History of Science & Technology). Specimen Sets carry **no `description`** in Lux.

**Type-status concept URIs** — prefix `https://lux.collections.yale.edu/data/concept/`. Query as
`{"classification":{"id":"<full concept URI>"}}` (optionally + `memberOf`). Resolve new ones by
searching `concepts` with the **lowercase** name.

| Type | Concept id | Note |
|---|---|---|
| HOLOTYPE | `0bb7dbf6-4a76-4891-8db8-0f931f4e0366` | includes "HOLOTYPE?" variants |
| PARATYPE | `7d0b544f-3f4e-4ec0-9f98-3e56e76ef834` | includes "PARATYPE?" |
| SYNTYPE | `886a40e1-f7b5-4d42-bac2-a556dcd2ef4a` | |
| LECTOTYPE | `489b31d9-faa1-4022-937d-1997b261b40e` | |
| HYPOTYPE | `8f634f9c-fd42-4f02-bb1e-c875d5c11112` | **figured/referred, NOT a primary type** |

---

## 6. What Lux can vs cannot support — when to fall back

**Lux CAN** (extract directly): collection enumeration + hit counts; stable per-record identifiers +
collection membership; determined taxon + rank; specimen/part count; image/IIIF availability;
type-specimen lists via `classification`; faceted search by collection/taxon/collector/place/date
**where populated**; geographic names for prose (Place `_label` + `part_of`); bounding-box
coordinates for a subset.

**Lux CANNOT — fall back to EMu / Darwin Core / GBIF / Peabody staff export:** per-field
completeness or null statistics; authoritative specimen (vs record) counts; precise decimal-degree
coordinates + `coordinateUncertaintyInMeters`; structured `sex` / `lifeStage` / `tissue` /
`preparations` / fixative; reliable date bins for Invertebrate Zoology and Ichthyology; anything that
is a free-text Note in Lux but needs to be queried/aggregated as a field.

---

## 7. Working recipes

```
# Collection size (Lux object hits) + representative records
search("objects", {"memberOf": {"id": "<set URI>"}})

# Type specimens in a collection (structured, correct)
search("objects", {"classification": {"id": "<type concept URI>"},
                   "memberOf": {"id": "<set URI>"}})

# Imaged records in a collection
search("objects", {"memberOf": {"id": "<set URI>"}, "hasDigitalImage": true})

# Collected before 1900 in a collection — date filter FIRST (or hand-author AND)
search("objects", {"encounteredDate": ["1900-01-01T00:00:00.000Z", "<"],
                   "memberOf": {"id": "<set URI>"}})

# Specimens from a named place
search("objects", {"memberOf": {"id": "<set URI>"}, "encounteredAt": {"name": "Bermuda"}})

# Full Linked Art record (structure, notes, linked Place/Person URIs)
get_item_details("<object URI>", full=True)
```

Then, for coordinates: read the object's `encountered_by[].took_place_at[]` Place URI and
`get_item_details` it — pull only `_label`, `part_of`, `defined_by` (may be a huge aggregate Place).

---

## 8. Maintenance

Keep new query evidence and private collection/project observations in the owning project's record.
Reusable corrections to concepts, filters or `luxmcp`/`luxy` behavior go through reviewed authoring and
release; do not modify installed package files directly. Keep dated reproductions in the maintained
query cookbook and recheck upstream fixes before changing the warning.