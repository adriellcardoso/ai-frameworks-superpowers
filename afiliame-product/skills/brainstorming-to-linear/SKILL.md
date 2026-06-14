---
name: brainstorming-to-linear
description: "Use this before any implementation when exploring a NEW Afiliame feature idea or problem space. Refines the idea into a design through collaborative dialogue, then persists the result as a Linear parent issue (spec) plus sub-issues (tasks) in team Afiliame — not to local files."
---

# Brainstorming an Afiliame Feature Into Linear

Turn an Afiliame feature idea into a refined design, then persist it to **Linear
(team Afiliame)** as the durable source of truth: one **parent issue** for the
spec and one **sub-issue** per implementable task.

This skill reuses the superpowers brainstorming **discipline** but changes the
**persistence target**: Linear issues instead of `docs/superpowers/specs/*.md`.

<SUBAGENT-STOP>
If you are a dispatched implementer subagent, STOP — this skill is not for you.
Implement against the materialized plan file in your worktree. Brainstorming and
Linear persistence are the coordinator's job, already done before you were
dispatched.
</SUBAGENT-STOP>

<HARD-GATE>
Do NOT write any code, scaffold anything, create a worktree, or take any
implementation action until BOTH are true:
1. The user has approved the design, AND
2. The Linear parent issue and its sub-issues exist (you have their identifiers).
This applies to every feature regardless of perceived simplicity.
</HARD-GATE>

## Discipline (same as superpowers brainstorming)

1. **Explore context** — read `context/afiliame.md` and any relevant prior Linear
   issues (`list_issues` in team Afiliame) before asking anything.
2. **Ask clarifying questions one at a time.** Prefer multiple choice. Focus on
   purpose, constraints, success criteria. Never batch questions.
3. **Propose 2–3 approaches** with trade-offs; lead with your recommendation.
4. **Present the design in sections**, scaled to complexity; get approval after
   each section. Cover architecture, components, data flow, error handling,
   testing.
5. **YAGNI ruthlessly** — cut speculative features. Capture them as non-goals.

Use Afiliame vocabulary from `context/afiliame.md` (Client, Store, Integration,
Order attribution, commission lifecycle, event-sourced WalletEvent, RBAC,
4-stage signup) so the spec is grounded in the real domain.

## Persistence: write the spec to Linear

After the user approves the design, persist it. **Do not** write a local spec
file — Linear is the source of truth.

### 1. Ensure labels exist (once)

- `list_issue_labels` for team Afiliame. If `feature-spec` or `task` is missing,
  `create_issue_label` for the missing one(s).

### 2. Create the parent issue (the spec)

- `save_issue` in team Afiliame (id `a0bda8ca-4dd4-4b8f-9903-1e3cf97f68b0`):
  - **Title** = the feature name.
  - **Description** = the full refined spec, with these sections:
    - **Problem** — what's broken / the user need.
    - **Goals** — what success looks like.
    - **Non-goals / YAGNI** — explicitly out of scope.
    - **Approach** — the chosen design and why (note rejected alternatives).
    - **Success criteria** — observable, testable outcomes.
    - **Resolved questions** — decisions made during brainstorming.
  - **Label** = `feature-spec`. **Status** = `Backlog` or `Todo`.

### 3. Decompose into sub-issues (the tasks)

For each independently implementable task:

- `save_issue` with **`parentId`** = the parent issue id, **label** = `task`,
  **status** = `Todo`.
- The sub-issue description MUST stand alone for a cold implementer:
  enough context to start without reading other issues, plus explicit
  **acceptance criteria**.
- Keep tasks independent where possible — each maps 1:1 to a worktree agent in
  `afiliame-product:dispatching-from-linear`. Note any ordering dependency
  explicitly in the description.

### 4. Confirm and hand off

- Echo the created identifiers to the user: the parent (e.g. `AFI-123`) and each
  child (e.g. `AFI-124`, `AFI-125`).
- **Terminal state:** the "plan" is now the Linear issue tree. Do NOT invoke
  `superpowers:writing-plans` — that workflow writes local plan docs. When the
  user is ready to build, hand off to **`afiliame-product:dispatching-from-linear`**.

## Key principles

- One question at a time; multiple choice preferred.
- Always propose 2–3 approaches before settling.
- YAGNI — trim the spec to what's actually needed.
- **Linear is the memory of record.** Never leave the durable spec in a local
  file or only in chat.
