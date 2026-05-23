#!/bin/bash
# =============================================================================
# package_squidguard.sh - Build a SquidGuard-compatible tarball.
#
# Produces:
#   exports/squidguard/mavablacklist.tar.gz        (consumed by SquidGuard)
#   exports/squidguard/mavablacklist.tar.gz.sha256 (integrity check)
#
# Structure inside the tarball matches the SquidGuard "Blacklist Update"
# expectation (same convention as Shalla / URLBlacklist):
#
#   mavablacklist/
#     <category>/
#       domains
#       urls
#     <group>/<category>/
#       domains
#       urls
#
# Top-level directory name MUST equal the value SquidGuard uses as `dbhome`
# basename. Keeping `mavablacklist` preserves backwards compatibility with
# existing pfSense installs that already point to mava.com.co/pfsense/mavablacklist.gz.
#
# Runs locally and on the GitHub Actions runner. Zero deps beyond coreutils + tar.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BL_DIR="$REPO_DIR/ListFilter-Squid/BL"
OUT_DIR="$REPO_DIR/exports/squidguard"
STAGE_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGE_DIR"' EXIT

PKG_NAME="mavablacklist"
MIN_CATEGORIES=10  # safety net: refuse to publish a near-empty tarball

echo "=== SquidGuard Tarball Builder ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Source: $BL_DIR"

if [ ! -d "$BL_DIR" ]; then
    echo "ERROR: source directory not found: $BL_DIR" >&2
    exit 1
fi

# Stage a clean copy. Only domains + urls survive — any stray files in BL/
# (READMEs, dotfiles, leftovers) are dropped on purpose so the tarball stays
# strictly to the SquidGuard schema.
mkdir -p "$STAGE_DIR/$PKG_NAME"
while IFS= read -r domfile; do
    rel_dir="$(dirname "${domfile#$BL_DIR/}")"
    mkdir -p "$STAGE_DIR/$PKG_NAME/$rel_dir"
    cp "$domfile" "$STAGE_DIR/$PKG_NAME/$rel_dir/domains"
    if [ -f "$BL_DIR/$rel_dir/urls" ]; then
        cp "$BL_DIR/$rel_dir/urls" "$STAGE_DIR/$PKG_NAME/$rel_dir/urls"
    else
        touch "$STAGE_DIR/$PKG_NAME/$rel_dir/urls"
    fi
done < <(find "$BL_DIR" -name "domains" -type f -not -empty | sort)

# Validate
cat_count=$(find "$STAGE_DIR/$PKG_NAME" -name "domains" -type f | wc -l | tr -d ' ')
if [ "$cat_count" -lt "$MIN_CATEGORIES" ]; then
    echo "ERROR: only $cat_count categories staged (min $MIN_CATEGORIES). Refusing to publish." >&2
    exit 1
fi

mkdir -p "$OUT_DIR"
TARBALL="$OUT_DIR/${PKG_NAME}.tar.gz"

# --sort=name + fixed mtime → reproducible tarball (same content = same hash).
# This is critical so the asset on GitHub Releases only changes when the data
# actually changed, not on every CI run.
tar --sort=name \
    --owner=0 --group=0 --numeric-owner \
    --mtime='UTC 2020-01-01' \
    -czf "$TARBALL" \
    -C "$STAGE_DIR" "$PKG_NAME"

sha=$(sha256sum "$TARBALL" | awk '{print $1}')
echo "$sha  ${PKG_NAME}.tar.gz" > "${TARBALL}.sha256"

size=$(wc -c < "$TARBALL" | tr -d ' ')
size_mb=$((size / 1024 / 1024))

echo ""
echo "=== Package Summary ==="
echo "Tarball:     $TARBALL"
echo "Categories:  $cat_count"
echo "Size:        ${size_mb} MB (${size} bytes)"
echo "SHA-256:     $sha"
echo ""
echo "Test locally:"
echo "  tar -tzf $TARBALL | head -5"
echo ""
echo "Done: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
