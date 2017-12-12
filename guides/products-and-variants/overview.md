# Products and Variants


## Option Types and Option Values

Option types denote the different options for a variant. A few examples include **size** or **color**. An option type of **size** would have option values like "Small", "Medium" and "Large". Another typical option type could be **color**, with option values of "Red", "Green", "Blue", and so on.

A product can be assigned many option types, but must be assigned at least one if you wish to create variants for that product.

## Variants

`Variant` records track the individual variants of a `Product`. Variants are of two types: master variants and normal variants.

Variant records can track some individual properties regarding a variant, such as height, width, depth, and cost price. These properties are unique to each variant, and so are different from [Product Properties](#product-properties), which apply to all variants of that product.

### Master Variants

A master variant acts as a template or set of defaults for other product variants.  Every product has a master variant. Whenever a product is created, a master variant for that product will also be created. If there are no option types on a product, then there is only 1 variant (the master variant). If 1 or more option types are created for a Product, the master variant becomes a template for the others, and is not actually "salable" itself.

There are a couple advantages of the master variant concept:

* Architecture simplification: [Line items](orders#line-items) simply need to store a variant_id, which in turn is associated with a product. More complex polymorphic relationships are avoided.
* Master variant as template: each time you create a variant of a product, the variant details are initially copied from the master.  Price will also default to the master value if left blank in a variant.


### Normal Variants

Variants which are not the master variant are unique based on [option type and option value](#option_type) combinations. For instance, you may be selling a product which is a Baseball Jersey, which comes in the sizes "Small", "Medium" and "Large", as well as in the colors of "Red", "Green" and "Blue". For this combination of sizes and colors, you would be able to create 9 unique variants:

* Small, Red
* Small, Green
* Small, Blue
* Medium, Red
* Medium, Green
* Medium, Blue
* Large, Red
* Large, Green
* Large, Blue
