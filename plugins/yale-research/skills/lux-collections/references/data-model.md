# Lux Linked Art data model — object & Place structure

Dated public-catalog observations from 2026-07. Recheck important structure/filter behavior and
current query counts at use; coverage observations are not a current completeness claim.

Deep reference for what a Lux record actually contains. Read alongside `SKILL.md` §2.
Inspect any record with `get_item_details("<uri>", full=True)`.

## Entity types (the nearest thing to "tables")

`objects`, `works`, `people`, `places`, `concepts`, `events`, `collections`.
- **Natural-history specimens = `objects`**, typed `HumanMadeObject` (a Linked Art convention — even a
  fossil or a fluid-preserved animal). `recordType` distinguishes only "Physical Object" vs "Digital Object".
- `collections` = **Sets** (the department/collection groupings; `member_of` targets these).
- `concepts` = the controlled vocabulary (taxa, ranks, type-status terms, materials, "Animals"/"Fossils").
- `places` = localities & gazetteer nodes; `people` = collectors/authors (as agents).

## Anatomy of a specimen `object`

Fields seen on Peabody specimen records:

- **`id`** — Lux data URI (`…/data/object/<uuid>`). UI view = `…/view/object/<uuid>`.
- **`_label`** — a big free-text concatenation (taxon + locality + collector + date + prep tokens like
  `[wet]`/`[skeleton]`/`(n=1)`). **This is display text, not structured data** — much of what looks like
  "data" (dates, collectors, lat/long, prep) exists *only* here for many records.
- **`identified_by[]`** — Names + typed Identifiers, each with a `classified_as` concept naming the id type:
  - `YPM External Catalog Number` (e.g. "YPM IZ 106943"), `YPM Internal Catalog Number` ("IZ.106943"),
    `YPM EMu IRN` (`ypm:ecatalogue:irn:…` → proves the EMu source), `YPM Accession Number` ("YPM.12517"),
    `field number`, `original catalog number`, `institutional specimen number`.
  - Primary Name = the taxon string (or "undetermined taxon").
- **`member_of[]`** — the collection **Set** (structured; the `memberOf` filter target).
- **`classified_as[]`** — concepts: `Animals` / `Fossils` / `Plants`; `three-dimensional`; the **taxon**
  Type with a **nested rank concept** (Kingdom / Phylum / Class / Order / Family / Genus / Species /
  Subspecies); a **type-status** concept when a type (HOLOTYPE, etc.); `Collection Item`.
- **`dimension[]`** — a `Dimension` with `classified_as` **"Number of Parts"** and an integer `value` =
  the lot/part count (1 → 135). Mammals also carry body-measurement dimensions (length/weight, metric).
  **Not an individual-specimen count.**
- **`encountered_by[]`** — an **Encounter** ("Collecting Event"), when present:
  - `timespan` → structured collection date (**often ABSENT** — then date is only in `_label`).
  - `took_place_at[]` → a **Place** whose `_label` is an opaque code (`IZS.*`, `HER.*`, `ICH.*`); the
    readable locality is in the object `_label`. Coordinates are on this Place (see below).
  - `carried_out_by[]` → `Person` or `Group` agents, frequently labelled just "Collector" (anonymized),
    sometimes absent, sometimes typed inconsistently (Group vs Person for the same role).
- **`representation[]`** + **`subject_of[]`** — Digital Image + IIIF manifest
  (`manifests.collections.yale.edu/ypm/nat/<n>`) when the record is imaged. NB: many records instead
  carry only an `equivalent` link to `images.peabody.yale.edu` (the DAMS) with **no** in-record IIIF —
  report those as *not* imaged to avoid overstating IIIF availability. Curiously, in Ichthyology the
  imaged records are often the *undetermined* mass lots, while fully-identified specimens lack IIIF.
- **`referred_to_by[]`** — free-text **Notes** (`classified_as` "Note" / Access Statement / etc.):
  - `Access Statement` — "in collection" / "on exhibit" / "on loan" / "not on view". The only status-like
    field; **not** a sensitivity/locality-suppression flag (Lux has none — suppression is applied upstream
    by coarsening or omitting coordinates).
  - `Visitors' Statement` — boilerplate ("Plan your visit…").
  - `Preservation Notes` — e.g. "10% form.->70% alc.", "tissue in EtOH", "skeleton (incomplete)", "dry",
    "microslide, balsam", "frozen tissue". **Fixative/fluid lives here as prose, never a field.**
  - `Latinized Name Hierarchy` / `Common Name Hierarchy` — the higher-taxonomy ladder, as a semicolon
    string. **Not structured ranks** (the single determined-taxon rank *is* structured; the ladder is not).
  - `Biological Notes` — "sex = female", "lifestage = larva/adult/embryo", "captive = yes".
  - `Anatomical Notes` — "whole mount", "serial section", "shell", "skeletal muscle", "tracks - 2 slabs".
  - `Identification Notes`, `Other Identifications`, `Provenance` ("Accession …, rcvd. via donation, 2014").
- **`equivalent[]`** — cross-links to the Peabody DAMS object.
- **`_links`** — `lux:itemDepartment` / `lux:itemUnit` (department derivable via a follow-up query, not
  an inline field).

## Place structure

`get_item_details` on a `…/data/place/<uuid>`:
- `classified_as` = "Location".
- `_label` = **dotted geographic string** ("North America. USA. Arkansas. Hot Spring County. Bismarck. …"
  or "Atlantic Ocean. Bermuda. Castle Roads. …") — the human-readable hierarchy, as free text.
- `part_of[]` = **one** structured parent (a county, country, or ocean) — not the full chain.
- `defined_by` = WKT **POLYGON = axis-aligned bounding box** (not a point, no uncertainty value):
  - **fine** ~0.03–0.05° (~3–5 km); consistent ~0.033° squares suggest a fixed buffer around a point.
  - **coarse** whole-county/region/country (e.g. "Costa Rica", part_of "North and Central America").
  - **absent** — no geometry at all (some Places have none).
  - **aggregate** — a single coarse node (e.g. "Bermuda Islands", ~25 km bbox) can collapse **hundreds**
    of distinct EMu locality numbers (`IZS.*`, `HER.*`, `ICH.*`, …). These responses can be **very large**
    (observed 385 KB) — extract only `_label`, `part_of`, `defined_by`.
- Identifiers: `YPM EMu Locality Number` + `ypm:ecollectionevents:irn:…`.

## Structured depth varies by department

- **Vertebrate Zoology** (Herpetology / Ichthyology / Mammalogy / Ornithology) — richest: species-level
  taxa, structured encounters (date + Place + collector) on modern records, Biological/Preservation notes.
- **Invertebrate Zoology & paleontology** — mostly **high-rank** IDs (Phylum/Class), dates & collectors
  usually **only in `_label`** (IZ structured-date coverage ~0.4%), Place is a bare code.
- **Invertebrate Paleontology** is taxonomically **mixed** — Foraminifera (protists) alongside animal
  fossils (Brachiopoda, Trilobita, Bryozoa, Graptolithina). **Vertebrate Paleontology** objects are
  `classified_as` **Fossils** (not Animals) and label by catalog number (type term not echoed in `_label`).