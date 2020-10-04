# Overview

Solidus includes a comprehensive returns system. This system includes logic for
customer returns, refunds, and exchanges. The `solidus_backend` gem includes an
admin interface for managing returns and exchanges.

The returns system is built with an automated returns process in mind, and it
can be extended to take advantage of the way that your store manages shipments,
return shipments, or a third-party warehouse.

We recommend that you [create a sandbox store][solidus-sandbox] to get familiar
with the returns system. Create multiple return authorizations (RMAs), customer
returns, and experiment with various reimbursement types, return reasons, and so
on.

[solidus-sandbox]: ../getting-started/develop-solidus.html#create-a-sandbox-application

## Returns models

The following sections summarize the core models that make up Solidus's returns
system.

### Return items

The central model in Solidus's returns system is the `Spree::ReturnItem`.
Many of the other models in the returns system require one or many return items.

Each `Spree::ReturnItem` tracks a lot of information about the return, and the
objects have many attributes. For example, it tracks whether the item is
resellable, whether the returned item has been received, and the total amount
that should be refunded or applied to the customer's store credit.

For more information about return items, see the [Return items][return-items]
article.

[return-items]: return-items.html

### Return authorizations

A customer return starts with a return authorization. A store administrator
creates a `Spree::ReturnAuthorization` (also called an RMA) for an order or part
of an order.

The RMA can authorize the return of one item or many items on the order. Once
the RMA is created, the `Spree::ReturnItem`s on it can be included in a new
customer return.

See the [Return authorizations][return-authorizations] article for more
information.

[return-authorizations]: return-authorizations.html

### Customer returns

A `Spree::CustomerReturn` represents an item or a group of items that the
customer is going to return to you.

Similar to a return authorization, a `Spree::CustomerReturn` can be associated
with one or many `Spree::ReturnItem`s from a single order.

### Reimbursements

A `Spree::Reimbursement` represents your store's compensation to the customer
who is returning items. Since each `Spree::ReturnItem` can be returned for a
different reason, you may have multiple reimbursements for a single
`Spree::CustomerReturn`.

See the [Reimbursements][reimbursements] article for more information.

[reimbursements]: reimbursements.html

### Reimbursement types

Each `Spree::ReturnItem` is associated with a `Spree::ReimbursementType`. This
allows you to offer many kinds of reimbursements, like store credit, refunds,
and exchanges.

[reimbursement-types]: reimbursement-types.html
