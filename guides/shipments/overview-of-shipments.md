# Overview of shipments

Solidus uses a flexible system to calculate shipping. It accommodates the full
range of shipment pricing: from simple [flat
rate](https://en.wikipedia.org/wiki/Flat_rate) calculations to more
complex calculations related to product weight or type, the customer's shipping
address, what shipping method is being used, and so on.

If your store has complex shipping needs, you may find one of Solidus's existing
shipping extensions, like [`solidus_active_shipping`][solidus-active-shipping]
or [`solidus_shipstation`][solidus-shipstation], useful. Check out [the list of
supported Solidus Extensions](https://extensions.solidus.io).

This article provides a summary of shipping concepts. If you are interested in
reading about example Solidus shipment setups see
[Shipment setup examples](shipment-setup-examples.html.markdown).

<!-- TODO:
  Add section that summarizes what Spree::Objects are created related to
  shipments and explains what their function is in the larger checkout process.
-->

[solidus-active-shipping]: solidus-active-shipping-extension.html.markdown

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

## Definitions, Design, & Functionality

To properly leverage Solidus' shipping system's flexibility you must understand a few key concepts:

* Stock Locations
* Shipping Methods
* Zones
* Shipping Categories
* Calculators (through Shipping Rates)

### Stock Locations
Stock locations represent physical storage locations from which stock is shipped.

### Shipping Methods

Shipping methods identify the actual services or carriers used to ship the product. For example:

* UPS Ground
* UPS One Day
* FedEx 2Day
* FedEx Overnight
* DHL International

Each shipping method is only applicable to a specific geographic **Zone**. For example, you wouldn't be able to get a package delivered internationally using a domestic-only shipping method. You can't ship from Dallas, USA to Rio de Janeiro, Brazil using UPS Ground (a US-only carrier).

If you are using shipping categories, these can be used to qualify or disqualify a given shipping method.

**Note**: *Shipping methods can have multiple shipping categories assigned to them. This allows the shipping methods available to an order to be determined by the shipping categories of the items in a shipment.*

### Zones

Zones serve as a mechanism for grouping geographic areas together into a single entity. You can read all about how to configure and use Zones in the [Zones Guide](addresses#zones).

The Shipping Address entered during checkout will define the zone the customer is in and limit the Shipping Methods available to him.

### Shipping Categories

Shipping Categories are useful if you sell products whose shipping pricing vary depending on the type of product (TVs and Mugs, for instance) or the handling of the product (frigile or large). Shipping categories can be assigned when editing a product.

**Note:** *For simple setups, where shipping for all products is priced the same (ie. T-shirt-only shop), all products would be assigned to the default shipping category for the store.*

Some examples of Shipping Categories would be:

* Light (for lightweight items like stickers)
* Regular
* Heavy (for items over a certain weight)

Shipping Categories are created in the admin interface (Settings -> Shipping -> Shipping Categories) and then assigned to products (Products -> Edit).

During checkout, the shipping categories of the products in your order will determine which calculator will be used to price its shipping for each Shipping Method.

### Shipping Calculators

A Calculator is the component responsible for calculating the shipping price for each available Shipping Method.

Solidus ships with 5 default Calculators:

* Flat percent
* Flat rate (per order)
* Flat rate per package item
* Flexible rate per package item
* Price sack

Flexible rate is defined as a flat rate for the first product, plus a different flat rate for each additional product.

You can define your own calculator if you have more complex needs. In that case, check out the Calculators Guide (*this guide has not yet been ported from Spree as of this edit*).

