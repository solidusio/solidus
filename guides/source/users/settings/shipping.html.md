# Shipping

You can manage Solidus's available shipping methods, shipping categories, and
stock locations from the **Settings > Shipping** page.

## Shipping methods

You can manage your store's shipping methods on the **Settings > Shipping**
page, on the **Shipping Methods** tab.

When you create a shipping method, the following settings are available:

- **Name**: The name for the shipping method. Customer may see this name during
    checkout and on invoices.
- **Internal Name**: The administrative name for the shipping method. Customers
    do not see the internal name for the shipping method.
- **Code**: An optional code that identifies the shipping method.
- **Carrier**: The carrier being used by this shipping method.
- **Tracking URL**: A tracking URL pattern that provides tracking for packages.
  For example, `https://quickship.com/package?num=:tracking`, where `:tracking`
  is a variable that is replaced by every shipment's tracking number.
- **Available to users**: Sets whether the shipping method should be available
  to users during checkout. If this is not checked, only store administrators
  can assign the shipping method to shipments from the admin interface.
- **Shipping Categories**: Only products with the selected shipping categories
  can use this shipping method. For more information, see [Shipping
  categories](#shipping-categories) below.
- **Base Calculator**: The shipping calculator that should be used for the
  current shipping method. The available fields depend on the calculator
  chosen. For more information, see [Shipping
  calculators](#shipping-calculators) below.
- **Zones**: Only customers in the selected zones can use this shipping method.
  For more information, see the [Zones][zones] documentation.
- **Tax Category**: Optionally set a tax category that applies to this shipping
  method. See the [Taxes][taxes] article for more information about tax
  categories.

<!-- TODO: The **Service Level** field is not currently documented.  -->

[taxes]: taxes.html
[zones]: zones.html

### Shipping calculators

<!-- TODO:
  The shipping calculators section is a good candidate to be split out into its
  own article.
-->

Shipping methods require a shipping calculator in order to calculate shipping
for each possible shipment that your store could send out.

The following shipping calculators are available by default:

- **Flat percent**: Pick a flat percentage of the order price to charge.
- **Flat rate**: Pick a flat rate to charge.
- **Flexible rate per package item**: Pick rates for the first item and another
  rate for any number of additional items. See [Flexible rate per package
  item](#flexible-rate-per-package-item) for more information.
- **Flat rate per package item**: Pick a flat rate for each item being shipped.
- **Price sack**: Charge a shipping rate or a discounted shipping rate,
  depending on the order subtotal. See [Price sack](#price-sack) for more
  information.

If your shipments require more specialized calculations, or you would like to
integrate a live shipping estimates from an external service, talk to your
developers.

#### Flexible rate per package item

When you select the **Flexible rate per package item** calculator, the following
settings are available:

- **First Item**: The rate that should be charged for the first item in a
  package.
- **Additional Item**: The rate that should be charged for additional items in a
  package.
- **Max Items**: The maximum number of items that the flexible rate should be
  applied to.
- **Currency**: The currency that shipping is charged in.

For example, you can charge $5 for the first item and $1 for each additional
item. If you set the **Max Items** setting to `3`, then a customer is charged $7
shipping if they buy three items ($5 + $1 + $1).

The flexible rate is re-applied if the customer goes over the set **Max Items**
number. For example, if they buy six items instead of three items, they are
only charged an additional $7 (a second flexible rate of $5 + $1 + $1).

#### Price sack

When you select the **Price sack** calculator, the following settings are
available:

- **Minimal Amount**: If the order subtotal is less than this value, the
    shipping rate equals the normal amount that you set.
- **Normal Amount**: The normal shipping charge.
- **Discount Amount**: The discounted shipping charge. This is charged only if
    the order subtotal is greater than the set minimal amount.
- **Currency**: The currency that shipping is charged in.

For example, you could create a price sack shipping calculator with these
settings:

- **Minimal Amount**: `$50`
- **Normal Amount**: `$15`
- **Discount Amount**: `$5`

A customer who orders a t-shirt that costs $20 would be offered a shipping rate
of $15 using this shipping method. A customer who order three t-shirts, for a
subtotal of $60, would be offered a shipping rate of $5.

## Shipping categories

You can manage your store's shipping categories on the **Settings > Shipping**
page, on the **Shipping Categories** tab.

When you create a new shipping category, you simply give it a **Name** value.
You can assign this shipping category to any of your
[products][product-details].

Shipping categories relate to your store's [shipping
methods](#shipping-methods). Each shipping method can allow or disallow products
with certain shipping categories.

If you assign two products to two different shipping categories, you could
ensure that these items are always sent as separate shipments.

For example, if your store can only ship oversized products via a specific
carrier, called "USPS Oversized Parcels", then you could create a shipping
category called "Oversized" for that shipping method, which can then be assigned
only to oversized products.

[product-details]: ../products/product-details.html

## Stock locations

You can manage your store's stock locations on the **Settings > Shipping** page,
on the **Stock Locations** tab. Each stock location represents a location where
your products ship from.

Product stock can be managed from the [**Stock**][stock] page or while you add
or edit products (from the [**Product Stock**][product-stock] tab).

Stock locations have the following settings:

- **Name**: Required. The name for the stock location. Customers could see this
    name during checkout or in invoices.
- **Code**: An optional code that identifies the current stock location.
- **Internal Name**: The administrative name of the stock location. Only store
    administrators would see this name.
- **Active**: Sets whether the stock location is active and can be used.
- **Default**: Sets whether this stock location should be used as the default
    stock location. Only one of your stock locations can be the default one.
- **Backorderable default**: Sets whether this stock location should allow
    backorders by default. This is enabled by default.
- **Propagate all variants**: Sets whether this stock location should create
    stock items for all of your store's [variants][variants]. This is enabled by
    default.
- **Restock inventory**: Sets whether returned items should restock inventory at
    this stock location. This is enabled by default.
- **Fulfillable**: Sets whether the stock items at this location are
    fulfillable. When the checkbox is checked, then stock is checked before
    shipments can be confirmed, and emails will be sent to customers about the
    stock items. This is enabled by default.
- **Check stock on transfer**: Sets whether stock should be checked when
    transferred to another stock location. This is enabled by default.

<!-- TODO: Add screenshot of stock location address fields. -->

You can also optionally set the address for the stock location using the
provided **Address** fields.

[product-stock]: ../products/product-stock.html
[stock]: ../stock/overview.html
[variants]: ../products/variants.html
