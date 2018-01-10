# Overview

The `Spree::Order` model is one of the key models in Solidus. It provides a
central place around which to collect information about a customer order. It
collects line items, adjustments, payments, addresses, return authorizations,
and shipments. 

Orders have the following attributes:

- `number`: The unique identifier for this order. It begins with the letter `R`
  and ends in a nine-digit number (for example, `R123456789`). This number is
  shown to the users, and can be used to find the order by calling
  `Spree::Order.find_by(number: "R123456789")`.
- `item_total`: The sum of all the line items for this order.
- `total`: The sum of the `item_total` and the `adjustment_total` attributes.
- `state`: The current state of the order. See the [Order state
  machine][order-state-machine] article for more information.
- `adjustment_total`: The sum of all adjustments on this order.
- `user_id`: The ID for the order's corresponding user. Stored only if the order
  is placed by a signed-in user.
- `completed_at`: The timestamp that logs when the order is completed.
- `bill_address_id` and `ship_address_id`: The IDs for the related
  `Spree::Address` objects with billing and shipping address information.
- `payment_total`: The sum of all the *finalized* payments on the order.
- `shipment_state`: The current [shipment state][shipment-states] of the order.
- `payment_state`: The current payment state of the order.
- `email`: The customer-provided email address for the order. This is stored in
  case the order is for a guest user.
- `special_instructions`: Any [special shipping
  instructions][special-instructions] that shave been specified by the customer
  during checkout.
- `currency`: The currency for this order. Determined by the
  `Spree::Config[:currency]` value that was set at the time of order.
- `last_ip_address`: The last IP address used to update this order in the
  frontend.
- `created_by_id`: The ID of object that created this order.
- `shipment_total`: The sum of all the shipments associated with an order.
- `additional_tax_total`: The sum of all the `additional_tax_total`s (sales tax)
  on an order's line items and shipments. 
- `promo_total`: The sum of all of the `promo_total`s on an order's shipments,
  line items, and promotions.
- `channel`: The channel specified when importing orders from other stores. For
  example, if you operate as an Amazon Seller and import orders from Amazon,
  some orders may have a channel value of `amazon`. Otherwise, this value is
  `spree`.
- `included_tax_total`: The sum of all the `included_tax_total`s (value-added
  tax) on an order's line items and shipments.
- `item_count`: The total amount of line items associated with the order.
- `approver_id`: The ID of user that approved the order.
- `approver_name`: The name of the user that approved the order.
- `approved_at`: The timestamp logging when this order is approved by the
  approver.
- `confirmation_delivered`: Boolean value that indicates that an order
  confirmation email has been delivered.
- `guest_token`: The guest token that links an uncompleted order to a specific
  guest user (via browser cookies).
- `canceler_id`: The ID of user that canceled this order.
- `canceled_at`: If the order is cancelled, this timestamp logs when the order
  was cancelled.
- `store_id`: The ID of `Spree::Store` in which the order has been created.

[display-totals-methods]: display-totals-methods.md
[order-state-machine]: order-state-machine.md
[shipment-states]: ../shipments/overview-of-shipments.md#shipping-states
[special-instructions]: ../shipments/user-interface-for-shipments.md#shipping-instructions
[update-orders]: update-orders.md

Some methods you may find useful:

* `outstanding_balance`: The outstanding balance for the order, calculated by
  taking the `total` and subtracting `payment_total`.
* `display_item_total`: A "pretty" version of `item_total`. If `item_total` was
  `10.0`, `display_item_total` would be `$10.00`.
* `display_adjustment_total`: Same as above, except for `adjustment_total`.
* `display_total`: Same as above, except for `total`.
* `display_outstanding_balance`: Same as above, except for
  `outstanding_balance`.

## The Order State Machine

Orders flow through a state machine, beginning at a `cart` state and ending up
at a `complete` state. The intermediary states can be configured using the
[Checkout Flow API](checkout).

The default states are as follows:

* `cart`
* `address`
* `delivery`
* `payment`
* `confirm`
* `complete`

The `payment` state will only be triggered if `payment_required?` returns
`true`.

The `confirm` state will only be triggered if `confirmation_required?` returns
`true`.

The `complete` state can only be reached in one of two ways:

1. No payment is required on the order.
2. Payment is required on the order, and at least the order total has been
received as payment.

Assuming that an order meets the criteria for the next state, you will be able
to transition it to the next state by calling `next` on that object. If this
returns `false`, then the order does *not* meet the criteria. To work out why it
cannot transition, check the result of an `errors` method call.

## Line Items

Line items are used to keep track of items within the context of an order. These
records provide a link between orders, and [Variants](products#variants).

When a variant is added to an order, the price of that item is tracked along
with the line item to preserve that data. If the variant's price were to change,
then the line item would still have a record of the price at the time of
ordering.

* Inventory tracking notes

$$$ Update this section after Chris+Brian have done their thing.  $$$

## Addresses

An order can link to two `Address` objects. The shipping address indicates where
the order's product(s) should be shipped to. This address is used to determine
which shipping methods are available for an order.

The billing address indicates where the user who's paying for the order is
located. This can alter the tax rate for the order, which in turn can change how
much the final order total can be.

For more information about addresses, please read the [Addresses](addresses)
guide.

## Adjustments

Adjustments are used to affect an order's final cost, either by decreasing it
([Promotions](promotions)) or by increasing it ([Shipping](shipments),
[Taxes](taxation)).

For more information about adjustments, please see the
[Adjustments](adjustments) guide.

## Payments

Payment records are used to track payment information about an order. For more
information, please read the [Payments](payments) guide.

## Return Authorizations

$$$ document return authorizations.  $$$

## Updating an Order

If you change any aspect of an `Order` object within code and you wish to update
the order's totals -- including associated adjustments and shipments -- call the
`update_with_updater!` method on that object, which calls out to the
`OrderUpdater` class.

For example, if you create or modify an existing payment for the order which
would change the order's `payment_state` to a different value, calling
`update_with_updater!` will cause the `payment_state` to be recalculated for
that order.

Another example is if a `LineItem` within the order had its price changed.
Calling `update_with_updater!` will cause the totals for the order to be
updated, the adjustments for the order to be recalculated, and then a final
total to be established.

