# /respond-to-cj-comments — Process `cj:` Annotations in a File

Scan a file for `cj:` comments (Craig's in-line instructions and questions) and handle each one with subagent-delegated accuracy. Used to batch-process notes Craig leaves in documents, code, or org files for later action.

## Usage

```
/respond-to-cj-comments [FILE_PATH]
```

If no file is given, ask the user for the target file. If the user references "this file" or similar with a visible editor buffer, confirm the path before starting.

## What counts as a `cj:` comment

A `cj:` comment is any line where the text `cj:` (case-insensitive) starts the comment content. The comment marker varies by file type:

| File type                                      | Example                                                      |
|------------------------------------------------|--------------------------------------------------------------|
| Org / plain text                               | `cj: what does this section actually deliver?`               |
| Markdown                                       | `<!-- cj: split this paragraph before the Scope section -->` |
| Python / shell / YAML                          | `# cj: check whether this still matches reality`             |
| JavaScript / C / Java / TypeScript / Rust / Go | `// cj: verify the error wrapping logic here`                |
| Lisp / Elisp / Scheme                          | `;; cj: is this hook still wired?`                           |
| LaTeX                                          | `% cj: rewrite, this sounds too corporate`                   |
| HTML / XML                                     | `<!-- cj: move this above the fold -->`                      |

Multi-line comments are supported when continuation lines keep the same comment prefix:

```
# cj: please check whether the feature flag is still wired.
# also confirm the fallback path matches the diagram in docs/arch.org.
```

Treat the whole contiguous block as one `cj:` item.

## Instructions

### 1. Scan the file

Read the target file and collect every `cj:` comment. For each one, record:

- File path and line number (or range for multi-line items)
- Enclosing context:
  - *Org file:* the parent `* TODO` / heading path (e.g. `Parent ▸ Subheading ▸ TODO Foo`)
  - *Code:* the surrounding function or class
  - *Other:* a few lines of surrounding prose
- The full comment text, including continuation lines
- The raw comment-marker style so the line can be located and removed later

### 2. Classify each item

For each `cj:` comment, decide whether it's:

- **Instruction** — a request for action. Signals: imperative verbs (check, rewrite, fix, remove, add, draft), "please do X".
- **Question** — a request for information. Signals: ends with `?`, starts with who/what/when/where/why/how, "is this", "does this", "should we".
- **Both** — contains an instruction and a question. Handle the instruction side, answer the question side.

When truly ambiguous, treat as both.

### 3. Delegate to subagents — accuracy over speed

For each non-trivial item, spawn an Agent subagent. Trivial items (e.g. "remove this blank line") the main thread can handle directly without delegation.

Two classes of subagent:

- **Instruction subagent** — given the comment, the enclosing context, and the file path, figures out what change is needed and reports a concrete recommendation. Reports: what should change, file paths + line numbers, any follow-up the user needs to decide.
- **Question subagent** — researches the question. For questions requiring codebase exploration, ticket lookups, web research, or cross-file reasoning, give the subagent explicit scope (files to read, tickets to check, search terms). Reports: direct answer, evidence (file:line refs, quotes, sources), confidence level, any remaining unknowns.

Run subagents in parallel when the items are independent. Wait for review between batches if items depend on each other.

Prompt every subagent with four required fields (see `subagents.md` for the full contract):

1. **Scope** — one bounded comment, named file, specific action or question
2. **Context** — paste the comment verbatim plus the surrounding context from step 1
3. **Constraints** — do not touch other `cj:` comments, do not refactor unrelated code, preserve file formatting
4. **Output format** — for instructions: a specific change proposal (before/after or file:line patch), plus URLs or file paths for every external source consulted. For questions: answer + evidence (including URLs or file:line refs for every claim) + confidence level + under 300 words. Subagents must cite sources. A claim without a URL or file reference doesn't belong in the report.

The main thread applies edits. Subagents report; they do not write to the source file. This keeps formatting consistent and makes review easier.

**Accuracy over speed is the rule.** Three subagents and fifteen minutes to answer one question correctly beats a fast wrong answer.

### 4. Apply changes

For **instructions**:

1. Review the subagent's proposed change before applying. Check that it matches the comment's intent and doesn't introduce a new issue. If the proposal looks wrong or incomplete, dispatch a fix subagent with the failure report as its context. Don't retry the diagnosis in the main thread (see the Context-Pollution Rule in `subagents.md`). After two failed fix attempts, stop and surface the problem to the user.
2. Apply the change once the proposal is sound. Edits come from the main thread.
3. **Org-mode subheader format.** When inserting new content under an existing org-mode task (research findings, drafted messages, log entries, recorded Slack replies), use a timestamped subheader one level deeper than the parent task:

   ```
   *** 2026-04-23 Thu @ 15:20:52 -0500 <short description>
   <content>
   ```

   Use one more `*` than the parent task's heading level. If the parent is `** TODO`, the subheader is `***`. If the parent is `**** TODO`, the subheader is `*****`. Generate the timestamp with `date "+%Y-%m-%d %a @ %H:%M:%S %z"` so it's accurate, not estimated.

4. **Surface URLs.** If the subagent's output includes URLs, file paths, or external references, list them under the updated task content. After applying the edit, offer to convert them into explicit org-mode links (`[[url][label]]` or `[[file:path][label]]`) at the location where the `cj:` comment originated, or elsewhere in the task if that fits better.

5. If the comment is inside an org-mode `TODO` heading, mark that `TODO` as `DOING` when work begins. Leave it `DOING` for the user to advance to `DONE` after review.

6. Remove the `cj:` comment from the file (the entire contiguous block, including continuation lines).

For **questions**:

1. Capture the answer in the summary (step 5).
2. Remove the `cj:` comment. The user can re-open the thread conversationally if they have follow-ups.

For **writing destined for public channels** (commit messages, PR descriptions, PR comments, Slack or email messages, public docs):

1. Invoke `/humanizer` on the draft.
2. Apply these voice and attribution rules to the writing you produced (adapted from `/home/cjennings/code/rulesets/claude-rules/commits.md`):

   **No AI attribution, anywhere.** Never include AI, LLM, Claude, or Anthropic attribution in any public-facing text. That means:
   - No `Co-Authored-By: Claude` (or Claude Code, or any AI) trailers
   - No "Generated with Claude Code" footers or equivalents
   - No emojis implying AI authorship
   - No references to Claude, Anthropic, LLM, or "AI tool" as a credited contributor
   - Strip any attribution a tool or template inserts by default

   **First person where it fits.** When the subject is Craig or a decision he made, use "I". When the subject is a team decision or shared rationale, "we" fits. Name other authors when crediting their work ("Kostya's PR #116 did X"). Avoid third-person press-release voice ("This PR introduces X", "This change restores Y") unless the code or system is the actor.

   **Brief. Terse is fine.** A one-sentence body beats a paragraph saying the same thing. If the subject line covers it, skip the body entirely. Cut every clause that restates what the diff, the card, or the surrounding context already shows. Length isn't a proxy for care. Rhetorical padding ("worth noting", "it's important to understand") always comes out.

   **Kind.** Text directed at a specific person: acknowledge them when it fits, without pouring it on. Frame disagreement as your read ("I think...", "my read was...", "did you mean X?"). Leave room for the other person to have seen something you didn't. A polite question beats a defensive explanation.

   **Plain English.** Complete sentences a low- or mid-level engineer who isn't a native speaker can read without stumbling. Replace semicolons with periods or commas. Prefer contractions ("it's", "that's", "don't", "we're"). Split long sentences on conjunctions ("so", "and", "but") when meaning survives the split. No em-dashes, use regular dashes instead. Em-dashes break in GitHub, Linear, and Slack.

   **Don't stack jargon.** A sentence that chains three or more type signatures, API names, or compiler concepts reads as a wall. Break it into shorter sentences. Keep the terms a reader will grep for, drop the ones that name compiler internals.

3. Scan the output for AI-attribution tells. If you catch yourself having written any of these, stop, delete, and rewrite:
   - `Co-Authored-By: Claude`
   - `Generated with Claude Code` (with or without the robot emoji)
   - "Created with Claude Code"
   - "Assisted by AI"

   Rewrite as Craig would write it: concise, focused on the content, with no mention of how the text was produced.

If the writing will be *posted* (not just saved as a draft), follow the Review and Publish flow in `commits.md` — draft to `/tmp/`, open in `emacsclient -n`, wait for Craig's explicit approval before posting.

**Private writing** (todo.org entries, session-context.org, scratch notes, internal rulesets) skips the humanizer pass. Voice rules still apply where relevant, but the overhead of a draft-and-approve cycle is not warranted.

### 5. Report

Produce one summary at the end, structured:

```
## Summary

### Instructions (N)

1. <file:line> <one-line recap>
   → done. <brief what-changed>.
   → TODO status: <DOING | unchanged>.
2. ...

### Questions (N)

1. <file:line> Q: <comment verbatim, trimmed to one line>
   A: <direct answer>
   Evidence: <file:line refs, ticket IDs, URLs, quotes>
   Confidence: <high | medium | low with caveat>
2. ...

### Follow-ups

- <anything the user needs to decide, review, or act on>

### Unresolved

- <any `cj:` comments that couldn't be handled — say why, leave them in place>

### File state

State explicitly one of:
- "File is now clean. All `cj:` comments resolved and removed."
- "File still contains N unresolved `cj:` comment(s), listed under Unresolved above."

Never leave the reader guessing about whether the file is ready for follow-up work.
```

Keep answers direct. If a question has a simple answer, one sentence. If it needs nuance, two or three. Do not pad. The user reads the summary, not the intermediate work.

**Long summaries go to a file.** If the summary runs beyond six to eight items, or beyond ~500 words of prose, write it to `/tmp/respond-to-cj-summary-YYYY-MM-DD.org` as an org file and open it in `emacsclient -n <path>`. The user may annotate the file, add new `cj:` comments in-line, or answer open questions in-line, then save. After the user saves, re-read the file for any additional instructions or answers and handle those before ending the run. A long summary dumped straight into chat is hard to comment on and hard to return to; the file form makes it reviewable and iterable.

**Every file path in the summary must be a clickable org-mode link.** Use absolute paths: `[[file:/absolute/path/to/file][display label]]`. Plain paths wrapped in `=verbatim=` markers aren't clickable in emacs. URLs in the summary should also use link form: `[[https://...][label]]`. This applies to every file reference in the summary file — source files read, artifacts created, archive destinations, anywhere the user might want to jump. If there's a path in the summary, it should open when clicked.

### 6. Cleanup pass

Remove every `cj:` comment that was handled in step 4 (instructions done) or step 5 (questions answered). The file is clean after the skill runs. Any comment left unresolved stays in place and is listed under `### Unresolved` in the summary with the reason.

Confirm the cleanup by re-scanning the file after removals. If any `cj:` line survives that shouldn't, remove it and note the correction.

## Principles

- **Accuracy > speed.** Subagent generously. A wrong answer to a `cj:` comment is worse than a slow one.
- **Don't guess.** If a question needs verification and verification isn't possible, say so. Surface unknowns rather than fabricate.
- **Preserve the file.** Don't reformat surrounding lines. Don't reorder tasks. Touch only what the comment asks for, plus the comment's own removal.
- **The user reads the summary, not the process log.** Write summaries that are directly useful.
- **Public writing gets humanizer + commits.md. Private writing doesn't.** Don't over-process internal notes.

## Anti-patterns

- Handling complex `cj:` items inline in the main thread instead of subagenting.
- Batching unrelated `cj:` comments into one giant subagent prompt.
- Removing a `cj:` comment before the user has seen the answer in the summary.
- Skipping the humanizer + commits.md pass on public-facing writing because it "looked fine already."
- Guessing on a question instead of spawning a research subagent.
- Letting a subagent edit the source file directly — review surface loss.

## Example

Input file: `todo.org` containing:

```
** TODO Draft the D2P2 Pillar 1 writeup
cj: what do we actually know about Orion's Belt's partner API contract?
cj: check whether Redwire's AdTech feed is still in scope. Eric mentioned deprecating it in sprint planning.
```

Skill run:

1. Scans, finds two `cj:` items (one question, one instruction-with-verification).
2. Marks the parent `** TODO` as `DOING`.
3. Spawns two subagents in parallel:
   - **Q subagent:** reads `deepsat/knowledge.org`, greps ticket history for "Orion's Belt API", checks recent meeting transcripts. Reports findings with evidence.
   - **Instruction-with-verification subagent:** reads sprint-planning transcripts, searches for "Redwire AdTech deprecation", checks Linear for related tickets. Reports whether the feed is still in scope.
4. Main thread applies the `DOING` status change, writes the summary with both answers, removes both `cj:` comments.
5. Reports:
   - Q1: What we know about Orion's Belt's partner API contract → answer + file:line refs + confidence.
   - Q2/Instruction: Redwire AdTech scope → answer + evidence + recommendation for whether to cite in Pillar 1.

Craig reads the summary, decides what to do with the Redwire finding, and the TODO stays in `DOING` until he advances it.
