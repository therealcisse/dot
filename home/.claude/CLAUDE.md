# Global Agent Instructions

## Search & Documentation Tools

**Searching files:**
- For plain lexical/regex pattern matching, use the built-in Grep tool (default behavior). Do NOT use grep, rg, or ripgrep via Bash.
- For semantic or hybrid searches, use `ck` via Bash:
  - **Semantic:** `ck --sem "error handling" src/` (search by meaning)
  - **Hybrid:** `ck --hybrid "connection timeout" src/` (combines lexical + semantic)
- NEVER use awk or sed to search files by pattern.

**Text processing:**
- awk and sed are permitted for text transformation, replacement, and positional extraction (e.g. line ranges)

**Documentation lookup:**
- Prefer `webfetch` on known authoritative URLs (e.g. GitHub repo, official docs site) over Exa search tools
- Use `exa_web_search_exa` or `exa_get_code_context_exa` only when you do not already have a specific URL to start from

## Communication Style
- Be concise and direct
- No unnecessary preamble or postamble
- One-word answers when appropriate
- Do not edit or write files unless explicitly asked to do so

## Security Rules — STRICTLY ENFORCED

### Forbidden commands (never run these or any equivalent)
- `env`, `printenv`, `set`, `export` (when used to display), `echo $VAR_NAME`
- `cat`, `less`, `head`, `tail`, `grep`, `awk`, `sed` on any file matching: `.env*`, `*credentials*`, `*secret*`, `*.pem`, `*.key`, `*token*`
- `docker inspect`, `ps eww`, `history`, `cat /proc/*/environ`
- Any Python/Ruby/Node one-liner that reads `os.environ` or equivalent
- Any command with `--debug` or `--verbose` flags that may dump env context

### General principles
- NEVER access, read, or print the VALUES of environment variables
- Referencing variable NAMES/keys is acceptable
- When commands require secrets, use placeholders like `<YOUR_SECRET>`
- If a task cannot be completed without reading a secret value, STOP and ask the user
- NEVER read files that commonly contain secrets (`.env`, `.env.*`, `credentials`, `*.key`, `*.pem`, AWS/GCP/Azure config files)

# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
