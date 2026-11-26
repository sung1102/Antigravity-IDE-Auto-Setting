#!/usr/bin/env sh
# Non-destructive mount & V1->V2 upgrade tool for Antigravity-IDE-Auto-Setting (macOS / Linux)
set -eu

TARGET_DIR="${HOME}/.gemini/config"
REPO_URL="https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git"
BRANCH="main"
BACKUP_ON_MODIFY=0
REPO_ARG_SET=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    -t|--target)
      TARGET_DIR="$2"
      shift 2
      ;;
    -r|--repo)
      REPO_URL="$2"
      REPO_ARG_SET=1
      shift 2
      ;;
    -b|--branch)
      BRANCH="$2"
      shift 2
      ;;
    --backup-on-local-modify)
      BACKUP_ON_MODIFY=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [-t|--target DIR] [-r|--repo URL] [-b|--branch BRANCH] [--backup-on-local-modify]"
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "[ERROR] git CLI not found in PATH." >&2
  exit 1
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
PARENT_DIR="$(dirname "$TARGET_DIR")"
MODE_LABEL=""

if [ ! -d "$TARGET_DIR" ]; then
  MODE_LABEL="Fresh Install"
  mkdir -p "$PARENT_DIR"
  echo "[INFO] Mode: $MODE_LABEL -> Cloning $REPO_URL ($BRANCH) into $TARGET_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR"
elif [ ! -d "$TARGET_DIR/.git" ]; then
  MODE_LABEL="In-Place Non-Destructive Mount"
  echo "[INFO] Mode: $MODE_LABEL -> Preserving local IDE files & custom skills in $TARGET_DIR"
  git -C "$TARGET_DIR" init
  if git -C "$TARGET_DIR" remote get-url origin >/dev/null 2>&1; then
    git -C "$TARGET_DIR" remote set-url origin "$REPO_URL"
  else
    git -C "$TARGET_DIR" remote add origin "$REPO_URL"
  fi
  git -C "$TARGET_DIR" fetch origin "$BRANCH"

  BACKUP_DIR="${PARENT_DIR}/backup_pre_mount_${TIMESTAMP}"
  BACKED_COUNT=0
  while IFS= read -r rel; do
    [ -z "$rel" ] && continue
    if [ -f "$TARGET_DIR/$rel" ]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      cp -p "$TARGET_DIR/$rel" "$BACKUP_DIR/$rel"
      BACKED_COUNT=$((BACKED_COUNT + 1))
    fi
  done <<EOF
$(git -C "$TARGET_DIR" -c core.quotepath=false ls-tree -r --name-only "origin/$BRANCH")
EOF

  if [ "$BACKED_COUNT" -gt 0 ]; then
    echo "[BACKUP] Backed up $BACKED_COUNT colliding tracked file(s) to $BACKUP_DIR"
  fi

  git -C "$TARGET_DIR" checkout -f -B "$BRANCH" "origin/$BRANCH"
  git -C "$TARGET_DIR" branch --set-upstream-to="origin/$BRANCH" "$BRANCH"
else
  MODE_LABEL="Git Fast-Forward Upgrade"
  REMOTE_TARGET="origin"
  if [ "$REPO_ARG_SET" -eq 1 ]; then
    REMOTE_TARGET="$REPO_URL"
  else
    if ! git -C "$TARGET_DIR" remote get-url origin >/dev/null 2>&1; then
      git -C "$TARGET_DIR" remote add origin "$REPO_URL"
    fi
  fi

  DIRTY_TRACKED="$(git -C "$TARGET_DIR" -c core.quotepath=false status --porcelain --untracked-files=no)"
  if [ -n "$DIRTY_TRACKED" ]; then
    if [ "$BACKUP_ON_MODIFY" -ne 1 ]; then
      echo "[ERROR] Tracked governance files have local modifications:" >&2
      printf '%s\n' "$DIRTY_TRACKED" >&2
      echo "Re-run with --backup-on-local-modify to back up modified tracked files before upgrading." >&2
      exit 2
    fi
    BACKUP_EDIT_DIR="${PARENT_DIR}/backup_local_edits_${TIMESTAMP}"
    for mp in $(git -C "$TARGET_DIR" -c core.quotepath=false diff --name-only; git -C "$TARGET_DIR" -c core.quotepath=false diff --cached --name-only); do
      [ -z "$mp" ] && continue
      if [ -f "$TARGET_DIR/$mp" ]; then
        mkdir -p "$BACKUP_EDIT_DIR/$(dirname "$mp")"
        cp -p "$TARGET_DIR/$mp" "$BACKUP_EDIT_DIR/$mp"
      fi
    done
    echo "[BACKUP] Saved local tracked modifications to $BACKUP_EDIT_DIR"
    git -C "$TARGET_DIR" reset --hard HEAD
  fi

  echo "[INFO] Mode: $MODE_LABEL -> Fetching $BRANCH from $REMOTE_TARGET"
  git -C "$TARGET_DIR" fetch "$REMOTE_TARGET" "$BRANCH"
  git -C "$TARGET_DIR" checkout "$BRANCH"
  git -C "$TARGET_DIR" merge --ff-only FETCH_HEAD
fi

git -C "$TARGET_DIR" config core.hooksPath .githooks
HEAD_SHA="$(git -C "$TARGET_DIR" rev-parse --short HEAD)"
echo "[PASS] Synced ($MODE_LABEL) at commit $HEAD_SHA -> $TARGET_DIR"
echo "[INFO] Untracked personal skills, rules, mcp_config.json, plugins, and projects remain untouched."

if command -v pwsh >/dev/null 2>&1 && [ -f "$TARGET_DIR/scripts/verify-repo.ps1" ]; then
  pwsh -File "$TARGET_DIR/scripts/verify-repo.ps1" -RepoRoot "$TARGET_DIR" -TrackedOnly
elif [ ! -f "$TARGET_DIR/rules/engineering-governance.md" ] || [ ! -d "$TARGET_DIR/skills/engineering-review-orchestrator" ]; then
  echo "[ERROR] Expected core governance files missing after sync!" >&2
  exit 1
fi
