---
name: beantr
description: Manage a personal coffee inventory, brew log, recipes, and recommendations through Markdown files instead of an API or database.
version: 1.0.0
author: Tiago Moraes
license: Unspecified
platforms: [linux, macos, windows]
metadata:
  beantr:
    ledger_default: "~/beantr"
    format: markdown-ledger
    requires_tools: [read_file, write_file, patch, search_files]
  hermes:
    tags: [coffee, markdown, filesystem, personal-assistant, inventory, brewing]
---

# Beantr

Use this skill when a user wants an AI assistant to manage coffee context through the filesystem.

Beantr is intentionally file-native. Do not look for a Beantr API, MCP server, database, or web backend. The assistant should read and write a small set of Markdown files that remain understandable to humans.

## Core responsibilities

Manage these domains:

- bean inventory and container assignments;
- brewing gear and default method context;
- canonical recipes and preferred brew profiles;
- append-only brew sessions;
- distilled recommendations and insights.

## Default ledger layout

Assume the ledger lives at `~/beantr` unless the user gives another path.

```text
beantr/
  README.md
  beans/current.md
  beans/history/YYYY-MM.md
  gear/current.md
  gear/history/YYYY-MM.md
  recipes/current.md
  sessions/YYYY-MM.md
  insights/current.md
```

## File roles

### `beans/current.md`

Live inventory: what beans exist now, how much is left, and where they are stored.

Recommended fields:

- `id`
- `label`
- `coffee_name`
- `roaster`
- `species`
- `origin`
- `producer`
- `farm`
- `variety`
- `process`
- `altitude_m`
- `score`
- `sensory_notes`
- `roast_date`
- `purchase_date`
- `bag_size_g`
- `remaining_g`
- `container`
- `container_capacity_g`
- `state`
- `priority`
- `source_url`
- `notes`

### `beans/history/YYYY-MM.md`

Append-only inventory changes: new bags, moved beans, finished beans, corrections.

### `gear/current.md`

Permanent or semi-permanent brewing context: grinders, espresso machines, brewers, kettles, filters, water, scales, and recurring constraints.

### `gear/history/YYYY-MM.md`

Append-only gear changes: new equipment, repairs, calibration notes, water changes.

### `recipes/current.md`

Current preferred recipes. A recipe can be scoped to a bean, roaster, process, brew method, grinder, or general default.

### `sessions/YYYY-MM.md`

Append-only brew log. Each brew session should capture enough detail to support later recommendations.

Recommended fields:

- timestamp
- bean id / label
- method
- grinder and setting
- dose
- yield / water
- ratio
- temperature
- time
- sensory result
- score
- next change

### `insights/current.md`

Distilled advice from the evidence. Update this only when there is enough signal to be useful.

## Metadata enrichment

When adding or correcting a bean, capture important coffee metadata from the user statement and package/label images first. If important fields remain unknown and web/search tools are available, make a best-effort online lookup before finalizing the inventory update.

Important metadata includes:

- species;
- variety/cultivar;
- origin, country, region, farm, and producer;
- process/fermentation;
- altitude;
- score or grade;
- roast profile/level;
- sensory notes;
- lot, harvest, or batch identifiers;
- official product/source URL.

Source priority:

1. User-provided facts and visible package/label details.
2. Official roaster or shop product pages for the same coffee/lot.
3. Other roaster-owned pages, archived product pages, or reputable coffee listings.
4. General web results only as search aids, not as proof.

Lookup rules:

- Search with the roaster, coffee name, farm/producer, variety, process, and any label-specific terms.
- Only copy online facts when the source plausibly matches the same coffee and lot; be especially careful with changing fields like roast date, availability, price, and current product batch.
- Prefer stable agronomic/profile facts from online sources over nothing, but keep storage facts, remaining weight, and user-specific dates from the user or ledger.
- Record the source URL or source description in `source_url` or `notes`, and append a history entry describing what was enriched.
- If sources conflict, preserve user/label facts, note the conflict, and leave uncertain fields as `unknown` unless the user resolves it.
- If no trustworthy source is found quickly, do not stall the update; write `unknown` and report which fields remain missing.
- Never infer lot-specific metadata from a different coffee just because it has the same roaster, farm, or marketing name.

## Update workflow

When the user logs a brew, adds coffee, changes gear, or asks for advice:

1. Identify the ledger path.
2. Read the relevant `current.md` files first.
3. Read recent session/history files only when needed for evidence.
4. For bean inventory updates, enrich missing important metadata from online sources when tools are available and the lookup can be done without delaying the core update.
5. Make the smallest file updates that reflect the user's statement and any trustworthy enrichment.
6. Append to the correct monthly log when an event occurred, including metadata source notes when facts were enriched.
7. Update `recipes/current.md` or `insights/current.md` only if the new evidence changes a recommendation.
8. Report exactly what changed, what source was used, and what remains uncertain.

## Recommendation rules

Prefer evidence in this order:

1. Same bean and method.
2. Same bean with another method.
3. Same roaster, origin, process, or roast level.
4. Same grinder / brewer family.
5. General brewing heuristics.

Adjustment heuristics:

- sour, sharp, thin, or fast: grind finer, increase contact time, increase temperature, or add gentle agitation;
- bitter, harsh, dry, or slow: grind coarser, reduce contact time, reduce temperature, or reduce agitation;
- weak or watery: increase dose or reduce yield/water;
- muddy or low clarity: reduce agitation, grind slightly coarser, or inspect fines/channeling;
- very good brews: preserve the recipe and make only one variable change next time.

Label advice as a recommendation, not a fact, unless it is directly supported by logged sessions.

## File editing rules

- Preserve user labels, IDs, and headings.
- Use UTC timestamps in ISO 8601 format unless the user asks otherwise.
- Keep monthly logs append-only.
- Do not derive live state only by replaying history when a `current.md` file exists.
- Do not silently delete uncertain information.
- If a value is unknown but the update can proceed, write `unknown` rather than inventing it.
- If the ambiguity changes the edit, ask a concise question.

## Good prompts

- "Log this shot: 18g in, 42g out, 31 seconds, sour but aromatic."
- "Add this new bag from Dak: Milky Cake, 250g, roasted yesterday."
- "Which beans should I finish first?"
- "What is my best V60 recipe for this coffee?"
- "Update the grinder setting for my default espresso recipe."
- "Summarize this month's brews and tell me what to try next."

## Verification checklist

Before replying after a Beantr edit:

- the live state answers "what is true now?";
- the appropriate append-only log contains the event;
- recommendations cite evidence or are clearly labeled as heuristics;
- online-enriched metadata includes a source or explicit uncertainty;
- IDs and labels stayed stable;
- the user can understand the changed files without special software.
