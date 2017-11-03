# Shipping

This guide explains how Solidus represents shipping options and how it calculates expected costs, and shows how you can configure the system with your own shipping methods. After reading it you should know:

* how shipments and shipping are implemented in Solidus
* how to specify your shipping structure
* how split shipments work
* how to configure products for special shipping treatment
* how to capture shipping instructions

Solidus uses a very flexible and effective system to calculate shipping, accommodating the full range of shipment pricing: from simple flat rate to complex product-type- and weight-dependent calculations.

The Shipment model is used to track how items are delivered to the buyer.

Shipments have the following attributes:

* `number`: The unique identifier for this shipment. It begins with the letter H and ends in an 11-digit number. This number is shown to the users, and can be used to find the order by calling `Spree::Shipment.find_by(number: number)`.
* `tracking`: The identifier given for the shipping provider (i.e. FedEx, UPS, etc).
* `shipped_at`: The time when the shipment was shipped.
* `state`: The current state of the shipment.
* `stock_location_id`: The ID of the Stock Location where the items for this shipment will be sourced from.
* Other attributes likely of interest to developers:
  * `adjustment_total`
  * `additional_tax_total`
  * `promo_total`
  * `included_tax_total`
  * `cost`
  * `order_id`

**Needed:** shipment process flow diagram

An explanation of the different shipment states:

* `pending`: The shipment has backordered inventory units and/or the order is not paid for.
* `ready`: The shipment has *no* backordered inventory units and the order is paid for.
* `shipped`: The shipment is on its way to the buyer.
* `canceled`: When an order is cancelled, all of its shipments will also be cancelled. When this happens, all items in the shipment will be restocked. If an order is "resumed", then the shipment will also be resumed.

Explaining each piece of the shipment world inside of Solidus separately and how each piece fits together can be a cumbersome task. Fortunately, using a few simple examples makes it much easier to grasp. In that spirit, the examples are shown first in this guide.

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

## UI

### What the Customer Sees

In the standard system, there is no mention of shipping until the checkout phase.

After entering a shipping address, the system displays the available shipping options and their costs for each shipment in the order. Only the shipping options whose zones include the _shipping_ address are presented.

The customer must choose a shipping method for each shipment before proceeding to the next stage. At the confirmation step, the shipping cost will be shown and included in the order's total.

**Note:** *You can enable collection of extra _shipping instructions_ by setting the option `Spree::Config.shipping_instructions` to `true`. This is set to `false` by default. See [Shipping Instructions](#shipping-instructions) below.*

### What the Order's Administrator Sees

**Shipment** objects are created during checkout for an order. Initially each records just the shipping method and the order it applies to. The administrator can update the record with the actual shipping cost and a tracking code, and may also (once only) confirm the dispatch. This confirmation causes a shipping date to be set as the time of confirmation.

## Advanced Shipping Methods

Solidus comes with a set of calculators that should fit most of the shipping situations that may arise. If the calculators that come with Solidus are not enough for your needs, you might want to use an extension - if one exists to meet your needs - or create a custom one.

### Extensions

There are a few Solidus extensions which provide additional shipping capabilities. See the [Solidus Extension List](http://extensions.solidus.io/) for the latest information.

### Writing Your Own

For more detailed information, check out the section on [Calculators](calculators).

Your calculator should accept an array of `LineItem` objects and return a cost. It can look at any reachable data, but typically uses the address, the order and the information from variants which are contained in the line_items.

### Product & Variant Configuration

Store administrators can assign products to specific Shipping Categories or include extra information in variants to enable custom calculators to determine results. Weight and dimension information can also be used in the calculator.

## Shipping Instructions

The option `Spree::Config[:shipping_instructions]` controls collection of additional shipping instructions. This is turned off (set to `false`) by default. If an order has any shipping instructions attached, they will be shown in an order's shipment admin page and can also be edited at that stage. Observe that instructions are currently attached to the _order_ and not to actual _shipments_.

## Filtering Shipping Methods On Criteria Other Than the Zone

Ordinarily, it is the zone of the shipping address that determines which shipping methods are displayed to a customer at checkout. Here is how the availability of a shipping method is determined:

```ruby
class Spree::Stock::Estimator
  def shipping_methods(package)
    shipping_methods = package.shipping_methods
    shipping_methods.delete_if { |ship_method| !ship_method.calculator.available?(package.contents) }
    shipping_methods.delete_if { |ship_method| !ship_method.include?(order.ship_address) }
    shipping_methods.delete_if { |ship_method| !(ship_method.calculator.preferences[:currency].nil? || ship_method.calculator.preferences[:currency] == currency) }
    shipping_methods
  end
end
```

Unless overridden, the calculator's `available?` method returns `true` by default. It is, therefore, the zone of the destination address that filters out the shipping methods in most cases. However, in some circumstances it may be necessary to filter out additional shipping methods.

Consider the case of the USPS First Class domestic shipping service, which is not offered if the weight of the package is greater than 13oz. Even though the USPS API does not return the option for First Class in this instance, First Class will appear as an option in the checkout view with an unfortunate value of 0, since it has been set as a Shipping Method.

To ensure that First Class shipping is not available for orders that weigh more than 13oz, the calculator's `available?` method must be overridden as follows:

```ruby
class Calculator::Usps::FirstClassMailParcels < Calculator::Usps::Base
  def self.description
    "USPS First-Class Mail Parcel"
  end

  def available?(order)
    multiplier = 1.3
    weight = order.line_items.inject(0) do |weight, line_item|
      weight + (line_item.variant.weight ? (line_item.quantity * line_item.variant.weight * multiplier) : 0)
    end
    #if weight in ounces > 13, then First Class Mail is not available for the order
      weight > 13 ? false : true
  end
end
```

## Documentation ToDo and notes
* This guide was adapted from the original spree guide: https://github.com/spree/spree-guides/blob/master/content/developer/core/shipments.md
* There were diagrams and screen shots in the original Spree docs that were dated.  It would be nice to add some diagrams and screenshots to this doc.
* The examples of implementing custom calculators, shipping splitters, etc have been reviewed and seem accurate, but have not yet been validated in Solidus directly.

