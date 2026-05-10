# Community Blocklists

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Last update](https://img.shields.io/github/last-commit/StbanMc/CommunityBlocklists/main?label=last%20update)](https://github.com/StbanMc/CommunityBlocklists/commits/main/)
[![Categories](https://img.shields.io/badge/categories-74-orange)](#categories)
[![Domains](https://img.shields.io/badge/domains-4M%2B-red)](#stats)
[![Sources](https://img.shields.io/badge/sources-5-purple)](#data-sources)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING.md)

Community-driven URL/domain blocklists organized by category. Compatible with **pfBlockerNG**, **Pi-hole**, **AdGuard Home**, **OPNsense**, **Unbound**, **dnsmasq**, **SquidGuard**, and any DNS-based filtering solution.

> **4,000,000+ domains** across **74 categories**, updated weekly from 5 open sources. Programmatic catalogue: [`manifest.json`](manifest.json).

---

## Quick Start

### Pi-hole
Add as Adlist (hosts format):
```
https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main/exports/hosts/<category>.txt
```

### AdGuard Home
Add as DNS blocklist:
```
https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main/exports/adguard/<category>.txt
```

### pfBlockerNG (pfSense) — step by step
1. **Firewall** → **pfBlockerNG** → **DNSBL** → **DNSBL Groups** → **+ Add**
2. **Source URL**:
   ```
   https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main/exports/domains/<category>.txt
   ```
3. **Format**: `Auto`
4. **State**: `ON`
5. **Frequency**: `Weekly` (matches our update cycle)
6. Save → go to **pfBlockerNG → Update** → **Reload** → **Force**

Tip: subscribe to specific categories instead of `combined/all-domains.txt`. Easier to revert if a single category blocks something legitimate.

### OPNsense (Unbound DNS)
```
https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main/exports/unbound/<category>.conf
```

### dnsmasq
```
https://raw.githubusercontent.com/StbanMc/CommunityBlocklists/main/exports/dnsmasq/<category>.conf
```

### Combined (all categories)
```
exports/combined/all-domains.txt   # Plain domains
exports/combined/all-hosts.txt     # Hosts format
exports/combined/all-adguard.txt   # AdGuard format
```

### SquidGuard (legacy)
Clone the repo and point SquidGuard to `ListFilter-Squid/BL/`.

### CDN alternative — jsDelivr (better global latency)

GitHub raw is fine for most users. If you are far from US edges or need lower latency, jsDelivr automatically mirrors this repo:

```
https://cdn.jsdelivr.net/gh/StbanMc/CommunityBlocklists@main/exports/domains/<category>.txt
https://cdn.jsdelivr.net/gh/StbanMc/CommunityBlocklists@main/exports/hosts/<category>.txt
https://cdn.jsdelivr.net/gh/StbanMc/CommunityBlocklists@main/exports/adguard/<category>.txt
```

To pin to a specific release tag instead of `@main` (recommended for production firewalls), replace `@main` with the tag, e.g. `@v2026.05.10`.

### Programmatic catalogue (`manifest.json`)

The full list of categories with sizes, formats and source attribution lives at [`manifest.json`](manifest.json) — useful for tools, dashboards or wrappers that want to discover what is available without scraping the README.

---

## Available Formats

| Format | Directory | Use case |
|--------|-----------|----------|
| Plain domains | `exports/domains/` | pfBlockerNG, generic |
| Hosts file | `exports/hosts/` | Pi-hole, /etc/hosts |
| AdGuard | `exports/adguard/` | AdGuard Home |
| dnsmasq | `exports/dnsmasq/` | dnsmasq, OPNsense |
| Unbound | `exports/unbound/` | Unbound DNS resolver |
| Combined | `exports/combined/` | All categories merged |
| SquidGuard | `ListFilter-Squid/BL/` | Legacy SquidGuard |

---

## Categories

### Security
| Category | File name | Description |
|----------|-----------|-------------|
| Phishing/Scam | `hacking` | Phishing, scam, hacking tools |
| Malware/Spyware | `spyware` | Malware, spyware, tracking, ransomware, cryptojacking |
| Fraud | `costtraps` | Fraud, cost traps |
| Aggressive | `aggressive` | Aggressive/hostile content |
| Violence | `violence` | Violence, dangerous material |

### Privacy
| Category | File name | Description |
|----------|-----------|-------------|
| Advertising | `adv` | Ads, trackers |
| VPN/Proxy | `anonvpn` | Anonymous VPN, proxies, DoH |
| Redirectors | `redirector` | URL redirectors |
| URL shorteners | `urlshortener` | URL shortening services |
| Remote control | `remotecontrol` | Remote access tools |
| Dynamic DNS | `dynamic` | Dynamic DNS services |

### Adult Content
| Category | File name | Description |
|----------|-----------|-------------|
| Pornography | `porn` | Pornography (1.1M+ domains) |
| Lingerie | `sex-lingerie` | Lingerie |
| Dating | `dating` | Dating sites |

### Entertainment
| Category | File name | Description |
|----------|-----------|-------------|
| Gambling | `gamble` | Gambling, betting (238K+ domains) |
| Online games | `hobby-games-online` | Online games |
| Movies | `movies` | Movie streaming |
| Music | `music` | Music streaming |
| Social networks | `socialnet` | Social networks |
| Chat | `chat` | Chat platforms |
| Webmail | `webmail` | Webmail services |

### Commerce & Finance
| Category | File name | Description |
|----------|-----------|-------------|
| Shopping | `shopping` | Online shopping |
| Banking | `finance-banking` | Banking |
| Trading/Crypto | `finance-trading` | Trading, cryptocurrency |

### Other
| Category | File name | Description |
|----------|-----------|-------------|
| News | `news` | News, press |
| Warez/Piracy | `warez` | Piracy, warez |
| Drugs | `tracker-drugs` | Drug-related |
| Job search | `jobsearch` | Job search sites |

See all 74 categories in `ListFilter-Squid/BL/`.

---

## Data Sources

| Source | Updated | What it provides |
|--------|---------|-----------------|
| [UT1 Blacklists](https://dsi.ut-capitole.fr/blacklists/) (Univ. Toulouse) | Daily | 40+ categorized lists |
| [BlockListProject](https://blocklistproject.github.io/Lists/) | Regular | ads, malware, phishing, gambling, porn, drugs, piracy, scam, tracking |
| [Hagezi DNS Blocklists](https://github.com/hagezi/dns-blocklists) | Regular | gambling, DoH |
| [StevenBlack/hosts](https://github.com/StevenBlack/hosts) | Regular | unified ads/malware |
| [Phishing Army](https://phishing.army/) | Daily | phishing domains |

---

## Automated Updates

GitHub Actions updates the lists **every Monday** automatically:
1. Downloads latest data from all upstream sources
2. Merges with existing lists (additive, no domains lost)
3. Deduplicates and sorts
4. Exports to all formats
5. Auto-commits

Trigger manually from the **Actions** tab anytime.

### Run locally
```bash
bash scripts/update_lists.sh      # Update from sources
bash scripts/export_formats.sh    # Export to all formats
```

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

- Add domains to categories via Pull Request
- Report false positives via Issues
- Suggest new categories or data sources
- Improve scripts or add export formats

---

## Stats

- **4,000,000+** domains
- **74** categories
- **6** export formats
- **5** upstream sources
- **Weekly** automated updates

---

## License

Open source. See [LICENSE](LICENSE).
