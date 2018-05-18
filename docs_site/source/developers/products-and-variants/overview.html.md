# Overview

Products and variants are integral to Solidus. While the `Spree::Product` and
`Spree::Variant` models depend on each other, it is important to understand how
they are different:

- `Spree::Product`s track the general information about a product. This includes
  the product description and the permalink where a customer would find the
  product listing on a store. If you sell a mug and a t-shirt, you would set up
  a separate product for each of them.
- `Spree::Variant`s track the specific information about a variant of that
  product. For example, the variant provides the dimensions and weight. The
  variant provides the information required by orders and shipments. If you sell
  a red t-shirt and a green t-shirt, you could make each one a variant of your
  t-shirt product. Similarly, if all of your t-shirts come in small, medium, and
  large, then you would make additional variants for each of those: small green
  t-shirt, small red t-shirt, medium green t-shirt, medium red t-shirt, and
  so on.

The rest of this article introduces essential information for using products and
variants in Solidus.

<!-- TODO:
  It might be worth diagramming how Spree::Products, Spree::Variants,
  and Spree::LineItems affect an order and how it's priced.
-->

## Products

`Spree::Product`s track unique products within your store. If you sell a mug and
a t-shirt, you would set up a product for each of them.

If you have a number of items that are similar (like t-shirts that come in
small, medium, and large sizes), you can create [variants](#variants) for a
single product instead of creating three separate products.

You can categorize products using [taxonomies and
taxons](#taxonomies-and-taxons). And, if you want to offer more extensive
information about a single product, you can add custom [product
properties](product-properties.html) for any product.

## Variants

`Spree::Variant`s track the unique properties of multiple similar products that
you sell. For example, if you sell a red mug and a green mug that have many
other properties in common, you could create a single product ("Mug") with two
variants.

Here are a few key points to note about variants:

- If a product has more than one variant, all variants require an option type
  and option value. (For example, an option type of "Size" with the values
  "Small", "Medium", and "Large".)
- Every product has a master variant. When additional variants are created, they
  inherit properties from the master variant. The properties can be overridden
  by the variant's own unique values. See [Master variants][master-variants] for
  more information.
- All product images are linked to a product's variants. Product images are
  either associated with a specific variant or can be used for all of the
  variants.

For more information about variants, see the [Variants][variants] article.

[master-variants]: variants.html#master-variants
[variants]: variants.html

## Taxonomies and taxons

You can create categories for products using `Spree::Taxonomy`s and
`Spree::Taxon`s. The following taxonomies are common in ecommerce stores:

- Categories
- Brands

Where taxons act as subcategories to taxonomies:

```
Categories
|-- Luggage
|-- Clothing
    |-- T-shirts
    |-- Socks
|-- Shoes
Brands
|-- Adidas
|-- Bentley
|-- Calvin Klein
```

Taxons become associated with products via the `Spree::Classification` model.

For more detailed information about taxonomies and taxons, see the [Taxonomies
and taxons](taxonomies-and-taxons.html) article.

