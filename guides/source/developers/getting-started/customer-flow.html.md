# Customer flow

This article outlines a typical customer flow in Solidus on a technical level.
The [`Spree::Order`][spree-order] model ties much of this flow together.
However, every order placed touches many Solidus models.

At a high level, this article outlines these steps of a customer flow:

1. [Shopping](#shopping): The customer's pre-checkout activities. For example:
   the customer browses the store and adds items to the cart.
2. [Account](#account): The customer logs in to an account or checks out as a
   guest.
3. [Address](#address): The customer confirms billing and shipping addresses.
4. [Shipments](#shipments): Shipping and taxation is calculated. The
   customer can choose from available shipping methods.
5. [Promotions](#promotions)\*: The customer can apply code-based promotions to
   their order. Alternatively, Solidus may automatically apply a promotion based
   on other factors.
6. [Payments](#payments): The customer submits their payment information.
7. [Confirmation](#confirmation): The customer confirms and places their order.
8. [Capture and fulfillment](#capture-and-fulfillment): The payment is captured
   by the store (or manually by a store administrator), and the order shipments
   are shipped to the customer.

Note that this article does not detail _every_ single interaction that a Rails
server logs. Nor does it detail every single attribute on every single relevant
model. For example, it does not mention the `special_instructions` that a
customer might add to an order, or any of the order cancellation process.

\* Promotions can be applied at any point in the pre-checkout or checkout
process.

## Standard flow

### Shopping

Customer arrives at the store's URL.

- Solidus determines whether the customer is _new_ or _returning_.
  - If returning, Solidus determines whether the customer is a guest.
    - If customer was logged in during a previous session, Solidus determines
      whether customer should be logged in again.
  - If new, `guest_token` cookie might be generated for the customer.
- Solidus routes the user to the correct view (including the correct
  permissions).
- Store loads entrance page for user.

Customer navigates to a product page.

Customer chooses a variant of the product.

Customer chooses a quantity of the product.

Customer adds the product to their cart.

- A [`Spree::Order`][spree-order] object is created and given an `id`.
  - The order has a `state` of `cart`.
- A `Spree::LineItem` object is created for each item in the cart.
  - The line item records which [`Spree::Variant`][spree-variant] of a product
    the customer added to the cart.
  - The line item records the quantity of the `Spree::Variant` added to
    the cart.
  - The price of the variant is added to the line item.
  - The line item is associated with the customer's order using its
    `order_id` value.
  - The taxes and price adjustments start at `0.0`: they cannot be
    calculated until after the Solidus knows the customer's address.
  - The `tax_category_id` for each item is set according to the [tax
    category][tax-categories] of each item in the cart.

[spree-order]: overview.html
[spree-variant]: ../products-and-variants/variants.html
[tax-categories]: ../taxation/overview.html#tax-categories

### Account 

If the customer is not logged in, the user is asked to log into their
account or continue the checkout process as a guest.

- Customer logs in or continues checkout as a guest.
  - The `Spree::Order` is updated.
    - If the customer logs into an existing account, their `Spree::User`
      ID is now associated with the `Spree::Order`. The `user_id` value is
      no longer `nil`.
      - The current `Spree::Order` may be merged with the user's last
        order (if that order still had a `state` of `cart`).
    - If the customer creates a new account, their `Spree::User` is
      created. Its ID is now associated with the `Spree::Order` using
      the `user_id` value.
    - The `email` of the customer is no longer `nil`.
      - If the customer is logged in, the `email` from the `Spree::User`
        object is used as part of the order object.
      - If the customer is a guest, they are required to enter an
        email into a "Continue checking out as guest" form in order to
        continue, which will be used in as the `Spree::Order`'s `email`
        value.
    - The order's `state` changes from `cart` to `address`.

### Address

Customer submits shipping and/or billing address information for the
order.

- The customer's `tax_address` is set. By default, Solidus uses the
  [`Spree::Address`][spree-address] ID that's being used as the order's billing
  address.
- For each `Spree::LineItem`, a [`Spree::Adjustment`][spree-adjustment] is
  created and stores the item's calculated tax amount.
- The `Spree::LineItem` for each item in the cart is updated.
  - Now that the customer's `tax_address` is set, the order taxes can be
    calculated.
  - The `additional_tax_total`, `included_tax_total`, and `adjustment_total`
    values are updated from `nil` to an integer (according to the associated
    `Spree::Adjustment`).
    - Either the additional tax or the included tax total will be set to
      `0.0`, depending on whether the customer's shipping zone uses
      value-added tax or not.
- The `Spree::Order` object is updated.
  - The `bill_address_id` is no longer `nil` and is associated with a new
    `Spree::Address` with that ID.
  - The `ship_address_id` is no longer `nil` and is associated with a new
    `Spree::Address` with that ID.
    - If the customer used the same shipping address as the billing
      address, the `ship_address_id` and the `bill_address_id` would be
      the same ID.
  - The order state changes from `address` to `delivery`.
  - Note that even if the customer has ordered with the store previously and
    saved their address, the order's `bill_address_id` and `ship_address_id`
    values would have still been `nil` up until this point.
- A [`Spree::Shipment`][spree-shipment] object is created.
  - The shipment is given an 11-digit `number`: `H12341234123`.
  - Multiple `Spree::Shipment`s may be created. This depends on product
    availability, and a number of other (configurable) factors. For more
    information see the [Shipments][spree-shipment] documentation.

[spree-address]: ../users/addresses.html
[spree-adjustment]: ../adjustments/overview.html
[spree-shipment]: ../shipments/overview.html

### Shipments 

Customer chooses their [shipping method][shipping-methods] (if more than one is
available).

- _If the order includes multiple shipments, the customer may need to choose
  more than one shipping method for the order._
- A `Spree::Shipment` object is updated.
  - It is assigned an `order_id` that matches the `Spree::Order`.
  - Solidus checks for available [product stock][inventory].
    - If stock is available from a [stock location][stock-locations], the
      shipment's `state` is `pending`.
    - If stock is unavailable from any stock location, but the product is
      backorderable, the shipment's `state` is `backorder`.
  - A stock location is determined.
  - The shipment's price adjustments are added.
- At least one [`Spree::ShippingRate`][shipping-rates] object is created.
  - One object is created for each shipping method that may be picked to ship
    the order. That means even shipping methods that are never used are still
    calculated and created.
  - Each object calculates the total `cost` of this shipping rate on the current
    order.
  - Each shipping rate is associated with the shipment using the `shipment_id`
    value.
- For each `Spree::Shipment`, a [`Spree::Adjustment`][spree-adjustment] is
  created to store the shipment's calculated tax amount.
- The `Spree::Order` object is updated.
  - The order total is updated.
    - The correct shipping fees are added.
    - The `shipment_total` is no longer `nil`. It is updated with all
      shipping fees from associated `Spree::Shipment` objects.

[inventory]: ../inventory/overview.html
[shipping-methods]: ../shipments/overview.html#shipping-methods
[shipping-rates]: ../shipments/overview.html#shipping-rates
[stock-locations]: ../inventory/overview.html#stock-locations

<!-- TODO:
  What happens if shipping costs are taxable?
-->

### Promotions

Customer adds a promo code to their order.

- Solidus determines whether the [promotion][spree-promotion] is valid.
- It checks whether the cart passes the [promotion rules][promotion-rules].
  - It checks whether the promotion is past its expiration date.
  - It checks whether the promotion usage is exceeded.
  - Only if the above checks pass is a `Spree::OrderPromotion` object
    created.
- The new `Spree::OrderPromotion` object associates the `Spree::Order` ID
  with the `Spree::Promotion` ID.
  - If the promotion only applies to a specific product (or multiple
    products), that product's `Spree::LineItem` object is updated with a new
   `promo_total` value.
  - If the promotion only applies to a specific shipment (or multiple
    shipments), that shipment's `Spree::Shipment` object is updated with a new
    `promo_total` value.
  - If the promotion applies to the entire order and now a specific line
    item or shipment, only the `Spree::Order`'s	 `promo_total` value is
    updated.
- The `Spree::Order` object is updated.
  - The `promo_total` is no longer `nil`. It is updated with the values
    from all `promo_total` values associated with the order.

[promotion-rules]: ../promotions/promotion-rules.html
[spree-promotion]: ../promotions/overview.html

### Payments

Customer is prompted to enter payment information.

- The customer chooses an option from the listed payment methods
  ([`Spree::PaymentMethod`s][spree-payment-method]).
  - If customer has placed an order previously and saved payment
    information, the customer can use the payment details on file or
    choose a different payment method.
  - A new customer can choose one of the listed `Spree::PaymentMethod`s.
- Depending on which payment method the customer selected, the payment method
  uses its associated [payment service provider][payment-service-providers] that
  will process the payment.
- Based on the payment method, a [payment source][spree-payment-source] can be
  determined.
- A new [`Spree::Payment`][spree-payment] object that uses a `order_id` to
  associate with the `Spree::Order`.
  - The payment is associated with the `Spree::PaymentMethod`'s ID.
  - The payment has a `source_type` and `source_id` associated with the
    `Spree::PaymentMethod` and payment source being used.
  - The `state` of the payment is `checkout`.
- The `Spree::Order` object is updated.
  - The `payment_state` is no longer `nil` and is now `balance_due`.

[payment-service-providers]: ../payments/payment-service-providers.html
[spree-payment]: ../payments/payments.html
[spree-payment-method]: ../payments/payment-methods.html
[spree-payment-source]: ../payments/payment-sources.html

Customer enters their preferred payment details and submits them.


### Confirmation

Customer reviews the confirmation screen and places order.

- The `Spree::Payment`'s `state` changes from `checkout` to `pending`.
- The [`Spree::StockItem`'s][spree-stock-item] `count_on_hand` value decrease by
  the quantity of variants that have been ordered.
  - The stock location associated with the item is updated in the admin
    panel.

### Capture and fulfillment 

Administrator can opt to manually approve the shipment. (Optional.)[^1]

- The `Spree::Order`'s `approver_id` and `approved_at` values are no
  longer `nil`.

[spree-stock-item]: ../inventory/stock-items.html

Administrator captures the payment.[^1]

- The `Spree::Shipment` objects associated with the order are updated with a
  `state` of `ready`.
- The `Spree::Payment` object is updated.
  - If the payment goes through, the `state` changes from `pending` to
    `processing` to `completed`.
  - If the payment does not go through, the `state` changes from
    `pending` to `processing` to `failure`.

Administrator ships the order and marks the order as shipped.[^1]

- A [`Spree::Carton`][spree-carton] object is created for each shipment
  associated with the order.
  - The carton is given an 11-digit `number`: `C12341234123`.
- The `Spree::Shipment`'s `state` changes from `ready` to `shipped`.
- The `Spree::Order`'s `shipment_state` changes to `shipped`.

[spree-carton]: ../shipments/cartons.html

Administrator adds a tracking number.[^1]

- The `Spree::Shipment`'s `tracking` value is no longer `nil`.

Customer waits patiently for a package in the mail.

Customer receives their product.

[^1]: Note that a store's administrator workflow can be automated.
