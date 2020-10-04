# Overview

Solidus uses a flexible system to calculate shipping. It accommodates the full
range of shipment pricing: from simple [flat
rate](https://en.wikipedia.org/wiki/Flat_rate) calculations to more
complex calculations related to product weight or type, the customer's shipping
address, what shipping method is being used, and so on.

If your store has complex shipping needs, you may find one of Solidus's existing
shipping extensions, like [`solidus_active_shipping`][solidus-active-shipping]
or [`solidus_shipstation`][solidus-shipstation], useful. Check out [the list of
supported Solidus Extensions][extensions].

This article provides a summary of shipping concepts. If you are interested in
reading about example Solidus shipment setups see
[Shipment setup examples][shipment-setup-examples].

<!-- TODO:
  Add section that summarizes what Spree::Objects are created related to
  shipments and explains what their function is in the larger checkout process.
-->

[extensions]: http://extensions.solidus.io
[shipment-setup-examples]: shipment-setup-examples.html
[solidus-active-shipping]: solidus-active-shipping-extension.html
[solidus-shipstation]: https://github.com/boomerdigital/solidus_shipstation

## Shipment attributes

The `Spree::Shipment` model tracks how items should be delivered to the
customer. Developers may be interested in the following attributes:

- `number`: The unique identifier for this shipment. It begins with the letter
  `H` and ends in an 11-digit number. This number is visible to customers, and
  it can be used to find the order (by calling `Spree::Shipment.find_by(number:
  H12345678910)`).
- `tracking`: The identifier given for the shipping provider (such as FedEx or
  UPS).
- `shipped_at`: The time when the shipment is shipped.
- `state`: The current state of the shipment. See [Shipping
  states](#shipping-states) for more information.
- `stock_location_id`: The ID of the stock location where the items for this
  shipment are sourced from.
- `adjustment_total`: The sum of the promotion and tax adjustments on the
  shipment.
- `additional_tax_total`: The sum of U.S.-style sales taxes on the shipment.
- `promo_total`: The sum of the promotions on the shipment.
- `included_tax_total`: The sum of the VAT-style taxes on the shipment.
- `cost`: The estimated shipping cost (for the selected shipping method).
- `order_id`: The ID for the order that the shipment belongs to.

<!-- TODO:
  Add a shipment process flow diagram.
-->

### Shipping states

Each shipment is assigned a `state` attribute. Depending on its state, different
actions can be performed on shipments. There are four possible states:

- `pending`: The shipment has backordered inventory units and/or the order is
  not paid for.
- `ready`: The shipment has no backordered inventory units and the order is paid
  for.
- `shipped`: The shipment has left the stock location.
- `canceled`: When an order is cancelled, all of its shipments will also be
  cancelled. When this happens, all items in the shipment will be restocked. If
  an order is "resumed", then the shipment will also be resumed.

## Core concepts

To leverage Solidus's shipping system, become familiar with its key concepts:

- Stock locations
- Shipping methods
- Zones
- Shipping categories
- Shipping calculators
- Shipping rates
- Inventory units
- Cartons

### Stock locations

Stock locations represent physical storage locations from which stock is
shipped.

### Shipping methods

Shipping methods identify the actual delivery services used to ship the
product. For example:

- UPS Ground
- UPS One Day
- FedEx 2Day
- FedEx Overnight
- DHL International

Each shipping method is only applicable to a specific geographic
zone. For example, you wouldn't be able to get a package delivered
internationally using a domestic-only shipping method. You can't ship from
Dallas, USA, to Rio de Janeiro, Brazil, using UPS Ground, which is a United
States-only carrier.

### Shipping categories

You can further restrict when shipping methods are available to customers by
using shipping categories. If you assign two products to two different shipping
categories, you could ensure that these items are always sent as separate
shipments.

For example, if your store can only ship oversized products via a specific
carrier, called "USPS Oversized Parcels", then you could create a shipping
category called "Oversized" for that shipping method, which can then be assigned
to oversized products.

Shipping categories are created in the admin interface (**Settings -> Shipping
-> Shipping Categories**) and then assigned to products (**Products -> Edit**).

### Zones

Zones serve as a mechanism for grouping distinct geographic areas together.

The shipping address entered during checkout defines the zone (or zones) for the
order. The zone limits the available shipping methods for the order. It also
defines regional taxation rules.

For more information about zones see the [Locations][locations] documentation.

[locations]: ../locations/overview.html

### Shipping calculators

A shipping calculator is the component responsible for calculating the shipping
rate for each available shipping method.

Solidus ships with five default shipping calculators:

- [Flat percent](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_percent_item_total.rb)
- [Flat rate (per order)](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_rate.rb)
- [Flat rate per package item](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/per_item.rb)
- [Flexible rate per package item](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flexi_rate.rb)
- [Price sack](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/price_sack.rb)
  (which offers variable shipping cost that depends on order total)

If you want to estimate shipping rates using carrier APIs, You can use an
extension like [`solidus_active_shipping`][solidus-active-shipping]. Or, if you
have other complex needs, you can create a [custom shipping
calculators][custom-shipping-calculators] for more information.

[custom-shipping-calculators]: custom-shipping-calculators.html

### Shipping rates

For each shipment, a `Spree::ShippingRate` object is created for each of your
store's shipping methods. These objects represent the cost of the shipment as
calculated by each shipping method's calculator.

| `Spree::ShippingRate` | 1     | 2     | 3     | Description                                         |
|-----------------------|-------|-------|-------|-----------------------------------------------------|
| `shipment_id`         | 1     | 1     | 1     | All of these rates are for one shipment             |
| `shipping_method_id`  | 1     | 2     | 3     | Each available shipping method                      |
| `selected`            | false | true  | false | Set to `true` for the selected shipping method only |
| `cost`                | $0.50 | $1.75 | $1.25 | The shipment's shipping rate                        |

Once the shipping method has been chosen, the matching `Spree::ShippingRate`'s
`selected` key becomes `true`. Only one shipping rate can be `selected` for each
shipment.

### Inventory units

A `Spree::InventoryUnit` is created for each item in a shipment. It tracks
whether the item has shipped, what product variant the item is, and what order
and shipment the item is associated with.

<!-- TODO:
  This section is a stub. It may be worth revisiting inventory units in detail,
  or in its own article.
-->

### Cartons

The `Spree::Carton` model represents how an order was shipped. For stores that
use third-party logistics or complicated warehouse workflows, the shipment
described when the order is confirmed may not be how the _actual_ shipment is
packaged when it leaves its destination.

For more information, see the [Cartons](cartons.html) article.
