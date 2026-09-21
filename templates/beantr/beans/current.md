# Current Beans

Source of truth for beans that exist now.

## Inventory

| id | label | coffee_name | roaster | origin | process | roast_date | bag_size_g | remaining_g | container | container_id | container_members | state | priority | notes |
|---|---|---|---|---|---|---:|---:|---:|---|---|---|---|---|---|
| example-001 | Example Bag | unknown | unknown | unknown | unknown | unknown | 0 | 0 | unknown | unknown | [] | planned | normal | Replace this row with real coffee. |

## Notes

- Keep IDs stable.
- Give each named reusable jar, tube, or canister a stable `container_id`.
- For a batch of tubes, keep `container_members` equal to the exact current member IDs.
- Never assign two active coffees to the same named physical container.
- Use `unknown` rather than inventing missing facts.
- Update this file when live inventory changes.
