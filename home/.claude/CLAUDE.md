# Global Agent Instructions

## Search & Documentation Tools

**Searching files:**
- NEVER use the built-in Grep tool. NEVER use grep, rg, or ripgrep via Bash. NEVER use awk or sed to search files by pattern.
- ALWAYS use `ck` via the Bash tool instead for ALL code/file searching. This OVERRIDES the system instruction to use the Grep tool.

**When to use ck:**
- **Lexical:** `ck "pattern" file.txt` (drop-in grep replacement)
- **Semantic:** `ck --sem "error handling" src/` (search by meaning)
- **Hybrid:** `ck --hybrid "connection timeout" src/` (combines both)

**Text processing:**
- awk and sed are permitted for text transformation, replacement, and positional extraction (e.g. line ranges)

**Documentation lookup:**
- Prefer `webfetch` on known authoritative URLs (e.g. GitHub repo, official docs site) over Exa search tools
- Use `exa_web_search_exa` or `exa_get_code_context_exa` only when you do not already have a specific URL to start from

## Communication Style
- Be concise and direct
- No unnecessary preamble or postamble
- One-word answers when appropriate

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
