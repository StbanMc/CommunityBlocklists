#!/bin/bash
# =============================================================================
# generate_manifest.sh - Generate manifest.json describing all categories
#
# Output: manifest.json at repo root, with category counts, sizes,
#         total domains, sources, and stable subscribe URLs.
#
# Zero dependencies (pure bash + coreutils). Runs on the GitHub Actions
# runner after export_formats.sh, and reproducibly on any local machine
# with bash + wc + ls + date.
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
OUT_DIR="$REPO_DIR/exports"

VERSION=$(date -u +%Y.%m.%d)
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

combined_file="$OUT_DIR/combined/all-domains.txt"
if [ -f "$combined_file" ]; then
    combined_unique=$(wc -l < "$combined_file" | tr -d ' ')
else
    combined_unique=0
fi

categories_json=""
total_categories=0
total_domains=0
first=true

for f in "$OUT_DIR/domains/"*.txt; do
    [ -e "$f" ] || continue
    name=$(basename "$f" .txt)
    count=$(wc -l < "$f" | tr -d ' ')
    size=$(wc -c < "$f" | tr -d ' ')

    if [ "$first" = true ]; then
        first=false
    else
        categories_json+=","
    fi

    categories_json+=$'\n    {'
    categories_json+=$'\n      "id": "'"$name"$'",'
    categories_json+=$'\n      "domains": '"$count"$','
    categories_json+=$'\n      "size": '"$size"$','
    categories_json+=$'\n      "formats": {'
    categories_json+=$'\n        "domains": "exports/domains/'"$name"$'.txt",'
    categories_json+=$'\n        "hosts": "exports/hosts/'"$name"$'.txt",'
    categories_json+=$'\n        "adguard": "exports/adguard/'"$name"$'.txt",'
    categories_json+=$'\n        "dnsmasq": "exports/dnsmasq/'"$name"$'.conf",'
    categories_json+=$'\n        "unbound": "exports/unbound/'"$name"$'.conf"'
    categories_json+=$'\n      }'
    categories_json+=$'\n    }'

    total_categories=$((total_categories + 1))
    total_domains=$((total_domains + count))
done

cat > "$REPO_DIR/manifest.json" <<EOF
{
  "name": "CommunityBlocklists",
  "version": "$VERSION",
  "lastUpdate": "$TIMESTAMP",
  "totalCategories": $total_categories,
  "totalDomains": $total_domains,
  "combinedUniqueDomains": $combined_unique,
  "formats": ["domains", "hosts", "adguard", "dnsmasq", "unbound", "combined"],
  "baseUrls": {
    "github": "https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main",
    "jsdelivr": "https://cdn.jsdelivr.net/gh/StbanMc/CommunityBlocklists@main"
  },
  "sources": [
    {
      "name": "UT1 Blacklists",
      "owner": "Université Toulouse 1",
      "url": "https://dsi.ut-capitole.fr/blacklists/",
      "categories": "40+"
    },
    {
      "name": "The Block List Project",
      "url": "https://blocklistproject.github.io/Lists/",
      "categories": "ads, malware, phishing, gambling, porn, drugs, piracy, scam, tracking, ransomware, fraud, crypto"
    },
    {
      "name": "Hagezi DNS Blocklists",
      "url": "https://github.com/hagezi/dns-blocklists",
      "categories": "gambling, DoH"
    },
    {
      "name": "StevenBlack/hosts",
      "url": "https://github.com/StevenBlack/hosts",
      "categories": "unified ads"
    },
    {
      "name": "Phishing Army",
      "url": "https://phishing.army/",
      "categories": "phishing"
    }
  ],
  "categories": [$categories_json
  ]
}
EOF

echo "manifest.json generated:"
echo "  categories      : $total_categories"
echo "  total domains   : $total_domains"
echo "  combined unique : $combined_unique"
echo "  output          : $REPO_DIR/manifest.json"
