#!/bin/bash
# Hook: Enforce .qmd as the default for numbered analysis scripts in scripts/.
# Cluster (path /nfs/roberts/ exists): auto-skip — .py is the cluster default.
# Local: block numbered .py/.R/.Rmd in scripts/ unless content has "# allow-py: <reason>".
# Allows: scripts/scratch/*, scripts/old/*, scripts/exploratory/*, R/*, python/*
# Reads tool_input from stdin JSON (PreToolUse:Write|Edit format).

# Auto-skip on cluster (Bouchet): .py is the default there
if [[ -d /nfs/roberts ]]; then
    exit 0
fi

python3 -c '
import json, os, re, sys

data = json.load(sys.stdin)
ti = data.get("tool_input", {})
file_path = ti.get("file_path") or ti.get("filePath") or ""
tool_name = data.get("tool_name", "")

if not file_path:
    sys.exit(0)

filename = os.path.basename(file_path)
dirname = os.path.basename(os.path.dirname(file_path))

# Only files directly in scripts/ (not subdirs like scratch/, old/, exploratory/)
if dirname != "scripts":
    sys.exit(0)

# Only numbered scripts (01_, 15a_, etc.)
if not re.match(r"^[0-9]+[a-z]?_", filename):
    sys.exit(0)

# .qmd is always allowed
if filename.endswith(".qmd"):
    sys.exit(0)

# Numbered non-.qmd: check for "# allow-py: <reason>" marker in first 20 lines
# - Write: marker must be in the new content
# - Edit/MultiEdit: marker must be in the existing file on disk
if tool_name == "Write":
    content = ti.get("content", "")
elif os.path.isfile(file_path):
    try:
        with open(file_path) as f:
            content = f.read()
    except OSError:
        content = ""
else:
    content = ""

head = "\n".join(content.splitlines()[:20])
if re.search(r"^\s*#\s*allow-py\s*:", head, flags=re.MULTILINE | re.IGNORECASE):
    sys.exit(0)

reason = (
    f"BLOCKED: Numbered scripts in scripts/ should be .qmd on local "
    f"(got: {filename}). To use .py here, ask the user first, then add a "
    "comment in the first 20 lines: # allow-py: <one-line reason>. "
    "Alternatives: scripts/scratch/ for iteration, R/python/ for helpers, "
    "scripts/old/ for archiving."
)
print(json.dumps({"decision": "block", "reason": reason}))
sys.exit(0)
'