# Landing page prototype (throwaway)

**Status (2026-09-21): decided.** Variant B, second pass, was folded into `site/index.html`,
`site/beantr.css`, `site/beantr.js`, `site/guide/` and the per-agent pages. This directory is
kept only as the record of the exploration; move it to a throwaway branch and delete it from
`develop`. It must not be deployed.

Three structurally different redesigns of `site/index.html`, built to answer one
question: **what should the Beantr landing page look like after a fresh start?**

This directory is a prototype. It is not the site, it is not linked from the site,
and it should not be deployed. Once a direction wins, fold it into `site/index.html`
and `site/beantr.css`, then delete this directory (keep it on a throwaway branch).

## Run

```bash
make preview-site
# then open http://localhost:8088/prototype/
```

`/prototype/?variant=a|b|c` opens a variant directly. Every page has a floating
orange bar at the bottom to cycle variants (also the left and right arrow keys).

## Variants

| Key | Name | Structure | Type | Palette |
|---|---|---|---|---|
| A | Ledger split | Sticky top nav, asymmetric split hero (copy + install on the left, the real Markdown file being appended on the right), hairline sections | Instrument Sans + JetBrains Mono | Neutral stone, forest green accent, soft 8px radii, light and dark |
| B | Manifesto | Floating pill nav, centered giant headline, the install command as the hero object, one marquee, a question-and-answer use-case section, sticky-quote story, giant footer wordmark. Second pass: coffee-first plain copy, word-mask hero, typed command, blur reveals, drawn rules on answers, magnetic Copy, scroll-driven footer wordmark | Bricolage Grotesque + IBM Plex Mono | Off-black and tan, pill buttons, 16px containers, dark only |
| C | Index | Two-column page: sticky left index that holds the install command the whole way down, content rows with hanging labels on the right | Archivo (wide) + Geist Mono | Paper white, cobalt accent, sharp corners, light and dark |
| D | Roastery | B's structure with bag-label spec cards and CC0 coffee photography. Built after the first review; the photos were rejected, kept only for the record | Bricolage Grotesque + IBM Plex Mono | Matte black, crema accent, dark only |

All three keep the same information architecture as the current page (install,
model, ledger roles, a real session, five rules) and the same real facts. Nothing
in the copy is invented; the session data is the one already used in the docs.

## Notes

- Fonts load from Google Fonts for speed of iteration. The real site should self-host.
- Variants A, B and C use no photography; the visual is the product's own artifact (a real Markdown file). D's photos are CC0 from Wikimedia Commons (Unsplash-era) and were not adopted.
- The direction after the first review is B. Its second pass is the one to fold into the real site.
- The example file header uses a hyphen where the template uses an em dash.
