# PromotionMigrator duplicate code fix

## Context

During migration from `solidus_legacy_promotions` to `solidus_promotions`, `PromotionMigrator#copy_promotion_codes`
uses a SQL join from legacy code batches to new code batches.

In current releases (4.4.x, 4.5.x, 4.6.x, and `main` at time of writing), the relevant join condition is:

```sql
LEFT OUTER JOIN solidus_promotions_promotion_code_batches
  ON solidus_promotions_promotion_code_batches.base_code = spree_promotion_code_batches.base_code
```

## Problem

`base_code` is not globally unique across promotions. If multiple promotions have code batches with the same
`base_code`, this join can match more than one target row for a single source row.

That multiplies result rows in `INSERT ... SELECT`, which can duplicate `value` insert attempts into
`solidus_promotions_promotion_codes`.

Because `solidus_promotions_promotion_codes.value` is unique, migration can fail with:

```text
PG::UniqueViolation: duplicate key value violates unique constraint
"index_solidus_promotions_promotion_codes_on_value"
DETAIL: Key (value)=(suvie-lgm4gw) already exists.
```

## Change

Constrain the join to the current migrated promotion and the copied batch timestamp:

```sql
LEFT OUTER JOIN solidus_promotions_promotion_code_batches
  ON solidus_promotions_promotion_code_batches.base_code = spree_promotion_code_batches.base_code
  AND solidus_promotions_promotion_code_batches.promotion_id = #{Integer(new_promotion.id)}
  AND solidus_promotions_promotion_code_batches.created_at = spree_promotion_code_batches.created_at
```

This makes each migrated code row resolve to the corresponding batch for the promotion currently being migrated,
preventing cross-promotion row multiplication.

## Validation

A regression spec covers two legacy promotions that both have `PromotionCodeBatch` records with the same
`base_code`. The migration now inserts each code exactly once, without duplicate key violations.

## Related issues and pull requests reviewed

- Searched open and closed issues/PRs in `solidusio/solidus` for:
  - `PromotionMigrator`
  - `copy_promotion_codes`
  - `base_code`
  - promotion code migration duplicate-key failures
- No issue or PR appears to cover this specific join condition in `PromotionMigrator#copy_promotion_codes`.
- Historic issue [`#1248`](https://github.com/solidusio/solidus/issues/1248) was reviewed. It concerns an older
  migration path (`spree_promotions.code` to `spree_promotion_codes`) and is not the same bug as this
  cross-promotion batch join multiplication.
