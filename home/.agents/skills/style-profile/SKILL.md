---
name: style-profile
description: Analyzes Victor's own Slack messages and local Claude Code session transcripts to build and update a personal writing-style profile, stored as a markdown vault at ~/style-profile. Manually triggered only — never runs on a schedule. Use when Victor asks to "update my style profile", "refresh style profile", "analyze my writing style", or invokes /style-profile.
---

# Style Profile

Builds and incrementally updates a personal writing-style profile for Victor Tennekes, based on messages he has actually written — not third parties'. Output lives in the markdown vault at `~/style-profile/` (index: `STYLE.md`).

**Slack is the primary source.** Victor communicates with other people on Slack — that's his real interpersonal voice. Claude Code transcripts are a secondary/contrast source only: talking to an LLM is a wildly different register (fast, typo-tolerant, no social stakes) and shouldn't dominate the profile. Default future runs to a full Slack sweep; only touch Claude transcripts again if Victor asks for a refresh of that source specifically.

This skill is manual-trigger only. Do not suggest scheduling it via cron/loop unless Victor explicitly asks for that.

## Privacy rules (non-negotiable)

- Only sample messages **authored by Victor**. Read surrounding thread/channel context only as much as needed to interpret tone (e.g. what he was replying to) — do not extract or store other people's writing style.
- Never copy secrets, tokens, credentials, or customer/PII data into the vault, even as "examples." If a sampled message contains something sensitive, paraphrase the *stylistic* feature instead of quoting it verbatim.
- Skip DMs unless Victor has explicitly said DMs are in scope for a given run.

## Sources

1. **Slack (primary)** — via the connected Slack MCP tools. Find Victor's own user id (`slack_search_users` or `slack_read_user_profile`), then pull messages he authored (`slack_search_public_and_private` / `slack_search_public` scoped to `from:<him>`, or `slack_read_channel` / `slack_read_thread` for threads he's active in). Aim for full coverage across **all channels he's a member of**, all-time — don't rely on one relevance-ranked query, since Slack search under-returns low-volume/casual channels by default; enumerate channels and run per-channel searches to counter that bias. Channels only, no DMs, unless Victor has explicitly said DMs are in scope for a given run.
2. **Local Claude Code transcripts (secondary/contrast only)** — `~/.claude/projects/**/*.jsonl`. Each line is a JSON record; extract `role":"user"` message text. Filter out: tool-result blocks, `<system-reminder>` content, file contents pasted into messages, anything that's clearly command output rather than Victor's own words. Keep only his freeform prose. Use this to illustrate contrast with the Slack voice, not as the main body of evidence.
3. **Web claude.ai history** — not reachable from this environment (no MCP/API exposes it), and not available as a self-serve export either: Victor is on a Team/Enterprise plan, where data export is an admin/workspace-level control, not something an individual member can pull themselves. Treat this source as unavailable. Don't suggest chasing it again unless Victor says his plan or access has changed.

## Procedure

1. Read `~/style-profile/sources-log.md`. The top of the file has `Last run:`, `Claude transcripts sampled through:`, and `Slack sampled through:` fields.
   - If `Last run: never`, this is the first run — sample as much history as reasonably available, not just "since last time."
   - Otherwise, use the two `sampled through:` dates as the cutoffs for each source below (they can differ, e.g. if a past run skipped Slack because MCP wasn't connected).
2. Gather new material:
   - Claude transcripts: only `.jsonl` files modified after the Claude cutoff, and within those, only message records timestamped after it.
   - Slack: use the Slack cutoff as an `after:` bound on the search/read calls.
   - Source 3 (manual export) only if Victor points you to a new file this run.
3. Analyze for:
   - **Tone** — directness vs hedging, formality, warmth, how it shifts by audience (Slack teammates vs Claude vs code review).
   - **Vocabulary** — recurring words/phrases, jargon, technical vs casual register.
   - **Phrasing quirks** — sentence length/rhythm, punctuation and emoji habits, idioms, characteristic openers/closers.
   - **Context variance** — concrete contrasts between how he writes in Slack vs to Claude vs elsewhere.
4. Update the vault files **in place** — this is a living profile, not a report:
   - Append new evidence/examples under the relevant dimension file, don't overwrite prior conclusions unless new evidence contradicts them (in which case note the change, don't silently erase history).
   - Keep examples as paraphrased patterns, not verbatim sensitive quotes (see privacy rules).
   - Update `STYLE.md` if a new dimension emerges that doesn't fit the existing five files.
   - Update the `Last run:`, `Claude transcripts sampled through:`, and `Slack sampled through:` fields at the top of `sources-log.md` to today's date (or the actual newest message timestamp seen, if you want the cutoff precise). Append a new entry under `## Runs`: date, what was sampled (counts, channels, date range), one-line summary of what changed.
5. Report a short summary to Victor of what changed since the last run — don't dump the full vault back into chat, he can read the files directly.

## Notes

- This is a personal reference tool (e.g. for briefing a fresh agent on "write like me," or so Victor can self-inspect how his communication shifts by context) — treat accuracy and honesty in the profile as more valuable than flattering phrasing.
- The vault is plain markdown by design — greppable, portable, opens fine in Obsidian for graph/backlink exploration if Victor wants that later.
