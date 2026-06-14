---
name: linear-feature-context
description: "Use this for a follow-up on an EXISTING Afiliame feature, or whenever the user references an existing Linear issue (by title or identifier like AFI-123). Loads the feature's spec, sub-issues, and recent discussion from Linear before answering, and writes any new decisions back to Linear — never to local files."
---

# Loading Existing Afiliame Feature Context From Linear

When the user follows up on a feature that already exists in Linear, **Linear is
the memory of record**. Load the current state from Linear before answering —
don't reconstruct it from `docs/`, git history, or chat memory.

<SUBAGENT-STOP>
If you are a dispatched implementer subagent, STOP — work from your worktree's
materialized plan file. Loading and updating Linear is the coordinator's job.
</SUBAGENT-STOP>

## Steps

1. **Resolve the feature.**
   - If the user gave an identifier (e.g. `AFI-123`) → `get_issue`.
   - If they gave a name/topic → `list_issues` in team Afiliame
     (id `a0bda8ca-4dd4-4b8f-9903-1e3cf97f68b0`), filter by title, and confirm
     with the user if more than one plausibly matches.

2. **Load the full state.**
   - The **parent issue** description = the current spec.
   - Its **sub-issues** (`parentId` = the parent) = the tasks and their statuses
     (`Todo` / `In Progress` / `In Review` / `Done`).
   - **Recent comments** (`list_comments`) = the latest discussion and decisions.

3. **Summarize before answering.** Give the user a short state summary — spec
   intent, which tasks are done / in flight / not started, and the most recent
   decisions — so the follow-up is grounded in reality, not assumption.

4. **Then answer or act** on the follow-up.

## Writing decisions back to Linear

New information must persist to Linear, never to local files or only to chat:

- **Spec changed** (scope, approach, success criteria) → `save_issue` to update
  the **parent** description. Keep the section structure from
  `afiliame-product:brainstorming-to-linear`.
- **Discussion / rationale / open question** → `save_comment` on the relevant
  issue.
- **New task discovered** → `save_issue` with `parentId` = the parent, label
  `task`, status `Todo`, self-contained description + acceptance criteria.
- **Status change** → update the sub-issue status on the issue itself.

## Principles

- **Linear is the source of truth.** When a Linear issue exists, prefer it over
  `docs/` or git history for what the feature is and where it stands.
- Don't silently diverge: if the user's request contradicts the recorded spec,
  surface the discrepancy and update Linear deliberately.
- Ready to build a refined feature whose tasks are in Linear? Hand off to
  **`afiliame-product:dispatching-from-linear`**.
