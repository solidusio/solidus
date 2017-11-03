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

## Examples

### Simple Setup

Consider you sell T-shirts to the US and Europe and ship from a single location, and you work with 2 carriers:

* USPS Ground (to US)
* FedEx (to EU)

and their pricing is as follow:

* USPS charges $5 for one T-shirt and $2 for each additional one
* FedEx charges $10 each, regardless of the quantity

To achieve this setup you need the following configuration:

* Shipping Categories: All your products are the same, so you only need to define one default shipping category. Each of your products would then need to be assigned to this shipping category.
* 1 Stock Location: You are shipping all items from the same location, so you can use the default.
* 2 Shipping Methods (Configuration->Shipping Methods) as follows:

|Name|Zone|Calculator|
|---:|---:|---:|
|USPS Ground|US|Flexi Rate($5,$2)|
|FedEx|EU_VAT|FlatRate-per-item($10)|

With the above configuration, a customer shipping to the US would see the USPS Ground shipping option presented to them at checkout, while a customer shipping to the EU would see the FedEx option.  Shipping rate would be calculatd at checkout according to the calculator rules.


### Advanced Setup

Consider you sell products to a single zone (US) and you ship from 2 locations (Stock Locations):

* New York
* Los Angeles

and you work with 3 carriers (Shipping Methods):

* FedEx
* DHL
* US postal service

and your products can be classified into 3 Shipping Categories:

* Light
* Regular
* Heavy

and their pricing is as follow:

FedEx charges:

* $10 for all light items regardless of how many you have
* $2 per regular item
* $20 for the first heavy item and $15 for each additional one

DHL charges:

* $5 per item if it's light or regular
* $50 per item if it's heavy

USPS charges:

* $8 per item if it's light or regular
* $20 per item if it's heavy

To achieve this setup you need the following configuration:

* 4 Shipping Categories: Default, Light, Regular and Heavy
* 3 Shipping Methods (Settings -> Shipping -> Shipping Methods): FedEx, DHL, USPS
* 2 Stock Locations (Settings -> Shipping -> Stock Locations): New York, Los Angeles

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

## Documentation ToDo and notes
* This guide was adapted from the original spree guide: https://github.com/spree/spree-guides/blob/master/content/developer/core/shipments.md
* There were diagrams and screen shots in the original Spree docs that were dated.  It would be nice to add some diagrams and screenshots to this doc.
* The examples of implementing custom calculators, shipping splitters, etc have been reviewed and seem accurate, but have not yet been validated in Solidus directly.

