# BUSCO odb10 Lineage Reference

These odb10 names and counts are retained examples for the current templates, not a live
catalog or a claim that odb10 is the newest release. Check the project's chosen BUSCO version
with `busco --list-datasets`; record the actual lineage name, creation date and `n` from the
completed short summary. Do not silently substitute another dataset release.

Taxonomic scopes are nested, but marker sets and detection thresholds differ. A match in one
lineage dataset does not guarantee a match or the same score in another. Choose an appropriate
lineage for the primary assessment before any optional sensitivity comparison.

## Universal

| Lineage | Orthologs | Use for |
|---------|-----------|---------|
| `eukaryota_odb10` | 255 | Broad eukaryotic assessment when appropriate; lower resolution than a suitable specific set. |
| `bacteria_odb10` | 124 | Any bacterium |
| `archaea_odb10` | 194 | Any archaean |

## Animals

| Lineage | Orthologs | Use for |
|---------|-----------|---------|
| `metazoa_odb10` | 954 | Any animal — sponges, ctenophores, cnidarians, bilaterians |
| `vertebrata_odb10` | 3,354 | Vertebrates |
| `mammalia_odb10` | 9,226 | Mammals |
| `tetrapoda_odb10` | 5,310 | Tetrapods (amphibians + reptiles + birds + mammals) |
| `actinopterygii_odb10` | 3,640 | Ray-finned fishes |
| `aves_odb10` | 8,338 | Birds |
| `arthropoda_odb10` | 1,013 | Arthropods (insects, arachnids, crustaceans) |
| `insecta_odb10` | 1,367 | Insects (more specific than arthropoda) |
| `nematoda_odb10` | 3,131 | Nematodes |
| `mollusca_odb10` | 5,295 | Molluscs |

### Other commonly-used animal lineages

Counts omitted — verify with `busco --list-datasets`.

| Lineage | Use for |
|---------|---------|
| `diptera_odb10` | Flies (Drosophila etc.) |
| `hymenoptera_odb10` | Bees, ants, wasps |
| `lepidoptera_odb10` | Butterflies, moths |
| `primates_odb10` | Primates (human, chimp, macaque) |
| `euarchontoglires_odb10` | Primates + rodents + rabbits |
| `glires_odb10` | Rodents + rabbits |

## Fungi

| Lineage | Orthologs | Use for |
|---------|-----------|---------|
| `fungi_odb10` | 758 | Any fungus |
| `ascomycota_odb10` | 1,706 | Ascomycetes |
| `basidiomycota_odb10` | 1,764 | Basidiomycetes |
| `saccharomycetes_odb10` | 2,137 | Yeasts |

## Plants & Algae

| Lineage | Orthologs | Use for |
|---------|-----------|---------|
| `viridiplantae_odb10` | 425 | Land plants + green algae |
| `embryophyta_odb10` | 1,614 | Land plants only |
| `eudicots_odb10` | 2,326 | Eudicot flowering plants |
| `liliopsida_odb10` | 3,236 | Monocots (grasses, palms, etc.) |
| `chlorophyta_odb10` | 1,519 | Green algae |

## Protists

| Lineage | Orthologs | Use for |
|---------|-----------|---------|
| `alveolata_odb10` | 171 | Alveolates (apicomplexans, ciliates, dinoflagellates) |
| `apicomplexa_odb10` | 446 | Apicomplexans (Plasmodium etc.) |
| `stramenopiles_odb10` | 100 | Stramenopiles (diatoms, oomycetes) |

## Example primary choices by clade

Check for a more specific appropriate dataset in the chosen release before copying an example.
These examples do not require a second, broader run.

| Organism | Example primary lineage in odb10 |
|----------|----------------------------------|
| Mammal | Most specific appropriate available set; `mammalia_odb10` is a broader mammalian example |
| Vertebrate (non-mammal) | Appropriate vertebrate subgroup where available; otherwise `vertebrata_odb10` |
| Insect | Appropriate insect subgroup where available; otherwise `insecta_odb10` |
| Sponge / ctenophore / cnidarian / placozoan | `metazoa_odb10` when no suitable narrower set is available |
| Choanoflagellate | An available lineage containing the organism; `eukaryota_odb10` is a broad example, not `metazoa_odb10` |
| Yeast | A lineage matching the actual yeast clade; `saccharomycetes_odb10` only for Saccharomycetes |
| Land plant | Appropriate plant subgroup where available; otherwise `embryophyta_odb10` |
| Diatom / oomycete | Appropriate subgroup where available; otherwise `stramenopiles_odb10` |
| Bacterium | Appropriate bacterial subgroup where available; otherwise `bacteria_odb10` |

## Interpreting optional lineage comparisons

A broader set may answer a defined sensitivity question. A deliberately out-of-clade set is an
exploratory comparison and must not be presented as the organism's primary completeness score.
Keep the purpose and each lineage's marker count visible in the report.

High scores mean the selected conserved markers were largely recovered; they do not prove the
whole assembly or gene set is complete. Low scores warrant checking the input, mode, lineage fit,
logs, search/gene-prediction limitations and marker-level results. Missing calls can reflect
non-recovery, including divergence or prediction failure, rather than demonstrated biological
absence. Different scores alone do not identify the cause or make a broader score authoritative.

Method guidance: [BUSCO user guide](https://busco.ezlab.org/busco_userguide#interpreting-the-results).
