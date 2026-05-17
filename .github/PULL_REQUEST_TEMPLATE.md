<!--
Thanks for contributing! Pick the section that fits your PR and delete
the rest. If your change spans more than one section, that's fine —
keep both.
-->

## Summary

<!-- One paragraph: what changes and why. -->

## Type of contribution

- [ ] Add domains to an existing category (e.g. `gamble`, `anonvpn`, `adv`, `phishing`)
- [ ] Remove a false-positive domain
- [ ] Add a brand-new category
- [ ] Add or change a data source in `scripts/update_lists.sh`
- [ ] Documentation only
- [ ] Tooling / CI / workflow

## Category changes (if applicable)

<!--
If you added/removed domains, please fill this in. It speeds up review
and helps reviewers spot mistakes.
-->

- Category: `<category-name>`
- Domains added: `N` (paste a small sample if helpful)
- Domains removed (false positives): `N`
- Source / justification: <!-- e.g. UT1 ai category, manual research, user report #123 -->

## Checklist

- [ ] All domains are **lowercase** and bare (no `http://`, no paths, no wildcards)
- [ ] No IP addresses, only domain names
- [ ] No duplicates with existing entries in the same category
- [ ] If false positive: I named the source list **and** confirmed the domain is legitimate
- [ ] If new source: source is open / free to redistribute under the project license
- [ ] No personal info, no internal company domains, no PII included

## Notes for the reviewer

<!-- Anything tricky? Edge cases? Domains you almost added but didn't? -->
