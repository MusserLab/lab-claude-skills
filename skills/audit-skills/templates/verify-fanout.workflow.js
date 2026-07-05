// verify-fanout.workflow.js — FULL-LIBRARY verification fan-out skeleton.
//
// Runs AFTER the orchestrator has done the solo cross-skill read and formed findings.
// It does NOT read the library for the first time and does NOT do cross-skill (overlap/
// redundancy/naming) analysis — those stay solo in the orchestrator, because fanning out the
// read destroys the cross-skill signal. This script only VERIFIES findings already formed:
//   - Refuter   — fans out per FINDING (confirm / downgrade / reject)
//   - Completeness critic — fans out per SKILL (find what was missed)
// Two different fan-out axes, run concurrently, then the orchestrator folds the results.
//
// HOW TO USE: the orchestrator adapts this at runtime — pass the real data via `args`:
//   args = {
//     auditSkillsDir: "/abs/path/to/audit-skills",
//     findings: [ { id, skillName, skillDir, severity, category, location, finding, recommendation }, ... ],
//     skills:   [ { name, dir, labRepoDir, mechanicalEvidence, knownFindings /* findings[] for this skill */ }, ... ],
//   }
// The agent prompts deliberately point at the canonical templates/*.md (single source of truth)
// and append the specific inputs — so this skeleton never duplicates the prompt bodies.

export const meta = {
  name: 'audit-verify-fanout',
  description: 'Adversarially verify already-formed skill-audit findings: per-finding refute + per-skill completeness',
  phases: [{ title: 'Verify', detail: 'refute each finding + completeness-check each skill, in parallel' }],
}

const A = args.auditSkillsDir
const FINDINGS = args.findings || []
const SKILLS = args.skills || []

const REFUTE_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['id', 'verdict', 'final_severity', 'evidence', 'note'],
  properties: {
    id: { type: 'string' },
    verdict: { type: 'string', enum: ['CONFIRMED', 'DOWNGRADED', 'REJECTED'] },
    final_severity: { type: 'string', enum: ['FIX', 'PRUNE', 'RESTRUCTURE', 'REFINE', 'OK'] },
    evidence: { type: 'string', description: 'file:line + quoted source text' },
    note: { type: 'string' },
  },
}

const MISS_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['skill', 'new_findings'],
  properties: {
    skill: { type: 'string' },
    new_findings: {
      type: 'array',
      items: {
        type: 'object', additionalProperties: false,
        required: ['severity', 'category', 'location', 'finding', 'recommendation'],
        properties: {
          severity: { type: 'string', enum: ['FIX', 'PRUNE', 'RESTRUCTURE', 'REFINE', 'OK'] },
          category: { type: 'string' },
          location: { type: 'string' },
          finding: { type: 'string' },
          recommendation: { type: 'string' },
        },
      },
    },
  },
}

// Both fan-outs are independent → run them in one concurrent batch (the cap throttles to ~10 at a time).
const [verdicts, misses] = await Promise.all([
  parallel(FINDINGS.map(f => () =>
    agent(
      `Follow the verifier instructions in ${A}/templates/refuter-prompt.md ` +
      `(rubric/calibration in ${A}/SKILL.md). Skill files are under ${f.skillDir}. ` +
      `Verify exactly this one finding and return its row:\n${JSON.stringify(f, null, 2)}`,
      { label: `refute:${f.skillName}#${f.id}`, phase: 'Verify', schema: REFUTE_SCHEMA }
    ).then(v => ({ ...v, id: f.id }))
  )),
  parallel(SKILLS.map(s => () =>
    agent(
      `Follow the completeness-critic instructions in ${A}/templates/completeness-prompt.md ` +
      `(rubric in ${A}/SKILL.md). Skill files under ${s.dir}; lab-repo twin: ${s.labRepoDir || 'none'}. ` +
      `Mechanical evidence:\n${s.mechanicalEvidence || '(none)'}\n` +
      `Do NOT re-report these already-raised findings — only NEW ones:\n` +
      `${JSON.stringify(s.knownFindings || [], null, 2)}`,
      { label: `complete:${s.name}`, phase: 'Verify', schema: MISS_SCHEMA }
    )
  )),
])

// Hand structured results back to the orchestrator to FOLD (drop REJECTED, apply DOWNGRADED
// severities, append new_findings) and present. Cross-skill synthesis stays in the orchestrator.
return {
  verdicts: verdicts.filter(Boolean),
  missed: misses.filter(Boolean).flatMap(m => m.new_findings.map(nf => ({ skill: m.skill, ...nf }))),
}