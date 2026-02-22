#!/usr/bin/env Rscript
# =============================================================================
# TEMPLATE: iTOL Annotation Files
# =============================================================================
# Generates iTOL annotation files for a phylogenetic tree:
#   - Relabeled Newick tree (short display labels, no pipe characters)
#   - TREE_COLORS: branch coloring by taxonomy (clade + individual entries)
#   - TREE_COLORS: label coloring by taxonomy
#   - COLLAPSE: pure-clade collapsing entries
#   - LABELS: collapsed clade labels with focal species annotations
#
# Two-script workflow: this R script generates annotations, then a separate
# Python script (upload_export.py) uploads to iTOL and exports rendered images.
#
# CRITICAL: Tip labels are relabeled to short display names (no | characters)
# before writing the tree. This is required because iTOL uses | as the MRCA
# separator in clade/collapse entries, so | in tip labels breaks parsing.
#
# USAGE: Copy this template into your project's scripts/ directory,
#        then adapt the sections marked PROJECT-SPECIFIC.
# =============================================================================

library(ape)
library(phytools)  # for midpoint.root()

# =============================================================================
# PROJECT-SPECIFIC: Paths
# =============================================================================
tree_file <- "data/phylogenetics/GENE/ALIGNMENT.treefile"
taxonomy_file <- "data/phylogenetics/taxonomy_mapping.tsv"
out_dir <- "outs/phylogenetics/XX_itol_annotations"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# PROJECT-SPECIFIC: Taxonomy mapping
# =============================================================================
# Option A: Load from TSV (columns: species, group, color)
# tax_map <- read.delim(taxonomy_file)
# sp_to_group <- setNames(tax_map$group, tax_map$species)
# group_colors <- unique(setNames(tax_map$color, tax_map$group))

# Option B: Define inline (uncomment and populate)
taxonomy <- list(
  "Demosponges" = c(
    "Amphimedon_queenslandica", "Spongilla_lacustris", "Ephydatia_muelleri",
    "Tethya_wilhelma", "Halichondria_panicea", "Geodia_barretti"
  ),
  "Calcarea + Homoscleromorpha" = c(
    "Sycon_ciliatum", "Oscarella_lobularis", "Corticium_candelabrum"
  ),
  "Ctenophora" = c(
    "Mnemiopsis_leidyi", "Pleurobrachia_bachei", "Bolinopsis_microptera"
  ),
  "Cnidaria + Placozoa" = c(
    "Hydra_vulgaris", "Nematostella_vectensis", "Aurelia_aurita",
    "Clytia_hemisphaerica", "Sarsia_tubulosa", "Tripedalia_cystophora",
    "Cladocora_caespitosa", "Trichoplax_sp_H1", "Trichoplax_sp_H2",
    "Trichoplax_sp._H2", "Trichoplax_adhaerens", "Thelohanellus_kitauei",
    "Hydractinia_symbiolongicarpus"
  ),
  "Deuterostomia" = c(
    "Homo_sapiens", "Mus_musculus", "Danio_rerio", "Callorhinchus_milii",
    "Petromyzon_marinus", "Ambystoma_mexicanum", "Xenopus_tropicalis",
    "Ciona_intestinalis", "Strongylocentrotus_purpuratus",
    "Branchiostoma_lanceolatum", "Meara_stichopi", "Waminoa"
  ),
  "Protostomia" = c(
    "Drosophila_melanogaster", "Caenorhabditis_elegans",
    "Parasteatoda_tepidariorum", "Daphnia_pulex", "Hyalella_azteca",
    "Parhyale_hawaiensis", "Platynereis_dumerilii", "Schistosoma_mansoni",
    "Schmidtea_mediterranea", "Prostheceraeus_crozeri",
    "Biomphalaria_glabrata", "Crassostrea_gigas", "Aplysia_californica",
    "Acanthochitona_crinita", "Spadella_cephaloptera"
  )
)

sp_to_group <- list()
for (group in names(taxonomy)) {
  for (sp in taxonomy[[group]]) sp_to_group[[sp]] <- group
}

group_colors <- c(
  "Demosponges"                = "#2ca02c",
  "Calcarea + Homoscleromorpha" = "#98df8a",
  "Ctenophora"                 = "#9467bd",
  "Cnidaria + Placozoa"        = "#ff7f0e",
  "Deuterostomia"              = "#d62728",
  "Protostomia"                = "#1f77b4",
  "Non-metazoan eukaryotes"    = "#555555"
)

# =============================================================================
# PROJECT-SPECIFIC: Tip label parsing
# =============================================================================
# These functions MUST be adapted to match actual label formats in the tree.
# Inspect tip labels first: head(tree$tip.label, 20)

# UniProt suffix -> full species name
uniprot_to_species <- c(
  HUMAN = "Homo_sapiens", MOUSE = "Mus_musculus",
  DROME = "Drosophila_melanogaster", CAEEL = "Caenorhabditis_elegans",
  DANRE = "Danio_rerio", ANOGA = "Anopheles_gambiae",
  RAT = "Rattus_norvegicus", BOVIN = "Bos_taurus",
  CHICK = "Gallus_gallus", XENLA = "Xenopus_laevis",
  SHEEP = "Ovis_aries", ARATH = "Arabidopsis_thaliana",
  DICDI = "Dictyostelium_discoideum"
)

parse_species_id <- function(label) {
  if (grepl("^(sp|tr)\\|", label)) {
    parts <- strsplit(label, "\\|")[[1]]
    if (length(parts) >= 3) return(sub(".*_", "", parts[3]))
  }
  if (grepl("\\|", label)) return(strsplit(label, "\\|")[[1]][1])
  return(label)
}

resolve_species <- function(species_id) {
  if (species_id %in% names(uniprot_to_species)) {
    return(uniprot_to_species[species_id])
  }
  return(species_id)
}

# Extract protein/gene ID from tip label.
# Handles: sp|acc|GENE_SPECIES, tr|acc|..., Species|taxid.acc, Species|acc
parse_protein_id <- function(label) {
  parts <- strsplit(label, "\\|")[[1]]
  if (grepl("^sp\\|", label) && length(parts) >= 3) {
    return(sub("_[^_]+$", "", parts[3]))  # gene name from sp| label
  }
  if (grepl("^tr\\|", label) && length(parts) >= 2) {
    return(parts[2])  # accession
  }
  if (length(parts) == 2 && grepl("^[0-9]+\\.", parts[2])) {
    return(sub("^[0-9]+\\.", "", parts[2]))  # strip taxid prefix
  }
  if (length(parts) == 2) {
    return(parts[2])
  }
  return(label)
}

# =============================================================================
# PROJECT-SPECIFIC: Model and focal species
# =============================================================================
# Model species: always labeled with gene name, never collapsed
model_species <- c("HUMAN", "MOUSE", "DROME", "CAEEL")
model_species_full <- c("Homo_sapiens", "Mus_musculus",
                        "Drosophila_melanogaster", "Caenorhabditis_elegans")

# Focal non-model species: labeled, may be collapsed but annotated on triangles
focal_species_full <- c(
  "Amphimedon_queenslandica", "Spongilla_lacustris", "Ephydatia_muelleri",
  "Tethya_wilhelma", "Halichondria_panicea", "Geodia_barretti",
  "Sycon_ciliatum", "Oscarella_lobularis", "Corticium_candelabrum",
  "Hydra_vulgaris", "Nematostella_vectensis"
)

# =============================================================================
# STYLE PARAMETERS
# =============================================================================
BRANCH_LINE_WIDTH <- 0.5   # branch/clade width in TREE_COLORS entries
LABEL_FONT_STYLE  <- "bold"
LABEL_FONT_SIZE   <- 1

# Collapsing parameters
COLLAPSE_MIN_PURITY   <- 1.0    # 1.0 = only 100% pure clades
COLLAPSE_MIN_SIZE     <- 3
COLLAPSE_MAX_FRACTION <- 0.25

# Species abbreviation: "H. sapiens" format
abbrev_species <- function(sp_name) {
  parts <- strsplit(sp_name, "_")[[1]]
  if (length(parts) >= 2) return(paste0(substr(parts[1], 1, 1), ". ", parts[2]))
  return(sp_name)
}

# =============================================================================
# CORE LOGIC (generally does not need modification)
# =============================================================================

# --- Load and root tree ---
tree <- read.tree(tree_file)
cat("Tips:", Ntip(tree), "\n")
rooted_tree <- phytools::midpoint.root(tree)

# --- Assign species and groups ---
get_group <- function(species_id) {
  if (species_id %in% names(sp_to_group)) return(sp_to_group[[species_id]])
  if (species_id %in% names(uniprot_to_species)) {
    mapped <- uniprot_to_species[species_id]
    if (mapped %in% names(sp_to_group)) return(sp_to_group[[mapped]])
  }
  return("Non-metazoan eukaryotes")
}

tip_data <- data.frame(
  id = tree$tip.label,
  species_id = sapply(tree$tip.label, parse_species_id),
  stringsAsFactors = FALSE, row.names = NULL
)
tip_data$species <- sapply(tip_data$species_id, resolve_species)
tip_data$group <- sapply(tip_data$species_id, get_group)
tip_data$color <- group_colors[tip_data$group]
tip_data$protein_id <- sapply(tip_data$id, parse_protein_id)

# --- Build display labels (no | characters, underscores for spaces) ---
# CRITICAL: ape::write.tree() silently converts spaces to underscores.
# Use underscores from the start so annotation IDs match the tree.
tip_data$display_label <- sapply(seq_len(nrow(tip_data)), function(i) {
  sp_abbr <- abbrev_species(tip_data$species[i])
  pid <- tip_data$protein_id[i]
  gsub(" ", "_", paste0(sp_abbr, "_", pid))
})

# Ensure uniqueness (append counter for duplicates)
dup_counts <- table(tip_data$display_label)
dups <- names(dup_counts[dup_counts > 1])
for (d in dups) {
  idx <- which(tip_data$display_label == d)
  for (j in seq_along(idx)) {
    tip_data$display_label[idx[j]] <- paste0(d, "_", j)
  }
}
stopifnot(length(unique(tip_data$display_label)) == nrow(tip_data))

# --- Relabel tree ---
old_to_new <- setNames(tip_data$display_label, tip_data$id)
rooted_tree$tip.label <- old_to_new[rooted_tree$tip.label]

# Group/color vectors indexed by new tip positions
new_tip_groups <- tip_data$group[match(rooted_tree$tip.label, tip_data$display_label)]
new_tip_colors <- tip_data$color[match(rooted_tree$tip.label, tip_data$display_label)]

# Write relabeled tree
tree_out <- file.path(out_dir, "GENE.tree")
write.tree(rooted_tree, tree_out)
cat("Wrote relabeled tree:", basename(tree_out), "\n")

# --- Tree traversal helpers ---
getDescendants <- function(tree, node) {
  n <- Ntip(tree)
  all_desc <- c()
  queue <- node
  while (length(queue) > 0) {
    current <- queue[1]
    queue <- queue[-1]
    children <- tree$edge[tree$edge[, 1] == current, 2]
    all_desc <- c(all_desc, children)
    queue <- c(queue, children[children > n])
  }
  return(all_desc)
}

get_tips <- function(tree, node) {
  desc <- getDescendants(tree, node)
  desc[desc <= Ntip(tree)]
}

n_tips <- Ntip(rooted_tree)

# --- Helper: get MRCA tip pair for an internal node ---
# Picks one tip from each child subtree, ensuring correct MRCA specification.
get_mrca_pair <- function(tree, node) {
  children <- tree$edge[tree$edge[, 1] == node, 2]
  get_one_tip <- function(child_node) {
    if (child_node <= Ntip(tree)) return(child_node)
    return(get_tips(tree, child_node)[1])
  }
  c(tree$tip.label[get_one_tip(children[1])],
    tree$tip.label[get_one_tip(children[2])])
}

# =============================================================================
# ANNOTATION 1: TREE_COLORS — branch coloring by taxonomy
# =============================================================================
# Colors internal branches of pure subtrees via "clade" entries and remaining
# tips via individual "branch" entries.

node_ids <- (n_tips + 1):(n_tips + Nnode(rooted_tree))

# Find maximal pure subtrees
node_purity <- list()
for (nd in node_ids) {
  nd_tips <- get_tips(rooted_tree, nd)
  nd_groups <- new_tip_groups[nd_tips]
  grp_tab <- sort(table(nd_groups), decreasing = TRUE)
  node_purity[[as.character(nd)]] <- list(
    pure = (grp_tab[1] == length(nd_tips)),
    group = names(grp_tab)[1],
    size = length(nd_tips),
    tip_ids = nd_tips
  )
}

parent_of <- setNames(rooted_tree$edge[, 1], rooted_tree$edge[, 2])

maximal_pure <- list()
for (nd_str in names(node_purity)) {
  info <- node_purity[[nd_str]]
  if (!info$pure || info$size < 2) next
  nd <- as.integer(nd_str)
  parent <- parent_of[as.character(nd)]
  parent_pure <- FALSE
  if (!is.na(parent) && as.character(parent) %in% names(node_purity)) {
    parent_pure <- node_purity[[as.character(parent)]]$pure
  }
  if (!parent_pure) {
    maximal_pure <- c(maximal_pure, list(list(
      node = nd, group = info$group, tip_ids = info$tip_ids
    )))
  }
}

cat("Maximal pure subtrees:", length(maximal_pure), "\n")

covered_tips <- integer(0)
for (mp in maximal_pure) covered_tips <- c(covered_tips, mp$tip_ids)
uncovered_tips <- setdiff(seq_len(n_tips), covered_tips)

# Write TREE_COLORS for branches
lines <- c("TREE_COLORS", "SEPARATOR TAB", "DATA")

for (mp in maximal_pure) {
  pair <- get_mrca_pair(rooted_tree, mp$node)
  color <- group_colors[mp$group]
  lines <- c(lines, paste(
    paste0(pair[1], "|", pair[2]),
    "clade", color, "normal", BRANCH_LINE_WIDTH,
    sep = "\t"
  ))
}

for (idx in uncovered_tips) {
  label <- rooted_tree$tip.label[idx]
  color <- new_tip_colors[idx]
  lines <- c(lines, paste(label, "branch", color, "normal", BRANCH_LINE_WIDTH,
                           sep = "\t"))
}

out_file <- file.path(out_dir, "GENE_branch_colors.txt")
writeLines(lines, out_file)
cat("Wrote:", basename(out_file), "(", length(lines) - 3, "entries)\n")

# =============================================================================
# ANNOTATION 2: TREE_COLORS — label coloring by taxonomy
# =============================================================================
lines <- c("TREE_COLORS", "SEPARATOR TAB", "DATA")
for (i in seq_len(n_tips)) {
  lines <- c(lines, paste(
    rooted_tree$tip.label[i], "label", new_tip_colors[i],
    LABEL_FONT_STYLE, LABEL_FONT_SIZE,
    sep = "\t"
  ))
}

out_file <- file.path(out_dir, "GENE_label_colors.txt")
writeLines(lines, out_file)
cat("Wrote:", basename(out_file), "\n")

# =============================================================================
# ANNOTATION 3: COLLAPSE — pure clades (protecting model species only)
# =============================================================================
# Only 100% pure clades are collapsed. Model species are protected (never
# collapsed). Focal species may be collapsed but are annotated on triangle
# labels showing which focal species are inside.

find_collapsible <- function(tree, tip_groups, protected_ids,
                             min_purity = COLLAPSE_MIN_PURITY,
                             min_size = COLLAPSE_MIN_SIZE,
                             max_fraction = COLLAPSE_MAX_FRACTION) {
  n_tips <- Ntip(tree)
  max_size <- floor(n_tips * max_fraction)
  node_ids <- (n_tips + 1):(n_tips + Nnode(tree))

  clade_info <- lapply(node_ids, function(nd) {
    nd_tips <- get_tips(tree, nd)
    nd_groups <- tip_groups[nd_tips]
    grp_tab <- sort(table(nd_groups), decreasing = TRUE)
    list(node = nd, size = length(nd_tips),
         dominant = names(grp_tab)[1],
         purity = grp_tab[1] / length(nd_tips),
         tip_ids = nd_tips,
         has_protected = any(nd_tips %in% protected_ids))
  })

  candidates <- Filter(function(x) {
    x$purity >= min_purity & x$size >= min_size &
    x$size <= max_size & !x$has_protected
  }, clade_info)

  candidates <- candidates[order(sapply(candidates, `[[`, "size"),
                                 decreasing = TRUE)]

  selected <- list()
  collapsed_tips <- integer(0)
  for (cand in candidates) {
    if (any(cand$tip_ids %in% collapsed_tips)) next
    selected <- c(selected, list(cand))
    collapsed_tips <- c(collapsed_tips, cand$tip_ids)
  }
  return(selected)
}

new_tip_species_id <- tip_data$species_id[match(rooted_tree$tip.label,
                                                 tip_data$display_label)]
new_tip_species <- tip_data$species[match(rooted_tree$tip.label,
                                           tip_data$display_label)]
protected_ids <- which(new_tip_species_id %in% model_species)

clades <- find_collapsible(rooted_tree, new_tip_groups, protected_ids)
cat("Collapsible clades:", length(clades), "\n")

# Write COLLAPSE file
collapse_lines <- c("COLLAPSE", "DATA")
for (cl in clades) {
  pair <- get_mrca_pair(rooted_tree, cl$node)
  collapse_lines <- c(collapse_lines, paste0(pair[1], "|", pair[2]))
}

out_file <- file.path(out_dir, "GENE_collapse.txt")
writeLines(collapse_lines, out_file)
cat("Wrote:", basename(out_file), "\n")

# =============================================================================
# ANNOTATION 4: LABELS — collapsed clade labels with focal species
# =============================================================================
# Each collapsed clade gets: "N Group" or "N Group (FocalGenus1, FocalGenus2)"
label_lines <- c("LABELS", "SEPARATOR TAB", "DATA")
for (cl in clades) {
  pair <- get_mrca_pair(rooted_tree, cl$node)
  mrca_id <- paste0(pair[1], "|", pair[2])
  sp_in_clade <- unique(new_tip_species[cl$tip_ids])
  focal_in_clade <- sp_in_clade[sp_in_clade %in% focal_species_full]
  # Abbreviate focal species to genus name only
  abbrev_focal <- sapply(focal_in_clade, function(sp) {
    parts <- strsplit(sp, "_")[[1]]
    if (length(parts) >= 2) parts[1] else sp
  })
  label_text <- paste0(cl$size, " ", cl$dominant)
  if (length(abbrev_focal) > 0) {
    label_text <- paste0(label_text, " (", paste(abbrev_focal, collapse = ", "), ")")
  }
  label_lines <- c(label_lines, paste(mrca_id, label_text, sep = "\t"))
}

out_file <- file.path(out_dir, "GENE_collapse_labels.txt")
writeLines(label_lines, out_file)
cat("Wrote:", basename(out_file), "\n")

# =============================================================================
# SUMMARY
# =============================================================================
cat("\nAll annotation files:\n")
files <- list.files(out_dir, pattern = "\\.(txt|tree)$")
for (f in files) {
  size <- file.info(file.path(out_dir, f))$size
  cat(sprintf("  %-40s %6.1f KB\n", f, size / 1024))
}
cat("\nDone. Upload with the companion upload_export.py script.\n")
