# Results Writing Guide

## Core Principle: Narrative Flow

Results should tell a story, not list experiments. Each section should:
1. State what you asked
2. Describe what you did (briefly)
3. Present what you found
4. Explain what it means for the next question

## Structure Patterns

### Pattern 1: Question-Driven
Each section answers a specific question that flows from the previous finding.

```
## Section 1: [Question 1]
Finding → raises Question 2

## Section 2: [Question 2]
Finding → raises Question 3
```

### Pattern 2: Scale-Organized
Zoom in or out through levels of analysis.

```
## Organism-level behavior
## Tissue-level changes
## Cellular mechanisms
## Molecular basis
```

### Pattern 3: Hypothesis-Testing
Present predictions and test them systematically.

```
## If X, then we predict Y
## Testing prediction 1
## Testing prediction 2
## Integrating results
```

## Writing Principles

### Lead with the Finding
Start each paragraph with the result, not the method.

**Weak**: "We performed RNA-seq on X and Y samples. We found 847 DEGs."
**Strong**: "X and Y states differ in expression of 847 genes (Figure 1A), with enrichment for..."

### Integrate Figures
Reference figures as you make claims—don't describe figures.

**Weak**: "Figure 2A shows a heatmap of gene expression. Figure 2B shows GO enrichment."
**Strong**: "Contractile cells upregulate cytoskeletal genes (Figure 2A), with significant enrichment for actin binding (Figure 2B, p < 0.001)."

### Quantify Claims
Replace adjectives with numbers.

**Weak**: "Expression was significantly higher..."
**Strong**: "Expression increased 4.2-fold (p = 0.003)..."

### Connect Sections
End each section by setting up the next question.

**Weak**: "These results show X is important."
**Strong**: "The upregulation of X suggested a role in Y, which we tested directly."

## Section Headings

Use informative, conclusory headings—not descriptive ones.

**Weak**: "RNA-seq analysis of cell types"
**Strong**: "Contractile and secretory cells express distinct transcriptional programs"

**Weak**: "Proteomics results"
**Strong**: "Post-translational modifications drive rapid state transitions"

## Common Problems

| Problem | Example | Fix |
|---------|---------|-----|
| Methods in Results | Long protocol descriptions | Move to Methods, keep one sentence |
| Figure walk-through | "Panel A shows... Panel B shows..." | Integrate figures into claims |
| Missing logic | Sections don't connect | Add transition sentences |
| Interpretation creep | Discussion points in Results | Save interpretation for Discussion |
| Hedge overload | "may suggest," "appears to" | State findings directly |

## Data Presentation

### When to Use Each Format
- **Representative images**: Show qualitative patterns
- **Quantification**: Support images with statistics
- **Heatmaps**: Show many comparisons at once
- **Line graphs**: Show change over time/condition
- **Bar graphs**: Compare discrete conditions

### Statistical Reporting
Include: test type, test statistic, p-value, n, what n represents
"(t-test, t=4.2, p=0.003, n=5 biological replicates)"

## Balancing Act

Results should be:
- **Complete enough** to support conclusions
- **Concise enough** to maintain narrative momentum
- **Objective** in presentation (save interpretation)
- **Connected** to the larger story
