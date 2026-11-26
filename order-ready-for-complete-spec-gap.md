# Facts: spec gap for `order_payment_ready_checks` (outline, not prose)

## Change under review
- `class_methods.rb:95`: four `before_transition to: :complete` hooks replaced by one, `:order_ready_for_complete`
- `order.rb:736`: `Spree::Config.order_payment_ready_checks.none? { it.to_proc.call(self) == false }`
- `app_configuration.rb:276`: default list of four Symbols
- The four check methods moved above `private` (public now) so `Symbol#to_proc` (`public_send`) can reach them

## Halting semantics
- `state_machines-activemodel` 0.9.0, `integrations/active_model.rb:434`: terminator is `result == false`
- Only `false` halts. `nil` and `true` continue
- Default checks return: `validate_line_item_availability` nil, `ensure_promotions_eligible` true, `ensure_line_item_variants_are_not_deleted` true, `ensure_inventory_units` nil (raise `InsufficientStock` on failure)
- Hence `== false` rather than `all?`; `all?` returned false on a valid order

## Existing coverage
- `order_spec.rb` `#order_ready_for_complete`: runner in isolation (6 examples: false halts, all pass, Symbol, proc, stops at first false, defaults on a valid order / raises on no stock)
- `order_spec.rb` 302, 1845, 1879: unit specs for three of the checks, called directly
- `order/checkout_spec.rb` 573, 606, 700-703: instance stubs of the checks; still work because `public_send` hits instance stubs
- `order/state_machine_spec.rb`: `#next!` / `#complete` flows; never mentions the checks
- Run: `spec/models/spree/order/`, `order_spec.rb`, `spec/lib/spree/core/state_machines_spec.rb` -> 415 examples, 0 failures

## Gap
- No spec drives the real `:complete` transition with a stubbed `order_payment_ready_checks`
- Not proven: a `false` from a check makes `order.complete` return false and leave state unchanged
- Not proven: a proc added to the config list runs during `complete!`
- The old four hooks had the same gap beyond the per-method unit specs; the config now drives the wiring, so it matters more

## Possible specs (not written)
- In `state_machine_spec.rb` under `#complete`, reuse the `payment` -> complete setup:
  - stub checks to `[->(_) { false }]`, expect `order.complete` false and state unchanged
  - stub checks to `[->(o) { seen = o }]`, call `complete!`, expect `seen == order`

## Open design points
- `nil` from a custom check counts as a pass
- Checks are now public API on `Spree::Order` (upgrade-path concern for stores overriding them)
- Whether to also expose the list to `:resumed` (`ensure_line_item_variants_are_not_deleted` and `validate_line_item_availability` are still hardcoded there, `class_methods.rb:89-90`)
