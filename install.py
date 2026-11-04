#!/usr/bin/env python3
"""Install the design-language skill for any agent that reads ~/.agents/skills (Codex and others),
and for Claude Code via ~/.claude/skills. Works on macOS, Linux and Windows (home = %USERPROFILE%).

    python3 install.py
    curl -fsSL https://raw.githubusercontent.com/aravind-n/design-language/main/install.py | python3
"""
import shutil
import urllib.request
from pathlib import Path

NAME = "design-language"
RAW = f"https://raw.githubusercontent.com/aravind-n/{NAME}/main/SKILL.md"

# Use the SKILL.md next to this script when run from a clone, else download it.
here = Path(__file__).resolve().parent if "__file__" in globals() else None
local = here / "SKILL.md" if here else None
skill = local.read_text(encoding="utf-8") if local and local.exists() else urllib.request.urlopen(RAW).read().decode("utf-8")

agents = Path.home() / ".agents" / "skills" / NAME
agents.mkdir(parents=True, exist_ok=True)
(agents / "SKILL.md").write_text(skill, encoding="utf-8")
print(f"installed {agents}")

# Claude Code reads ~/.claude/skills. Link to the copy above, or copy where links are not allowed.
claude_home = Path.home() / ".claude"
if claude_home.exists():
    claude = claude_home / "skills" / NAME
    claude.parent.mkdir(parents=True, exist_ok=True)
    if claude.is_symlink() or claude.is_file():
        claude.unlink()
    elif claude.exists():
        shutil.rmtree(claude)
    try:
        claude.symlink_to(agents, target_is_directory=True)
        print(f"linked {claude} -> {agents}")
    except OSError:
        shutil.copytree(agents, claude)
        print(f"copied to {claude}")
