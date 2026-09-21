---
name: beantr
description: Manage a personal coffee inventory, brew log, recipes, and recommendations through Markdown files instead of an API or database.
version: 1.1.0
author: Tiago Moraes
license: MIT
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
- `container_id` for an individually named reusable container
- `container_members` for the exact current members of a multi-container row
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
2. Read the relevant `current.md` files first. For any assignment to a named physical container, read the entire live bean inventory and build the physical-container occupancy map before editing.
3. Resolve the current occupant of every source and destination container. Apply the physical-container exclusivity rules below before changing the ledger.
4. Read recent session/history files only when needed for evidence.
5. For bean inventory updates, enrich missing important metadata from online sources when tools are available and the lookup can be done without delaying the core update.
6. Make the smallest file updates that reflect the user's statement and any trustworthy enrichment. When a reusable container changes coffee, update the old and new assignments in the same operation.
7. Append to the correct monthly log when an event occurred, including the prior occupant and its fate when a container was reused.
8. Update `recipes/current.md` or `insights/current.md` only if the new evidence changes a recommendation.
9. If the user later clarifies a missing brew variable from the same session, append a short clarification entry to the same month log and propagate the stable fact into the recipe/insight files.
10. Run the post-write container-integrity checks below before claiming success.
11. Report exactly what changed, what source was used, and what remains uncertain.

### Espresso logging and inherited grinder settings

When the user logs an espresso and says the grinder configuration was unchanged from the previous espresso:

- Resolve the most recent logged espresso using the same grinder, rather than guessing from a filter brew or from an unrelated bean.
- Carry forward the grinder model and setting as an explicitly inherited fact, and note the source session in the new brew entry.
- If there is no unique prior espresso setting, leave the setting as `unknown` and ask one concise clarification only when the ambiguity materially affects the record.
- Compute and record the brew ratio from dose and yield, and decrement the live inventory by the dose.
- If the bag was sealed, change it to open after the first brew.
- When the user reports a clearly positive cup, add a bean-scoped recipe baseline while preserving unknown variables (for example temperature).

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

For V60/filter recommendations where the user wants acidity and clarity, especially with fermented/yeast-process coffees or large doses that create a deep bed, default to controlled pours and light final swirl rather than heavy repeated agitation. Explain that this is a clarity-oriented recommendation: less fines migration, less stalling, and less risk of harsh/alcoholic/heavy notes. Increase agitation only when the cup is under-extracted, sour, thin, or flat.

Label advice as a recommendation, not a fact, unless it is directly supported by logged sessions.

## Multi-container splits and corrections

- When one coffee is split across physical packages or containers, create one stable live row per portion/container; preserve the same coffee metadata and vary only storage, state, and remaining weight.
- If the transfer amount is unknown, do not copy the last known combined weight into multiple rows. Set the affected source/portion weights to `unknown`, preserve the last known combined remainder in notes/history, and ask for or accept a later weighing.
- When later per-container estimates are supplied, calculate the implied total with a tool and compare it with the previous aggregate estimate. Preserve the user's component estimates as approximate, record any discrepancy in history, and do not silently force the numbers to reconcile.
- If a later statement is internally ambiguous (for example, the stated total conflicts with the per-tube amount and claimed bag remainder), ask one concise clarification before editing the ledger.
- If the user says a portion moved directly from frozen storage without thawing, mark that portion `frozen`; use `thawing` only when the user says it is thawing. Keep an open bag explicitly outside the freezer when that distinction matters.
- If a container or Bean ID is later corrected, update the live `current.md` source of truth, but preserve append-only history/session records and append a dated clarification that references the old and corrected IDs.
- Never leave two active portions assigned to the same named physical container. A new assignment does not prove that the previous coffee was consumed.
- For tube batches, preserve every user-provided tube identifier verbatim as a string, including leading zeros (for example `02`, `08`, or `09`); record the count, per-tube estimate, total estimate, and frozen/thawing state separately.

### Physical-container identity and exclusivity

Treat a named reusable container as an exclusive physical resource, not as free-text metadata.

Definitions:

- An **exclusive container** is an individually named reusable vessel such as `Jar A`, `Jar B`, `tube 08`, or `canister 3`. It can hold at most one active coffee at a time.
- A **location** such as `freezer`, `cabinet`, or `shelf` may hold several packages and does not have this one-coffee restriction.
- An **active assignment** is any live row whose coffee is not explicitly finished, discarded, or at `0g`. Treat `remaining_g: unknown` as active, not empty.
- Use a stable `container_id` when the ledger format supports it, for example `jar-a`, `jar-b`, or `tube-08`. Normalize case and surrounding whitespace, but preserve user-provided numeric identifiers and leading zeros. If `tube-8` and `tube-08` may be aliases, flag the ambiguity instead of merging them silently.
- A batch row for several tubes must store the exact current `container_members`, not only the original list. Every member participates in the same exclusivity check as an individual row.
- Finished historical rows may retain their old container label. They do not count as active occupants.

Required workflow for every container assignment or transfer:

1. Read the full live inventory and build an occupancy map keyed by each exclusive `container_id`. Expand every active batch into its individual member IDs.
2. If the target container is free, or its only prior assignment is explicitly finished, assign the new coffee and append the event to history.
3. If the target already contains the same coffee, update the existing live row instead of creating a second active row.
4. If the target contains a different active coffee and the user's statement explicitly says what happened to it, record both sides in the same update. Mark it finished only when the user says none remains. If it moved, update its destination and validate that destination too.
5. If the target contains a different active coffee and the user did not explain its fate, do not write a second assignment and do not assume that the old coffee was consumed. Ask one concise question that names the conflict, for example: `Jar A still contains 83g of Coffee Y in the live inventory. Was it finished, moved somewhere else, discarded, or is the container label wrong?`
6. If the user confirms that the previous coffee left the container but does not know where it went, keep that coffee active with `container: unknown` and preserve its last known amount. Do not set it to `0g`.
7. If the ledger already contains a conflict, do not choose a winner or silently close a row. Report every conflicting active assignment and ask for the smallest correction needed.

Post-write container-integrity checks:

- Each exclusive physical container has zero or one active coffee.
- No active tube appears both inside a batch and as another active row, or in two different active batches.
- Every batch's member list contains only current members. Consumed, moved, or reused containers are removed from that list.
- A row marked finished has `0g`, and a row with a positive or unknown remainder is not marked finished.
- A transfer updates both the source balance and the destination assignment when those facts are known.
- If any check fails, fix the ledger or ask for clarification. Do not report the update as complete while the conflict remains.

See `references/physical-container-integrity.md` for worked examples and an audit procedure.

## File editing rules

- Preserve user labels, IDs, and headings.
- Use UTC timestamps in ISO 8601 format unless the user asks otherwise.
- Keep monthly logs append-only: append new events at end-of-file, not near a matching heading or earlier event.
- When patching an append-only Markdown log, use a unique end-of-file anchor; avoid broad or duplicated text anchors that can insert an entry in the wrong chronological position.
- After any patch to a log, re-read the relevant tail (and the whole file before any full overwrite) to verify ordering, preserve prior fields, and confirm the new event appears exactly once.
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
- after a correction, the live row uses the corrected ID while the old ID appears only in append-only clarification history;
- every named reusable physical container has at most one active coffee;
- active batch members do not overlap individual rows or other active batches;
- reused containers have an explicit disposition for the prior coffee in history;
- the user can understand the changed files without special software.