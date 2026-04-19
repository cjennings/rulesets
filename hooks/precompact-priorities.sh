#!/usr/bin/env bash
# PreCompact hook: inject priority-preservation instructions into the
# compaction prompt so the generated summary retains information that's
# disproportionately expensive to reconstruct after compact.
#
# Wire in ~/.claude/settings.json (or per-project .claude/settings.json):
#
#   {
#     "hooks": {
#       "PreCompact": [
#         {
#           "hooks": [
#             {
#               "type": "command",
#               "command": "~/.claude/hooks/precompact-priorities.sh"
#             }
#           ]
#         }
#       ]
#     }
#   }
#
# The hook writes to stdout; Claude Code appends this to its default
# compact prompt. It doesn't read stdin. Safe to install globally.

cat <<'PRIORITIES'

---

When producing the compact summary, preserve the following verbatim or
near-verbatim. Do not paraphrase, compress, or drop these categories — they
are disproportionately expensive to reconstruct after compaction.

These instructions patch the default compact-prompt sections; they do not
replace other parts of it.

### A. Unanswered questions

For every question the user asked, mark it as *answered*, *partially
answered*, or *unanswered*. List every unanswered question verbatim under
a "Pending Questions" heading in the summary. Do not drop a question
just because the conversation moved on; unanswered questions are the
single most common thing that gets lost across compactions.

### B. Root causes, not symptoms

- Distinguish *confirmed* root causes from *ruled-out hypotheses*.
- Cite confirmed causes with `path/to/file:line_number`.
- Keep ruled-out hypotheses under a short "Investigated and excluded"
  list so they don't get re-tried after compact.
- Preserve error messages, stack frames, exit codes, and error IDs
  verbatim — never paraphrase them.

### C. Exact numbers and identifiers

Retain exact digits and strings for all of:

- Commit SHAs, PR numbers, issue numbers, ticket IDs
- Run IDs, job IDs, container IDs
- Dataset names, model IDs, version numbers, release tags
- Measured latencies, throughput, token counts, costs, file sizes
- Line counts, port numbers, IP addresses
- Credentials format markers (not the credential itself — see §E)

These anchor future recall. Rounded or paraphrased numbers force
re-measurement.

### D. File path tiers

Group touched files by tier rather than flattening them into one list:

- **Critical** — files modified, or identified as the source of the bug.
  List with `path/to/file:line`.
- **Referenced** — files read for context but not modified. List the paths.
- **Mentioned** — files discussed but not opened. List by name.

The tiers matter for resumption: "critical" tells the next session where
the work is, "referenced" tells it what to re-open on demand, "mentioned"
is breadcrumb.

### E. Subagent findings as primary evidence

For every Task / Agent tool call, preserve the sub-agent's final report
in full or near-full. Subagent runs are expensive to re-execute; treat
their findings as primary evidence, not compressible chatter. Include:

- The sub-agent's summary heading
- Key findings verbatim
- Any cited code, file paths, or URLs exactly as returned
- The invoking prompt (brief) so the next session knows why the agent ran

If multiple sub-agents ran in parallel, preserve each — do not merge their
findings into a synthesized paragraph.

### F. A-vs-B comparisons and decisions

When two or more options were weighed:

- Preserve the options (labeled A, B, C as appropriate)
- Preserve the decision criteria used
- State which option won and why
- Preserve rejected alternatives with the reason for rejection

Decisions are load-bearing for future work. Losing the rationale forces
re-analysis or, worse, re-deciding the same question differently.

### G. Open TODO items

Any TODO lists, task lists, "next steps," or explicit follow-ups mentioned
in the conversation — preserve the items verbatim. Do not aggregate them
as "user has some follow-up items." A TODO without its exact text is
noise.

### H. Sensitive data handling

If credentials, tokens, API keys, PII, or classified markers appeared in
the conversation: preserve the *shape* (e.g., "AWS access key starting
with AKIA...") but never the full secret. If an operational question
depended on a specific value that can't be preserved safely, record that
the value exists and where it came from so the next session can re-fetch
rather than re-guess.
PRIORITIES
