In-Memory Order Updater TODO
===

- [ ] Consider Sofia's recommendation to break this class into POROs to simplify testing
- [ ] Add test coverage for `update_item_total` when line item totals change
- [ ] Test coverage to ensure state changes aren't persisted (if someone changes current implementation)
- [ ] Handle persistence in `update_promotions`
- [ ] Handle persistence in `update_taxes`
