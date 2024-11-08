In-Memory Order Updater TODO
===

- [ ] Finish renaming methods that don't persist ever
- [ ] Consider Sofia's recommendation to break this class into POROs to simplify testing
- [ ] Address FIXME on renaming `recalculate_adjustments`?
- [ ] Add test coverage for `update_item_total` when line item totals change
- [ ] Test coverage to ensure state changes aren't persisted (if someone changes current implementation)
- [ ] Handle persistence in `update_promotions`
- [ ] Handle persistence in `update_taxes`
