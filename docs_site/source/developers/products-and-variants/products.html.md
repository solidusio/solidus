# Products

`Spree::Product`s track separate products within your store. If you sell a mug
and a t-shirt, you would set up a product for each of them.

Products have the following attributes:

- `name`: The short name for a product.
- `description`: The full description for your product.
- `slug`: An SEO-slug based on the product name. This slug is used in the
  product's URL.
- `available_on`: The first date the product becomes available for sale online
  in your shop. If you don't set the `available_on` attribute, the product does
  not appear among your store's products for sale.
- `deleted_at`: The date the product is no longer available for sale in the
   store.
- `meta_description`: A description targeted at search engines for search engine
   optimization (SEO). This description is shown in search results and may be
   truncated after 160 characters.
- `meta_keywords`: Comma-separated keywords and phrases related to the product,
   also targeted at search engines.
- `meta_title`: Title to put in HTML `<title>` tag. If left blank, the product
   name is used instead.
- `promotionable`: Determines whether promotions can apply to the product.
  (Labeled "Promotable" in the admin interface.)

## Variants

Most of Solidus's product-related business logic belongs to `Spree::Variant`s
rather than products. This includes the product's price, dimensions, and product
images.

Even if your store only sells a single product that only comes in one size and
color, that product would have a single variant that handles the additional
properties.

For more information about variants, see the [variants](variants.html) article.

## Product properties

You can also configure products to have [product
properties](product-properties.html). Product properties allow you to add custom
product information for a single product.

A "Size" attribute would be used for many products and would be more useful as
an [option type](variants.html#option-types) for variants. However, if you decide
to sell a limited edition t-shirt you might want to add unique product
properties for marketing purposes - like "Fit", "Material", and "Manufacturer".

