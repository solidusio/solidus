# Order state machine

Orders flow through a state machine, which is defined in the
`Spree::Order::Checkout` module. It begins with a `cart` state and ends with
at a `complete` state.

There are six order states by default:

1. `cart`
2. `address`
3. `delivery`
4. `payment`
5. `confirm`
6. `complete`

If you go through the checkout provided in the `solidus_frontend` gem, you can
see that there is a clearly defined step for each of these states during checkout.

The `payment` state is optional and it's only triggered if `payment_required?`
returns `true`.

The `complete` state is triggered in one of two ways:

1. No payment is required on the order. (The `total` equals `0`.)
2. Payment is required on the order, and at least the order total has been
   received as payment.

## State criteria

Each order state has criteria that must be met before the state can change. For
example, before the state can change from `cart` to `address`, line items must be
present on the order. Then, to change from `address` to `delivery`, the user
must have a default address assigned.

Once an order meets the criteria to go to the next state, you can call `next` on
the order object to transition into the next state. For example, in the
`solidus_frontend` gem, the [`Spree::CheckoutController`][checkout-controller]
defines a `transition_forward` method that always calls `next` unless the order
can be completed:

```ruby
# /frontend/app/controllers/spree/checkout_controller.rb
def transition_forward
  if @order.can_complete?
    @order.complete
  else
    @order.next
  end
end
```

If `next` returns `false`, then the order does not meet the criteria and does
not transition to the next state.

[checkout-controller]: https://github.com/solidusio/solidus/blob/master/frontend/app/controllers/spree/checkout_controller.rb

## Payments and shipments have their own state machines

Note that a `Spree::Order` with the state `complete` does not mean that the
payment has been processed or the order shipments have been shipped. See also
the values of the [`payment_state`][payment-states] and
[`shipment_state`][shipment-states] attributes.

<!-- TODO:
  Documentation about the checkout flow could be extended.
-->

[payment-states]: ../payments/overview.html#payment-states
[shipment-states]: ../shipments/overview.html#shipment-states
