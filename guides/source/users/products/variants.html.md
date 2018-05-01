# Variants

A product can have many variants. Variants make it easy to sell multiple similar
items while only managing a single product listing.

For example, you may sell a t-shirt that comes in two colors and three sizes.
Instead of managing six product listings, you can manage a single product with
six variants.

<!-- TODO: Add screenshot of **Products -> Variants** interface. -->

Before you can create variants for a product, you need to create at least one
[option type and option value][option-types] for your store.

[option-types]: option-types.html

## Variants are customer-selectable product options

The customer can choose any variant of a product from the storefront.

In our t-shirt example, the product has six variants that customers can pick:

| Variant | Color    | Size      |
|---------|----------|-----------|
| 1       | Red      | Small     |
| 2       |          | Medium    |
| 3       |          | Large     |
| 4       | Green    | Small     |
| 5       |          | Medium    |
| 6       |          | Large     |

You can create [option types and option values][option-types] for any variant
that you want to create. In addition to **Size** and **Color**, you may want to
offer **Material**, **Quantity**, or other option types.

## Filter and search variants

If you have products with many variants, you can filter the list of variants
by entering a partial **SKU** or the name of an **Option Value**.

For example, if you want to see all of the variants with the size `Small`, you
could use "small" as a search term. Or, if you have a range of SKUs, like
`ROR-125000` to `ROR-125099`, you could use "ror-1250" as a search term.

<!-- TODO: Add screenshot of the variant filter in use. -->

## Variant details

A variant uses its product's [product details][product-details]. However, the
variant can also have its own details, which may different from the product's
values. The following variant details can optionally be added or overridden from
the product:

- **SKU**: Assigns a separate SKU for each variant.
- Dimensions (**Weight**, **Height**, **Width**, and **Depth**): Assigns
  distinct dimensions for the current variant.
- **Price**: Override the master price provided by the product details.
- **Cost Price**: Override the cost price provided by the product details.
- **Variant tax category**: Override the tax category provided by the product
    details with any other tax category.

[product-details]: product-details.html

### Option types and values

When you add or edit a variant, you can set which combination of [option
values][option-types] the variant represents.

You can set the available option types in the product's [product
details][product-details].

Note that if you do not assign any option values to the variant, it may not
appear on the storefront and customers would never be able to buy the variant.

