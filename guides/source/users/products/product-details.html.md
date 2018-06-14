# Product details

When you add or edit a product, you can provide essential information by filling
in each product details field.

<!-- TODO: Add screenshot of the "Product details" page -->

## Basic information

- **Name**: The customer-facing name for the product.
- **Slug**: The slug[^slug] for the product. By default, Solidus creates a slug
  based on the product's name. For example, a product called "Summer T-Shirt"
would have the slug `summer-t-shirt`.
- **Description**: A customer-facing description for the product. The
  description can be any length.
- **Master Price**: This price represents the price you want to sell this
  product for. (However, [products with multiple variants](#) can be
  sold for other price values.)
- **Cost Price**: What the product costs you, the seller, to purchase or
  produce. You may change the currency associated with the cost price.
- **Available On**: The date that this product is available to be sold. If this
  date is not set, then the product is not shown to customers on the storefront.
- **Taxons**: This adds the product your store's taxons.
- **Option Types**: Add option types to your product if you want to offer
  [multiple variants of the product](#). You need to define [option
  types](#option-types) before you can use this field.

<!-- TODO:
 Fill in (#) links to variants-related documentation.
-->

### Available On

Note that the **Available On** field should be filled if you want the product to
be displayed on the storefront.

If the **Available On** value is a date in the future, then the product is only
available after the date that has been set.

[^slug]: A slug is a part of a URL that identifies a page using human-readable
  words. Most blogs and stores use slugs for SEO purposes. For example, in the
  web address `https://example.com/store/summer-t-shirt`, the slug would be the
  `summer-t-shirt` part.

## Inventory information

The following product information is used by Solidus's inventory and shipping
systems:

- **SKU**: A [stock keeping unit][sku] code that your store uses to identify
  products.
- **Weight**: The product's weight.
- **Height**: The product's height.
- **Width**: The product's width.
- **Depth**: The product's depth.
- **Shipping Categories**: This sets the product's shipping category.
- **Tax Category**: This sets the products' tax category.

Solidus's product dimensions do not specify a unit of measurement. We recommend
that you use them consistently so that they can be used to calculate shipping
consistently across your store. Product dimensions round to two decimal points
(for example: `1.00`).


Note that the weight and dimensions of a product can be used to calculate an
order's shipment costs.

[sku]: https://en.wikipedia.org/wiki/Stock_keeping_unit

## SEO information

- **Meta Title**: Adds content to the product page's HTML `<title>` tag, which
    is used by search engines.
- **Meta Keywords**: A list of keywords that should be added to this
  product's metadata. These meta keywords are used by search
  engines.[^meta-keywords]
- **Meta Description**: The summary text that accompanies your page in search
  engine results.[^meta-descriptions]

If the product's SEO fields are not filled in, then the product inherits [the
store's global SEO information settings][stores].

[^meta-keywords]: Meta keywords are used for SEO purposes. For more information
  about meta keywords see the article [Meta Keywords: What They Are and How They
  Work][meta-keywords] from WordStream.
[^meta-descriptions]: Meta descriptions are short descriptions that accompany a
  link to your page in search engine results pages (SERPs). While each search
  engine works differently, Google truncates meta descriptions after 300
  characters. For more information, see the [Meta Description][meta-description]
  article on Moz.com.

[meta-keywords]: https://www.wordstream.com/meta-keyword
[meta-description]: https://moz.com/learn/seo/meta-description
[stores]: ../settings/stores.html
