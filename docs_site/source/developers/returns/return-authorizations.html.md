# Return authorizations

A `Spree::ReturnAuthorization` allows you to authorize the return of any part of
a customer's order. A return authorization can only be created for shipments
that have already been shipped. For each item in a return authorization, a
[`Spree::ReturnItem`][return-items] is created.

Return authorizations are also referred to as "return
merchandise authorizations" (RMAs) in the `solidus_backend`.

After an order is shipped, administrators can approve the return of any part
of an order in the `solidus_backend` (from the **Orders -> Order -> RMA** page).

Once an RMA has been created, store administrators can add any item listed in
the RMA to a new [`Spree::CustomerReturn`][customer-returns].

A `Spree::ReturnAuthorization` object has the following attributes:

- `number`: The number assigned to the return authorization. It begins with an
  `R` and is followed by ten-digits (`RA338330715`).
- `state`: The state of the return authorization. The state can be `authorized`
  or `cancelled`. 
- `order_id`: The ID of the `Spree::Order` associated with this return
  authorization. 
- `memo`: An administrative note regarding the authorization.
- `stock_location_id`: The `Spree::StockLocation` associated with this return
  authorization.
- `return_reason_id`: The ID for the `Spree::ReturnReason` associated with this
  return authorization.

RMAs begin the larger customer return process. Note that there are many ways
that the administrator could provide compensation to a customer.

[customer-returns]: customer-returns.html
[return-items]: return-items.html

## Return authorization flow

The RMA creation process typically includes the following steps:

1. The administrator presses the **New RMA** button (on the backend's **Orders
   -> Order -> RMA** page).
2. They select the items on the order that are being returned.
3. For each item selected, they choose the following optional values:
   - They choose a reimbursement type (if applicable). For example: store credit.
   - They choose an exchange item (if applicable).
   - They choose a reason for the return authorization for the item (if
     applicable). For example: "Damaged/Defective".
4. They choose a stock location that the return is authorized to be shipped to.
5. They write a memo that documents why the return authorization is being
   created.  
6. Once the new RMA form is completed, they press the **Create** button and
   generate a new `Spree::ReturnAuthorization` object. 

After the customer has mailed their returns back, the administrator can mark
the customer return as received (on the backend's **Orders -> Order -> Customer
Returns** page).

<!-- TODO:
  Again, we should add links here once additional returns documentation exists
  here.
-->
