# Cartons

The `Spree::Carton` model represents how an order was shipped. For stores that
use third-party logistics or complicated warehouse workflows, the shipment
described when the order is confirmed may not be how the *actual* shipment is
packaged when it leaves its destination.

## Example of usage

**A customer orders two t-shirts.**

Solidus creates one `Spree::Shipment` object, which is used to ship both
t-shirts in the order as one package.

**The customer is charged for a single shipment.**

Your t-shirt warehouse receives the shipping instructions for the new order.
However, they realize that one of the t-shirts is currently backordered. They
cannot send both t-shirts in a single package.

**The warehouse ship the first of two packages, which is the first of two
t-shirts.**

However, you do not want to charge the customer for a second shipment. Your
inventory was not accurate, and your store is paying for the additional package.

If you split the shipment into two `Spree::Shipment` objects, the customer would
be charged shipping for both packages.

To avoid an extra shipping charge, you can instead create additional
`Spree::Carton` objects for every package sent out of the warehouse. This way,
the shipment object stays unique and the order total does not change.

**The warehouse ships the second of two packages.**

This second package is associated with the order as another `Spree::Carton`
object. Although it is shipped as a separate package, the customer is not
charged for another shipment.

<!-- TODO:
  This article is a stub.
-->
