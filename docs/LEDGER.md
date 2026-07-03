# Beantr ledger filesystem contract

The Beantr ledger is a small Markdown ledger that gives an LLM enough durable context to act as a coffee assistant.

## Folder layout

```text
beantr/
  README.md
  beans/
    current.md
    history/
      YYYY-MM.md
  gear/
    current.md
    history/
      YYYY-MM.md
  recipes/
    current.md
  sessions/
    YYYY-MM.md
  insights/
    current.md
```

## State model

Beantr separates three kinds of information:

| Kind | Files | Editing model | Purpose |
|---|---|---|---|
| Live state | `*/current.md` | Mutated in place | Answer "what is true now?" |
| Evidence | `history/YYYY-MM.md`, `sessions/YYYY-MM.md` | Append-only | Preserve what happened and when |
| Distillation | `insights/current.md`, parts of `recipes/current.md` | Mutated when evidence improves | Keep recommendations easy to use |

This prevents the agent from replaying an entire history every time it needs to know what beans are available.

## Required behavior for agents

1. Read current state before editing.
2. Use monthly append-only logs for events.
3. Keep labels and IDs stable.
4. Prefer `unknown` over invented facts.
5. For bean inventory updates, use available package/label evidence first; when important metadata is still missing and web tools are available, make a best-effort lookup against official roaster or shop pages before finalizing.
6. Cite recent sessions when making recommendations.
7. Use UTC timestamps unless the user requests a different timezone.
8. Keep changes small and human-readable.

## Bean metadata enrichment

Beantr stays filesystem-native: web access is not required to use a ledger. When an agent does have search or browser tools, it should use them as a lightweight enrichment step for missing bean metadata such as species, variety/cultivar, origin, farm, producer, process, altitude, score, roast profile, sensory notes, lot, harvest, and official product URL.

Use this source order:

1. User-provided facts and visible package/label details.
2. Official roaster or shop product pages for the same coffee/lot.
3. Other roaster-owned pages, archived product pages, or reputable coffee listings.

Do not copy facts from a merely similar coffee. If the online source does not clearly match the user's bag or lot, leave uncertain fields as `unknown`, record the search/source notes, and tell the user what remains missing. User-specific state such as remaining grams, container, freezing date, and storage location should come from the user or ledger, not from online listings.

## Bean IDs and labels

Use stable IDs for internal references and human labels for conversation.

Example:

```markdown
| id | label | coffee_name | roaster | remaining_g | container | state |
|---|---|---|---|---:|---|---|
| dak-milky-cake-2026-06 | Milky Cake | Milky Cake | DAK | 180 | freezer box A | frozen |
```

A label can change for readability. An ID should not change unless it was wrong.

## Session entries

A good session entry is detailed enough to guide the next brew:

```markdown
### 2026-06-30T18:20:00Z — Milky Cake / espresso

- Bean ID: dak-milky-cake-2026-06
- Method: espresso
- Grinder: Lagom P64
- Grinder setting: 3.8
- Dose: 18 g
- Yield/water: 42 g
- Ratio: 1:2.33
- Temperature: 93 °C
- Brew time: 31 s
- Sensory result: bright, aromatic, slightly sour finish
- Score: 3.5/5
- Next change: grind slightly finer or increase yield target more conservatively
```

## Recommendation policy

Agents should state how strong the evidence is:

- **High confidence**: repeated good sessions with same bean/method.
- **Medium confidence**: one good session or multiple similar beans/methods.
- **Low confidence**: general brewing heuristic only.

Do not present generic brewing theory as if it were personalized evidence.
