# Reimbursements

<!-- TODO:
  This article is a stub.
-->

A `Spree::Reimbursement` represents your store's compensation to the customer
who is returning items. For example, if a customer is not happy with the quality
of your product and they decide to return it, your store may want to offer them
store credit for the price of the item.

A `Spree::Reimbursement` can represent the reimbursement of one or many
`Spree::ReturnItem`s. However, if the return items have different
`Spree::ReimbursementType`s assigned, then multiple reimbursements are created
for a single customer return.

Each `Spree:Reimbursement` object has the following attributes:

- `number`: A unique eleven-character number that identifies the reimbursement.
  The number starts with `RI`. For example: `RI123456789`.
- `reimbursement_status`: The status of the current reimbursement.
- `customer_return_id`: The ID for the `Spree::CustomerReturn` that is
  associated with this reimbursement.
- `order_id`: The ID for the `Spree::Order` that is associated with the items on
  the reimbursement.
- `total`: The total value of the reimbursement. Depending on the
  `Spree::ReimbursementType`, this value may be `nil`.

