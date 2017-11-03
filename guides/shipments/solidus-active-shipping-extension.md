# `solidus_active_shipping` extension

The [`solidus_active_shipping`][repo] extension wraps Shopify's popular
[`active_shipping`](http://shopify.github.io/active_shipping/) gem to interface
with carrier APIs (including USPS, FedEx, and UPS). This extension provides
Solidus-compatible shipping calculators for the delivery services offered by
supported carriers. This means that you can offer your customers accurate
shipping estimates for their orders before checkout.

[repo]: https://github.com/solidusio-contrib/solidus_active_shipping

Throughout this article, we will demonstrate usage of the
`solidus_active_shipping` extension with USPS delivery services. The other
carriers supported by this extension would follow a similar pattern.

## Install `solidus_active_shipping`

Follow the installation instructions provided by the `solidus_active_shipping`
extension.You can get more detailed information on installation from [the
extension's documentation][readme].

[readme]: https://github.com/solidusio-contrib/solidus_active_shipping/blob/master/README.md

Now, you will be able to use any of the pre-configured shipping calculators that
have been built into the extension.

## Add required configuration variables for web services

In addition to installing the extension, we need to authenticate with any
developer accounts we have with carriers. Administrators can add authentication
keys from the `/admin/active_shipping_settings` page (**Settings -> Stores ->
Active Shipping Settings** in the admin).

You can also set the keys from any initializer in your application. For example,
you could create a new file, `config/initializers/active_shipping.rb`, with the
contents:

```ruby
Rails.application.config.after_initialize do
  Spree::ActiveShipping::Config.set(:usps_login => "your-developer-key")
end
```

However, note that after the application has been initialized, any changes made
in the admin will override the initial value. Then, if the application is
restarted, the value in the initializer would overwrite the value set in the
admin again.

<!-- TODO:
  There currently isn't a reference list for how to configure the supported
  carriers with a initializer. I think we could either provide a complete list
  in the `solidus_active_shipping` README or more verbosely explain how to see a
  list of the possible preferences via a rails console.
-->

## Add optional configuration variables

You may also want to add shipping settings specifically for your store. The
following settings are available:

- Weight units
- Unit multiplier (for unit conversion)
- Default product weight
- Handling fee
- Maximum weight per package

You can configure these settings from the `admin/active_shipping_settings` page
(**Settings -> Store -> Active Shipping Settings** in the admin) or from any
initializer in your application. For example, you could create a new file,
`config/initializers/active_shipping.rb`, with the contents:

```ruby
Rails.application.config.after_initialize do
  Spree::ActiveShipping::Config[:default_weight] = 3.0
end
```

See [the extension's documentation][readme] for more information about available
configuration settings.

## Add shipping methods

When you set up a new shipping method (**Settings -> Shipping -> Shipping
Methods** in the admin), such as "USPS Media Mail", you can choose the
corresponding base calculator, "USPS Media Mail Parcel", from the list of
available calculators.

Now, once an order has been assigned a shipping method, a shipping estimate can
be provided to the customer before checkout.

If the delivery service you wish to use is not built into the extension (for
example, a delivery service called "USPS Bogus First Class International"), it
can be easily added as an additional calculator. See [Add additional shipping
calculators](#add-additional-shipping-calculators) for more information.

## Access pre-configured calculators

The `solidus_active_shipping` extension comes with pre-configured shipping
calculators. Administrators can access these calculators when adding new
shipping methods by picking them from the "Base Calculator" drop-down menu.

You can extend or override the pre-configured calculator classes, such as
`Spree::Calculator::Shipping::Usps::GlobalExpressGuaranteed`.

You can see all of the extension's included shipping calculators in the list
of [the extension's shipping models][models].

[models]: https://github.com/solidusio-contrib/solidus_active_shipping/tree/master/app/models/spree/calculator/shipping

## Add additional shipping calculators

Additional delivery services that are not pre-configured as a calculator in the
extension can be easily added.

### Inherit from an existing service's base class

For example, you need to a delivery service called "Bogus First Class
International" from USPS, you can add a new calculator class that inherits from
the `Spree::Calculator::Shipping::Usps::Base` class:

```ruby
module Spree
  module Calculator::Shipping
    module Usps
      class BogusFirstClassInternational < Spree::Calculator::Shipping::Usps::Base
        self.description
          "USPS Bogus First Class International"
        end
      end
    end
  end
end
```

Unlike shipping calculators that you write yourself, these calculators inherit
from the existing superclasses built into `solidus_active_shipping` and do not
require a `compute` instance method that returns a shipping amount.

### Match the delivery service's provided name

The string returned by the `description` method must match the name of the USPS
delivery service _exactly_. To determine the exact spelling, you should examine
what the USPS API returns.

The following code block returns the description and the rate of USPS delivery
services:

```ruby
class Calculator::ActiveShipping < Calculator
  def compute(line_items)
    #....
    rates = retrieve_rates(origin, destination, packages(order))
    # the key of this hash is the name you need to match
    # raise rates.inspect

    return nil unless rates
    rate = rates[self.description].to_f +
(Spree::ActiveShipping::Config[:handling_fee].to_f || 0.0)
    return nil unless rate
    # divide by 100 since active_shipping rates are expressed as cents

    return rate/100.0
  end

  def retrieve_rates(origin, destination, packages)
    #....
    # carrier is an instance of ActiveMerchant::Shipping::USPS
    response = carrier.find_rates(origin, destination, packages)
    # turn this beastly array into a nice little hash
    h = Hash[*response.rates.collect { |rate| [rate.service_name, rate.price]
}.flatten]
    #....
  end
end
```

<!-- TODO:
  Give more context to the code block above. Would you/how would you
  practically use this in your app? -->

This returns an array of services with their corresponding prices, which the
`retrieve_rates` method converts into a hash. Below is what would get returned
for an order with an international destination:

```ruby
{
  "USPS Bogus First Class International"=>9999,
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

From all of the viable shipping services in this hash, the `compute` method
selects the one that matches the description of the calculator.

### Register the new calculator

Finally, register the calculator you added. In extensions, this is accomplished
with the `activate` method:

```ruby
def activate
  Spree::Calculator::Shipping::Usps::BogusFirstClassInternational.register
end
```

