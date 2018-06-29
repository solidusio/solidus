# Zones

Solidus's **Zones** settings allow you to create zones that your store uses to
manage what taxes and shipping methods are available to customers. For example,
a customer in *Zone A* might be charged tax, while a customer in *Zone B* should
never be charged tax.

When you add or edit a zone, the following settings are available:

- **Name**: The name of the zone. Zones are not exposed to customers. 
- **Description**: The long description for the zone.
- **Type**: Sets the type of zone: either **Country**- or **State**-based.
- **Countries** or **States**: A list of countries or states (depending on the
    **Type** of zone). You can add or remove any country or state from the zone.

<!-- TODO:
  Add screenshot of zones settings, emphasizing the countries/states
  setting being used.
-->

## What is a zone?

In Solidus, any regions that you ship to are grouped using zones. Zones are
groups of states or countries. Zones might only have one member (such as a zone
that only consists of the United States) or many members (a zone that consists
of all of the non-contiguous United States: Hawaii and Alaska).

Zones allow you to set shipping rules and tax rates for specific places. They
also allow you group states or countries in a non-geographic way: for example,
if you ship to all of the United States but use different carriers when shipping
to Alaska and Hawaii.

Zones are especially useful if you need to comply with regional tax laws in
multiple states or countries. 

You can create zones that are either country- or state-based.

## Zones and taxation

When you configure tax rates, you must assign each tax rate a zone. This helps
you comply with local taxes for any region that you ship to.

You can only assign one zone per tax rate. However, if you have to comply with
more complicated tax rules, you can create multiple tax rates for a single zone
in conjunction with special tax categories, taxes with unique start or end
dates, and taxes that require other special calculations.

### Zones and taxes in the United States

If you are a U.S.-based company and ship within the United States, taxes vary
from state to state, and many counties and municipalities have their own
additional sales taxes. You should speak to a tax professional about which tax
rules apply to your store.

You could also automate your U.S. tax rates by using a web service that provides
U.S. tax rates. For example, you could use [Tax Cloud][tax-cloud] and the
[`solidus_tax_cloud`][solidus-tax-cloud] extension.

Talk to your development team about automating Solidus's tax calculations using
an API. 

[solidus-tax-cloud]: https://github.com/solidusio-contrib/solidus_tax_cloud
[tax-cloud]: https://taxcloud.net

## Zones and shipments

Zones affect the shipping methods available to customers in certain regions.
Shipping methods require at least one zone, but they could include any number of
zones.

### Shipping methods require a zone

Shipping methods require a zone. Zones can be as inclusive or exclusive as the
carriers you use for shipments.

For example, if you only want to allow UPS to ship packages domestically, you
could set its zone to your home country only. You could be even more restrictive
and make a state-based zone that only includes a few states that you wish to
ship to.

No matter what countries or states your zones include, note that each shipping
method requires at least one zone before it can be used.

### Shipping methods can include multiple zones

If you use carriers that ship to multiple regions (for example, throughout North
America, Europe, and Africa), you could configure your shipping methods to
include multiple zones.

This feature is useful in cases when you use multiple carriers that ship to
different regions. For example, if you use USPS to ship to the United States and
Canada, but you use FedEx to ship to the United States and Canada as well as to
Europe and Africa.