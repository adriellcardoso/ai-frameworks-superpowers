#!/usr/bin/env bash
# linear-to-worktree.sh — materialize a Linear sub-issue into a superpowers-style
# plan file inside a target worktree.
#
# Linear is authoritative; this script is a thin templatizer. The AGENT fetches
# the issue content via the Linear MCP and passes it here — the script does no
# network access of its own.
#
# Usage:
#   linear-to-worktree.sh --id <identifier> --slug <slug> --worktree <path> \
#       --title <title> [--goal <goal>] < body.md
#
#   --id        Linear identifier, e.g. AFI-123        (required)
#   --slug      filename slug, e.g. coupon-attribution (required)
#   --worktree  target worktree root path             (required)
#   --title     issue title                           (required)
#   --goal      one-line goal (defaults to the title) (optional)
#   stdin       issue description + acceptance criteria (markdown). Becomes the
#               body of the plan. If empty, a placeholder is written.
#
# Output: <worktree>/docs/superpowers/plans/<id>-<slug>.md  (overwritten if it
# exists — re-running re-syncs from Linear).

set -euo pipefail

id=""
slug=""
worktree=""
title=""
goal=""

while [ $# -gt 0 ]; do
    case "$1" in
        --id)        id="$2";       shift 2 ;;
        --slug)      slug="$2";     shift 2 ;;
        --worktree)  worktree="$2"; shift 2 ;;
        --title)     title="$2";    shift 2 ;;
        --goal)      goal="$2";     shift 2 ;;
        *)
            printf 'linear-to-worktree.sh: unknown argument: %s\n' "$1" >&2
            exit 2
            ;;
    esac
done

# Validate required args.
missing=""
[ -n "$id" ]       || missing="${missing} --id"
[ -n "$slug" ]     || missing="${missing} --slug"
[ -n "$worktree" ] || missing="${missing} --worktree"
[ -n "$title" ]    || missing="${missing} --title"
if [ -n "$missing" ]; then
    printf 'linear-to-worktree.sh: missing required argument(s):%s\n' "$missing" >&2
    exit 2
fi

[ -d "$worktree" ] || {
    printf 'linear-to-worktree.sh: worktree path does not exist: %s\n' "$worktree" >&2
    exit 1
}

[ -n "$goal" ] || goal="$title"

# Read the issue body (description + acceptance criteria) from stdin.
body="$(cat)"
[ -n "$body" ] || body="_No description was provided from Linear. Re-run with the issue body on stdin._"

plans_dir="${worktree}/docs/superpowers/plans"
mkdir -p "$plans_dir"
plan_file="${plans_dir}/${id}-${slug}.md"

# Templatize. printf (not heredoc) to avoid the bash 5.3+ heredoc hang.
{
    printf '# %s — %s\n\n' "$id" "$title"
    printf '> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Implement this plan with TDD; check off tasks as you go. This plan was materialized from Linear issue %s — Linear is authoritative. If this file and Linear disagree, Linear wins (re-materialize).\n\n' "$id"
    printf '**Goal:** %s\n\n' "$goal"
    printf '**Source:** Linear %s (team Afiliame). Update the sub-issue status back in Linear on pickup (`In Progress`) and completion (`In Review`/`Done`).\n\n' "$id"
    printf '**Tech stack:** Nx monorepo · NestJS server · React/Vite web · schedule cron app · Prisma + MongoDB (`@prisma-affiliate/client`) · Bagy/Dooca integrations.\n\n'
    printf -- '---\n\n'
    printf '## Spec (from Linear %s)\n\n' "$id"
    printf '%s\n' "$body"
} > "$plan_file"

printf 'Wrote %s\n' "$plan_file"
