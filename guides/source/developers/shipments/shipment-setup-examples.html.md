# Shipment setup examples
 
Your store's shipping setup may range from a simple, singular shipping rate to
a set of more specific shipping categories and rates. 

## Simple setup

In this example setup, you run a store that sells t-shirts to the United States 
and Europe and ship from a single location. You work with two carriers:

- USPS Ground (to the US)
- FedEx (to Europe)

Because you only sell t-shirts, you can easily anticipate the shipping costs of
any order. Instead of using live shipping calculator to estimate each order's 
shipping costs, you offer a flat rate to your customers and pay the carriers
directly.

Your pricing is as follows:

- **For USPS shipments**: $5 for the first item. Then, $2 for each additional
  item. (Flexible rate per package item.)
- **For FedEx shipments**: $3 for each item, regardless of the quantity. (Flat
  rate per package.)

To achieve this setup you need the following configuration:

- **One shipping category**: In this example, you only sell type of product 
  (t-shirts), so you only need to define one default shipping category. Each
  product would use this shipping category.
- **One stock location**: At least one stock location is required. You are
  shipping all items from the same location, so you can use the default stock
  location.
- **Two shipping methods**: In this case, USPS and FedEx.  
- **Two zones**: Because your shipping methods are bound to specific
  geographical regions, you can assign one zone for the United States and
  another for Europe. This way, customers from either region cannot
  mistakenly choose the wrong shipping method for their region.

For this example, the shipping methods should be configured as follows:

| Name         | Zones     | Base calculator                         |
|--------------|-----------|-----------------------------------------|
| USPS Ground  | `US`      | Flexible rate per package item ($5, $2) |
| FedEx        | `EU_VAT`  | Flat rate per package ($3)              |

### Summary

- Any shipment to a United States address is automatically charged for USPS
  Ground shipping.
- Any shipment to a European address is automatically charged for FedEx
  shipping.
- The customer does not need to pick a shipping method.
- The customer can see the shipping rates for the shipping method they have been
  assigned.
- If the customer is outside of the United States or Europe they will not be
  able to complete their order.

## Advanced setup

In this example setup, you run a store that sells t-shirts, mugs, and kayaks.
You only sell within the United States, and you ship orders from two different
stock locations (New York City, and Los Angeles).

### Zones

Because you only sell within the United States, you only need to set up a single
zone for the United States. 

If a customer tried to enter a shipping address that is outside of the United
States, they will not be able to complete their order.

### Stock locations

You need to set up two stock locations, which will help you keep track of your
inventory and prepare for shipments.

In some cases, multiple shipments might be required for a single order. For
example, if one product in the order is only available from your Los Angeles
location, while all the other items are only available from the New York City
location.

### Carriers and shipping methods

You use three different carriers: FedEx, UPS, and USPS. You use 
[`solidus_active_shipping`][solidus-active-shipping-repo] to get shipping
estimates from all three carriers. (When you have the
`solidus_active_shipping` extension installed and set up, you can select a
specific shipping estimate calculator for any supported shipping method.)

In order to get estimates, you require developer access to those shipping
services. (This article does not go into detail about using 
`solidus_active_shipping`. See [its
documentation][solidus-active-shipping-readme] for more information about
usage.)

[solidus-active-shipping-repo]: https://github.com/solidusio-contrib/solidus_active_shipping
[solidus-active-shipping-readme]: https://github.com/solidusio-contrib/solidus_active_shipping/blob/master/README.md  

Note that three carriers does not mean you will only be setting up three
shipping methods. Oversized items require a different shipping method, even
though they use the same carrier.

In this case you will set up four shipping methods: FedEx, UPS, USPS, and an
additional FedEx shipping method specifically for oversized items. 

### Shipping categories

Your store's products can be classified into three shipping categories:

- **Default**: For any product that can be shipped using your regular shipping
  methods.
- **Oversized**: For large, heavy items like kayaks that have special shipping
  needs.

For most products, you just use the default shipping category. This means that
the products can be shipped by any carrier. Products that are assigned to the
**Oversized** shipping category can only be shipped via FedEx.

However, because the items are oversized and have special shipping requirements,
you need to create an additional shipping method that better takes into account
how an order with oversized items should be handled. For example, how should a
customer be charged when they order multiple kayaks?

### Shipping configuration

Now, we have detailed the shipping configuration required in this example. To
summarize the information above:

- **One zone**: The United States.
- **Two stock locations**: Now York City and Los Angeles.
- **Two shipping categories**: Default and Oversized.
- **Four shipping methods**: FedEx, UPS, and USPS, and a FedEx variant for
  oversized items.

Because you will use the `solidus_active_shipping` extension to create shipping
estimates, you do not to set your own shipping rates.

When you set up each shipping location, you can choose which shipping categories
are available to each method: 

|                       | Default | Oversized |
|-----------------------|---------|-----------|
| FedEx                 | Yes     | No        | 
| FedEx (Oversized)     | No      | Yes       |
| UPS                   | Yes     | No        |
| USPS                  | Yes     | No        |

Now, you have ensured that any time that one of your oversized kayak products
are ordered, the customer can be charged reasonably for special oversized
shipping specifically—while regular products can be delivered at normal rate.

You have determined that the "FedEx 2 Day Freight" method that FedEx offers
gives you and your customers the best value for kayak shipments. When you set up
your "FedEx (Oversized)" shipping method, you can use "FedEx 2 Day Freight" as
the base calculator thanks to the `solidus_active_shipping` extension.

### Summary

- The customer can pick from a FedEx, UPS, or USPS shipping method for regular
  items like t-shirts and mugs.
- The customer who orders a kayak is assigned your special oversized shipping
  method.
- All of your shipping charges are automatically estimated using the
  `solidus_active_shipping` extension and your developer accounts with FedEx,
  UPS, and USPS.
- The customer can see the shipping rates for the shipping method they have
  chosen or been assigned.
- If the customer is outside of the United States they will not be able to
  complete their order.

