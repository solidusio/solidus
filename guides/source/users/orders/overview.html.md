# Orders

Orders are a key part of Solidus. The orders user interface is especially
complex because orders connect many of the other major parts
of the Solidus admin – like payments, shipments, taxes, and customer profiles.

To make sense of orders, this section of the guide explains orders in the
context of a typical ecommerce store that sells basic physical products (like
t-shirts), and it links out to other related parts of the users guide.

## What is an order?

Every time that a customer orders product(s) from your store, a new order is
created. But Solidus starts tracking orders *before* they are placed: as soon as
a customer has put something in their cart, a new order is generated.

There are many related database objects that "make up" an order, and are created
in service of an order:

<!-- TODO:
  Add links to other end-user documentation after it has been merged.
-->

- **[Customer][users]**: Every order requires an associated customer (also called a
  *user*.
- **Shipments**: An order may have one or many shipments associated with it.
- **Adjustments**: Additional charges (taxes and shipping fees) and credits
  ([promotional discounts][promotions]) are tied to the order.
- **Payments**: An order may have one or more payments associated with it. For
  example, a customer may use a gift card and a credit card to make a purchase.
  They might also require a refund if a product is defective.
- **RMAs and returns**: If a customer decides to return an order for some
  reason, return authorizations, return items, and reimbursements are created
  and tracked against the original order.

All of these objects can be viewed in the context of the order – or in their own
sections of the Solidus admin.

[users]: ../users/overview.html
[promotions]: ../promotions/overview.html

## Order states

Before an order is marked as **Complete**, orders go through a number of other
states. By default, the following states are available:

- **Cart**: A customer has placed product(s) in the cart.
- **Address**: The customer has begun checkout and has not yet provided their
  billing and/or shipping addresses.
- **Delivery**: The customer needs to choose from available shipping options.
- **Payment**: The customer needs to provide payment information.
- **Confirm**: The customer needs to confirm that the input checkout information
  is correct.
- **Complete**: The customer has submitted their order.

<!-- TODO:
  Link to payments and shipments state machine documentation for end users once
  it has been merged.
-->

Once an order has been completed, payments and shipments can start to be
processed by your store. Note that both payments and shipments have their own,
separate state sets.
