# Common Pfam IDs by use case

Quick reference for Pfam HMMs that show up in lab workflows. Download from
InterPro: `https://www.ebi.ac.uk/interpro/wwwapi/entry/pfam/<PFid>/?annotation=hmm`

## Mitochondrial markers (animal mt, table 5 for inverts)

| Marker | Pfam | Notes |
|--------|------|-------|
| CO1 | PF00115 | Cytochrome c oxidase subunit I — most-cited animal mt barcode |
| COX2 | PF00116 | Subunit II |
| COX3 | PF00510 | Subunit III |
| cyt-b | PF00033 | Cytochrome b N-terminal |
| ND1 | PF00146 | NADH dehydrogenase subunit 1 |
| ND4 | PF00361 | NADH dehydrogenase subunit 4 |
| ATP6 | PF00119 | ATP synthase subunit a (mt) |

Use all 4 of (CO1, COX2, COX3, cyt-b) for tree-based species ID — concordance
across markers protects against single-gene artifacts.

## Kinases / phosphatases

| Family | Pfam | Notes |
|--------|------|-------|
| Pkinase | PF00069 | Ser/Thr or dual-specificity kinase domain |
| Pkinase_Tyr | PF07714 | Tyrosine kinase domain (often co-occurs with Pkinase) |
| PI3K_p85_iSH2 | PF02192 | Inter-SH2 domain of p85 |
| PI3_PI4_kinase | PF00454 | PI3/PI4 kinase catalytic domain |
| Y_phosphatase | PF00102 | Protein-tyrosine phosphatase |
| DSPc | PF00782 | Dual-specificity phosphatase |

## Transcription factors (DBD families)

| Family | Pfam | Notes |
|--------|------|-------|
| HLH | PF00010 | bHLH transcription factor |
| Homeobox | PF00046 | Homeodomain (Hox, Pax, Six, etc.) |
| zf-C2H2 | PF00096 | Classical Cys2-His2 zinc finger |
| zf-C4 | PF00105 | Nuclear hormone receptor C4 zinc finger |
| Forkhead | PF00250 | Fox-family DBD |
| HMG_box | PF00505 | High-mobility group box (Sox, TCF/LEF) |
| Ets | PF00178 | Ets domain |
| GATA | PF00320 | GATA zinc finger |
| Myb_DNA-binding | PF00249 | Myb DBD (also plant R2R3-Myb) |
| T-box | PF00907 | T-box DBD (Brachyury, Tbx family) |

For lab TF list construction, hits to these Pfams are a strong fourth evidence
tier alongside eggNOG GO `DNA-binding transcription factor activity`, PROST GO,
curated TF lists (TFDB, AnimalTFDB), and name patterns.

## Signaling

| Family | Pfam | Notes |
|--------|------|-------|
| 7tm_1 | PF00001 | Rhodopsin-family GPCR (class A) |
| 7tm_2 | PF00002 | Secretin-family GPCR (class B) |
| 7tm_3 | PF00003 | Glutamate-family GPCR (class C, mGluR) |
| Wnt | PF00110 | Wnt ligand |
| TGF_beta | PF00019 | TGF-β / BMP family |
| FGF | PF00167 | Fibroblast growth factor |
| Notch | PF00066 | Notch DSL ligand |
| Frizzled | PF01392 | Frizzled / Smoothened CRD |

## ECM / cell-surface domains (common in sponges)

| Domain | Pfam | Notes |
|--------|------|-------|
| Laminin_N | PF00055 | Laminin LN domain (lab tree pipeline) |
| Laminin_EGF | PF00053 | Laminin EGF-like repeat |
| Laminin_G_1/2 | PF00054 / PF02210 | Laminin G domain |
| EGF | PF00008 | EGF-like domain (very common, multi-architecture) |
| EGF_CA | PF07645 | Calcium-binding EGF |
| Ig | PF00047 | Immunoglobulin V-set (also: PF07686 C-set, PF07679 I-set) |
| Fn3 | PF00041 | Fibronectin type III |
| Collagen | PF01391 | Collagen triple helix repeat |
| Spectrin | PF00435 | Spectrin repeat |
| CUB | PF00431 | CUB domain |

## Innate immunity / NLRs

| Family | Pfam | Notes |
|--------|------|-------|
| NACHT | PF05729 | NACHT NTPase domain (NLR signature) |
| NB-ARC | PF00931 | NB-ARC (plant resistance + animal NLRs) |
| LRR_4 | PF12799 | Leucine-rich repeat (also PF00560, PF13855) |
| TIR | PF01582 | TIR domain (TLRs, MyD88) |
| CARD | PF00619 | Caspase-recruitment domain |
| DEATH | PF00531 | Death domain |
| PYRIN | PF02758 | Pyrin / PYD domain |

## Single-copy ortholog markers (for assembly QC, similar to BUSCO logic)

For phylogenomic gene presence/absence checks across non-model species:
metazoa_odb10 lists ~954 of these, but you can also pull individual Pfam HMMs
for ribosomal proteins, RNA polymerase subunits, and proteasome components as
custom assembly QC.

## How to look up new Pfams

1. InterPro: search by family name → "Signature" → Pfam accession.
2. Pfam direct: <https://www.ebi.ac.uk/interpro/entry/pfam/>
3. Cross-check on UniProt: pick a known reference protein, look at "Family &
   Domains" → Pfam accessions listed.

For a brand-new family with no Pfam, build a custom HMM
(see `references/custom_hmms.md`).