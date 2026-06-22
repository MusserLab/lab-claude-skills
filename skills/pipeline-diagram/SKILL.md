---
name: pipeline-diagram
description: >
  Generate a publication-style processing-pipeline diagram from a small YAML spec:
  a flowing-backbone OVERVIEW (steps down a backbone, inputs branching in from the
  left, key decisions as blue annotations, output files branching right) plus an
  optional PER-STEP DETAIL view (one card per step showing input files -> key
  params/decisions -> output files). Use when the user wants to diagram, visualize,
  map, or document an analysis/processing pipeline or multi-script workflow; create
  a pipeline figure / schematic / flow diagram; or show/communicate the steps, key
  decisions, and input/output files of a pipeline. Spec-driven by design (you write
  a short YAML, not auto-parsed from code). Do NOT load for the analysis RESULT
  figures themselves (networks, heatmaps, trees), for generic flowcharts unrelated
  to a data pipeline, or for Quarto/script scaffolding (use script-organization).
user-invocable: false
---

# Pipeline diagram

Render a clean pipeline diagram in a flowing-backbone style (inputs branch in from
the left, steps run down a tan backbone with the key decision of each step as a blue
annotation, outputs branch out to the right with their file names). Spec-driven: you
describe the pipeline in a short YAML file and a generic renderer draws it.

## When to use

- The user wants to **see / communicate how a pipeline works** — its steps, the key
  decisions made at each step, and which files go in and out.
- After building a multi-script analysis, to produce an overview figure (and per-step
  detail) for a talk, methods section, lab onboarding, or your own understanding.

Do **not** use for the result figures (networks/heatmaps/trees), or for plain
flowcharts with no data-pipeline structure.

## Workflow

1. **Copy the spec template** into the project (e.g. into `scripts/<area>/` or `outs/`):
   `templates/pipeline_spec.example.yaml` → `pipeline.yaml`.
2. **Fill in the steps** (top → bottom = execution order). Per step, set `title` and the
   key decision (`decision`); add `inputs`/`outputs` for the overview and
   `script`/`files_in`/`files_out`/`params` for the detail cards. Build the spec by
   reading the project's numbered scripts: their input block (top of file), their
   `outs/XX_*/` outputs, and the genuine decisions they encode (thresholds, joins,
   filters, what's assumed). **Surface the real decisions** — that's the point of the
   blue annotations, not a restating of the title.
3. **Render** (needs `matplotlib` + `pyyaml` — use the project conda env):
   ```bash
   python templates/render_pipeline.py pipeline.yaml outs/<area>/pipeline_overview --detail
   ```
   Writes `<prefix>.png/.pdf` (overview) and, with `--detail`, `<prefix>_detail.png/.pdf`.
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
- A worked example is `templates/pipeline_spec.example.yaml` (the synapse-PPI pipeline).

## Files

- `templates/render_pipeline.py` — generic renderer (`overview` + optional `detail`).
- `templates/pipeline_spec.example.yaml` — annotated example spec + schema.
