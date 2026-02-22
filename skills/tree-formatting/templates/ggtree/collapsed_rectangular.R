#!/usr/bin/env Rscript
# =============================================================================
# TEMPLATE: Collapsed Rectangular Tree (Phylogram and/or Cladogram)
# =============================================================================
# Large trees (250+ tips) with:
#   - Pure-clade collapsing (colored triangles)
#   - Branch coloring by taxonomy
#   - Selective tip labeling (model + focal species only)
#   - Protected tips: model and focal species are never collapsed
#
# Produces phylogram (branch lengths) and/or cladogram (topology only).
#
# USAGE: Copy this template into your project's scripts/ directory,
#        then adapt the sections marked PROJECT-SPECIFIC.
# =============================================================================

library(ape)
library(ggtree)
library(treeio)
library(ggplot2)
library(tidytree)
library(phytools)  # for midpoint.root()

# =============================================================================
# PROJECT-SPECIFIC: Paths
# =============================================================================
tree_file <- "data/phylogenetics/GENE/ALIGNMENT.treefile"
out_dir   <- "outs/phylogenetics/XX_tree_name"
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# PROJECT-SPECIFIC: Tip label parsing
# =============================================================================
# These functions MUST be adapted to match the actual label formats in each tree.
# Inspect tip labels first: head(tree$tip.label, 20)
#
# parse_species_id(label) -> species identifier (full name or UniProt suffix)
# parse_accession(label)  -> protein/transcript accession
# resolve_gene_name(label, species_id) -> gene name for model species, ID for others
#
# Common label formats:
#   sp|O95631|NET1_HUMAN           -> species: HUMAN,  gene: NET1
#   tr|Q23158|Q23158_CAEEL         -> species: CAEEL,  accession: Q23158
#   Mus_musculus|10090.Q9R1A3      -> species: Mus_musculus, accession: Q9R1A3
#   Hydra_vulgaris|8692.t25743aep  -> species: Hydra_vulgaris, accession: t25743aep
#
# Key rules:
#   - Model species: resolve to gene names (from sp| labels or UniProt API lookup)
#   - Non-model species: use actual protein/transcript IDs only
#   - NEVER infer gene names from BLAST annotations for non-model species

parse_species_id <- function(label) {
  # UniProt: sp|acc|NAME_SPECIES or tr|acc|NAME_SPECIES
  if (grepl("^(sp|tr)\\|", label)) {
    parts <- strsplit(label, "\\|")[[1]]
    if (length(parts) >= 3) return(sub(".*_", "", parts[3]))
  }
  # Pipe-separated: Species_name|...
  if (grepl("\\|", label)) return(strsplit(label, "\\|")[[1]][1])
  return(label)
}

parse_accession <- function(label) {
  if (grepl("^(sp|tr)\\|", label)) return(strsplit(label, "\\|")[[1]][2])
  if (grepl("\\|", label)) {
    after_pipe <- strsplit(label, "\\|")[[1]][2]
    return(sub("^[0-9]+\\.", "", after_pipe))
  }
  return(NA_character_)
}

# Optional: gene name from Swiss-Prot labels
parse_gene_name_sp <- function(label) {
  if (grepl("^sp\\|", label)) {
    parts <- strsplit(label, "\\|")[[1]]
    if (length(parts) >= 3) return(sub("_[^_]+$", "", parts[3]))
  }
  return(NA_character_)
}

# Optional: load UniProt accession -> gene name mapping for non-sp| model species
# Generate by querying: https://rest.uniprot.org/uniprotkb/search?query=(accession:A1 OR ...)&fields=accession,gene_primary&format=tsv
gene_map_file <- file.path(out_dir, "accession_gene_map.tsv")
if (file.exists(gene_map_file)) {
  gene_map <- read.delim(gene_map_file, stringsAsFactors = FALSE)
  acc_to_gene <- setNames(gene_map$gene_name, gene_map$accession)
} else {
  acc_to_gene <- character(0)
}

resolve_gene_name <- function(label, species_id) {
  # 1. Swiss-Prot gene name
  sp_gene <- parse_gene_name_sp(label)
  if (!is.na(sp_gene)) return(sp_gene)
  # 2. UniProt mapping
  acc <- parse_accession(label)
  if (!is.na(acc) && acc %in% names(acc_to_gene)) {
    gene <- acc_to_gene[acc]
    if (!is.na(gene) && nchar(gene) > 0) return(gene)
  }
  # 3. Fallback: accession itself
  if (!is.na(acc)) return(acc)
  return(NA_character_)
}

# =============================================================================
# PROJECT-SPECIFIC: Taxonomy mapping
# =============================================================================
# Map species names to taxonomic groups. Add/remove species as needed.
taxonomy <- list(
  "Demosponges" = c(
    "Amphimedon_queenslandica", "Spongilla_lacustris", "Ephydatia_muelleri",
    "Tethya_wilhelma", "Halichondria_panicea", "Geodia_barretti"
  ),
  "Calcarea/Homoscl." = c(
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

# =============================================================================
# PROJECT-SPECIFIC: Model and focal species
# =============================================================================
# Model species: always labeled with gene name + species abbreviation
model_species <- c("HUMAN", "MOUSE", "DROME", "CAEEL")  # UniProt suffixes
model_species_full <- c("Homo_sapiens", "Mus_musculus",
                        "Drosophila_melanogaster", "Caenorhabditis_elegans")

# Focal non-model species: labeled with protein/gene ID + species abbreviation.
# Protected from collapsing. UPDATE THIS PER TREE.
# Typically: sponges + species with single-cell data.
focal_species_full <- c(
  "Amphimedon_queenslandica", "Spongilla_lacustris", "Ephydatia_muelleri",
  "Tethya_wilhelma", "Halichondria_panicea", "Geodia_barretti",
  "Sycon_ciliatum", "Oscarella_lobularis", "Corticium_candelabrum",
  "Hydra_vulgaris", "Nematostella_vectensis"
)

# =============================================================================
# STYLE PARAMETERS (tuned values — modify with care)
# =============================================================================
# Group colors
group_colors <- c(
  "Demosponges"       = "#2ca02c",
  "Calcarea/Homoscl." = "#98df8a",
  "Ctenophora"        = "#9467bd",
  "Cnidaria + Placozoa" = "#ff7f0e",
  "Deuterostomia"     = "#d62728",
  "Protostomia"       = "#1f77b4",
  "Non-metazoan euk." = "#555555",
  "Mixed"             = "#999999"
)

# Branch and triangle styling
BRANCH_LINE_WIDTH  <- 0.15    # branch thickness (also used for triangle outlines)
TRIANGLE_ALPHA     <- 0.4     # triangle fill transparency
TRIANGLE_MODE      <- "max"   # "max" = rectangular triangles

# Label styling
LABEL_SIZE_PHYLO   <- 1.0     # geom_text size for phylogram
LABEL_SIZE_CLADO   <- 0.8     # geom_text size for cladogram
LABEL_OFFSET_FRAC  <- 0.005   # label gap as fraction of x-axis range

# Label format: "G. species GENE_OR_ID"
# Species abbreviation: first initial + full epithet (e.g., "H. sapiens")
abbrev_species <- function(sp_name) {
  parts <- strsplit(sp_name, "_")[[1]]
  if (length(parts) >= 2) return(paste0(substr(parts[1], 1, 1), ". ", parts[2]))
  return(sp_name)
}

# Page dimensions (tuned for ~1000 visible elements)
PAGE_WIDTH_PHYLO   <- 14      # inches
PAGE_WIDTH_CLADO   <- 10      # inches
PAGE_HEIGHT        <- 36      # inches — scale ~0.04" per visible element
PLOT_MARGIN_RIGHT  <- 150     # points — room for labels extending past plot

# Collapsing parameters
COLLAPSE_MIN_PURITY   <- 0.90   # minimum taxonomic purity to collapse
COLLAPSE_MIN_SIZE     <- 3      # minimum tips in a collapsible clade
COLLAPSE_MAX_FRACTION <- 0.25   # max fraction of total tips in one collapsed clade

# Branch length capping (phylogram only)
BRANCH_CAP_PERCENTILE <- 0.90   # cap outlier branches at this percentile

# Legend styling
LEGEND_TEXT_SIZE    <- 8
LEGEND_TITLE_SIZE  <- 9
LEGEND_LINE_WIDTH  <- 2       # override for color swatches in legend

# =============================================================================
# CORE LOGIC (generally does not need modification)
# =============================================================================

# --- Load and root tree ---
tree <- read.tree(tree_file)
cat("Tips:", Ntip(tree), "\n")
tree <- phytools::midpoint.root(tree)

# --- Build species -> group lookup ---
sp_to_group <- list()
for (group in names(taxonomy)) {
  for (sp in taxonomy[[group]]) sp_to_group[[sp]] <- group
}

get_group <- function(species_id) {
  if (species_id %in% names(sp_to_group)) return(sp_to_group[[species_id]])
  if (species_id %in% names(uniprot_to_species)) {
    mapped <- uniprot_to_species[species_id]
    if (mapped %in% names(sp_to_group)) return(sp_to_group[[mapped]])
  }
  return("Non-metazoan euk.")
}

resolve_species <- function(species_id) {
  if (species_id %in% names(uniprot_to_species)) return(uniprot_to_species[species_id])
  return(species_id)
}

# --- Assign data to all tips ---
tip_species_id  <- sapply(tree$tip.label, parse_species_id)
tip_groups      <- sapply(tip_species_id, get_group)
tip_genes       <- mapply(resolve_gene_name, tree$tip.label, tip_species_id)
tip_species_full <- sapply(tip_species_id, resolve_species)

tip_data <- data.frame(
  label = tree$tip.label,
  species_id = tip_species_id,
  species_full = tip_species_full,
  group = tip_groups,
  gene = tip_genes,
  stringsAsFactors = FALSE,
  row.names = NULL
)

cat("\nGroup counts:\n")
print(table(tip_data$group))

# --- Identify protected tips ---
all_focal_full <- c(model_species_full, focal_species_full)
protected_tip_ids <- which(
  tip_data$species_id %in% model_species |
  tip_data$species_full %in% all_focal_full
)
cat("Protected tips:", length(protected_tip_ids), "\n")

# --- Tree traversal helpers ---
get_tips <- function(tree, node) {
  desc <- getDescendants(tree, node)
  desc[desc <= Ntip(tree)]
}

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

# --- Find collapsible pure clades ---
find_collapsible <- function(tree, tip_data,
                             min_purity = COLLAPSE_MIN_PURITY,
                             min_size = COLLAPSE_MIN_SIZE,
                             max_fraction = COLLAPSE_MAX_FRACTION) {
  n_tips <- Ntip(tree)
  max_size <- floor(n_tips * max_fraction)
  node_ids <- (n_tips + 1):(n_tips + Nnode(tree))

  clade_info <- lapply(node_ids, function(nd) {
    nd_tips <- get_tips(tree, nd)
    nd_groups <- tip_data$group[nd_tips]
    grp_tab <- sort(table(nd_groups), decreasing = TRUE)
    list(node = nd, size = length(nd_tips),
         dominant = names(grp_tab)[1],
         purity = grp_tab[1] / length(nd_tips),
         tip_ids = nd_tips)
  })

  candidates <- Filter(function(x) {
    x$purity >= min_purity & x$size >= min_size & x$size <= max_size
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

clades_to_collapse <- find_collapsible(tree, tip_data)
cat("Collapsing", length(clades_to_collapse), "pure clades\n")

collapsed_tip_ids <- unlist(lapply(clades_to_collapse, function(cl) cl$tip_ids))
visible_tip_ids <- setdiff(seq_len(Ntip(tree)), collapsed_tip_ids)

# --- Format display labels ---
# Label format: "G. species GENE_OR_ID"
tip_data$display_label <- NA_character_
tip_data$is_model <- FALSE

for (idx in visible_tip_ids) {
  row <- which(tip_data$label == tree$tip.label[idx])
  if (length(row) == 0) next

  sp_id  <- tip_data$species_id[row]
  sp_full <- tip_data$species_full[row]
  sp_abbr <- abbrev_species(sp_full)
  is_model <- sp_id %in% model_species | sp_full %in% model_species_full
  is_focal <- sp_full %in% focal_species_full

  if (is_model || is_focal) {
    gene <- tip_data$gene[row]
    if (!is.na(gene) && nchar(gene) > 0) {
      tip_data$display_label[row] <- paste0(sp_abbr, " ", gene)
    } else {
      tip_data$display_label[row] <- sp_abbr
    }
    tip_data$is_model[row] <- TRUE
  }
}

# --- Cap branch lengths (phylogram only — applied to tree object) ---
cap <- quantile(tree$edge.length, BRANCH_CAP_PERCENTILE, na.rm = TRUE)
tree$edge.length[tree$edge.length > cap] <- cap

# --- Assign group to all nodes for branch coloring ---
n_tips <- Ntip(tree)
node_group <- rep(NA_character_, n_tips + Nnode(tree))

for (i in seq_len(nrow(tip_data))) {
  tip_idx <- match(tip_data$label[i], tree$tip.label)
  if (!is.na(tip_idx)) node_group[tip_idx] <- tip_data$group[i]
}

for (nd in (n_tips + 1):(n_tips + Nnode(tree))) {
  nd_tips <- get_tips(tree, nd)
  nd_groups <- node_group[nd_tips]
  nd_groups <- nd_groups[!is.na(nd_groups)]
  if (length(nd_groups) > 0) {
    grp_tab <- sort(table(nd_groups), decreasing = TRUE)
    if (grp_tab[1] / sum(grp_tab) > 0.5) {
      node_group[nd] <- names(grp_tab)[1]
    } else {
      node_group[nd] <- "Mixed"
    }
  }
}

# =============================================================================
# BUILD PLOT
# =============================================================================
build_tree_plot <- function(tree, tip_data, node_group, clades_to_collapse,
                            use_branch_lengths = TRUE,
                            line_width = BRANCH_LINE_WIDTH,
                            label_size = LABEL_SIZE_PHYLO) {

  # ggtree cannot accept branch.length = NULL — must use if/else
  if (use_branch_lengths) {
    p <- ggtree(tree, layout = "rectangular",
                size = line_width, aes(color = group)) %<+% tip_data
  } else {
    p <- ggtree(tree, layout = "rectangular", branch.length = "none",
                size = line_width, aes(color = group)) %<+% tip_data
  }

  # Inject node group assignments
  p$data$group <- node_group[p$data$node]
  p$data$group[is.na(p$data$group)] <- "Mixed"

  # --- CRITICAL: Pre-compute label positions BEFORE collapse ---
  # collapse() modifies p$data coordinates, so we must capture them first.
  # Use match() on node column — do NOT assume p$data rows are ordered by node ID.
  pre_data <- p$data

  visible_rows <- tip_data[!is.na(tip_data$display_label), ]
  if (nrow(visible_rows) > 0) {
    tip_node_ids <- match(visible_rows$label, tree$tip.label)
    data_row_idx <- match(tip_node_ids, pre_data$node)
    tip_label_df <- data.frame(
      x = pre_data$x[data_row_idx],
      y = pre_data$y[data_row_idx],
      tip_label = visible_rows$display_label,
      group = visible_rows$group,
      stringsAsFactors = FALSE
    )
  } else {
    tip_label_df <- data.frame(x = numeric(0), y = numeric(0),
                               tip_label = character(0),
                               group = character(0))
  }

  x_range <- diff(range(pre_data$x, na.rm = TRUE))
  label_offset <- x_range * LABEL_OFFSET_FRAC

  # --- Apply collapse (colored triangles) ---
  for (cl in clades_to_collapse) {
    color <- group_colors[cl$dominant]
    if (is.na(color)) color <- "#555555"
    p <- p |> collapse(node = cl$node, mode = TRIANGLE_MODE,
                       fill = color, alpha = TRIANGLE_ALPHA, color = color,
                       linewidth = line_width)
  }

  # --- Add tip labels ---
  # show.legend = FALSE prevents "a" character artifacts in the color legend
  if (nrow(tip_label_df) > 0) {
    p <- p +
      geom_text(data = tip_label_df,
                aes(x = x + label_offset, y = y, label = tip_label,
                    color = group),
                hjust = 0, size = label_size,
                show.legend = FALSE,
                inherit.aes = FALSE)
  }

  # --- Theme and legend ---
  p <- p +
    scale_color_manual(
      values = group_colors,
      na.value = "#999999",
      name = "Taxonomic Group"
    ) +
    coord_cartesian(clip = "off") +
    theme_tree() +
    theme(
      plot.margin = margin(5, PLOT_MARGIN_RIGHT, 5, 5),
      legend.position = "bottom",
      legend.text = element_text(size = LEGEND_TEXT_SIZE),
      legend.title = element_text(size = LEGEND_TITLE_SIZE, face = "bold")
    ) +
    guides(color = guide_legend(override.aes = list(linewidth = LEGEND_LINE_WIDTH)))

  return(p)
}

# =============================================================================
# RENDER
# =============================================================================

# --- Phylogram ---
cat("\nBuilding phylogram...\n")
p_phylo <- build_tree_plot(tree, tip_data, node_group, clades_to_collapse,
                           use_branch_lengths = TRUE,
                           line_width = BRANCH_LINE_WIDTH,
                           label_size = LABEL_SIZE_PHYLO)
out_phylo <- file.path(out_dir, "GENE_ggtree_rect.pdf")
ggsave(out_phylo, p_phylo, width = PAGE_WIDTH_PHYLO,
       height = PAGE_HEIGHT, units = "in")
cat("Saved:", out_phylo, "\n")

# --- Cladogram ---
cat("Building cladogram...\n")
p_clado <- build_tree_plot(tree, tip_data, node_group, clades_to_collapse,
                           use_branch_lengths = FALSE,
                           line_width = BRANCH_LINE_WIDTH,
                           label_size = LABEL_SIZE_CLADO)
out_clado <- file.path(out_dir, "GENE_ggtree_cladogram.pdf")
ggsave(out_clado, p_clado, width = PAGE_WIDTH_CLADO,
       height = PAGE_HEIGHT, units = "in")
cat("Saved:", out_clado, "\n")

cat("\nDone.\n")
