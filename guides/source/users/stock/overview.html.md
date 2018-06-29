# Overview

From the **Stock** page of the Solidus admin interface, you can view and manage
the stock for all of your store's products.

You can change the [**Stock On Hand**](#stock-on-hand) value for any
[product][products] (or variant) in your store after selecting the **Edit**
button next to it. 

Note that you can also [view stock in a product context][product-stock]. 

<!-- TODO: Add screenshot of the stock UI, emphasizing the edit buttons -->

[product-stock]: ../products/product-stock.html

## Stock information

On the **Stock** page, you can see the following information about your stock
items:

- **Item**: Identifying information about the current item. This information
    includes the primary product image, the name, and the SKU of the item.
- **Options**: If the current item is [a variant][variants] of a product, this
    details which variant it is. For example, which size and color the current
    item is.
- **Stock Location**: The [stock location](#stock-locations) of the current
  item.
- **Back orderable**: Sets whether the current item should be
    [backorderable](#backorderable) or not.
- **Count On Hand**: The number of items that a stock location has of the
    current item. See [Count on hand](#count-on-hand) for more information.

## Filter and search

You can search for specific stock items. This makes locating stock information
easier when you have hundreds or thousands of products. You can filter by the
following values:

- **Stock Location**: Choose one of your existing [stock
  locations](#stock-locations) to filter results by.
- **Variant**: You can enter a product's SKU or [option value][option-values] to
    filter down your results. For example, you could enter a partial SKU to find
    a range of products that you know have similar SKUs. Or, you could enter
    "Yellow" to find all of the variants with a "Yellow" option value.

Note that the **Variant** filter searches for option **Name** values
as well as their **Presentation** values. For example, you may an option value
with the name "Extra Large" that is presented as "XL" on your storefront. This
means that you can search for either term and find the same results.

## Stock locations

Stock locations represent a location where your inventory is shipped from. For
every stock location that you create, a complete set of stock items that
represents your product collection is also created.

For example, if your store only sells one product, but it ships the product from
two stock locations, then you should have two items in the list of stock items
on the **Stock** page. 

<!-- TODO:
  Add screenshot of two items that represent a single product on the Stock page.
-->

## Count on hand

For each product you sell in your store, you can manage the **Count On Hand**
value. You may have inventory for this product at multiple stock locations, and
you can manage the count for each location.

### Changing the count on hand value

When you update the **Count On Hand** value for a stock item, be aware that you
are resetting the count.

For example, if your "T-Shirt" product has `5` in stock items and you received
`15` new shirts from your supplier, you should update the **Count On Hand**
value to `20`.
