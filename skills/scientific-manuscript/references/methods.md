# Methods Writing Guide

## Core Principle: Reproducibility

Methods should enable another scientist to replicate your experiments exactly. Include all parameters, reagents, and analysis steps.

## Organization

### By Technique (common for multi-method papers)
```
## Animal husbandry
## Sample collection
## RNA extraction and sequencing
## Proteomics
## Imaging
## Data analysis
```

### By Experiment (common for focused papers)
```
## Experiment 1: Behavioral characterization
## Experiment 2: Molecular profiling
## Experiment 3: Functional validation
```

## Essential Information Checklist

### Biological Materials
- [ ] Species, strain, genotype
- [ ] Source (supplier, collection site)
- [ ] Age, sex, developmental stage
- [ ] Sample size and replicates
- [ ] Housing/culture conditions

### Reagents
- [ ] Supplier and catalog number
- [ ] Concentrations used
- [ ] Lot numbers (for critical reagents)
- [ ] Buffer compositions

### Equipment
- [ ] Instrument manufacturer and model
- [ ] Key settings and parameters
- [ ] Software and version

### Analysis
- [ ] Software and version
- [ ] Statistical tests used
- [ ] Multiple testing correction
- [ ] Thresholds for significance
- [ ] Code availability

## Writing Style

### Be Precise, Not Verbose
Include all necessary details, but avoid excessive narrative.

**Weak**: "Samples were processed according to standard protocols as previously described."
**Strong**: "RNA was extracted using TRIzol (Invitrogen) following manufacturer's protocol with modifications: homogenization was extended to 2 min for tough tissues."

### Use Past Tense, Passive Voice (acceptable here)
Methods is the one section where passive voice is standard.
"Samples were collected..." / "Data were analyzed..."

### Reference Prior Work Appropriately
If using an established method without modification:
"Library preparation was performed as described (Smith et al., 2020)."

If modifying an established method:
"We adapted the protocol of Smith et al. (2020) with the following modifications: [details]."

## Common Problems

| Problem | Example | Fix |
|---------|---------|-----|
| Missing n | "Experiments were repeated" | "n = 5 biological replicates" |
| Vague stats | "Statistical analysis was performed" | "Two-tailed t-test, α = 0.05" |
| No version numbers | "Analysis used R" | "R v4.2.1 with DESeq2 v1.38.0" |
| Missing controls | Describes treatment only | Include all control conditions |
| Incomplete references | "Standard methods" | Cite or describe fully |

## Specialized Sections

### Bioinformatics/Computational
- Raw data accession numbers
- Processing pipeline with parameters
- Quality control steps and thresholds
- Code repository URL

### Imaging
- Microscope configuration
- Objective specifications
- Acquisition settings (exposure, gain)
- Image processing steps

### Statistics
- Sample size justification (power analysis if performed)
- Assumption testing (normality, homoscedasticity)
- Exact tests used for each comparison
- Definition of center/dispersion (mean ± SD vs SEM)

## Data Availability Statement

Required by most journals. Include:
- Raw data repository and accession number
- Processed data availability
- Code repository URL
- Any restrictions on access

Example:
"RNA-seq data have been deposited in GEO under accession GSE123456. Analysis code is available at github.com/lab/project. Source data for all figures are provided."

## Supplementary Methods

Move extended protocols to Supplements when:
- Standard methods with minor modifications
- Detailed computational pipelines
- Extensive reagent lists
- Quality control details

Keep in main Methods:
- Novel methods central to the paper
- Key parameters for all experiments
- Statistical approach overview
