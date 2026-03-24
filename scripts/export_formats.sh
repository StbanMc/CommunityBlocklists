#!/bin/bash
# =============================================================================
# export_formats.sh - Export blocklists to multiple formats
#
# Generates:
#   - hosts format (0.0.0.0 domain) for Pi-hole, /etc/hosts
#   - adguard format (||domain^) for AdGuard Home
#   - dnsmasq format (address=/domain/0.0.0.0) for dnsmasq/OPNsense
#   - unbound format (local-zone: "domain" always_refuse) for Unbound DNS
#   - plain domain list (one per line) for pfBlockerNG, generic use
#   - combined "all" files per format
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BL_DIR="$REPO_DIR/ListFilter-Squid/BL"
OUT_DIR="$REPO_DIR/exports"

echo "=== Blocklist Format Exporter ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/hosts" "$OUT_DIR/adguard" "$OUT_DIR/dnsmasq" "$OUT_DIR/unbound" "$OUT_DIR/domains" "$OUT_DIR/combined"

total_cats=0
total_domains=0

while IFS= read -r domfile; do
    cat_path="${domfile#$BL_DIR/}"
    cat_path="${cat_path%/domains}"
    safe_name=$(echo "$cat_path" | tr "/" "-")
    count=$(wc -l < "$domfile")
    total_domains=$((total_domains + count))
    total_cats=$((total_cats + 1))

    echo "  Exporting: $cat_path ($count domains)"

    # Plain domains
    cp "$domfile" "$OUT_DIR/domains/${safe_name}.txt"

    # Hosts format
    sed "s/^/0.0.0.0 /" "$domfile" > "$OUT_DIR/hosts/${safe_name}.txt"

    # AdGuard format
    sed "s/^/||/; s/$/^/" "$domfile" > "$OUT_DIR/adguard/${safe_name}.txt"

    # dnsmasq format
    sed "s/^/address=\//; s/$/\/0.0.0.0/" "$domfile" > "$OUT_DIR/dnsmasq/${safe_name}.conf"

    # Unbound format
    sed 's/^/local-zone: "/; s/$/" always_refuse/' "$domfile" > "$OUT_DIR/unbound/${safe_name}.conf"

done < <(find "$BL_DIR" -name "domains" -not -empty -type f | sort)

# Generate combined files (all categories merged)
echo ""
echo "  Generating combined files..."
cat "$OUT_DIR/domains/"*.txt | sort -u > "$OUT_DIR/combined/all-domains.txt"
cat "$OUT_DIR/hosts/"*.txt | sort -t " " -k2 -u > "$OUT_DIR/combined/all-hosts.txt"
cat "$OUT_DIR/adguard/"*.txt | sort -u > "$OUT_DIR/combined/all-adguard.txt"

combined_count=$(wc -l < "$OUT_DIR/combined/all-domains.txt")

echo ""
echo "=== Export Summary ==="
echo "Categories exported: $total_cats"
echo "Total domain entries: $total_domains"
echo "Combined unique domains: $combined_count"
echo "Output directory: $OUT_DIR"
echo ""
echo "Formats generated:"
echo "  - exports/domains/     Plain domain lists (pfBlockerNG, generic)"
echo "  - exports/hosts/       Hosts format (Pi-hole, /etc/hosts)"
echo "  - exports/adguard/     AdGuard Home format"
echo "  - exports/dnsmasq/     dnsmasq format (OPNsense)"
echo "  - exports/unbound/     Unbound DNS format"
echo "  - exports/combined/    All categories merged"
echo ""
echo "Done: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
