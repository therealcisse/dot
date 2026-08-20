---
name: teams-catchup
description: Digest of Teams @mentions since last run (across all channels/chats, including ones you don't follow). Writes a Markdown file and DMs the digest to yourself. Runs on cron; also invokable on demand. v0 covers @mentions only (not plain DMs — Teams API constraint).
allowed-tools: Bash, Read, Write, Edit, mcp__teams__teams_login, mcp__teams__teams_get_activity, mcp__teams__teams_get_message, mcp__teams__teams_send_message, mcp__teams__teams_search
---

# Teams Catchup

Reliable digest of @mentions you missed since the last run. Uses the Teams activity feed as the canonical source — it aggregates mentions across every channel and chat you have access to, whether you follow those channels or not.

## Scope (v0)

**Covers:**
- @mentions in channels (any channel you have access to)
- @mentions in group and 1:1 chats

**Does NOT cover (v0 limitations):**
- Plain DMs where you weren't @-mentioned (Teams API's `teams_get_unread` only checks favourites, and iterating all chats is expensive)
- Thread replies to your messages without an @-mention (would require thread-root lookup per candidate)
- Reactions

Add these later if v0 proves useful.

## Identity

- Display name: `Cisse, Amadou -ND`
- MRI: `8:orgid:be3ecbb9-dbf8-4e28-bd87-db057e886bee`
- Email: `Amadou.Cisse.-ND@disney.com`

## State files

Base directory: `/Users/amadou/.claude/state/teams-catchup/`

- `last-seen.iso` — ISO8601 timestamp of the last successful run. Default (missing): 24h before now.
- `latest.md` — copy of the most recent digest (or a "no items" placeholder if the last run was empty).
- `YYYY-MM-DD-HHMM.md` — dated digest files (one per run that had items).
- `auth-warning.flag` — created when auth fails during a run; next run prepends a warning to the digest and deletes the flag.
- `self-chat-id.txt` — cached chat ID to DM the digest to. If missing, populated on first successful run.

## API quirk to know

`teams_get_activity` returns each activity item with `sender.mri` set to **your own MRI**, not the sender's. This is a Teams API behavior. To get the real sender name and full message content, call `teams_get_message(conversationId, messageId)` on the item — the ID in the activity item is the same as the message ID.

The `content` on activity items is a short preview (usually the beginning of the message). Fine for the digest; drill in with `teams_get_message` only if you need more context.

## Execution steps

### 1. Auth

```
mcp__teams__teams_login()
```

If it fails with auth-required, write `auth-warning.flag` with the current timestamp and exit 0. Do not crash the cron.

### 2. Read state

- Read `last-seen.iso`; if missing use `now - 24h`.
- Note whether `auth-warning.flag` exists (for prepending a warning below).

### 3. Pull activity

```
mcp__teams__teams_get_activity(limit=100)
```

Filter to items where:
- `type == "mention"`
- `timestamp > last_seen`

The result gives you `id` (== `messageId`), `conversationId`, `content` preview, and `activityLink`.

### 4. Resolve sender + full context per mention

**Constraint:** The `conversationId` on activity feed items is often a synthetic aggregator (e.g. `nr:system:clump:Mentions`), not the real thread. Calling `teams_get_message` with those IDs returns 404. Two consequences:

- **You cannot reliably resolve the real sender name** from the activity feed alone.
- **The `activityLink` deep-links correctly in the Teams UI** — clicking it takes the user to the actual message. So use `activityLink` (not `messageLink`) for the "Open in Teams" URL.

Best-effort sender detection from the preview content:
- If content starts with `"<Name>: "`, use `<Name>` as the sender
- Look for known patterns like `"aaa-oncall <Name>: ..."`
- Bot messages: content contains `"Deploy failed"` / `"Deploy successful"` → sender = "Deploy bot"
- Fallback: leave sender as "(unresolved sender)" — the link still works, user clicks through

Alternative if you really need real sender: search for the message by content snippet via `teams_search` — the search results DO carry the real `conversationId` and `sender`. Only worth doing for a small number of items because search is rate-limited.

### 5. Filter out your own mentions

Drop any item where `sender.displayName == "Cisse, Amadou -ND"` (self-mentions from copy-paste of message threads).

Drop any item where `content` starts with "Daily PRs Workflow" (bot noise — adjust if you actually want these).

### 6. If 0 items remaining, exit silently

- Update `last-seen.iso` to now.
- Delete `auth-warning.flag` if it existed.
- Do NOT write a digest file, do NOT send a DM.
- Exit 0.

### 7. Format the digest

File name: `/Users/amadou/.claude/state/teams-catchup/{YYYY-MM-DD-HHMM}.md` (local time, e.g. `2026-07-01-1000.md`).

Format:

```markdown
# Teams catchup — {now-local-friendly} (since {last-seen-local-friendly})

{if auth-warning.flag existed:}
> ⚠️ Previous run at {flag-timestamp} couldn't authenticate. Auth is restored now.

## 📌 {N} mention(s) since {last-seen-short}

### {sender-display-name} — {channel-or-chat-label} — {when-local}

> {content, truncated to 300 chars, single line, backslash-escape newlines}

[Open in Teams]({messageLink})

---

{repeat for each item, newest first}
```

For `channel-or-chat-label`:
- If `channelName` and `teamName` present: `#{channelName} · {teamName}`
- If DM/group chat: `chat` (or the chat display name if resolvable)

Also copy the digest to `latest.md` (overwrite).

### 8. Send DM to self

Ensure `self-chat-id.txt` exists. If missing, resolve once and cache:

```
mcp__teams__teams_search(query='"Cisse, Amadou -ND" is:Chats', maxResults=5)
```

Look for a result where the `conversationId` starts with `48:` (notes-to-self) — that's your self-chat. Write it to `self-chat-id.txt`.

If resolution fails, log "DM skipped: could not find self-chat" as the first line of the digest file and continue (file is still written, cron doesn't crash).

Send the compact digest:

```
mcp__teams__teams_send_message(
  conversationId = <self-chat-id>,
  content = <compact digest, top 5 items with links>
)
```

Compact digest format (target < 1500 chars for readability):

```
📌 Teams catchup — {now-local-short}

{N} mention(s) since {last-seen-short}

1. {sender} in #{channel-or-chat} — {when-short}
   {content, truncated to 120 chars}
   {messageLink}

2. ...

{if N > 5:}
+ {N-5} more — see /Users/amadou/.claude/state/teams-catchup/latest.md
```

### 9. Update state

- Write current ISO to `last-seen.iso`.
- Delete `auth-warning.flag` if it existed.
- Exit 0.

## Failure modes to handle gracefully

- Auth expired → write flag, exit 0. Don't crash cron.
- `teams_get_activity` fails → retry once with backoff. If still failing, log to a `run-error.log` file in the state dir, exit 0.
- `teams_get_message` fails for a specific item → skip the enrichment (use the preview content), don't drop the item.
- DM send fails → note in digest file, continue. Don't crash.
- Zero items after filtering → silent exit (see step 6).

## Invocation

- **Interactive (this session or any Claude Code session)**: user says "run teams-catchup" or types `/teams-catchup`. Claude reads this SKILL.md and executes.
- **Headless (cron / launchd)**: shell command invokes `claude -p "run the teams-catchup skill"` with appropriate flags to allow all needed MCP tools without prompting.

The wrapper script `/Users/amadou/.claude/skills/teams-catchup/run-headless.sh` handles the headless invocation for launchd.

## Testing

To dry-run without writing state or sending DMs:

Run this skill and pass "--dry-run" as user context — Claude should print the digest that would have been written and describe the DM that would have been sent, but skip the file write, `last-seen.iso` update, and DM.

## Future improvements (not v0)

- Include plain DMs (needs a strategy: favourite chats you care about, or iterate recent conversations)
- Include thread replies to your posts (needs thread-root lookup per candidate)
- Rank by sender (Vlad/Jordan/Matt higher than random)
- Include GitHub PR mentions
- Include Jira mentions
- "Skip bots" list (currently hardcoded to "Daily PRs Workflow"; make configurable)
