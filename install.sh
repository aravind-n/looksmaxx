#!/bin/sh
# Install the design-language skill into ~/.agents/skills (Codex and other agents)
# and link it into ~/.claude/skills (Claude Code).
#   curl -fsSL https://raw.githubusercontent.com/aravind-n/design-language/main/install.sh | sh
set -eu
NAME=design-language
URL="https://raw.githubusercontent.com/aravind-n/$NAME/main/SKILL.md"
DEST="$HOME/.agents/skills/$NAME"

mkdir -p "$DEST"
curl -fsSL "$URL" -o "$DEST/SKILL.md"
echo "installed $DEST"

if [ -d "$HOME/.claude" ]; then
  LINK="$HOME/.claude/skills/$NAME"
  mkdir -p "$HOME/.claude/skills"
  # Skip when the link already leads to the copy above, including when
  # ~/.claude/skills is itself a link to ~/.agents/skills.
  if [ -e "$LINK" ] && [ "$(cd "$LINK" && pwd -P)" = "$(cd "$DEST" && pwd -P)" ]; then
    echo "already linked $LINK"
  else
    rm -rf "$LINK"
    ln -s "$DEST" "$LINK"
    echo "linked $LINK -> $DEST"
  fi
fi
