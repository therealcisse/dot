# Global Agent Instructions

## Search & Documentation Tools

**Searching files:**
- Never use grep, rg, or ripgrep to search files in the repository
- Never use awk or sed to search files by pattern
- Use the `ck` tool instead (semantic/hybrid code search)

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
