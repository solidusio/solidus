# User interface for shipments

This article explores important elements of the user interface for shipments.
While Solidus's user interface is entirely customizable, this article is
modelled after a typical Solidus installation, which would use the standard UI
elements present in the `solidus_frontend` and `solidus_backend` gems.

## Customer-facing UI

In a typical Solidus store, there is no mention of shipping until checkout.

After the customer enters the shipping address for their order, the UI displays
any shipping methods that are available for the current order. (Every time that
the order is changed or updated, the available shipping methods would also be
updated.)

For more information on how shipping methods are filtered, see [Shipping method
filters][shipping-method-filters].

The customer must choose a shipping method for each shipment before proceeding
to the next stage of the checkout process.

Once they have reached the order confirmation page, the shipping cost is shown
and included in the order total.

<!-- TODO:
  Add checkout images from a demo Solidus store.
-->

[shipping-method-filters]: shipping-method-filters.html

## Administrator-facing UI

Shipment objects (`Spree::Shipment`) are created during checkout. Multiple
shipments can be associated with a single order.

Shipments do not have their own dedicated part of the admin UI. Shipments are
viewable and editable from within an order.

In the admin dashboard, the administrator can update each shipment's shipping
cost and add tracking codes when editing an order. They can also perform other
tasks, such as splitting a single shipment into multiple shipments. They can do
all of this from the "Shipments" tab of any order.

### Shipping instructions

The optional configuration setting `Spree::Config[:shipping_instructions]`
controls whether customers can add additional shipping instructions for store
administrators. If enabled, the customer can provide shipping instructions
during checkout.

If your store uses the `solidus_frontend` gem, the shipping instructions can be
provided [during the checkout's delivery step][shipping-instructions-source].

By default, this setting is set to `false`.

If an order has any shipping instructions attached, the instructions are
displayed in the admin when you edit an order (from the `/admin/orders` URL) on
the "Shipment" tab.

Note that shipping instructions are attached to **the order** and not just an
individual shipment. 

[shipping-instructions-source]: https://github.com/solidusio/solidus/blob/master/frontend/app/views/spree/checkout/_delivery.html.erb#L91-L96

