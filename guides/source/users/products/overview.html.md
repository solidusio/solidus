# Overview

You can create and manage products from the Solidus backend. From your `/admin`
homepage, navigate to the **Products** page from the store navigation to start
managing products.

## What is a product?

A product represents an item that you have for sale. A product stores general
information about the item. If you sell two items, a mug and a t-shirt, then
you need to create two products: "Mug" and "T-Shirt".

### Products define customer-facing information about items for sale

When you add or edit a product, you are providing information about the product.
Most of this information is viewable on your storefront, which means that
customers can see it.

See the [Product management](#product-management) section below for more
information about the what each product stores.

### Products can have multiple variants

You can sell multiple version of a product. For example, if you want to sell
your T-Shirt product in two colors, you do not need to create two separate
products. Instead, you can create two variants of the T-shirt product.

You need to set up product [option types][option-types] (like size or color)
before you can create variants.

[option-types]: option-types.md

## Search and filter products

From the main **Products** page, you can search for and filter down a list of
products that you want to edit or remove. You can also use the **New Product**
button to start creating a new product.

<!-- TODO: Add image of search UI and "New Product" button -->

## Product management

When you add or edit a product, you can provide a lot of information 

Products track the general information about a product from a number of
sub-pages: 

- **[Product details][product-details]**: This page allows you to manage how
  both store administrators and customers see the product's essential
  information. 
- **Images**: This page manages the product images that are displayed on the
  storefront. 
- **Variants**: This page manages the variants of the product that customers can
  purchase.
- **Prices**: This page manages the product's prices if you sell it in multiple
  countries.
- **Product Properties**: This page manages the product's [product
  properties][product-properties], which can be used to list a product's
  specifications at a glance.
- **Product Stock**: This page manages the product's available stock and
  inventory details.

<!-- TODO:
  Provide links and descriptions above for each available view related to
  adding/editing products.
-->

[product-details]: product-details.html
[product-properties]: product-properties.html
