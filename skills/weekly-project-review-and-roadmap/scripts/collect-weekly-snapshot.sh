#!/usr/bin/env sh
# Read-only weekly project snapshot collector for weekly-project-review-and-roadmap (macOS / Linux)
set -eu

PROJECT_ROOT="${1:-.}"
DAYS="${2:-7}"
MAX_FINDINGS="${3:-40}"

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

echo "# Weekly Project Snapshot"
echo "- Generated At: $(date '+%Y-%m-%d %H:%M:%S')"
echo "- Project Root: $PROJECT_ROOT"
echo "- Window: Last $DAYS day(s)"
echo ""

if [ -d "$PROJECT_ROOT/.git" ]; then
  echo "## 1. Git Status & Branches"
  echo "- HEAD: $(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
  echo '```text'
  git -C "$PROJECT_ROOT" status -sb
  echo '```'
  BACKUPS="$(git -C "$PROJECT_ROOT" branch --list 'backup/*' | sed 's/^[ *]*//' | paste -sd ', ' - || true)"
  echo "- Backup Branches: ${BACKUPS:-None}"
  echo ""

  echo "## 2. Commits in Last $DAYS Day(s)"
  LOGS="$(git -C "$PROJECT_ROOT" log --since="$DAYS days ago" --oneline --no-decorate || true)"
  if [ -z "$LOGS" ]; then
    echo "- No commits in the last $DAYS day(s)."
  else
    echo '```text'
    printf '%s\n' "$LOGS"
    echo '```'
    echo "### Most Frequently Modified Files (Last $DAYS Day(s))"
    git -C "$PROJECT_ROOT" log --since="$DAYS days ago" --name-only --pretty=format: \
      | grep -v '^$' | sort | uniq -c | sort -rn | head -n 15 \
      | awk '{printf "- (%sx) %s\n", $1, $2}'
  fi
  echo ""
else
  echo "## 1. Git Status"
  echo "- [WARN] Not a Git repository."
  echo ""
fi

echo "## 3. Governance, Matrix & Feature Map Status"
if [ -f "$PROJECT_ROOT/Change_Log.md" ]; then
  echo "### Change_Log.md (Latest 5 Entries)"
  grep '^## \[' "$PROJECT_ROOT/Change_Log.md" | tail -n 5 | sed 's/^/- /' || true
else
  echo "- Change_Log.md: [MISSING]"
fi

if [ -f "$PROJECT_ROOT/VerificationCoverageMatrix.md" ]; then
  echo "### VerificationCoverageMatrix.md Non-PASS Items"
  grep -E '^\|.*\b(FAIL|BLOCKED|NOT RUN)\b' "$PROJECT_ROOT/VerificationCoverageMatrix.md" || echo "- All recorded items are PASS."
else
  echo "- VerificationCoverageMatrix.md: [MISSING]"
fi

if [ -f "$PROJECT_ROOT/docs/Feature_Map.md" ]; then
  echo "### docs/Feature_Map.md: Present"
  grep -E '核對日期|上次巡檢|Drift' "$PROJECT_ROOT/docs/Feature_Map.md" | head -n 3 | sed 's/^/- /' || true
else
  echo "- docs/Feature_Map.md: [MISSING]"
fi
echo ""

echo "## 4. Detected Verification Levers"
FOUND_LEVER=0
if [ -d "$PROJECT_ROOT/.agents/skills" ]; then
  for d in "$PROJECT_ROOT/.agents/skills"/verify-*; do
    if [ -d "$d" ]; then
      echo "- .agents/skills/$(basename "$d")/SKILL.md"
      FOUND_LEVER=1
    fi
  done
fi
for c in scripts/verify-repo.ps1 scripts/verify.ps1 scripts/verify.sh Makefile; do
  if [ -f "$PROJECT_ROOT/$c" ]; then
    echo "- $c"
    FOUND_LEVER=1
  fi
done
[ "$FOUND_LEVER" -eq 0 ] && echo "- [NONE DETECTED] Suggest creating verification lever via verification-harness-builder."
echo ""

echo "## 5. Technical-Debt Markers (TODO / FIXME / HACK / DEPRECATED)"
if [ -d "$PROJECT_ROOT/.git" ]; then
  git -C "$PROJECT_ROOT" grep -nE '\b(TODO|FIXME|HACK|DEPRECATED)\b' -- ':!**/collect-weekly-snapshot*' ':!**/weekly-project-review-and-roadmap/*' ':!Change_Log.md' \
    | head -n "$MAX_FINDINGS" | sed 's/^/  - /' || echo "- None found."
else
  echo "- Skipped (not a Git repository)."
fi
