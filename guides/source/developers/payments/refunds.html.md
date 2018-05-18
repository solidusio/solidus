# Refunds

<!-- TODO:
  This article is a stub.
-->

A `Spree::Refund` can be generated for any existing `Spree::Payment` object.
Refunds can equal the full amount of a payment or just a part of the full
payment.

If a refund is being created because of a customer return, then it should be
associated with a `Spree::Reimbursement`.

`Spree::Refund` objects have the following attributes:

- `payment_id`: The ID for the `Spree::Payment` that this refund is associated
  with.
- `amount`: The amount that is being refunded to the payment.
- `transaction_id`: A unique transaction ID. Note that this does not relate to a
  `Spree` model.
- `refund_reason_id`: The ID for the `Spree::RefundReason` associated with this
  refund.
- `reimbursement_id`: The ID for the `Spree::Reimbursement` associated with this
  refund. For more information, see the [Reimbursements][reimbursements]
  article.

[reimbursements]: ../returns/reimbursements.html

## Refund reasons

A `Spree::RefundReason` has the following attributes:

- `name`: The descriptive name for the refund reason.
- `active`: Set whether the refund reason is active and can be used.
- `mutable`: Sets whether the name of the refund reason can be changed. For new
  `Spree::RefundReason`s, this is set to `true`.
- `code`: An optional code for the refund reason.

## Admin interface

From the `solidus_backend` interface, store administrators can generate refunds
for a payment from the **Payments** page on an order. Then, they can use the
**Refund** button to start creating a refund.

