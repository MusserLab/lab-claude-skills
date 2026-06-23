#!/usr/bin/env bash
# UserPromptSubmit hook: nudge Claude to use the /done skill on wrap-up phrasing.
#
# Reads the hook JSON on stdin; if the user's prompt looks like an end-of-session /
# wrap-up request, injects a non-blocking system-reminder (additionalContext) telling
# Claude to invoke the `done` skill rather than hand-rolling the summary/commit.
# False positives are harmless (it's only a reminder).
set -euo pipefail

prompt="$(jq -r '.prompt // empty' 2>/dev/null || true)"
[ -z "$prompt" ] && exit 0

if printf '%s' "$prompt" | grep -qiE "wrap.{0,8}up|let'?s wrap|let'?s commit|ready to commit|end of( the)? session|end the session|we'?re done|we are done|finish(ing)? up|call it( a)?( day| session| night)|done for (the day|today|now)|wrap(ping)? things up"; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"[done-reminder hook] The user appears to be wrapping up / ending the session. You MUST invoke the `done` skill via the Skill tool to do the wrap-up — do NOT hand-roll the summary, doc updates, or git commit/push yourself. This holds EVEN IF the message also includes a specific sub-task (e.g. 'update the planning docs') and EVEN IF context is nearly full. If you genuinely judge this is not an end-of-session moment, you may proceed normally."}}
JSON
fi
exit 0
