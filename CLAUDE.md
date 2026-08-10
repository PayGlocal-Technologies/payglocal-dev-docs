# CLAUDE.md — project-level instructions for AI agents

## Security: never read secrets

**Never read, echo, or inspect the contents of:**
- `.env`, `.env.*`, `*.env` files
- Unfiltered `env` / `printenv` / `set` / `export` output
- Individual env var values (e.g. `echo $TOKEN`) — not even for verification
- Any file the user identifies as holding secrets, tokens, or credentials

**Why:** These contain API tokens and credentials. Reading them pulls secrets into the agent's context, where they can leak through tool logs, summaries, or echoed commands.

**How to apply:**
- If a task needs a secret, ask the user to run the sensitive command themselves.
- If a script needs an env var, write it so the script reads the var at runtime — don't pre-read it.
- For "is this set?" checks, give the user a masked command to run (e.g. `env | grep ^PREFIX_ | sed 's/=.*/=****/'`).
- This rule takes priority over auto-mode autonomy. Pause if necessary.

This mirrors and reinforces the user-global `~/.claude/CLAUDE.md` and `AGENTS.md §0`.

---

## Repo-specific guidance

For contribution conventions, file layout, MDX rules, and verification steps, read `AGENTS.md`. Do not duplicate that guidance here.
