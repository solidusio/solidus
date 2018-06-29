# Zones

In Solidus, any regions that you ship to are grouped using zones. Zones are
groups of states or countries. Zones might only have one member (such as a zone
that only consists of the United States) or many members (a zone that consists
of all of the non-contiguous United States: Hawaii and Alaska).

Zones allow store administrators to set shipping rules and tax rates for
specific places. They also allow you to group states or countries in a
non-geographic way: for example, if you ship to all of the United States but use
different carriers when shipping to Alaska and Hawaii.

Zones are especially useful for helping you comply with the tax variations in
different regions.

Administrators can create zones that are either country- or state-based.

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

For more information about taxation, see the [Taxation][taxation] documentation.

[solidus-tax-cloud]: https://github.com/solidusio-contrib/solidus_tax_cloud
[taxation]: ../taxation/overview.md
[tax-cloud]: https://taxcloud.net

## Zones and shipments

Zones affect the shipping methods available to customers in certain regions.
Shipping methods require at least one zone, but they could include any number of
zones.

### Shipping methods require a zone

Shipping methods require a zone. Zones can be as inclusive or exclusive as the
carriers you use for shipments.

For example, if you only want to allow UPS to ship packages domestically, you
could set its zone your home country only. You could be even more restrictive
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

For more information about shipments, see the [Shipments][shipments]
documentation.

[shipments]: ../shipments/overview.md

## Example zone configuration

*Note that the following example should not be followed for a store in
production. Always speak with a tax professional before determining your tax
rates and shipping fees.*

In this simplified example, you operate a store that is located within Arizona,
United States. You need to comply with U.S. and Arizona tax laws, and create
zones that define which shipping methods are available for customers from
different regions. Here is some additional context to flesh out the example:

- You operate the business out of Arizona.
- Your stock is stored and mailed from your warehouse in Arizona.
- You ship to all 50 of the United States and to Canada.
- You offer USPS First-Class as a delivery service for orders being delivered
  within Arizona.
- You offer UPS Ground as a delivery service to any of the 48 continental (or
  contiguous) U.S. states.
- You offer only FedEx Express as a delivery service to non-contiguous states
  (like Alaska and Hawaii) and to Canada.
- You are only required to apply sales tax to orders delivered within Arizona.
  (You have determined the Arizona tax rate by using the maximum amount of tax
  charged by a county and a municipality state-wide. You charge the maximum
  amount on all in-state orders.)

In the table below, you can see how your store could use zones in conjunction
with the required tax rates and any shipping methods you wish to use:

| Zone                  | Description                                 | Tax rate | Available shipping methods                  |
|-----------------------|---------------------------------------------|----------|---------------------------------------------|
| In-state              | Purchases shipped within Arizona (taxable)  | 9.9%     | FedEx Express, UPS Ground, USPS First-Class |
| Non-contiguous States | Purchases shipped to Alaska or Hawaii       | 0        | FedEx Express                               |
| Contiguous States     | Purchases shipped to all other states       | 0        | FedEx Express, UPS Ground                   |
| Canada                | Purchases shipped internationally to Canada | 0        | FedEx Express                               |

All of the zones in this table would be state-based except for the "Canada"
zone, which you could configure as a country-based zone with a single country in
it.

While you might choose to use zones differently in your own store, this example
shows how you might want to group different states according to your own
business needs. 

