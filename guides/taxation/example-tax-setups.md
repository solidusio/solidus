# Example tax setups

*The examples in this article are for illustrative purposes only. Always defer
to a tax professional before setting up taxation in a production environment.* 

Your store's tax setup may range from simple to complicated. This article
provides simplified examples for typical stores that need to comply with
value-added tax regulations, sales tax regulations, or both.

## Sales tax

Your U.S.-based company has [tax nexus][nexus-definition] in two states: New
York and Pennsylvania. You do not ship outside of these two states. Because of
this, you are required to charge different tax rates to anything shipped within
those states:

- You are required to charge 5% tax on any item shipped to New York.
- You are required to charged 6% tax on any clothing item shipped to
	Pennsylvania and 5% tax on non-clothing items.

### Zones

To simplify your taxation setup, you can create two zones:

- **New York (NY)**: A state-based zone that contains only the state of New
	York.
- **Pennsylvania (PA)**: A state-based zone that contains only the state of
	Pennsylvania.

### Tax categories

In order to create your store's tax rates, you need to create two tax categories
for your products:

- **Clothing**: All the clothing items that you sell should have this tax
	category applied.
- **Other items**: Every non-clothing product on your store should have this tax
  category applied.

Note that if one of your products does not have either the "Clothing" or the
"Other items" tax category, any customer who buys that item would be charged no
tax on it.

### Tax rates

Now that you have your zones and tax categories set up, you can see what kind of
meaningful tax rates you could create for both New York and Pennsylvania:

| Zone              | Tax category | Tax rate | 
|-------------------|--------------|----------|
| New York (NY)     | Clothing     | 5%       |
|                   | Other items  | 5%       |
| Pennsylvania (PA) | Clothing     | 6%       |
|                   | Other items  | 5%       |

Because there are only two distinct tax rates required (5% and 6%) you only need
to create two tax rates:

| Tax rate          | Zones  | Tax categories        | Tax rate |
|-------------------|--------|-----------------------|----------|
| PA Clothing       | PA     | Clothing              | 6%       |
| NY and PA General | NY, PA | Clothing; Other items | 5%       |

Provided your products have the correct tax categories added, your store now
complies with the Pennsylvania and New York tax regulations for the products
that you sell.

[nexus-definition]: http://www.salestaxinstitute.com/Sales_Tax_FAQs/What_is_nexus

<!-- TODO:
	Add additional examples for VAT and using a service like Tax Cloud to handle
	taxes. It would be great to hear from developers experience with VAT or a
  and their suggested best practices.
-->
