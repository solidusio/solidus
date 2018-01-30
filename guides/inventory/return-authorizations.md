# Return authorizations (RMAs)

After an order is shipped, administrators can approve the return of any part
of an order in the `solidus_backend` (from the **Orders -> Order -> RMA** page).

Return authorizations are just the first part of the larger returns system built
into Solidus. When a store administrator creates a new RMA, they fill out a form
that defines the scope of the anticipated return.

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

After the customer has mailed their returns back, the administrator can mark the
the customer return as received (on the backend's **Orders -> Order -> Customer
Returns** page).

<!-- TODO:
  Again, we should add links here once additional returns documentation exists
  here.
-->

