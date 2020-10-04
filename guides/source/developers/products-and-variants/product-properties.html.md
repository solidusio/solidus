# Product properties

Product properties belong to the `Spree::ProductProperty` model. They track
individual attributes for a product, especially if the attributes only apply to
one specific product. Typically, product properties are used for technical
specifications or additional product information.

For example, you might see a list of product properties for a limited edition
t-shirt as a table on its product page:

| Property name | Property value   |
|---------------|------------------|
| Fit           | Tapered          |
| Manufacturer  | American Apparel |
| Material      | 100% cotton      |

You can retrieve the value for a property on a `Spree::Product` object by
calling the `property` method on it and passing through that property's name:

```ruby
Spree::Product.find(1).property("fit")
=> "Tapered"
```

You can set a property on a product by calling the `set_property` method:

```ruby
Spree::Product.find(1).set_property("fit", "Tapered")
```

If this property doesn't already exist, a new `Property` instance with this name
will be created.

## Product properties are not option types

A product property should not be confused with an [option type][option-types],
which is used to define variants for a product.

Use product properties to describe a product: "The t-shirt is 100% cotton." Use
option types to show how variants are distinct from each other: "The t-shirt can
be purchased in one of two colors: red or green."

[option-types]: variants.html#option-types

## Variant properties

If you have product properties that only apply to a variant (or a subset of
variants), you can set variant properties as well as product properties.

You can access applied variant properties from the `Spree::Variant` rather than
the product:

```ruby
Spree::Variant.find(1).variant_properties
```
