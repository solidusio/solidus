# Return items

The `Spree::ReturnItem` model is the central model in Solidus's return system.
All of the other models related to returns either use or depend on return items.

Return items are associated with [`Spree::InventoryUnit`s][inventory-units] and
can be re-added to your store's inventory once they are received.

A `Spree::ReturnItem` has the following attributes:

- `return_authorization_id`: The ID for the `Spree::ReturnAuthorization`
  associated with the return item.
- `inventory_unit_id`: The ID for the `Spree::InventoryUnit` that is associated
  with the return item.
- `exchange_variant_id`: If the `Spree::ReimbursementType` is an exchange, this
  attribute's value is the variant ID that is going to be exchanged.
- `amount`: The amount that the customer paid for the item.
- `included_tax_total`: The amount of [VAT-style tax][vat] included in the
  `amount` of the item.
- `additional_tax_total` The amount of sales tax that the customer paid for the
  item.
- `reception_status`: Tracks whether the stock location has received the item.
  See [Reception states](#reception-states) for more information.
- `acceptance_status`: Tracks the acceptance status of the return item. The
  possible states include `pending`, `accepted`, and `rejected`.
- `customer_return_id`: The ID for the `Spree::CustomerReturn` that includes the
  return item.
- `reimbursement_id`: The ID for the `Spree::Reimbursement` that includes the
  return item.
- `exchange_inventory_unit_id`: If the `Spree::ReimbursementType` is an
  exchange, this attribute's value is the ID of the `Spree::InventoryUnit` that
  that is going to be exchanged.
- `acceptance_status_errors`: A hash that lists reasons why the return item does
  is not acceptable.
- `preferred_reimbursement_type_id`: The ID for the reimbursement type that was
  originally set for the return item.
- `override_reimbursement_type_id`: An optional reimbursement type that
  overrides the preferred reimbursement type.
- `resellable`: States whether the return item can be re-sold.
- `return_reason_id`: The ID for the `Spree::ReturnReason` that is given for the
  item.

[vat]: ../taxation/value-added-tax.html
[inventory-units]: ../inventory/inventory-units.html

## Reception states

The `Spree::ReturnItem` object tracks whether your stock location has received
the item. The following reception states are available:

- `awaiting`
- `canceled`
- `expired`
- `given_to_customer`
- `in_transit`
- `lost_in_transit`
- `received`
- `shipped_wrong_item`
- `short_shipped`
- `unexchanged`

In order to offer a reimbursement to the customer, the status needs to be
`received`.

## Acceptance

Return items can be accepted or rejected based on defined business reasons.

For example, Solidus rejects returns on items that are not included in a
[`Spree::ReturnAuthorization`][return-authorizations]. If the item is not
referenced in a return authorization, then the `Spree::ReturnItem`'s
`acceptance_status` transitions to `rejected` and the `acceptance_status_errors`
attribute should have the following value:

```ruby
{:rma_required=>"Return item requires an RMA"}
```

### Change acceptance behavior

Return items are accepted or rejected using the
`Spree::ReturnItem::EligibilityValidator` classes. You can change the
eligibility validators that your store uses by overriding the `::Default`
subclass' list in an initializer.

For example, by default Solidus rejects return items that are not included in a
return authorization using the
`Spree::ReturnItem::EligibilityValidator::RMARequired` class. You could exclude
the `RMARequired` item when you replace the list of eligibility validators in
your `config/initializers/spree.rb` initializer:

```ruby
Rails.application.config.to_prepare do
  Spree::ReturnItem::EligibilityValidator::Default.permitted_eligibility_validators = [
    ReturnItem::EligibilityValidator::OrderCompleted,
    ReturnItem::EligibilityValidator::TimeSincePurchase,
    ReturnItem::EligibilityValidator::InventoryShipped,
    ReturnItem::EligibilityValidator::NoReimbursements,
  ]
end
```

See the
[`Spree::ReturnItem::EligibilityValidator::Default`][eligibility-validator-default]
for a list of the default eligibility validators.

<!-- TODO:
  This documentation does not cover how acceptance works extensively.
-->

[eligibility-validator-default]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/return_item/eligibility_validator/default.rb
[return-authorizations]: return-authorizations.html
