#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
BL_DIR="$REPO_DIR/ListFilter-Squid/BL"
TMP_DIR=$(mktemp -d)
echo "=== pfSenseSquidGuardLists Updater ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

merge_ut1() {
    local u="$1" l="$2"
    local url="https://raw.githubusercontent.com/olbat/ut1-blacklists/master/blacklists/${u}/domains"
    echo "  [UT1] ${u} -> ${l}"
    mkdir -p "$BL_DIR/$l"
    local tmp="$TMP_DIR/ut1_${u//\//_}"
    if curl -sfL "$url" -o "$tmp" 2>/dev/null; then
        local b
        b=$(wc -l < "$BL_DIR/$l/domains" 2>/dev/null || echo 0)
        { cat "$BL_DIR/$l/domains" 2>/dev/null || true; cat "$tmp"; } \
            | grep -v "^#" | grep -v "^$" | tr "[:upper:]" "[:lower:]" | sort -u > "$TMP_DIR/m" || true
        mv "$TMP_DIR/m" "$BL_DIR/$l/domains"
        local a
        a=$(wc -l < "$BL_DIR/$l/domains")
        local d=$((a - b))
        if [ "$d" -gt 0 ]; then echo "    +${d} (${b}->${a})"; fi
    else echo "    (skip)"; fi
}

merge_list() {
    local url="$1" l="$2" tag="$3"
    echo "  [${tag}] -> ${l}"
    mkdir -p "$BL_DIR/$l"
    local tmp="$TMP_DIR/pl_${tag// /_}"
    if curl -sfL "$url" -o "$tmp" 2>/dev/null; then
        local b
        b=$(wc -l < "$BL_DIR/$l/domains" 2>/dev/null || echo 0)
        { cat "$BL_DIR/$l/domains" 2>/dev/null || true
          sed -e "s/^0\.0\.0\.0 //" -e "s/^127\.0\.0\.1 //" -e "s/#.*//" -e "/^$/d" -e "/^#/d" -e "/localhost/d" "$tmp"
        } | tr "[:upper:]" "[:lower:]" | tr -d "\r" | grep -E "^[a-z0-9]" | sort -u > "$TMP_DIR/m" || true
        mv "$TMP_DIR/m" "$BL_DIR/$l/domains"
        local a
        a=$(wc -l < "$BL_DIR/$l/domains")
        local d=$((a - b))
        if [ "$d" -gt 0 ]; then echo "    +${d} (${b}->${a})"; fi
    else echo "    (skip)"; fi
}

echo "--- [1/5] UT1 Blacklists ---"
# Note: UT1 publishes some categories as symlinks (ads->publicite, aggressive->agressif,
# drugs->drogue, proxy->redirector, violence->agressif, porn->adult). raw.githubusercontent.com
# does NOT follow symlinks, so we must use the real target name as upstream slug.
# `adult` is partitioned (domains.0/1/2) — skip here, BLP-porn covers it.
merge_ut1 publicite adv;            merge_ut1 agressif aggressive
merge_ut1 audio-video webtv;        merge_ut1 bank finance/banking
merge_ut1 bitcoin finance/trading;  merge_ut1 chat chat
merge_ut1 cryptojacking spyware;    merge_ut1 dangerous_material violence
merge_ut1 dating dating;            merge_ut1 download downloads
merge_ut1 drogue tracker/drugs;     merge_ut1 dynamic-dns dynamic
merge_ut1 fakenews news;            merge_ut1 filehosting imagehosting
merge_ut1 financial finance/other;  merge_ut1 forums forum
merge_ut1 gambling gamble;          merge_ut1 games hobby/games-online
merge_ut1 hacking hacking;          merge_ut1 jobsearch jobsearch
merge_ut1 lingerie sex/lingerie;    merge_ut1 malware spyware
merge_ut1 phishing hacking;         merge_ut1 press news
merge_ut1 radio webradio;           merge_ut1 redirector redirector
merge_ut1 remote-control remotecontrol
merge_ut1 sexual_education sex/education
merge_ut1 shopping shopping;        merge_ut1 shortener urlshortener
merge_ut1 social_networks socialnet
merge_ut1 sports recreation/sports; merge_ut1 stalkerware spyware
merge_ut1 vpn anonvpn;              merge_ut1 warez warez
merge_ut1 agressif violence;        merge_ut1 webmail webmail

echo ""; echo "--- [2/5] BlockListProject ---"
B="https://blocklistproject.github.io/Lists/alt-version"
merge_list "$B/ads-nl.txt" adv BLP-ads; merge_list "$B/malware-nl.txt" spyware BLP-malware
merge_list "$B/phishing-nl.txt" hacking BLP-phishing; merge_list "$B/gambling-nl.txt" gamble BLP-gambling
merge_list "$B/porn-nl.txt" porn BLP-porn; merge_list "$B/drugs-nl.txt" tracker/drugs BLP-drugs
merge_list "$B/piracy-nl.txt" warez BLP-piracy; merge_list "$B/scam-nl.txt" hacking BLP-scam
merge_list "$B/tracking-nl.txt" spyware BLP-tracking; merge_list "$B/ransomware-nl.txt" spyware BLP-ransomware
merge_list "$B/fraud-nl.txt" costtraps BLP-fraud; merge_list "$B/crypto-nl.txt" finance/trading BLP-crypto

echo ""; echo "--- [3/5] Hagezi DNS Blocklists ---"
H="https://raw.githubusercontent.com/hagezi/dns-blocklists/main/wildcard"
merge_list "$H/gambling-onlydomains.txt" gamble Hagezi-gambling
merge_list "$H/doh-onlydomains.txt" anonvpn Hagezi-doh

echo ""; echo "--- [4/5] StevenBlack Unified Hosts ---"
merge_list "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" adv StevenBlack

echo ""; echo "--- [5/5] Phishing Army ---"
merge_list "https://phishing.army/download/phishing_army_blocklist.txt" hacking PhishingArmy

echo ""; echo "--- Ensuring urls files ---"
# Defensive: avoid `[ ! -f ... ] && touch ...` because under `set -e`,
# the entire compound returns 1 when the file already exists and aborts
# the script. `touch` is idempotent and cheap, so just create unconditionally.
while IFS= read -r d; do
    touch "$d/urls"
done < <(find "$BL_DIR" -name "domains" -type f -exec dirname {} \;)
echo "Done."

echo ""; echo "=== Summary ==="
td=0; tc=0
while IFS= read -r f; do l=$(wc -l < "$f"); td=$((td+l)); tc=$((tc+1)); done < <(find "$BL_DIR" -name "domains" -type f)
echo "Categories: $tc"; echo "Total domains: $td"
echo "Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
