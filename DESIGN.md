# Design

Visual system for Beantr's landing page and brand surfaces. Direction: **"Vellum & Ember"** — a file-native coffee ledger given the composure of a well-made object. Sourced from the `Beantr Design System` project on claude.ai/design (projectId `de75fede-21f4-4ce7-91d1-d2dcd11310e2`). This is a **committed, shipped identity**: preserve it. New work extends these tokens rather than re-deciding them.

## Design Language

Warm vellum paper and near-black espresso ink, used as two full alternating chapter surfaces (not a light page with one dark footer). One brass accent carries links, primary actions, focus, and the seal mark; oxblood is a secondary reserved strictly for seals/emphasis. Three type roles: a high-contrast display serif for moments that matter, a humanist serif for prose, a soft mono for all data/labels/paths. No gradients, no blue/purple, no glassmorphism, no emoji. Crisp letterpress-adjacent radii; hairline warm borders; umber-tinted shadows used sparingly. Calm, deliberate motion.

## Color

OKLCH-adjacent warm ramps, expressed as hex tokens (kept verbatim from the design system).

**Vellum (paper surfaces):** `--paper-50 #FBF5E9` · `--paper-100 #F5EAD6` · `--paper-200 #EDDCC0` · `--paper-300 #E0C69C` · `--paper-400 #C9A876`

**Ink (text + dark surface, never flat black):** `--ink-900 #1B1310` · `--ink-800 #241A14` · `--ink-700 #4A392C` · `--ink-600 #5C4936` · `--ink-500 #7C6A57` · `--ink-400 #A6947E`

**Brass (primary accent):** `--brass-200 #E8D2A0` · `--brass-400 #C9A055` · `--brass-600 #AD7C3C` · `--brass-700 #8C6129` · `--brass-900 #5C3E19`

**Oxblood (secondary — seals/emphasis only, never status):** `--oxblood-600 #7A342A` and ramp.

**Status (a hue apart from brand, status-only):** olive (success), rust (danger), amber (warning).

**Semantic aliases (light):** page `--paper-100`, raised `--paper-50`, sunken `--paper-200`; text primary `--ink-800`, secondary `--ink-700`, muted `--ink-500`; accent `--brass-600`, hover `--brass-700`; borders `--paper-300` / `--paper-400`; focus ring `--brass-600`.

**Inverse scope (dark espresso chapters):** page `--ink-900`, raised `--ink-800`, sunken `rgba(0,0,0,.28)`; text primary `--paper-100`, secondary `--paper-300`, muted `--paper-400`; accent `--brass-400`; borders `rgba(245,234,214,.14)`. Applied by re-pointing the semantic aliases inside a `.section--dark` scope.

**Contrast:** body ≥ 4.5:1, large/bold ≥ 3:1, verified on both surfaces. Notably `--ink-500` muted labels clear AA against `--paper-100`; on dark, muted uses `--paper-400`.

## Typography

Three roles, deliberately (this is the identity — do not reduce to a reflex serif/sans pair, and do not add a fourth):

- **Display — DM Serif Display** (`--font-display`): headlines, pull-quotes, the wordmark. High-contrast, dramatic. *Committed brand font; kept despite being a common default because it is the shipped identity.*
- **Prose — Spectral** (`--font-serif`): body copy, nav, UI text. Humanist serif, warm.
- **Data — Spline Sans Mono** (`--font-mono`): tags, badges, file paths, timestamps, numeric fields, micro-labels — almost always uppercase + letter-spaced.

Decision rule: is this a *moment* (display), *prose* (serif), or *data* (mono)? Never use display for body or small labels.

**Scale (fluid):** display `clamp(46px, 7vw, 96px)` (capped at 96px — the page states, it does not shout); h1 `clamp(38px,5vw,56px)`; h2 `clamp(28px,4vw,36px)`; h3 24px; h4 19px; body 16px; small 14px; micro/eyebrow 12–12.5px. Line-heights: tight 0.98 (display), snug 1.2, normal 1.55, relaxed 1.7. Letter-spacing: display `-0.01em` (never below −0.04em); mono labels `+0.1–0.18em`. Use `text-wrap: balance` on headings, `pretty` on long prose. Fonts are Google-Fonts substitutes pending a real license.

## Spacing

4px base scale `--space-1 … --space-14` (4,8,12,16,20,24,32,40,48,64,80,96,128,160). Used generously — this is a document, not a dense app. Prefer the larger steps for section and chapter-band rhythm; vary spacing for rhythm rather than a uniform gap everywhere.

## Shape / Radius

Crisp, letterpress-adjacent: `--radius-xs 2px` · `--radius-sm 4px` · `--radius-md 8px` · `--radius-lg 14px` · `--radius-full 999px`. Tags and badges stay rectangular "stamps" (`--radius-xs`) — **not** pills. `--radius-full` is reserved for the one true binary toggle (Switch).

## Elevation / Shadow

Always umber-tinted, never pure black; softer and longer than a typical UI shadow, used sparingly. Most surfaces rely on a hairline border at rest, not elevation. `--shadow-sm 0 3px 10px rgba(27,19,16,.10)`; `--shadow-md 0 14px 34px -16px rgba(27,19,16,.34)`; focus `0 0 0 3px rgba(173,124,60,.32)`. A dedicated `--shadow-seal` inner emboss exists for the mark only.

## Motion

Calm, deliberate; no bounce/spring/elastic, nothing loops. Easing `--ease-elegant cubic-bezier(.16,1,.3,1)`; durations fast 120 / base 200 / slow 360 / reveal 620ms. Signature moment: a hairline underline that draws in from the left (brass) on link hover, over the resting hairline — not a color change. Entrance reveals are opacity + ~14px translate-y, and must **enhance an already-visible default**: the hidden state is gated behind a JS-added `.js-reveal` class set only when IntersectionObserver + motion are available, so no-JS, reduced-motion, and headless renderers show all content. `prefers-reduced-motion` collapses everything to instant.

## Iconography

No custom icon set. Inline hairline SVGs (copy/check glyphs on copy buttons) at 1.5–1.75px stroke, tinted as ink/brass — never pure black. A few Unicode glyphs (`→`, `✓`, `/`) appear as part of the file-path voice. No emoji, ever. The bean-seal mark (`beantr-mark.svg` + inverse) is the one figurative device: a bean silhouette inside a thin wax-seal ring, holding up from favicon to hero lockup.

## Components

- **Copy command chip (`.cmd` + `.copy-btn`):** mono command that **wraps** (never a horizontal scrollbar) inside a `width: fit-content` box so it hugs its command on wide screens; inline chips use a compact icon-only copy button, the hero/prompt keep a text label. Copy flips to a brass "Copied" check for ~1.6s.
- **Prompt block (`.prompt-block`):** serif natural-language instruction with the shell command inline-coded, plus one "Copy prompt" button — the "hand it to your agent" install path.
- **Section mark (`.section-mark`):** brass-ringed number badge + hairline rule + mono label. The deliberate "annotated manual" chapter device (01–0N). Kept as committed identity; not generic per-section scaffolding.
- **Compat row (`.compat-row`):** per-agent name + note + copyable install command.
- **Flow diagram / directory tree / field-row ledger card:** typographic, data-native "imagery" — real paths and real session data stand in for photography, deliberately, per brand.
- **Text link (`.textlink`):** the editorial CTA; underline draws in on hover. Filled `Button` exists for app-like surfaces but this page favors textlinks + command chips.
- Cards are flat: raised surface one step lighter than the page, hairline border, no shadow at rest.

## Layout

Content column `max-width: 1040px`, 32px gutters (20px on mobile); focused pages (per-agent installs) use `.wrap--narrow`, `max-width: 760px`. Prose is meant to **fill the column, not sit in a narrow strip** — leads/notes cap at ~72rem and the primary `.prompt-block` at ~1040px (both larger than the container, so they fill it) and the text visibly uses the full width. Tiago's explicit call: widen the *inner content* to fill the column, but keep the original page margins (the 1040 container) — don't widen the outer container to gain width. These are short blurbs, so the wide measure is fine; don't re-narrow them to a 58–65ch "readable" cap. Left-aligned headers, never centered hero copy. Slim sticky top bar with frosted-vellum blur (the only place blur is used). Long pages **alternate full light and dark chapter bands deliberately** (vellum → dark → vellum → dark+footer) — a core layout device, not a footer treatment. Two-column grids (`truth`, `session`) span the full column and collapse to one column ≤ 860px; grid/flex children that hold `nowrap`/`pre` content get `min-width: 0` so commands never blow out page width.
