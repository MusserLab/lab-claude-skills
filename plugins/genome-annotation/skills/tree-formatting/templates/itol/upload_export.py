#!/usr/bin/env python3
"""
TEMPLATE: iTOL Upload & Export

Uploads a relabeled Newick tree + annotation files to iTOL, then exports
rendered images in multiple layout/format combinations.

Two uploads are made:
  1. Uncollapsed — tree + branch colors + label colors (no collapse files)
  2. Collapsed — tree + all annotations including collapse + collapse labels

Requirements:
  pip install itolapi

Environment variables:
  ITOL_API_KEY    — API key from iTOL > My Account > API access
  ITOL_PROJECT    — account project name on iTOL (default: "misc")

Destination choice:
  Account upload uses ITOL_API_KEY and ITOL_PROJECT.
  --anonymous explicitly selects anonymous upload and ignores both environment values.
  Without a key or --anonymous, the destination is unselected and upload is refused.

USAGE: Copy into your project and adapt the paths and TREE_NAME.
Run without arguments to preview files/destination. Verify sharing settings and
obtain approval before running with --upload; add --anonymous for an approved
anonymous destination. Preview alone authorizes no upload. Visibility and retention
are not verified by this script.
"""

import argparse
import os
from pathlib import Path

# =============================================================================
# PROJECT-SPECIFIC: Paths and naming
# =============================================================================
# Input: annotation directory from the R annotation script
ANNOTATION_DIR = Path("outs/phylogenetics/XX_itol_annotations")
OUT_DIR = Path("outs/phylogenetics/XX_itol_upload_export")

TREE_FILE = ANNOTATION_DIR / "GENE.tree"
TREE_NAME = "GENE_NNNtips"  # Name shown in iTOL interface

# =============================================================================
# CONFIGURATION
# =============================================================================
ITOL_API_KEY = os.environ.get("ITOL_API_KEY", "")
ITOL_PROJECT = os.environ.get("ITOL_PROJECT", "misc")

# =============================================================================
# CORE LOGIC
# =============================================================================

# Discover annotation files
annotation_files = sorted(ANNOTATION_DIR.glob("GENE_*.txt"))
assert TREE_FILE.exists(), f"Tree not found: {TREE_FILE}"

print(f"Tree: {TREE_FILE.resolve()} ({TREE_FILE.stat().st_size / 1024:.1f} KB)")
print(f"Annotations ({len(annotation_files)}):")
for f in annotation_files:
    print(f"  {f.resolve()} ({f.stat().st_size / 1024:.1f} KB)")

# Split into shared vs collapse-specific
collapse_keywords = ["collapse"]
shared_files = [f for f in annotation_files
                if not any(k in f.stem for k in collapse_keywords)]
collapse_files = [f for f in annotation_files
                  if any(k in f.stem for k in collapse_keywords)]


def upload_tree(tree_file, annotation_files, tree_name):
    """Upload tree + annotations to iTOL. Returns (uploader, tree_id) or None."""
    uploader = Itol()
    uploader.add_file(tree_file)
    for f in annotation_files:
        uploader.add_file(f)
    uploader.params['treeName'] = tree_name
    if account_upload:
        uploader.params['APIkey'] = ITOL_API_KEY
        uploader.params['projectName'] = ITOL_PROJECT

    print(f"\nUploading '{tree_name}' with {len(annotation_files)} annotations...")
    tree_id = uploader.upload()

    if tree_id:
        print(f"  Tree ID: {tree_id}")
        print(f"  URL: {uploader.get_webpage()}")
    else:
        print(f"  FAILED: {uploader.comm.upload_output}")

    if uploader.comm.warnings:
        for w in uploader.comm.warnings:
            print(f"  Warning: {w}")

    return (uploader, tree_id) if tree_id else None


parser = argparse.ArgumentParser(description="Preview or upload the reviewed iTOL files")
parser.add_argument("--upload", action="store_true",
                    help="Upload only after approval of the preview and destination visibility")
parser.add_argument("--anonymous", action="store_true",
                    help="Explicitly choose anonymous upload, ignoring account key and project")
args = parser.parse_args()
account_upload = bool(ITOL_API_KEY) and not args.anonymous
if args.anonymous:
    print("\nDestination: anonymous iTOL upload (explicit choice; account key/project ignored)")
elif account_upload:
    print(f"\nDestination: iTOL account project {ITOL_PROJECT!r}")
else:
    print("\nDestination: unselected; set ITOL_API_KEY or explicitly choose --anonymous")
print(f"Tree names: {TREE_NAME}_uncollapsed, {TREE_NAME}_collapsed")
print("Uncollapsed annotations:", ", ".join(str(f.resolve()) for f in shared_files))
print("Collapsed annotations:", ", ".join(str(f.resolve()) for f in shared_files + collapse_files))
print("Verify destination visibility/sharing and retention before approving these uploads.")
print("This script has not verified those service settings.")
if not args.upload:
    upload_flags = "--anonymous --upload" if args.anonymous else "--upload"
    print(f"Preview only. After approval, rerun with {upload_flags}.")
    raise SystemExit(0)
if not account_upload and not args.anonymous:
    raise SystemExit("Choose an iTOL destination: set ITOL_API_KEY or explicitly use --anonymous")
if OUT_DIR.exists() and any(OUT_DIR.iterdir()):
    raise SystemExit("Export destination is not empty; preserve it or use a fresh OUT_DIR")
from itolapi import Itol
OUT_DIR.mkdir(parents=True, exist_ok=True)

# --- Upload 1: Uncollapsed ---
result1 = upload_tree(TREE_FILE, shared_files, f"{TREE_NAME}_uncollapsed")

# --- Upload 2: Collapsed ---
result2 = upload_tree(TREE_FILE, shared_files + collapse_files,
                      f"{TREE_NAME}_collapsed")

# =============================================================================
# EXPORT
# =============================================================================
# display_mode: 1=rectangular, 2=circular, 3=unrooted
export_configs = [
    ("circular",    "pdf", "2"),
    ("circular",    "svg", "2"),
    ("circular",    "png", "2"),
    ("rectangular", "pdf", "1"),
    ("rectangular", "svg", "1"),
    ("unrooted",    "pdf", "3"),
]

tree_uploads = []
if result1:
    tree_uploads.append(("uncollapsed", result1[0], result1[1]))
if result2:
    tree_uploads.append(("collapsed", result2[0], result2[1]))

for tree_label, uploader, tid in tree_uploads:
    print(f"\n--- Exporting {tree_label} tree ---")
    for suffix, fmt, mode in export_configs:
        exporter = uploader.get_itol_export()
        exporter.set_export_param_value('format', fmt)
        exporter.set_export_param_value('display_mode', mode)

        out_file = OUT_DIR / f"GENE_{tree_label}_{suffix}.{fmt}"

        try:
            exporter.export(out_file)
            size_kb = out_file.stat().st_size / 1024
            print(f"  {out_file.name} ({size_kb:.0f} KB)")
        except Exception as e:
            print(f"  FAILED: {out_file.name} -- {e}")

# =============================================================================
# SUMMARY
# =============================================================================
print("\n" + "=" * 60)
print("iTOL Upload Summary")
print("=" * 60)
for tree_label, uploader, tid in tree_uploads:
    print(f"\n{tree_label.upper()}:")
    print(f"  Tree ID:  {tid}")
    print(f"  Web URL:  {uploader.get_webpage()}")

if tree_uploads:
    print(f"\nExports: {OUT_DIR}")
    print("\nOpen the web URLs to explore the trees interactively on iTOL.")
    print("Tip: toggle 'Align labels' in Controls > Other > Label options.")
else:
    print("No successful uploads.")
