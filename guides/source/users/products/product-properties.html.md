# Product properties

Product properties track individual attributes for a product, especially if the
attributes only apply to one specific product. Typically, product properties
would be used for technical specifications or additional production information.

For example, you can see a list of product properties for a limited edition
t-shirt as a table on its product page:

| Property name | Property value   |
|---------------|------------------|
| Fit           | Tapered          |
| Manufacturer  | American Apparel |
| Material      | 100% cotton      |

## Product properties are not option types

A product property should not be confused with an [option type][option-types],
which is used to define variants for a product.

Use product properties to describe a product: "The t-shirt is 100% cotton." Use
option types to show how variants are distinct from each other: "The t-shirt can
be purchased in one of two colors: red or green."

[option-types]: option-types.html

## Create a product property

You can create a new product property in just a few steps:

1. While you add or edit a product, select the **Product Properties** tab.
2. Select the **Add Product Properties** button.
   Empty **Property Type** and **Property Value** fields appear.
3. Enter a **Property Type** value and a **Value** value.
4. Select the **Update** button.

## Set variant properties

You can also create product properties that only apply to a specific variant:

1. While you add or edit a product, select the **Product Properties** tab.
2. Scroll down to the **Variant Properties** section of the page.
3. Choose which variants you want to add properties to using the provided
   filters.
4. Select the **Filter Results** button.
5. Select the **Add Variant Properties** button.
   Empty **Property Type** and **Property Value** fields appear.
6. Enter a **Property Type** value and a **Property Value** value.
7. Select the **Update** button.

Note that if you use the default Solidus frontend, variant properties are not
displayed. Talk to your developers about integrating variant properties on your
store's product pages.
