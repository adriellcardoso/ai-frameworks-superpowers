# Afiliame `afiliame-product` Overlay Plugin — Implementation Plan

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax for tracking. This plan is the **engineering-agent** half of the Afiliame setup. Its sibling — the Hermes product agent — is planned in `mep/docs/plans/2026-06-13-afiliame-hermes-product-agent.md`. Both halves share the Linear conventions in §2.

**Goal:** A superpowers **overlay plugin** for claude code / opencode that persists feature specs and tasks to **Linear** (not local files) and bridges Linear issues into git worktrees for parallel implementation — composing superpowers rather than editing it.

**Architecture:**

```
LINEAR (team Afiliame)                ENGINEERING agent (claude code / opencode)
  parent issue = full spec    ──pull──▶  afiliame-product overlay plugin
  sub-issues  = tasks                       → materialize issue → worktree plan file
                                            → superpowers: using-git-worktrees
                                            → superpowers: dispatching-parallel-agents
                                            → superpowers: subagent-driven-development
                                            → update sub-issue status back to Linear
```

**Tech stack:** Superpowers (Claude Code plugin format) · Claude Code / opencode · Linear MCP (already connected on this side) · Bash hooks.

---

## 1. Decisions locked (from discovery)

| Decision | Choice | Why |
|---|---|---|
| Packaging | **Separate overlay plugin** `afiliame-product` | Upstream superpowers skills stay untouched → `git pull` never conflicts; complies with the fork's own contributor rules. |
| Linear model | **Parent issue (spec) + sub-issues (tasks)** | Matches the desired flow; sub-issues map 1:1 to worktree agents. |
| Implementer spec source | **Materialize Linear → worktree-local plan file** | Linear stays source of truth; worktrees are self-contained and don't all need Linear MCP. |

## 2. Shared Linear conventions (both agents obey these)

- **Workspace team:** `Afiliame` — id `a0bda8ca-4dd4-4b8f-9903-1e3cf97f68b0`.
- **Feature = one parent issue.** Title = feature name. Description = the full refined spec (problem, goals, non-goals/YAGNI, approach, success criteria, resolved open questions).
- **Tasks = sub-issues** of that parent (`parentId` set), each independently implementable. Sub-issue description = enough context for a cold implementer + acceptance criteria.
- **Labels:** `feature-spec` on parents, `task` on sub-issues (create once if missing).
- **Status:** parent `Backlog`/`Todo`; sub-issues `Todo`. Implementer moves a sub-issue `In Progress` on pickup, `In Review`/`Done` on completion.
- **Spec lives in Linear, not git.** Any local `docs/.../specs/*.md` is an ephemeral cache; the durable artifact is the Linear issue.
- **Linear MCP tools (this workspace):** `save_issue` (create/update; set `parentId` for sub-issues), `get_issue`, `list_issues`, `list_issue_labels` / `create_issue_label`, `save_comment`.

---

## 3. Location & final tree

**Location (for now):** a sibling directory inside the fork working tree, `ai-frameworks-superpowers/afiliame-product/`. Adds **zero** files to upstream's tracked skill tree, so pulls stay clean. **Recommendation:** later move to its own repo (`afiliame-product-plugin`) + Claude Code marketplace; nothing in the files assumes the current location.

```
afiliame-product/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── hooks/
│   ├── hooks.json
│   └── session-start
├── context/
│   └── afiliame.md
├── skills/
│   ├── brainstorming-to-linear/SKILL.md
│   ├── linear-feature-context/SKILL.md
│   └── dispatching-from-linear/SKILL.md
└── scripts/
    └── linear-to-worktree.sh
```

---

## Task 1 — Plugin manifest + marketplace

**Files:** Create `afiliame-product/.claude-plugin/plugin.json`, `afiliame-product/.claude-plugin/marketplace.json`

- [ ] **plugin.json** — name `afiliame-product`, version `0.1.0`, description "Afiliame product agent: Linear-backed brainstorming, feature refinement, and worktree dispatch. Composes superpowers." Author = Adriel. Keywords: `linear`, `product`, `affiliate`, `superpowers`, `brainstorming`.
- [ ] **marketplace.json** — marketplace `afiliame` with a single plugin entry `source: "./"`; install = `/plugin marketplace add <path>` then `/plugin install afiliame-product@afiliame`.

## Task 2 — Session-start hook (makes the Linear flow primary)

**Files:** Create `afiliame-product/hooks/hooks.json`, `afiliame-product/hooks/session-start` (chmod +x)

- [ ] `hooks.json` registers a `SessionStart` matcher `startup|clear|compact` → command `"${CLAUDE_PLUGIN_ROOT}/hooks/session-start"`, `async: false` (same shape as superpowers `hooks/hooks.json`).
- [ ] `session-start` is dependency-free bash printing JSON `additionalContext` (mirror superpowers' platform branching: `hookSpecificOutput.additionalContext` for Claude Code, `additional_context` for Cursor, top-level `additionalContext` otherwise; printf not heredoc, per the bash 5.3 hang). Injected context states:
  - You are in the **Afiliame** product context (see `context/afiliame.md`, summarized inline).
  - **Persistence rule:** feature specs and tasks persist to **Linear (team Afiliame)**, NOT to local `docs/specs` or memory files. New feature → `afiliame-product:brainstorming-to-linear`; follow-up on an existing feature → `afiliame-product:linear-feature-context`.
  - Superpowers still governs *how* you build (TDD, debugging, plans, worktrees); this plugin only changes *where the spec/tasks live*.

## Task 3 — Afiliame product context

**Files:** Create `afiliame-product/context/afiliame.md`

- [ ] Durable product context: Afiliame = multi-tenant SaaS for managing affiliate programs, Brazilian market (pt-BR, BRL, CNPJ-identified clients, PIX payout expectations), early-stage (feature discovery + roadmap).
- [ ] Domain-model crib from the `affiliate` repo `CLAUDE.md`: entity hierarchy (Admin → Client → Store → Integration/UserStoreLink → Order → WalletEvent), order attribution (coupon/UTM match), commission lifecycle, event-sourced wallet, RBAC (USER/CLIENT/ADMIN), 4-stage signup — as a vocabulary map, not a copy.
- [ ] Stack: Nx monorepo, NestJS server, React/Vite web, schedule cron app, Prisma+MongoDB (`@prisma-affiliate/client`), Bagy/Dooca integration.

## Task 4 — Skill: `brainstorming-to-linear`

**Files:** Create `afiliame-product/skills/brainstorming-to-linear/SKILL.md`

- [ ] Frontmatter `name: brainstorming-to-linear`; description triggers on "any Afiliame feature idea / problem space, before implementation; persists the result to Linear."
- [ ] Reuse superpowers brainstorming discipline (one question at a time, 2–3 approaches, sectioned design, YAGNI) but replace the persistence steps:
  - Instead of `docs/superpowers/specs/*.md`, **create a Linear parent issue** in team Afiliame via `save_issue`, full spec as description (template §2), label `feature-spec`.
  - **Decompose into sub-issues**: each actionable task → `save_issue` with `parentId` = parent id, label `task`, self-contained description + acceptance criteria.
  - Echo created identifiers (e.g. `AFI-123` + children).
  - **Terminal state:** hand off to `afiliame-product:dispatching-from-linear` (the plan is now the Linear issue tree, not a writing-plans doc).
- [ ] HARD-GATE: no implementation until the user approves the design AND the Linear issues exist.
- [ ] `<SUBAGENT-STOP>`-style note so dispatched implementer subagents skip this skill.

## Task 5 — Skill: `linear-feature-context`

**Files:** Create `afiliame-product/skills/linear-feature-context/SKILL.md`

- [ ] Trigger: "follow-up about an existing Afiliame feature / when the user references an existing Linear issue."
- [ ] Steps: resolve the feature (`list_issues`/`get_issue` by title or identifier) → load parent spec + sub-issues + recent comments → summarize state before answering. New decisions written **back** to Linear (`save_issue` to update spec, `save_comment` for discussion, new sub-issues for new tasks) — never to local files.
- [ ] Prefer Linear as memory of record; don't reconstruct from `docs/` or git history when a Linear issue exists.

## Task 6 — Skill: `dispatching-from-linear`

**Files:** Create `afiliame-product/skills/dispatching-from-linear/SKILL.md`

- [ ] Trigger: "ready to implement a refined Afiliame feature whose tasks live in Linear."
- [ ] Steps:
  1. `get_issue` parent + `list_issues` its `Todo` sub-issues.
  2. For each independent sub-issue, run `scripts/linear-to-worktree.sh` to **materialize** it into a fresh worktree as `docs/superpowers/plans/<issue-id>-<slug>.md`.
  3. Invoke **`superpowers:using-git-worktrees`** for isolation and **`superpowers:dispatching-parallel-agents`** to launch one implementer per independent sub-issue; each follows **`superpowers:subagent-driven-development`** against its materialized plan.
  4. Update sub-issue status in Linear on pickup/completion (`In Progress` → `In Review`/`Done`) + result comment.
- [ ] Be explicit: this composes superpowers; it only adds the Linear↔worktree bridge.

## Task 7 — Script: `linear-to-worktree.sh`

**Files:** Create `afiliame-product/scripts/linear-to-worktree.sh` (chmod +x)

- [ ] Input: a Linear issue identifier + target worktree path. Output: a superpowers-style plan markdown in that worktree's `docs/superpowers/plans/`.
- [ ] The agent fetches issue content via the Linear MCP and passes it to the script (args/stdin); the script templatizes it with the superpowers plan header (`> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development …`, Goal/Architecture/Tech Stack, checkbox tasks). Keep the script thin.
- [ ] Idempotent: re-running overwrites the plan file (Linear is authoritative).

---

## Verification

- [ ] `find afiliame-product -type f` matches the tree; `bash -n` passes on both shell files; `chmod +x` set.
- [ ] All JSON valid (`python -c "import json,glob;[json.load(open(f)) for f in glob.glob('afiliame-product/**/*.json',recursive=True)]"`).
- [ ] Every `SKILL.md` has valid frontmatter and references only real superpowers skill names (`using-git-worktrees`, `dispatching-parallel-agents`, `subagent-driven-development`, `writing-plans`).
- [ ] Dry-run the hook: `CLAUDE_PLUGIN_ROOT=$PWD/afiliame-product afiliame-product/hooks/session-start | python -m json.tool` → valid JSON with the Afiliame/Linear context.
- [ ] Install locally: `/plugin marketplace add ./afiliame-product` → `/plugin install afiliame-product@afiliame`; new session injects the context; superpowers still loads alongside.
- [ ] Upstream clean: `git status` shows only the untracked `afiliame-product/` dir, no tracked skill files modified.

## Manual steps for Adriel

1. Install the plugin in claude code/opencode (`/plugin marketplace add …` → `/plugin install`).
2. Decide the plugin's final home — recommended: move `afiliame-product/` to its own repo before it grows.

## Out of scope (YAGNI)

- Two-way Linear↔git sync beyond status updates (no webhook listener).
- Auto-creating Linear projects/initiatives (parent+sub-issues until a feature is genuinely epic-sized).
- Retroactively migrating existing `affiliate` specs into Linear.
