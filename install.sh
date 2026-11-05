#!/bin/sh
# Install from a local clone with: sh install.sh [--dest DIRECTORY] [--no-link]
# Or: curl -fsSL https://raw.githubusercontent.com/aravind-n/looksmaxx/main/install.sh | sh
set -eu

NAME=looksmaxx
DEST="$HOME/.agents/skills/$NAME"
MAKE_LINK=true
STAGE=
BACKUP=
BACKUP_ROOT=

fail() { printf 'looksmaxx: %s\n' "$*" >&2; exit 1; }
usage() { printf 'Usage: sh install.sh [--dest DIRECTORY] [--no-link]\n'; }
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dest)
      [ "$#" -ge 2 ] && [ -n "$2" ] || fail '--dest requires a directory'
      DEST=$2
      shift 2
      ;;
    --no-link) MAKE_LINK=false; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; fail "unknown option: $1" ;;
  esac
done

# A neighboring manifest identifies a local clone only when $0 names an actual
# script file. With curl | sh, $0 names the shell, not a file in the current dir.
SOURCE=
case "$0" in
  */*|*.sh)
    if [ -f "$0" ] && [ ! -L "$0" ]; then
      SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd -P) || SCRIPT_DIR=
      if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/runtime-files.txt" ]; then
        SOURCE=$SCRIPT_DIR
      fi
    fi
    ;;
esac

case "$DEST" in /*) ;; *) DEST="$PWD/$DEST" ;; esac
# Strip trailing separators so a symlink cannot be hidden with a trailing slash.
while [ "$DEST" != / ] && [ "${DEST%/}" != "$DEST" ]; do DEST=${DEST%/}; done
case "$DEST" in /|*/.|*/..) fail 'destination must name a skill directory' ;; esac
[ ! -L "$DEST" ] || fail "destination is a symlink; leaving it unchanged: $DEST"
[ ! -e "$DEST" ] || [ -d "$DEST" ] || fail "destination is not a directory: $DEST"
PARENT=$(dirname -- "$DEST")
LEAF=$(basename -- "$DEST")
mkdir -p "$PARENT"
PARENT=$(CDPATH= cd -- "$PARENT" && pwd -P)
DEST="$PARENT/$LEAF"

cleanup() {
  EXIT_STATUS=$?
  trap - 0
  trap '' 1 2 3 15
  # A command can move the old bundle successfully and then fail or receive a
  # catchable signal. Restore it whenever publication left the canonical path
  # absent. SIGKILL and power loss cannot run portable shell cleanup.
  if [ -n "$BACKUP" ] && [ -d "$BACKUP" ] && [ ! -e "$DEST" ] && [ ! -L "$DEST" ]; then
    if mv "$BACKUP" "$DEST"; then
      printf 'restored previous installation: %s\n' "$DEST" >&2
    else
      printf 'could not restore previous installation; backup remains: %s\n' "$BACKUP" >&2
      EXIT_STATUS=1
    fi
  fi
  if [ -n "$BACKUP_ROOT" ] && [ -d "$BACKUP_ROOT" ]; then rmdir "$BACKUP_ROOT" 2>/dev/null || :; fi
  if [ -n "$STAGE" ] && [ -d "$STAGE" ]; then rm -rf -- "$STAGE"; fi
  exit "$EXIT_STATUS"
}
trap cleanup 0
trap 'exit 1' 1 2 3 15
STAGE=$(mktemp -d "$PARENT/.looksmaxx-stage.XXXXXX")
mkdir "$STAGE/bundle"
if [ -n "$SOURCE" ]; then
  cp "$SOURCE/runtime-files.txt" "$STAGE/runtime-files.txt"
else
  # Resolve the moving branch once so the manifest and files cannot come from
  # different revisions if main advances during acquisition.
  curl -fsSL -H 'Accept: application/vnd.github.sha' \
    "https://api.github.com/repos/aravind-n/$NAME/commits/main" -o "$STAGE/revision.txt"
  REVISION=$(cat "$STAGE/revision.txt")
  [ "${#REVISION}" -eq 40 ] || fail 'GitHub returned an invalid commit SHA'
  case "$REVISION" in *[!0-9a-fA-F]*) fail 'GitHub returned an invalid commit SHA' ;; esac
  BASE_URL="https://raw.githubusercontent.com/aravind-n/$NAME/$REVISION"
  curl -fsSL "$BASE_URL/runtime-files.txt" -o "$STAGE/runtime-files.txt"
fi

# Validate the entire manifest before using any path. Never allow traversal,
# absolute paths, shell metacharacters, or ambiguous dot/empty segments.
: > "$STAGE/validated-files.txt"
HAS_SKILL=false
CR=$(printf '\r')
while IFS= read -r FILE || [ -n "$FILE" ]; do
  FILE=${FILE%"$CR"}
  [ -n "$FILE" ] || continue
  case "$FILE" in
    *[!A-Za-z0-9._/-]*|/*|*/|*//*|.|..|./*|../*|*/./*|*/../*|*/.|*/..)
      fail "invalid runtime path: $FILE" ;;
  esac
  if grep -F -x -q -- "$FILE" "$STAGE/validated-files.txt"; then
    fail "duplicate runtime path: $FILE"
  fi
  printf '%s\n' "$FILE" >> "$STAGE/validated-files.txt"
  [ "$FILE" != SKILL.md ] || HAS_SKILL=true
done < "$STAGE/runtime-files.txt"
[ "$HAS_SKILL" = true ] || fail 'runtime manifest must include SKILL.md'

while IFS= read -r FILE; do
  mkdir -p "$(dirname -- "$STAGE/bundle/$FILE")"
  if [ -n "$SOURCE" ]; then
    [ -f "$SOURCE/$FILE" ] && [ ! -L "$SOURCE/$FILE" ] || fail "missing regular runtime file: $FILE"
    cp "$SOURCE/$FILE" "$STAGE/bundle/$FILE"
  else
    curl -fsSL "$BASE_URL/$FILE" -o "$STAGE/bundle/$FILE"
  fi
done < "$STAGE/validated-files.txt"

# All acquisition has succeeded. Preserve the previous real directory, then
# publish the staged bundle by renaming within the same filesystem.
[ ! -L "$DEST" ] || fail "destination became a symlink; leaving it unchanged: $DEST"
[ ! -e "$DEST" ] || [ -d "$DEST" ] || fail "destination is not a directory: $DEST"
if [ -d "$DEST" ]; then
  BACKUP_ROOT=$(mktemp -d "$PARENT/.looksmaxx-backup.XXXXXX")
  BACKUP="$BACKUP_ROOT/$LEAF"
  mv "$DEST" "$BACKUP"
  printf 'backup: %s\n' "$BACKUP"
fi
if ! mv "$STAGE/bundle" "$DEST"; then
  fail 'could not publish the staged installation'
fi
printf 'installed %s\n' "$DEST"

if [ "$MAKE_LINK" = true ] && [ -d "$HOME/.claude" ]; then
  LINK="$HOME/.claude/skills/$NAME"
  if ! mkdir -p "$HOME/.claude/skills"; then
    printf 'skipped Claude compatibility link: cannot create %s\n' "$HOME/.claude/skills" >&2
  elif [ -d "$LINK" ] && [ "$(CDPATH= cd -- "$LINK" && pwd -P)" = "$DEST" ]; then
    printf 'already linked %s\n' "$LINK"
  elif [ -e "$LINK" ] || [ -L "$LINK" ]; then
    printf 'skipped occupied Claude compatibility path: %s\n' "$LINK"
  elif ln -s "$DEST" "$LINK"; then
    printf 'linked %s -> %s\n' "$LINK" "$DEST"
  else
    printf 'skipped Claude compatibility link: could not create %s\n' "$LINK" >&2
  fi
fi
