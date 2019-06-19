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

## Managing taxonomies and taxons

If your store has no taxonomies, you can create one using the **New Taxonomy**
button.

Once you have a taxonomy, use the **Edit** button to start managing the taxons
that belong to it.

<!-- TODO: Add screenshot of the taxonomy edit screen. -->

On the taxonomy's edit screen, you can add, move, edit, or remove taxons:

- Use the **Add** button next to the taxonomy name to add a new top-level
  taxon.
- Use the **Add** button next to a taxon name to add a new nested taxon.
- Drag any taxon to change its position in the list.
- Drag any nested taxon to change its position in the taxon hierarchy.
- Use the **Edit** button to [edit taxon](#edit-taxons) information.
- Use the **Delete** button to remove a taxon.

## Edit taxons

When you edit a taxon, there are a number of optional fields that can be filled:

- **Name**: The taxon's name.
- **Description**: The taxon's description.
- **Permalink**: The path to the product listing page with all of the products
  with the current taxon.
- **Icon**: The image file that should be used as an icon for the current taxon.
- **Meta Title**: The content of the `<title>` HTML tag that is used as your
  page title in search engine results.
- **Meta Keywords**: Add a list of keywords that should be added to this
  product's metadata. These meta keywords are used by search
  engines.[^meta-keywords]
- **Meta Description**: The summary text that accompanies your page in search
  engine results.[^meta-descriptions]

[^meta-keywords]: Meta keywords are used for SEO purposes. For more information
  about meta keywords see the article [Meta Keywords: What They Are and How They
  Work][meta-keywords] from WordStream.
[^meta-descriptions]: Meta descriptions are short descriptions that accompany a
  link to your page in search engine results pages (SERPs). While each search
  engine works differently, Google truncates meta descriptions after 300
  characters. For more information, see the [Meta Description][meta-description]
  article on Moz.com.

<!-- TODO:
  This SEO field-related content is duplicated throughout the documentation.
  Let's find a way to more intelligently deal with duplicated content. For
  example: we could use partials to import duplicated content from a partial into
  an article.

  Alternatively, we could just make more generalized SEO articles that explain
  these concepts in the depth required and then link out to them.
-->

[meta-keywords]: https://www.wordstream.com/meta-keyword
[meta-description]: https://moz.com/learn/seo/meta-description
