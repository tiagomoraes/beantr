# Design

Visual system for Beantr's site: the landing page, the install guide (`/guide/`) and the per-agent install pages. Direction: **"Crema on black"**. One dark page, the black of a matte coffee bag and the tan of crema, with typography doing all the work. Chosen on 2026-09-21 after a four-variant prototype (see `site/prototype/README.md`); it replaces the earlier "Vellum & Ember" system. This is the shipped identity: extend these tokens rather than re-deciding them.

## Design Language

A single dark surface from top to bottom, no light sections, no photography. Very large, tight grotesk headlines set centered; one crema accent that carries emphasis words, the primary button, rules and focus; everything else in three steps of warm off-white. Hairlines separate sections. Interactive things are pills; containers are soft 16px boxes; the prompt card is a 22px "message" you are about to send. Motion is calm and always earned: words rise out of a mask, the command types itself once, headings settle from a blur, the agent's answers draw a rule as they arrive. No gradients, no glass, no blue or purple, no emoji, no em dashes.

## Color

Tokens live in `site/beantr.css` on `:root` and are the only colors used.

| Token | Value | Role |
|---|---|---|
| `--bg` | `#0F0F0E` | page |
| `--bg-2` | `#161615` | cards, code, the prompt card |
| `--bg-3` | `#1C1C1A` | hover fills, inline code inside the prompt, the ghost footer wordmark |
| `--ink` | `#EDEBE5` | headlines, primary text |
| `--ink-2` | `#B3B0A7` | body text |
| `--mute` | `#86837B` | labels, captions, file paths |
| `--line` | `#262624` | hairlines |
| `--line-2` | `#353532` | borders on interactive things |
| `--accent` | `#D8B48B` | crema: emphasis words, primary button, rules, quotes, `.arg` in commands |
| `--accent-2` | `#E7CBA8` | accent hover, code inside the prompt |
| `--on-accent` | `#151310` | text on the accent |

**Contrast:** `--ink` on `--bg` is about 15:1, `--ink-2` about 9:1, `--mute` about 4.9:1 (kept at or above 4.5:1 because it is used at 12 to 13 px), `--accent` about 10:1, `--on-accent` on `--accent` about 10:1. The site is dark only: `color-scheme: dark`, no light theme. There is no secondary or status color; if one is ever needed it must sit a hue away from crema.

## Typography

Two faces, deliberately:

- **Bricolage Grotesque** (`--sans`), variable (`opsz`, `wdth`, `wght`), for everything that is not code. Headlines at 700 with `letter-spacing: -.04em` and `line-height: .96`; questions and quotes at 500; body at 400. Emphasis inside a headline is color (`<em>` set upright in `--accent`), never a second family.
- **IBM Plex Mono** (`--mono`) for commands, file paths, labels, captions and the marquee. Labels stay sentence case; no uppercase-tracked eyebrows anywhere.

Scale (fluid): h1 `clamp(38px, 6vw, 88px)` (inner pages `clamp(36px, 5.2vw, 76px)`); h2 `clamp(34px, 4.4vw, 64px)`, small variant `clamp(28px, 3.2vw, 44px)`; question `clamp(26px, 3vw, 42px)`; h3 22 to 34 px; body 17 px; lede `clamp(17px, 1.6vw, 20px)`; mono 13 to 14 px; labels 12 px. Headlines use `text-wrap: balance`, prose `text-wrap: pretty`. The hero headline is at most two lines on desktop; each line is its own mask for the entrance.

Fonts load from Google Fonts with `display=swap`. Self-hosting is a fine later improvement; keep the two families.

Every page links `/beantr.css?v=<version>` and `/beantr.js?v=<version>`. The edge cache keeps static assets for four hours, so the version in the URL is what makes a new release render with its own stylesheet; bump it on every release (see `docs/RELEASING.md`).

## Spacing and Layout

Content column `--wrap: 1180px`, long-form and inner pages `--wrap-narrow: 820px`, gutters `clamp(20px, 4vw, 40px)` as `padding-inline` on `.wrap` only; section rhythm is `padding-block: clamp(72px, 10vw, 130px)` on `.section .wrap` (tight sections `clamp(56px, 7vw, 96px)`). Sections are separated by a `--line` hairline, never by a change of background. The hero is centered; below it, two-column grids (`.qa`, `.story`) and the three-column `.groups` collapse to one column at 900 px. The floating nav pill sticks 14 px from the top and drops its links under 560 px.

## Shape

Pills (`999px`) for every interactive element: nav, buttons, the command line, table-of-contents chips. `--r: 16px` for containers (files, code blocks, notes, block command lines). `--r-card: 22px` for the prompt card only. Inline code gets 6 px. Nothing is square-cornered.

## Motion

Easing `--ease: cubic-bezier(.16, 1, .3, 1)` everywhere; nothing bounces, nothing loops except the marquee. Every animation is gated: the head script adds `.js` to `<html>` only when `IntersectionObserver` exists and `prefers-reduced-motion` is not set, so no-JS, reduced-motion and headless renderers see everything at rest.

- **Hero entrance:** each headline word rises out of its line mask (`.w` with `--i` delay, 55 ms apart); lede, prompt card and command line fade up in sequence.
- **Typed command:** on screens 720 px and wider, the secondary command reveals with a `steps(64)` clip and a brief crema caret, once, after the card has landed. The text is in the DOM the whole time, so Copy works before it finishes.
- **Reveals:** `.reveal` fades up on intersection; `.reveal--blur` also settles from a 10 px blur (headings, the story quote). A 2.6 s fallback reveals everything for renderers that never intersect.
- **Answers:** in `.qa`, the crema rule beside the agent's answer scales in from the top, then the text arrives.
- **Feedback:** `.copy` flips to "Copied" for 1.6 s and its container (`.ask`, `.cmdline`, `.codeblock`) borders in crema. The primary button is magnetic on hover devices only: it leans up to 18% of the pointer offset within 140 px.
- **Marquee:** one per page, 38 s linear, pauses on hover.
- **Footer wordmark:** lifts into place with a CSS scroll-driven animation where `animation-timeline: view()` is supported.

## Iconography and Mark

No icon set. The mark is a crema circle with an S-shaped crease: a bean, drawn as one path (`M10 6c9 0 3 20 12 20`). It is the favicon and sits in the nav pill, and spins half a turn on hover. The only other icon is the star in the GitHub badge, which appears only once the repository has more than 100 stars. Unicode glyphs (`/`, `→`, curly quotes, `+`) carry the rest.

## Components

- **Nav pill (`.navbar` / `.pill`):** brand, two or three links, one crema `Install` pill. Sticky, blurred backdrop (the only blur on the page).
- **Prompt card (`.ask`):** the primary call to action. Mono label, the natural-language install instruction with the command as inline code, `Copy prompt` bottom right. Copy reads the card's text, so the visible words are exactly what gets pasted.
- **Command line (`.cmdline`):** the secondary path: mono command in a hairline pill with a ghost `Copy`. `.cmdline--block` is the full-width variant for inner pages; `.cmdline--type` opts into the typed entrance.
- **Buttons:** `.copy` (crema pill), `.copy--ghost` (hairline), `.btn` (crema pill as a link). One label per intent: `Install` in the nav, `Copy prompt`, `Copy`, `Read the install guide`.
- **Marquee (`.marquee`):** the list of assistants Beantr works with, separated by crema slashes.
- **Questions and answers (`.qa-list`):** alternating question (large, quoted) and answer (body text with a crema rule and a mono `your agent` label). Sample data must stay consistent across the page and be labeled as a sample.
- **Story (`.story`):** a sticky quote on the left, the real appended Markdown on the right with a crema `+` gutter, lines staggering in.
- **Three notes (`.groups`):** three text columns, each with a heading, a mono crema line ("kept current / kept forever / kept honest"), a sentence, and the file list in mono.
- **Numbered list (`.rules`, `.rules--compact`):** crema mono numeral, heading, one sentence. Used for "Why it feels different" and the per-agent "What that does".
- **Note (`.note`):** the block addressed to an AI agent reading the page.
- **Doc (`.doc`):** the install guide: `h2` anchors, `.toc` chips, `.codeblock` with comments in `--mute` and a top-right ghost Copy, `.callout`, `.tree`, a two-column table that stacks on mobile.
- **Footer (`.foot`):** one line of links and the giant ghost wordmark in `--bg-3`.

## Copy voice

Coffee first, plain second, files third. Headlines and questions talk about bags, brews, the shelf, resting, dialing in. Explanations avoid architecture words up front ("append-only", "filesystem is the API" are for the docs). File paths appear in mono as quiet proof, never as the headline. Sentence case everywhere. No hype, no exclamation marks, no em dashes; use a period, a comma or a colon.

## Accessibility

WCAG 2.1 AA on the dark surface (values above). Every control is keyboard-operable with a 2 px crema `:focus-visible` ring. Copy buttons announce their state by changing their label. Decorative headline spans are `aria-hidden` behind an `aria-label` on the `h1`. Everything renders without JavaScript; motion only enhances an already visible page and collapses entirely under `prefers-reduced-motion`.
