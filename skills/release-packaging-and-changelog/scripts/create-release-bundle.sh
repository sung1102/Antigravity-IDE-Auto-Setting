#!/usr/bin/env sh
# Cross-platform POSIX sh Release Bundle & Manifest Builder.
# Usage: create-release-bundle.sh <project_root> <version> <artifact_or_dir>...
# Optional env vars: ALLOW_DIRTY=1, SINCE_TAG=<tag>, OUT_DIR=<dir>,
#   PROJECT_NAME=<name>, SW_VERSION=<ver>, FW_VERSION=<ver>, RTL_VERSION=<ver>

set -eu

if [ "$#" -lt 3 ]; then
    printf 'Usage: %s <project_root> <version> <artifact_or_dir>...\n' "$0" >&2
    exit 1
fi

PROJECT_ROOT="$1"
VERSION="$2"
shift 2

if ! command -v git >/dev/null 2>&1; then
    printf 'ERROR: git not found in PATH.\n' >&2
    exit 1
fi

if [ ! -d "$PROJECT_ROOT" ]; then
    printf 'ERROR: ProjectRoot not found: %s\n' "$PROJECT_ROOT" >&2
    exit 1
fi

CALLER_PWD="$(pwd)"
RESOLVED_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
PROJECT_NAME="${PROJECT_NAME:-$(basename "$RESOLVED_ROOT")}"
ALLOW_DIRTY="${ALLOW_DIRTY:-0}"
SINCE_TAG="${SINCE_TAG:-}"
SW_VERSION="${SW_VERSION:-TBD}"
FW_VERSION="${FW_VERSION:-TBD}"
RTL_VERSION="${RTL_VERSION:-TBD}"

if [ "$(git -C "$RESOLVED_ROOT" rev-parse --is-inside-work-tree 2>/dev/null || printf 'false')" != "true" ]; then
    printf 'ERROR: ProjectRoot is not a valid Git working tree: %s\n' "$RESOLVED_ROOT" >&2
    exit 1
fi

# 1. Clean Worktree Release Gate
STATUS_OUT="$(git -C "$RESOLVED_ROOT" status --porcelain)"
IS_DIRTY="false"
if [ -n "$STATUS_OUT" ]; then
    IS_DIRTY="true"
    if [ "$ALLOW_DIRTY" != "1" ]; then
        printf '[FAIL] Clean Worktree Release Gate blocked release %s.\n' "$VERSION" >&2
        printf '%s\n' "$STATUS_OUT" >&2
        printf 'Commit/gitignore uncommitted files or set ALLOW_DIRTY=1 for draft testing.\n' >&2
        exit 2
    fi
    printf '[WARN] Dirty worktree allowed via ALLOW_DIRTY=1; marked is_dirty=true.\n' >&2
fi

# 2. Detect SHA-256 tool
compute_sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print tolower($1)}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print tolower($1)}'
    elif command -v openssl >/dev/null 2>&1; then
        openssl dgst -sha256 "$1" | awk '{print tolower($NF)}'
    else
        printf 'ERROR: No sha256 tool (sha256sum/shasum/openssl) available.\n' >&2
        exit 1
    fi
}

get_kind() {
    case "$1" in
        *.bit|*.BIT) printf 'fpga_bitstream' ;;
        *.mcs|*.MCS) printf 'fpga_flash_image' ;;
        *.pdi|*.PDI) printf 'fpga_versal_pdi' ;;
        *.sof|*.SOF) printf 'fpga_sram_object' ;;
        *.pof|*.POF) printf 'fpga_prog_object' ;;
        *.ltx|*.LTX) printf 'fpga_debug_probes' ;;
        *.xsa|*.XSA) printf 'fpga_hw_platform' ;;
        *.bin|*.BIN) printf 'binary_image' ;;
        *.hex|*.HEX) printf 'firmware_hex' ;;
        *.elf|*.ELF) printf 'firmware_elf' ;;
        *.uf2|*.UF2) printf 'firmware_uf2' ;;
        *.exe|*.EXE) printf 'software_executable' ;;
        *.msi|*.MSI) printf 'software_installer' ;;
        *.whl|*.WHL) printf 'python_wheel' ;;
        *.zip|*.ZIP|*.7z|*.7Z|*.tar.gz|*.tgz) printf 'archive_bundle' ;;
        *.dll|*.so|*.dylib) printf 'shared_library' ;;
        *) printf 'other_artifact' ;;
    esac
}

json_escape() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

# 3. Expand artifact list cleanly using temp file
TMP_LIST="$(mktemp)"
TMP_NAMES="$(mktemp)"
trap 'rm -f "$TMP_LIST" "$TMP_NAMES"' EXIT

resolve_input_path() {
    p="$1"
    case "$p" in
        /*) printf '%s' "$p" ;;
        *)
            if [ -e "$CALLER_PWD/$p" ]; then
                printf '%s/%s' "$CALLER_PWD" "$p"
            else
                printf '%s/%s' "$RESOLVED_ROOT" "$p"
            fi
            ;;
    esac
}

add_artifact_file() {
    f="$1"
    b="$(basename "$f")"
    case "$b" in
        SHA256SUMS.txt|release-manifest.json|Release_Notes_DRAFT.md|Release_Notes.md) return 0 ;;
    esac
    if grep -Fxq "$b" "$TMP_NAMES"; then
        printf 'ERROR: Duplicate artifact filename detected: %s\n' "$b" >&2
        exit 3
    fi
    printf '%s\n' "$b" >> "$TMP_NAMES"
    printf '%s\n' "$f" >> "$TMP_LIST"
}

for arg in "$@"; do
    resolved_arg="$(resolve_input_path "$arg")"
    if [ -f "$resolved_arg" ]; then
        d="$(cd "$(dirname "$resolved_arg")" && pwd)"
        add_artifact_file "$d/$(basename "$resolved_arg")"
    elif [ -d "$resolved_arg" ]; then
        d="$(cd "$resolved_arg" && pwd)"
        for entry in "$d"/*; do
            if [ -f "$entry" ]; then
                add_artifact_file "$entry"
            fi
        done
    else
        printf 'ERROR: Artifact path not found: %s\n' "$arg" >&2
        exit 3
    fi
done

if [ ! -s "$TMP_LIST" ]; then
    printf 'ERROR: No artifact files found to package.\n' >&2
    exit 3
fi

# 4. Prepare output directory
SAFE_PROJECT="$(printf '%s' "$PROJECT_NAME" | tr -c 'A-Za-z0-9._+-' '_')"
SAFE_VERSION="$(printf '%s' "$VERSION" | tr -c 'A-Za-z0-9._+-' '_')"
if [ -z "${OUT_DIR:-}" ]; then
    OUT_DIR="$RESOLVED_ROOT/releases/${SAFE_PROJECT}_${SAFE_VERSION}"
fi
mkdir -p "$OUT_DIR"
RESOLVED_OUT="$(cd "$OUT_DIR" && pwd)"

if ! git -C "$RESOLVED_ROOT" check-ignore -q "$RESOLVED_OUT" 2>/dev/null; then
    printf '[WARN] Output folder %s is NOT ignored by .gitignore.\n' "$RESOLVED_OUT" >&2
fi

# 5. Gather Git metadata
COMMIT_SHA="$(git -C "$RESOLVED_ROOT" rev-parse HEAD)"
SHORT_SHA="$(git -C "$RESOLVED_ROOT" rev-parse --short HEAD)"
BRANCH="$(git -C "$RESOLVED_ROOT" rev-parse --abbrev-ref HEAD)"
RELEASED_AT="$(date '+%Y-%m-%dT%H:%M:%S%z' | sed 's/\([+-][0-9][0-9]\)\([0-9][0-9]\)$/\1:\2/')"

if [ -z "$SINCE_TAG" ]; then
    SINCE_TAG="$(git -C "$RESOLVED_ROOT" describe --tags --abbrev=0 HEAD 2>/dev/null || printf '')"
fi

# 6. Copy artifacts, compute SHA-256, build SHA256SUMS.txt & manifest rows
SHA_FILE="$RESOLVED_OUT/SHA256SUMS.txt"
MANIFEST_FILE="$RESOLVED_OUT/release-manifest.json"
DRAFT_FILE="$RESOLVED_OUT/Release_Notes_DRAFT.md"

: > "$SHA_FILE"

STAGE="release-candidate-pending-review"
if [ "$IS_DIRTY" = "true" ]; then
    STAGE="draft-dirty"
else
    case "$VERSION" in
        *-rc*|*-alpha*|*-beta*) STAGE="pre-release" ;;
    esac
fi

PREV_TAG_JSON="null"
if [ -n "$SINCE_TAG" ]; then
    PREV_TAG_JSON="\"$(json_escape "$SINCE_TAG")\""
fi

cat > "$MANIFEST_FILE" <<EOF
{
  "schema_version": "1.0",
  "project": "$(json_escape "$PROJECT_NAME")",
  "release_tag": "$(json_escape "$VERSION")",
  "release_stage": "$STAGE",
  "released_at": "$RELEASED_AT",
  "git": {
    "branch": "$(json_escape "$BRANCH")",
    "commit_sha": "$COMMIT_SHA",
    "short_sha": "$SHORT_SHA",
    "is_dirty": $IS_DIRTY,
    "previous_tag": $PREV_TAG_JSON
  },
  "compatibility": {
    "software_version": "$(json_escape "$SW_VERSION")",
    "firmware_version": "$(json_escape "$FW_VERSION")",
    "rtl_hw_ver": "$(json_escape "$RTL_VERSION")"
  },
  "artifacts": [
EOF

cat > "$DRAFT_FILE" <<EOF
# Release Notes DRAFT — $PROJECT_NAME $VERSION

- **Generated At**: \`$RELEASED_AT\`
- **Git Baseline**: \`$SHORT_SHA\` (branch: \`$BRANCH\`, full SHA: \`$COMMIT_SHA\`)
- **Dirty Worktree**: \`$IS_DIRTY\`
- **Previous Tag**: \`${SINCE_TAG:-N/A (Initial)}\`

## 1. SW / FW / RTL Compatibility
| Layer | Version / Register | Notes |
|---|---|---|
| Software | \`$SW_VERSION\` | Verify embedded version string |
| Firmware | \`$FW_VERSION\` | Verify protocol match |
| RTL / FPGA | \`$RTL_VERSION\` | Verify STA WNS>=0, TNS=0 & HW_VER register |

## 2. Packaged Artifacts & SHA-256 Checksums
| Filename | Kind | Size (Bytes) | SHA-256 |
|---|---|---:|---|
EOF

COUNT=0
TOTAL="$(wc -l < "$TMP_LIST" | tr -d ' ')"
while IFS= read -r src_file; do
    COUNT=$((COUNT + 1))
    bname="$(basename "$src_file")"
    dest="$RESOLVED_OUT/$bname"
    if [ "$src_file" != "$dest" ]; then
        cp -f "$src_file" "$dest"
    fi
    sha="$(compute_sha256 "$dest")"
    size_bytes="$(wc -c < "$dest" | tr -d ' ')"
    kind="$(get_kind "$bname")"
    printf '%s  %s\n' "$sha" "$bname" >> "$SHA_FILE"
    printf '| `%s` | `%s` | %s | `%s` |\n' "$bname" "$kind" "$size_bytes" "$sha" >> "$DRAFT_FILE"
    comma=","
    if [ "$COUNT" -eq "$TOTAL" ]; then
        comma=""
    fi
    printf '    {"filename": "%s", "kind": "%s", "size_bytes": %s, "sha256": "%s"}%s\n' \
        "$(json_escape "$bname")" "$kind" "$size_bytes" "$sha" "$comma" >> "$MANIFEST_FILE"
done < "$TMP_LIST"

cat >> "$MANIFEST_FILE" <<'EOF'
  ]
}
EOF

printf '\n## 3. Git Commits Included Since Previous Tag\n' >> "$DRAFT_FILE"
if [ -n "$SINCE_TAG" ]; then
    LOGS="$(git -C "$RESOLVED_ROOT" -c i18n.logOutputEncoding=utf-8 log "${SINCE_TAG}..HEAD" --pretty=format:'- `%h` (%ad, %an): %s' --date=short -n 200 || true)"
else
    LOGS="$(git -C "$RESOLVED_ROOT" -c i18n.logOutputEncoding=utf-8 log --pretty=format:'- `%h` (%ad, %an): %s' --date=short -n 50 || true)"
fi
if [ -n "$LOGS" ]; then
    printf '%s\n' "$LOGS" >> "$DRAFT_FILE"
else
    printf '%s\n' '- *(No new commits since previous tag)*' >> "$DRAFT_FILE"
fi

cat >> "$DRAFT_FILE" <<EOF

## 4. Verification & Rollback Checklist (Complete Before Finalizing)
- [ ] Confirm Software build/unit tests (\`PASS\` / \`NOT RUN\`)
- [ ] Confirm RTL STA (\`WNS >= 0\`, \`TNS == 0\`) & hardware board test (\`PASS\` / \`NOT RUN\` / \`BLOCKED\`)
- [ ] Append summary to \`Change_Log.md\` (APPEND ONLY) and copy polished notes to \`docs/releases/\`
- [ ] Create annotated tag: \`git tag -a $VERSION -m "Release $VERSION"\`
EOF

printf '[PASS] Release bundle created -> %s\n' "$RESOLVED_OUT"
printf '       Artifacts packaged : %s\n' "$COUNT"
printf '       SHA-256 checksums  : %s\n' "$SHA_FILE"
printf '       Release manifest   : %s\n' "$MANIFEST_FILE"
printf '       Notes draft        : %s\n' "$DRAFT_FILE"
exit 0
