# Taxonomies and taxons

Taxonomies and taxons provide a robust way to classify and categorize products.
They belong to the `Spree::Taxonomy` and `Spree:Taxon` models.

Administrators can define as many structures as they need from Solidus's
backend. Then, they can associate individual products with any number of
taxonomies or taxons using the `Spree::Classification` model.

## Taxonomies

Use taxonomies to define the ways that you want to classify products in
your store at a high level. They are the parent nodes for taxons.

The following taxonomies are common in ecommerce stores:

- Categories
- Brands

## Taxons

Once the taxonomies have been established, you can start to break down the
lower-level organization by adding child nodes, called taxons.

For example, if you decide to create `Categories` and `Brands` as taxons, your
taxonomies might look like this:

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

Taxons can have child taxons. For example, a `Clothing` taxon may have further
sub-categories like `T-shirts` and `Socks`.

## Classifications and taxon management

`Spree::Product`s become associated with taxons through the
`Spree::Classification` model.

This model exists so that if a product is deleted, all of the links from that
product to its taxons are also deleted. A similar action takes place when a
taxon is deleted: all of the links to products are deleted automatically.

## Using taxons in controllers and templates

Linking to a taxon in a controller or a template should be done using the
`spree.nested_taxons_path` helper, which uses the taxon's permalink to
generate a URL such as `/t/categories/clothing`.

<!-- TODO:
  This section could be expanded. From time to time, people ask about views and
  taxons in the Solidus Slack team.
-->

## Database tables

Taxons use the [Nested set model][nested-set-model] for their hierarchy.

The `lft` and `rgt` properties on the `Spree::Taxons` model represent the
locations within the hierarchy of the item. This logic is handled by the
`awesome_nested_set` gem. See [the gem's documentation][awesome-nested-set]
for more information about these fields.

[awesome-nested-set-usage]: https://github.com/collectiveidea/awesome_nested_set
[nested-set-model]: http://en.wikipedia.org/wiki/Nested_set_model
