# Physical-container integrity

Use this reference when a user assigns, moves, empties, reuses, or corrects a named coffee container.

## Occupancy audit

1. Read the whole live inventory, not only rows for the new coffee.
2. Ignore rows that are explicitly finished or have `0g` remaining.
3. Build one occupancy entry for every named reusable container.
4. Expand active batch rows into one entry per current member.
5. Compare normalized IDs. Normalize case and whitespace, but preserve numeric text and leading zeros.
6. Report any occupancy key with more than one active coffee.
7. Also flag finished rows with a positive remainder, active rows with `0g`, and batch members that were already consumed or reused.

Generic locations such as a freezer, shelf, cabinet, or pantry are not exclusive containers. Several distinct bags can occupy the same location. A source bag remains a bean-specific row even when several rows display `open bag`.

## Examples

### New coffee placed into an occupied jar

Live state:

- `Jar A` contains 83g of Coffee Y.

User statement:

- `I put 150g of Coffee X into Jar A.`

Required response:

- Do not create a second active `Jar A` row.
- Do not mark Coffee Y as consumed.
- Ask: `Jar A still contains 83g of Coffee Y in the live inventory. Was it finished, moved somewhere else, discarded, or is the container label wrong?`

### Explicit replacement

User statement:

- `Coffee Y is finished, and I put 150g of Coffee X into Jar A.`

Required update:

- Set the Coffee Y portion in `Jar A` to `0g` and `finished`.
- Create or update the Coffee X portion in `Jar A` with 150g.
- Append one history event that records the old occupant, its confirmed end, and the new occupant.

### Previous coffee moved elsewhere

User statement:

- `I removed Coffee Y from Jar A, returned it to its bag, and put Coffee X into the jar.`

Required update:

- Add the removed amount back to the correct Coffee Y source row when the amount and source bag are known.
- Set Coffee Y's `Jar A` portion to `0g` and `finished` only after recording the move.
- Assign Coffee X to `Jar A`.
- Validate the source bag and `Jar A` as separate destinations.

If the amount moved is unknown, preserve that uncertainty. Do not invent a reconciled balance.

### Previous coffee removed, destination unknown

User statement:

- `I removed Coffee Y from Jar A, but I do not know where it went.`

Required update:

- Keep Coffee Y active with its last known amount.
- Change its container to `unknown`.
- Free `Jar A` only because the user explicitly confirmed that Coffee Y left it.

### Tube reused by another coffee

Live state:

- Tube `30` is a current member of Coffee Y's frozen batch.

User statement:

- `I put 17g of Coffee X into tube 30.`

Required response when the prior fate is missing:

- Do not leave tube `30` in Coffee Y's batch while creating Coffee X's tube row.
- Ask what happened to Coffee Y in tube `30`.

Required update when the user says Coffee Y was consumed:

- Remove `30` from Coffee Y's current `container_members`.
- Decrement Coffee Y's aggregate weight when its dose is known. Otherwise keep the aggregate amount `unknown` and record why.
- Create or update Coffee X's tube `30` row.
- Append the reuse event to history.

### Identifier ambiguity

Treat `Jar A` and `jar a` as the same container after case and whitespace normalization. Preserve `08` exactly. Do not assume `tube 8` and `tube 08` are the same physical tube unless the user or existing ledger establishes that alias.

### Shared storage location

Two bean-specific bags may both use `freezer` as their location. This is valid because the freezer is a location, not a single exclusive container. Two active coffees may not both use the same named jar or tube.
