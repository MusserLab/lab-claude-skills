# Independent scientific-code review brief

Use this as a starting brief when a fresh perspective is useful. Replace the placeholders and
include only the authority and files needed for the bounded review.

You are independently reviewing `{{TARGET}}` in `{{PROJECT_ROOT}}`.

Read the project instructions and the named active scientific/data authority first:
`{{AUTHORITIES}}`. The scientific question and intended retained result are `{{PURPOSE}}`.
The review boundary is `{{SCOPE}}`; do not expand beyond it without identifying the concrete
dependency or risk. Do not edit files, run expensive producers, replace outputs, install software,
launch jobs, or make external writes unless the brief explicitly authorizes them.

Trace the connected input → producer/helper → output → downstream path. Inspect consequential
scientific choices, identities, joins/missingness, transformations, statistics, seeds, actual
producing-state evidence, output preservation, and readability as relevant. Research unfamiliar
tool/format semantics only where correctness depends on them. Treat generated or ignored outputs
as potentially retained; do not infer disposability from location or Git state.

Return:

1. the workflow and evidence actually inspected;
2. findings ordered by consequence, with exact file/line or output references;
3. what each finding changes scientifically or operationally;
4. a focused check or fix when one is justified;
5. limitations, inaccessible evidence, and questions requiring scientific judgment.

Label static inference, executed evidence, and comparison evidence separately. Try to refute each
major candidate finding in the actual use case. Do not produce a report merely to satisfy this
brief; the lead will integrate useful evidence into the project's durable record.
