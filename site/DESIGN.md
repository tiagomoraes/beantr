# Beantr, "In writing"

A new landing direction for Beantr. Not a reskin of the previous "Crema on black"
page: a different world, a different narrative, a different interface.

The page is a notebook. Beantr's product is a folder of Markdown that your agent
keeps true, so the landing page behaves like the thing it sells: paper, ink,
margin notes, a file being written while you read.

The machine only appears as a dark surface: the prompt card, the session file,
the install band. That contrast is the whole argument. Your coffee is written
down in your own words; the machine is just where it gets filed.

## The two voices

- **Newsreader** (variable serif, 200 to 700, real italic) for everything human:
  headlines, the sentence you say to your agent, the answers, the prose.
- **IBM Plex Mono** for everything the machine touches: file paths, fields,
  commands, ledger metadata, buttons.

No grotesk display font, no uppercase eyebrows, no gradients, no drop shadows,
no cards except the dark machine surfaces, no em dashes.

## Tokens

| Token | Value | Role |
|---|---|---|
| `--paper` | `#F1F0EA` | page |
| `--paper-2` | `#E9E7DE` | quiet tint, inline code |
| `--ink` | `#17160F` | primary text |
| `--ink-2` | `#4B4840` | body text |
| `--mute` | `#6E6A5F` | metadata, labels |
| `--rule` | `#D6D2C3` | hairlines, all structure |
| `--crema` | `#C08A4E` | the single accent: spine, period, active tube |
| `--crema-deep` | `#8A5A2B` | accent text on paper (5.1:1) |
| `--crema-soft` | `#D9B78C` | accent on dark (9.8:1) |
| `--night` | `#14130E` | machine surfaces |
| `--night-2` | `#1C1A13` | machine surface raised |

Shapes are sharp everywhere. The only curve in the system is the bean mark and
the spine tip; the tubes are rectangles by design.

## Structure

- **The spine.** A 1px crema rule starts under the bean in the header and runs
  the full document. Its fill is the scroll position; a 5px crema tip tracks the
  end of the fill like a pen. It is the page's only progress indicator.
- **The margin.** Each section is labeled with the file it is about
  (`beans/current.md`, `sessions/2026-11.md`, `insights/current.md`,
  `README.md`, `install`). The rail sticks while you read the section, so the
  page always tells you which part of the ledger you are in.
- **Numbered pages, not numbered sections.** No `01 / 02` labels anywhere.

## The five movements

1. **Hero.** "Your coffee, in writing." Roman and italic serif at up to 158px,
   the crema period, and the one thing to do: paste the prompt. The left column
   closes with "no app / no account / one folder". Pointer parallax moves the
   two lines in opposite directions by a few pixels; the crema glow follows the
   pointer across the paper.
2. **Three kinds of notes.** A sample shelf drawn as twelve tubes. Hovering or
   focusing a tube lifts it, marks it, and rewrites the detail panel (name,
   grams, bag, roast, tube, state). Below, three notes: kept current, kept
   forever, kept honest.
3. **Say it. It's filed.** The centerpiece. As you scroll, the sentence you said
   lights up field by field and the Markdown session entry fills in on the dark
   panel: dose, yield, ratio, time, sensory result, next change. The agent's
   inferences are tagged `from your shelf`; what it does not know stays
   `unknown`. The future lines sit at 32% opacity as ghosts, so the panel reads
   as a ledger waiting to be written, not as an empty card.
4. **Then ask it anything.** Four real questions and answers, with a column
   header (`you ask` / `your agent`). Hovering a row dims the others.
5. **Why it feels different / Start with one line.** Five principles in an
   asymmetric 2+3 grid, then the page closes in the dark: the command, the
   agents, the guide, and a wordmark that fills the content width.

## Motion inventory

All of it is gated behind `.js` (set only when IntersectionObserver exists and
reduced motion is not requested), so content is fully visible without JS, in
headless renderers, and under `prefers-reduced-motion`.

- Hero lines rise out of a mask, staggered; the rest reveals at 16px with 0.9s
  cubic-bezier(.16, 1, .3, 1).
- Pointer: paper glow (620px, 13% crema) and hero line parallax.
- Scroll: spine fill and tip, and the filed section's five steps.
- Copy buttons lean up to 12% toward the pointer inside a 120px radius and swap
  to `copied` for 1.8s.
- Tubes fill from the bottom with a 30ms stagger when the shelf enters.
- Only `transform` and `opacity` animate. No `window` scroll listener drives
  layout: one passive listener schedules a single rAF that writes two CSS
  variables.

## Accessibility

- AA contrast verified for every text token (lowest: mute on paper at 4.7:1;
  the inactive sentence is 3.2:1 at 35px, which is AA for large text).
- Focus rings are 2px crema-deep on paper, crema-soft on dark.
- The shelf detail is `aria-live="polite"`; tubes are buttons with full labels.
- The file panel is real text, not an image.
- No horizontal overflow at 1440, 1280, or 390; no console errors.

## Files and preview

- `index.html`, `site.css`, `site.js`. No build step, no dependencies, no images.
- Fonts: Newsreader and IBM Plex Mono via Google Fonts. Asset URLs carry
  `?v=3.0.0`; bump it whenever the CSS or JS changes, because the artifact host
  sets a 4h edge cache.
- Deploy: through the private artifacts hub. The built `site/` is mirrored into
  the `tiagomoraes/artifacts` repo under `beantr/`, and a push to its `main`
  produces an immutable release and swaps the live symlink. The old
  `beantr/beantr.css` and `beantr.js` stay in place for the guide and per-agent
  pages until those are ported.
- Live at `https://beantr.tiagomoraes.cloud/`.

## Not ported yet

`/guide/` and the per-agent pages (`/hermes/`, `/claude-code/`, `/opencode/`,
`/openclaw/`, `/cowork/`) still use the previous dark system (`beantr.css`).
They are the next step once this direction is approved: they should inherit
these tokens, the rail, and the hairlines, with their existing content.
