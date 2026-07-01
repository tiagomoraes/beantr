# Product

## Register

brand

## Users

Coffee enthusiasts who already use an AI assistant — Claude Code, Hermes, OpenCode, OpenClaw, Claude Cowork, or any file-capable agent — as a daily personal operator. They dial in espresso, track beans and gear, and want their assistant to *remember* that context across sessions instead of re-explaining it. Skews toward developers and local-first / plain-text tool users comfortable running one shell command. Typical moment of use: at a laptop, deciding what to brew next or logging a shot they just pulled, wanting a fast answer grounded in their own history — not generic coffee theory.

## Product Purpose

Beantr is an agent-native coffee ledger: a portable skill plus a folder of Markdown templates that teach a file-capable AI agent to track a person's beans, gear, recipes, and brew sessions on their own filesystem. It used to be a FastAPI + PostgreSQL + MCP service; that architecture was deliberately removed. There is no app, dashboard, database, or account — the agent is the interface and the plain files are the product.

The landing page's job, in order: (1) make a visitor understand the "a skill, not an app" model in seconds; (2) get Beantr installed into their agent with a single copyable command, or a prompt they hand to the agent itself. **Installation guidance is the page's primary purpose** — success is measured in installs, not time-on-page.

## Brand Personality

Plainspoken and warm, like a knowledgeable friend — not a barista performing expertise. Patient, precise, trustworthy: the feeling of a well-bound notebook with a wax seal, not a SaaS product. Names real variables (ratio, temperature, time, origin) instead of vague praise ("rich," "bold"). No hype, no exclamation points, no emoji. Three words: **warm, precise, composed.**

## Anti-references

- SaaS dashboards and the "hero-metric" marketing template (big number + gradient accent + supporting stats).
- Database-first or API/MCP-server-first product framing — that architecture was intentionally removed and must not be implied.
- Generic AI-startup gloss: gradients, glassmorphism, blue/purple, rocket-ship "supercharge your coffee with AI" copy, emoji.
- The project's own prior landing page: warm radial gradients, emoji logo, pill buttons, Inter.

## Design Principles

1. **Practice what you preach.** Show real file paths, real Markdown, and a real brew session lifted from the docs — the file-native promise is demonstrated, never merely asserted.
2. **Installation is the product surface.** Copy-ready commands and an agent-runnable prompt are the primary CTAs; everything else supports getting installed.
3. **The agent is the interface.** Sell the capability that lives *inside* the agent the user already has. Never imply a separate app to open.
4. **Warmth through precision, not adjectives.** Exact numbers, real commands, calm pacing. Reach for craft, never enthusiasm.
5. **Composed, not loud.** Alternating vellum/espresso chapters, one brass accent, generous type — presence without gloss.

## Accessibility & Inclusion

Target WCAG 2.1 AA. Body text ≥ 4.5:1 and large/bold text ≥ 3:1, verified against **both** the light vellum and the dark espresso surfaces. Copy buttons and links are fully keyboard-operable with a visible brass focus ring. Honor `prefers-reduced-motion` (entrance reveals collapse to instant). Content must render fully without JavaScript and in headless/preview renderers — motion only ever enhances an already-visible default; it never gates visibility.
