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

<!-- TODO:
  For more information about zones, see [the Locations guide](../locations).
-->

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

[custom-shipping-calculators]: custom-shipping-calculators.html.markdown

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

<!-- TODO:
  For more information, see the [Cartons](cartons.md) article.
-->

## Shipment setup examples

### Simple setup

Consider you sell T-shirts to the US and Europe and ship from a single location, and you work with 2 carriers:

- USPS Ground (to US)
- FedEx (to EU)

and their pricing is as follow:

- USPS charges $5 for one T-shirt and $2 for each additional one
- FedEx charges $10 each, regardless of the quantity

To achieve this setup you need the following configuration:

- Shipping Categories: All your products are the same, so you only need to define one default shipping category. Each of your products would then need to be assigned to this shipping category.
- 1 Stock Location: You are shipping all items from the same location, so you can use the default.
- 2 Shipping Methods (Configuration->Shipping Methods) as follows:

|Name|Zone|Calculator|
|---:|---:|---:|
|USPS Ground|US|Flexi Rate($5,$2)|
|FedEx|EU_VAT|FlatRate-per-item($10)|

With the above configuration, a customer shipping to the US would see the USPS Ground shipping option presented to them at checkout, while a customer shipping to the EU would see the FedEx option.  Shipping rate would be calculatd at checkout according to the calculator rules.

### Advanced setup

Consider you sell products to a single zone (U.S.) and you ship from 2 locations (Stock Locations):

- New York
- Los Angeles

and you work with 3 carriers (Shipping Methods):

- FedEx
- DHL
- US postal service

and your products can be classified into 3 Shipping Categories:

- Light
- Regular
- Heavy

and their pricing is as follow:

FedEx charges:

- $10 for all light items regardless of how many you have
- $2 per regular item
- $20 for the first heavy item and $15 for each additional one

DHL charges:

- $5 per item if it's light or regular
- $50 per item if it's heavy

USPS charges:

- $8 per item if it's light or regular
- $20 per item if it's heavy

To achieve this setup you need the following configuration:

- 4 Shipping Categories: Default, Light, Regular and Heavy
- 3 Shipping Methods (Settings -> Shipping -> Shipping Methods): FedEx, DHL, USPS
- 2 Stock Locations (Settings -> Shipping -> Stock Locations): New York, Los Angeles

|S. Category / S. Method|DHL|FedEx|USPS|
|---:|---:|---:|---:|
|Light|Per Item ($5)|Flat Rate ($10)|Per Item ($8)|
|Regular|Per Item ($5)|Per Item ($2)|Per Item ($8)|
|Heavy|Per Item ($50)|Flexi Rate($20,$15)|Per Item ($20)|

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

## The Active Shipping Extension

The solidus_active_shipping extension harnesses the active_shipping gem to interface with carrier APIs such as USPS, Fedex and UPS, ultimately providing Solidus-compatible calculators for the different delivery services of those carriers.

To install the solidus_active_shipping extension add the following to your Gemfile:

```ruby
gem 'solidus_active_shipping'
gem 'active_shipping', :git => 'git://github.com/Shopify/active_shipping.git'
```

and run `bundle install` from the command line.

As an example of how to use the [solidus_active_shipping extension](https://github.com/solidusio-contrib/solidus_active_shipping) we'll demonstrate how to configure it to work with the USPS API. The other carriers follow a very similar pattern.

For each USPS delivery service you want to offer (e.g. "USPS Media Mail"), you will need to create a `ShippingMethod` with a descriptive name (Settings -> Shipping -> Shipping Methods) and a `Calculator` (registered in the `active_shipping` extension) that ties the delivery service and the shipping method together.

### Default Calculators

The `solidus_active_shipping` extension comes with several pre-configured calculators out of the box. For example, here are the ones provided for the USPS carrier:

```ruby
def activate
  [
    #... calculators for Fedex and UPS not shown ...
    Calculator::Usps::MediaMail,
    Calculator::Usps::ExpressMail,
    Calculator::Usps::PriorityMail,
    Calculator::Usps::PriorityMailSmallFlatRateBox,
    Calculator::Usps::PriorityMailRegularMediumFlatRateBoxes,
    Calculator::Usps::PriorityMailLargeFlatRateBox
  ].each(&:register)
end
```

Each USPS delivery service you want to make available at checkout has to be associated with a corresponding shipping method. Which shipping methods are made available at checkout is ultimately determined by the zone of the customer's shipping address. The USPS' basic shipping categories are domestic and international, so we'll set up zones to mimic this distinction. We need to set up two zones then - a domestic one, consisting of the USA and its territories; and an international one, consisting of all other countries.

With zones in place, we can now start adding some shipping methods through the admin panel. The only other essential requirement to calculate the shipping total at checkout is that each product and variant be assigned a weight.

The `spree_active_shipping` gem needs some configuration variables set in order to consume the carrier web services.

```ruby
  # these can be set in an initializer in your site extension
  Spree::ActiveShipping::Config.set(:usps_login => "YOUR_USPS_LOGIN")
  Spree::ActiveShipping::Config.set(:fedex_login => "YOUR_FEDEX_LOGIN")
  Spree::ActiveShipping::Config.set(:fedex_password => "YOUR_FEDEX_PASSWORD")
  Spree::ActiveShipping::Config.set(:fedex_account => "YOUR_FEDEX_ACCOUNT")
  Spree::ActiveShipping::Config.set(:fedex_key => "YOUR_FEDEX_KEY")
```

### Adding Additional Calculators

Additional delivery services that are not pre-configured as a calculator in the `spree_active_shipping` extension can be easily added. Say, for example, you need First Class International Parcels via the US Postal Service.

First, create a calculator class that inherits from `Calculator::Usps::Base` and implements a description class method:

```ruby
class Calculator::Usps::FirstClassMailInternationalParcels < Calculator::Usps::Base
  def self.description
    "USPS First-Class Mail International Package"
  end
end
```

**Note:** *unlike calculators that you write yourself, these calculators do not have to implement a `compute` instance method that returns a shipping amount. The superclasses take care of that requirement.*

There is one gotcha to bear in mind: the string returned by the `description` method must _exactly_ match the name of the USPS delivery service. To determine the exact spelling of the delivery service, you'll need to examine what gets returned from the API:

```ruby
class Calculator::ActiveShipping < Calculator
  def compute(line_items)
    #....
    rates = retrieve_rates(origin, destination, packages(order))
    # the key of this hash is the name you need to match
    # raise rates.inspect

    return nil unless rates
    rate = rates[self.description].to_f + (Spree::ActiveShipping::Config[:handling_fee].to_f || 0.0)
    return nil unless rate
    # divide by 100 since active_shipping rates are expressed as cents

    return rate/100.0
  end

  def retrieve_rates(origin, destination, packages)
    #....
    # carrier is an instance of ActiveMerchant::Shipping::USPS
    response = carrier.find_rates(origin, destination, packages)
    # turn this beastly array into a nice little hash
    h = Hash[*response.rates.collect { |rate| [rate.service_name, rate.price] }.flatten]
    #....
  end
end
```

As you can see in the code above, the `solidus_active_shipping` gem returns an array of services with their corresponding prices, which the `retrieve_rates` method converts into a hash. Below is what would get returned for an order with an international destination:

```ruby
{
  "USPS Priority Mail International Flat Rate Envelope"=>1345,
  "USPS First-Class Mail International Large Envelope"=>376,
  "USPS USPS GXG Envelopes"=>4295,
  "USPS Express Mail International Flat Rate Envelope"=>2895,
  "USPS First-Class Mail International Package"=>396,
  "USPS Priority Mail International Medium Flat Rate Box"=>4345,
  "USPS Priority Mail International"=>2800,
  "USPS Priority Mail International Large Flat Rate Box"=>5595,
  "USPS Global Express Guaranteed Non-Document Non-Rectangular"=>4295,
  "USPS Global Express Guaranteed Non-Document Rectangular"=>4295,
  "USPS Global Express Guaranteed (GXG)"=>4295,
  "USPS Express Mail International"=>2895,
  "USPS Priority Mail International Small Flat Rate Box"=>1345
}
```

From all of the viable shipping services in this hash, the `compute` method selects the one that matches the description of the calculator. At this point, an optional flat handling fee (set via preferences) can be added:

```ruby
rate = rates[self.description].to_f + (Spree::ActiveShipping::Config[:handling_fee].to_f || 0.0)
```

Finally, don't forget to register the calculator you added. In extensions, this is accomplished with the `activate` method:

```ruby
def activate
  Calculator::Usps::FirstClassMailInternationalParcels.register
end
```

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

<!-- TODO:
  - This guide was adapted from the original spree guide:
    https://github.com/spree/spree-guides/blob/master/content/developer/core/shipments.md
  - There were diagrams and screen shots in the original Spree docs that were
    dated.  It would be nice to add some diagrams and screenshots to this doc.
  - The examples of implementing custom calculators, shipping splitters, etc.
    have been reviewed and seem accurate, but have not yet been validated in
    Solidus directly.
-->
