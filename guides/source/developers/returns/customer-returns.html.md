# Customer returns

Once a [return authorization][return-authorizations] has been created and marked
as authorized, administrators can create a `Spree::CustomerReturn` for the
authorized order.

A [`Spree::StockLocation`][stock-locations] should be assigned for each customer
return. This stock location is where the customer return is to be received.

A `Spree::CustomerReturn` object has the following attributes:

- `number`: A unique eleven-character return number starting with `CR`. For
  example: `CR123456789`.
- `stock_location_id`: The ID for the `Spree::StockLocation` where the customer
  return should be received.

You may want to also see a list of the `Spree::ReturnItem`s that are associated
with a customer return with the `return_items` method:

```ruby
Spree::CustomerReturn.find(1).return_items
# => <Spree::ReturnItem id: 1 ...>, <Spree::ReturnItem id: 2 ...>
```

[return-authorizations]: return-authorizations.html
[stock-locations]: ../inventory/overview.html#stock-locations

## User interface

Solidus does not include a customer-facing customer returns interface. Only
store administrators can authorize and administrate returns from the
`solidus_backend` interface.

Once a store administrator has created a customer return in the
`solidus_backend` interface, each [return item][return-items] can be managed and
[reimbursements][reimbursements] can be made.

For example, you can specify whether return items are resellable, whether your
stock location has received each item, and what they reason for the return is.
All of this information is stored in a `Spree::ReturnItem` object's attributes.

Once an item is marked as "Received", you can create a `Spree::Reimbursement`
for it.

[reimbursement-types]: reimbursement-types.html
[reimbursements]: reimbursements.html
[return-items]: return-items.html

