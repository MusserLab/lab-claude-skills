---
name: pipeline-diagram
description: >
  Generate a publication-style processing-pipeline diagram from a small YAML spec:
  a flowing-backbone OVERVIEW (steps down a backbone, inputs branching in from the
  left, key decisions as blue annotations, output files branching right) plus an
  optional PER-STEP DETAIL view (one card per step showing input files, key
  parameters and decisions, and output files). Use when the user wants to diagram, visualize,
  map, or document an analysis/processing pipeline or multi-script workflow; create
  a pipeline figure / schematic / flow diagram; or show/communicate the steps, key
  decisions, and input/output files of a pipeline. Spec-driven by design (you write
  a short YAML, not auto-parsed from code). Do NOT load for the analysis RESULT
  figures themselves (networks, heatmaps, trees), for generic flowcharts unrelated
  to a data pipeline, or for Quarto/script scaffolding (use script-organization).
---

# Pipeline diagram

Render a clean pipeline diagram in a flowing-backbone style: inputs branch in from
the left, steps run down the center with key decisions annotated, and outputs branch right.
The built-in theme is a neutral public default. Use a project or optional private style
resource only when the researcher or project explicitly selects it.

## When to use

- The user wants to **see / communicate how a pipeline works** — its steps, the key
  decisions made at each step, and which files go in and out.
- After building a multi-script analysis, to produce an overview figure (and per-step
  detail) for a talk, methods section, lab onboarding, or your own understanding.

Do **not** use for the result figures (networks/heatmaps/trees), or for plain
flowcharts with no data-pipeline structure.

## Workflow

1. **Resolve the installed resources, then copy the spec template.** Take the absolute skill
   directory from the loaded `pipeline-diagram/SKILL.md`; do not assume its `templates/` directory
   exists inside the current project. Confirm both bundled files before continuing:
   ```bash
   PIPELINE_SKILL_DIR="<absolute directory containing this SKILL.md>"
   test -f "$PIPELINE_SKILL_DIR/templates/pipeline_spec.example.yaml"
   test -f "$PIPELINE_SKILL_DIR/templates/render_pipeline.py"
   cp "$PIPELINE_SKILL_DIR/templates/pipeline_spec.example.yaml" scripts/<area>/pipeline.yaml
   ```
   If either check fails, stop and report the missing installed resource rather than guessing a
   project-local path.
2. **Fill in the steps** (top → bottom = execution order). Per step, set `title` and the
   key decision (`decision`); add `inputs`/`outputs` for the overview and
   `script`/`files_in`/`files_out`/`params` for the detail cards. Build the spec by
   reading the project's numbered scripts: their input block (top of file), their
   `outs/XX_*/` outputs, and the genuine decisions they encode (thresholds, joins,
   filters, what's assumed). **Surface the real decisions** — that's the point of the
   blue annotations, not a restating of the title.
3. **Render** (needs `matplotlib` + `pyyaml` — use the project conda env):
   ```bash
   python "$PIPELINE_SKILL_DIR/templates/render_pipeline.py" \
     scripts/<area>/pipeline.yaml outs/<area>/pipeline_overview --detail
   ```
   Writes `<prefix>.png/.pdf/.svg` (overview) and, with `--detail`,
   `<prefix>_detail.png/.pdf/.svg`. The overview canvas is 14 inches wide and at least 7 inches
   high (height grows with step count); detail is 13 inches wide with 2.2 inches per step plus
   one inch. PNG is 300 DPI; PDF and SVG retain vector geometry.
4. **Look at the PNG and iterate.** Layout is auto-computed (steps evenly spaced;
   inputs/outputs greedily spread to avoid label collisions; connectors fan by
   distance). If two labels still touch, nudge a step's input order or split a long step.

## Spec schema (per step)

| field | used by | meaning |
|---|---|---|
| `title` | both | step name (bold) — required |
| `decision` | overview | the KEY decision/assumption (blue italic). Use `\n` to wrap. |
| `inputs` | overview | list of `{label, kind: required\|optional}` (left nodes) |
| `outputs` | overview | list of `{label, file, terminal}` (right nodes; `file` shown in monospace; `terminal: true` = purple end node) |
| `script` | detail | script filename (card header) |
| `files_in` / `files_out` | detail | exact file paths/names (basenames read best) |
| `params` | detail | key params / decisions as short bullets |

Top-level: `title`, `subtitle`, optional `theme:` (override any palette colour, e.g.
`theme: {line: '#888', blue: '#2a6'}`).

## Tips / gotchas

- **Spec-driven, not inferred.** Writing the spec forces you to state the real I/O and
  decisions; auto-parsing scripts is brittle. Draft from the scripts, then refine.
- **Keep `decision` text to the genuine choice** (threshold, what's excluded, what's
  assumed) — e.g. "trust an edge only if recovered in human", not "score the edges".
- **Long file paths** in `files_in` read best as basenames; the detail card puts files
  and decisions on separate rows, but very long names still crowd — shorten them.
- **Node types** in the legend appear only if present (required/optional inputs, terminal).
- A generic worked example is `templates/pipeline_spec.example.yaml`; replace every illustrative value with the project's actual inputs, decisions, and outputs.

## Files

- `templates/render_pipeline.py` — generic renderer (`overview` + optional `detail`).
- `templates/pipeline_spec.example.yaml` — annotated example spec + schema.
