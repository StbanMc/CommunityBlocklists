# Contributing to Community Blocklists

Thank you for your interest in contributing! This project relies on community collaboration to keep blocklists accurate and up-to-date.

## How to Contribute

### Adding domains to a category

1. Fork the repository
2. Add domains to the appropriate file in `ListFilter-Squid/BL/<category>/domains`
3. One domain per line, lowercase, no protocol prefix
4. Submit a Pull Request with a clear description

**Example:**
```
malicious-site.com
phishing-example.net
```

### Reporting false positives

If a legitimate domain is incorrectly blocked:

1. Open an [Issue](../../issues/new) with the label `false-positive`
2. Include: the domain, which category it's in, and why it's legitimate
3. We'll review and remove it promptly

### Suggesting new categories

Open an [Issue](../../issues/new) with:
- Proposed category name
- Description of what it covers
- Initial list of 10+ domains (if available)

### Improving the update script

The `scripts/update_lists.sh` fetches from multiple open sources. To add a new source:

1. Ensure the source is open/free to use
2. Add a new `merge_ut1` or `merge_list` call in the script
3. Map it to the appropriate local category
4. Test with `bash scripts/update_lists.sh`

## Guidelines

- **No duplicates** - lists are automatically deduplicated on update
- **Lowercase only** - domains must be lowercase
- **No URLs** - only bare domains (no `http://`, no paths)
- **No wildcards** - use the exact domain
- **No IP addresses** - domains only
- **Verify before adding** - ensure the domain actually belongs in the category
- **No personal vendettas** - don't block competitors or sites you personally dislike

## Categories

See the full list of categories in the [README](README.md#categories).

## Automated Updates

A GitHub Actions workflow runs weekly (every Monday) to:
1. Fetch latest domains from all upstream sources
2. Merge and deduplicate with existing lists
3. Export to all supported formats
4. Auto-commit changes

## Code of Conduct

- Be respectful and constructive
- Focus on improving internet safety
- Report issues responsibly
- Don't include domains for censorship purposes

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
