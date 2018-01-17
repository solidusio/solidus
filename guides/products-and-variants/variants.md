# Variants

`Spree:Variant`s track the distinct properties of multiple similar products that
you sell.

For example, if you sell a red mug and a green mug that have many other
properties in common, you could create a single product ("Mug") with two
variants.

Your "Mug" product requires an [option type](#option-types) of "Color". Then,
your "Color" option type requires two possible option values ("Red" and
"Green"). Both the red and green variants can each have their own price,
dimensions, and other properties.

Line items use a `variant_id` to associate a variant with an order. So, every
product has at least one `Spree::Variant`. The first variant is also the [master
variant](#master-variants) by default.

Variants are used to define properties that are specific to the variant:

- `weight`, `height`, `width`, and `depth`: Sets unique dimensions or weight for
  a variant.
- `cost_currency`: Set an alternative currency for your variant.
- `cost_price`: Sets the manufacturing cost for the variant (for internal use).
- `position`: Sets the variant's position in the list of variants. For example,
  if there are two variants the position could be `1` or `2`. (Administrators
  can set positions by drag-and-dropping any variant in the list of variants on
  a product's **Variants** tab.)
- `track_inventory`: Set whether inventory should or should not be tracked for
  this variant. <!-- See the inventory documentation for more information -->
- `tax_category_id`: Overrides the product's tax category for this variant.
  See the [Taxation][tax-categories] documentation for more information.

[tax-categories]: ../taxation/overview-of-taxation.md#tax-categories

<!-- TODO:
  Once there is documentation about inventory, add a link to it from the
  `track_inventory` attribute for context..
-->

## Option types

In order to create variants, you need to create option types and option values:

- The product needs to have at least one `Spree::OptionType` assigned to it. For
  example, if you intend to offer a product in multiple colors, you could create
  a "Color" option type.
- The option type requires at least one associated `Spree::OptionValue` to be
  used. For example, your "Color" option type might have ten or one hundred
  option values.

Administrators are able to create option types and associated option values in
the backend (from the **Products -> Option Types** page). Then, when they add or
edit products, they can add available option types to the product and option
values to each variant.

## Master variants

Every product has a master variant. By default, the master variant is the first
variant created for a product. When additional variants are created, they
inherit the properties of the master variant until their unique properties are
set.

The master variant is used by `Spree::LineItem`s in two different ways:

- If a product has no variants configured, then the product's master variant
  is the variant that provides the price and other properties to the line
  item.
- If a product has more than one variant, then the master variant does *not*
  provide the price and other properties to the line item. Instead, it is used
  as a template for other variants.

The master variant should be an effective template for all of your other
variants. For example, if you have five variants on your mug product that have
option types of "Color" and "Size", as well as different prices, it would be
advantageous to set the master variant to the variant that has the most common
color, size, and price.

| "Mug" variant | Color | Size    | Price |
|---------------|-------|---------|-------|
| 1             | Green | Regular | $12   |
| 2             | Green | Large   | $14   |
| 3             | Red   | Regular | $12   |
| 4             | Red   | Large   | $14   |
| 5             | White | Regular | $12   |

In the table above, the "Mug" variant 1 or 3 would be appropriate master
variants. This is because the majority of the variants share values with them
("Green" or "Red", "Regular", and "$12").

## Product images

Product images link to variants via the `Spree::Image` model. For more
information about images, see the [product images](product-images.md) article.
