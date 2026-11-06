#!/bin/sh
set -eu

DRY_RUN=false
case "${1:-}" in
  --dry-run) DRY_RUN=true; shift ;;
  -h|--help) printf 'Usage: install.sh [--dry-run]\n'; exit 0 ;;
esac
[ "$#" -eq 0 ] || { printf 'Usage: sh install.sh [--dry-run]\n' >&2; exit 1; }

INSTALL_HOME=${HOME:?HOME is not set}
CLAUDE_ROOT=${CLAUDE_CONFIG_DIR:-$INSTALL_HOME/.claude}
CONFIG_ROOT=${XDG_CONFIG_HOME:-$INSTALL_HOME/.config}
SOURCE=
SCRIPT_FILE=false
case "$0" in
  */*|*.sh)
    if [ -f "$0" ]; then
      SCRIPT_FILE=true
      SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd -P)
      [ ! -f "$SCRIPT_DIR/runtime-files.txt" ] || SOURCE=$SCRIPT_DIR
    fi ;;
esac

fail() { printf 'looksmaxx: %s\n' "$*" >&2; exit 1; }
green() {
  if [ -t 1 ] && [ -z "${NO_COLOR+x}" ]; then printf '\033[32m%s\033[0m\n' "$*"
  else printf '%s\n' "$*"; fi
}

# curl | sh needs a separate input stream for the prompts.
if [ "$SCRIPT_FILE" = true ] || [ -t 0 ]; then exec 3<&0
elif ( : </dev/tty ) 2>/dev/null; then exec 3</dev/tty
else fail 'Open a terminal to run the installer.'; fi

DEFAULTS=
DETECTED=
probe() {
  probe_id=$1; probe_label=$2; probe_commands=$3; shift 3
  probe_found=false
  for probe_command in $probe_commands; do
    if command -v "$probe_command" >/dev/null 2>&1; then probe_found=true; break; fi
  done
  if [ "$probe_found" = false ]; then
    for probe_path do
      if [ -e "$probe_path" ]; then probe_found=true; break; fi
    done
  fi
  if [ "$probe_found" = true ]; then
    DETECTED="${DETECTED}${DETECTED:+, }$probe_label"
    case " $DEFAULTS " in *" $probe_id "*) ;; *) DEFAULTS="${DEFAULTS}${DEFAULTS:+ }$probe_id" ;; esac
  fi
}

green 'Detecting agents'
probe 1 Codex codex "${CODEX_HOME:-$INSTALL_HOME/.codex}"
probe 1 Pi pi "$INSTALL_HOME/.pi/agent"
probe 1 Cursor 'cursor cursor-agent' "$INSTALL_HOME/.cursor" /Applications/Cursor.app "$INSTALL_HOME/Applications/Cursor.app" "$CONFIG_ROOT/Cursor" "$INSTALL_HOME/AppData/Roaming/Cursor"
probe 1 'GitHub Copilot' copilot "$INSTALL_HOME/.copilot" "$INSTALL_HOME"/.vscode/extensions/github.copilot-*
probe 1 'Gemini CLI' gemini "$INSTALL_HOME/.gemini/settings.json" "$INSTALL_HOME/.gemini/oauth_creds.json" "$INSTALL_HOME/.gemini/skills"
probe 1 OpenCode opencode "$CONFIG_ROOT/opencode"
probe 1 Amp amp "$CONFIG_ROOT/amp"
probe 1 'Kilo Code' 'kilo kilocode' "$INSTALL_HOME/.kilo" "$INSTALL_HOME/.kilocode" "$INSTALL_HOME"/.vscode/extensions/kilocode.kilo-code-*
probe 2 'Claude Code' claude "$CLAUDE_ROOT"
probe 3 Antigravity 'agy antigravity' "$INSTALL_HOME/.gemini/antigravity" "$INSTALL_HOME/.gemini/antigravity-cli" "$INSTALL_HOME/.gemini/config" /Applications/Antigravity.app "$INSTALL_HOME/Applications/Antigravity.app"
probe 4 Cline cline "$INSTALL_HOME/.cline" "$INSTALL_HOME"/.vscode/extensions/saoudrizwan.claude-dev-*
probe 5 Kiro 'kiro kiro-cli' "$INSTALL_HOME/.kiro" /Applications/Kiro.app "$INSTALL_HOME/Applications/Kiro.app"
probe 6 Windsurf windsurf "$INSTALL_HOME/.codeium/windsurf" /Applications/Windsurf.app "$INSTALL_HOME/Applications/Windsurf.app"
printf 'Detected: %s\n\n' "${DETECTED:-none}"

target_for() {
  case "$1" in
    1) TARGET_NAME=Universal; TARGET_ROOT=$INSTALL_HOME/.agents/skills ;;
    2) TARGET_NAME='Claude Code'; TARGET_ROOT=$CLAUDE_ROOT/skills ;;
    3) TARGET_NAME=Antigravity; TARGET_ROOT=$INSTALL_HOME/.gemini/config/skills ;;
    4) TARGET_NAME=Cline; TARGET_ROOT=$INSTALL_HOME/.cline/skills ;;
    5) TARGET_NAME=Kiro; TARGET_ROOT=$INSTALL_HOME/.kiro/skills ;;
    6) TARGET_NAME=Windsurf; TARGET_ROOT=$INSTALL_HOME/.codeium/windsurf/skills ;;
  esac
  TARGET=$TARGET_ROOT/looksmaxx
}

printf 'Pick where to install looksmaxx:\n'
AVAILABLE=
for option in 1 2 3 4 5 6; do
  case " $DEFAULTS " in *" $option "*) ;; *) [ "$option" = 1 ] || continue ;; esac
  AVAILABLE="${AVAILABLE}${AVAILABLE:+ }$option"
  target_for "$option"
  case " $DEFAULTS " in *" $option "*) mark=x ;; *) mark=' ' ;; esac
  printf '  [%s] %s) %s\n' "$mark" "$option" "$TARGET_NAME"
  if [ "$option" = 1 ]; then
    printf '         Codex, Pi, Cursor, Copilot, Gemini CLI, OpenCode, Amp, Kilo Code\n'
  fi
done
printf '\nOther agents: copy SKILL.md and references/ into their skills folder.\n'
set -f
while :; do
  printf '\nChoose numbers, separated by spaces%s: ' "${DEFAULTS:+ [$DEFAULTS]}"
  IFS= read -r CHOICES <&3 || { printf '\nCancelled.\n'; exit 0; }
  CHOICES=${CHOICES:-$DEFAULTS}
  SELECTED=
  VALID=true
  for option in $CHOICES; do
    case " $AVAILABLE " in *" $option "*) ;; *) VALID=false; break ;; esac
    case " $SELECTED " in *" $option "*) ;; *) SELECTED="${SELECTED}${SELECTED:+ }$option" ;; esac
  done
  if [ "$VALID" = true ] && [ -n "$SELECTED" ]; then break; fi
  printf 'Choose at least one of the options shown.\n'
done

NAMES=
for option in $SELECTED; do
  target_for "$option"
  NAMES="${NAMES}${NAMES:+, }$TARGET_NAME"
done
if [ "$DRY_RUN" = true ]; then printf '\nDry run: no files will be changed.\n'; fi
while :; do
  printf '\nInstall looksmaxx for %s? (y/n): ' "$NAMES"
  IFS= read -r ANSWER <&3 || ANSWER=n
  case "$ANSWER" in
    y|Y|yes|YES|Yes) break ;;
    n|N|no|NO|No|'') printf 'Cancelled.\n'; exit 0 ;;
    *) printf 'Enter y or n.\n' ;;
  esac
done

fetch_source() {
  [ -z "$SOURCE" ] || return 0
  command -v curl >/dev/null 2>&1 || fail 'curl is required.'
  SOURCE=$(mktemp -d "${TMPDIR:-/tmp}/looksmaxx.XXXXXX")
  trap 'rm -rf -- "$SOURCE"' 0
  BASE_URL=https://raw.githubusercontent.com/aravind-n/looksmaxx/main
  FILES=$(curl -fsSL "$BASE_URL/runtime-files.txt")
  [ -n "$FILES" ] || fail 'Could not read the skill files.'
  CR=$(printf '\r')
  for FILE in $FILES; do
    FILE=${FILE%"$CR"}
    mkdir -p "$(dirname -- "$SOURCE/$FILE")"
    curl -fsSL "$BASE_URL/$FILE" -o "$SOURCE/$FILE"
  done
}

SHARED=
case " $SELECTED " in *" 1 "*) SHARED=$INSTALL_HOME/.agents/skills/looksmaxx ;; esac

# Install Universal first, regardless of the order the user selected.
for option in 1 2 3 4 5 6; do
  case " $SELECTED " in *" $option "*) ;; *) continue ;; esac
  target_for "$option"
  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    printf 'Skipped %s (already exists)\n' "$TARGET_NAME"
  elif [ -n "$SHARED" ] && [ "$option" != 1 ]; then
    if [ "$DRY_RUN" = true ]; then
      printf 'Would link %s -> %s\n' "$TARGET_NAME" "$SHARED"
    else
      [ -d "$SHARED" ] || fail "Universal skill directory not found: $SHARED"
      mkdir -p "$TARGET_ROOT"
      ln -s "$SHARED" "$TARGET"
      green "Linked $TARGET_NAME"
    fi
  elif [ "$DRY_RUN" = true ]; then
    printf 'Would install %s -> %s\n' "$TARGET_NAME" "$TARGET"
  else
    fetch_source
    mkdir -p "$TARGET"
    cp -R "$SOURCE/SKILL.md" "$SOURCE/references" "$TARGET/"
    green "Installed $TARGET_NAME"
  fi
done
