---
name: dispatching-from-linear
description: "Use this when ready to implement a refined Afiliame feature whose tasks already live in Linear (a parent issue with Todo sub-issues). Materializes each sub-issue into a worktree-local plan file and dispatches parallel implementers via superpowers, updating sub-issue status back to Linear."
---

# Dispatching Afiliame Implementation From Linear

The bridge between **Linear (where tasks live)** and **git worktrees (where they
get built)**. This skill **composes superpowers** — it does not reimplement
worktrees, parallel dispatch, or TDD. It only adds the Linear↔worktree bridge:
materialize each Linear sub-issue into a self-contained plan file, then let
superpowers do the building.

<SUBAGENT-STOP>
If you are a dispatched implementer subagent, STOP — you already have your
materialized plan file in your worktree. Implement that. Do not re-read Linear
or re-dispatch.
</SUBAGENT-STOP>

## Prerequisite

The feature exists in Linear as a parent issue (spec) with `Todo` sub-issues
(tasks). If it doesn't yet, use `afiliame-product:brainstorming-to-linear` first.

## Steps

1. **Load the work from Linear.**
   - `get_issue` on the parent (the spec).
   - `list_issues` for its `Todo` sub-issues (`parentId` = the parent id), in
     team Afiliame (id `a0bda8ca-4dd4-4b8f-9903-1e3cf97f68b0`).
   - Identify which sub-issues are **independent** (no shared state, no ordering
     dependency). Dependent tasks run sequentially, not in parallel.

2. **Materialize each task into a worktree plan file.**
   - For each task to be built, create its isolated worktree using
     **`superpowers:using-git-worktrees`**.
   - Fetch the sub-issue's content via the Linear MCP (`get_issue`) and pass its
     title + description + acceptance criteria to
     `${CLAUDE_PLUGIN_ROOT}/scripts/linear-to-worktree.sh`, which writes a
     superpowers-style plan to that worktree's
     `docs/superpowers/plans/<issue-id>-<slug>.md`.
   - The script is idempotent — re-running overwrites the plan file because
     Linear is authoritative.

3. **Dispatch implementers.**
   - Use **`superpowers:dispatching-parallel-agents`** to launch one implementer
     per *independent* sub-issue, each in its own worktree.
   - Each implementer follows **`superpowers:subagent-driven-development`**
     against its materialized plan file. Run dependent tasks sequentially.

4. **Update Linear as work progresses.**
   - On pickup: set the sub-issue status to `In Progress`.
   - On completion: set it to `In Review` (or `Done` per the team's flow) and
     `save_comment` with a short result summary (what landed, branch/worktree,
     anything the reviewer should know).

## Principles

- **Compose, don't reinvent.** Worktrees, parallel dispatch, and TDD come from
  superpowers. This skill only bridges Linear ↔ worktrees and keeps Linear
  status in sync.
- **Linear stays authoritative.** The materialized plan file is a worktree-local
  cache of a Linear sub-issue; if they diverge, Linear wins — re-materialize.
- **Independence gates parallelism.** Only dispatch tasks in parallel when they
  truly don't share state.
