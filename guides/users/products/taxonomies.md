# Taxonomies

Products can be associated with taxonomies and taxons. These provide categories
and sub-categories for them. You can define many taxons and taxonomies for each
product. 

When you [add or edit a product][overview], you can use the **Taxons** field to
add any of your store's configured taxons.

To manage your store's taxonomies and taxons, go to the **Products ->
Taxonomies** page of the Solidus backend.

[overview]: overview.md

## The difference between taxonomies and taxons

When you work with taxonomies, you should know the difference between
*taxonomies* and *taxons*:

- **Taxonomies** are a top-level category for your products. Typically, a
  taxonomy would be "Brands".
- **Taxons** are the lower-level categories for the products. In the "Brands"
  taxonomy, the *taxons* could be actual brand names being carried by your
  store.

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

Note that taxons can have child taxons. You can see this in the above example
where the `Clothing` taxon has `T-shirts` and `Socks` nested within.
