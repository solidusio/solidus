In-Memory Order Updater TODO
===

- [x] Add additional cases to item_total_updater_spec (doesn't currently account for included adjustments)
- [x] Consider Sofia's recommendation to break this class into POROs to simplify testing
- [x] Add test coverage for `recalculate_item_total` when line item totals change
- [x] Scope handling of tax adjustments in `InMemoryOrderUpdater` to *not* marked for destruction
- [x] Scope handling of tax adjustments in `OrderUpdater` to *not* marked for destruction
- [x] Ensure order-level tax adjustments (like Colorado delivery) are scoped out of tax total and adjustment total calculations
- [x] Handle persistence in `update_taxes`
- [x] ~Write the `InMemoryOrderAdjuster` (also, should we rename this to `InMemoryOrderPromotionAdjuster`)~
- [ ] Fix CI failures from previous session (if any)
- [ ] Add high level test for manipulative queries around new Promotion system
- [ ] Add high level test for manipulative queries around Legacy Promotion system
- [ ] Adding shared examples that could be used in both promotion system gems to
  ensure the above?
- [In Progress] Handle persistence in all implementations of `promotions.order_adjuster_class`
  - [x] Follow up on any failing test relating to change in promotion chooser
  - [x] Ensure adjustments are marked for destructions instead of destroyed
  - [ ] Continue on with new promotion system similar change
    - [ ] DiscountOrder
- [ ] Investigate if any promotion actions write to the database when calling `compute_amount`
  - [ ] Create quantity adjustments, this action persists when compute_amount is called
- [ ] Test coverage to ensure state changes aren't persisted (if someone changes current implementation)
- [ ] We should be able to blow up if something tries to persist
  - https://github.com/sds/db-query-matchers/blob/0deaaac360f43e6cc15c03a7fca8425cf65dd703/lib/db_query_matchers/make_database_queries.rb#L74-L82
  - https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html#method-c-subscribed
  - "By calling this in memory order updater, we are making a contract with the user that it will be in memory"
  - "This is really something which theoretically should be covered in tests"

