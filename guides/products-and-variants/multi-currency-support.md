# Multi-currency support

`Spree::Price` objects track a price for a specific currency and variant
combination. For example, if a variant is available for $15 USD or €7 EUR, that
variant would have two `Spree::Price` objects associated with it (one for each
currency).

<!-- TODO:
  It looks like there are other circumstances where another a Spree::Price
  object would be created in regards to currency. For example, if you sell your
  products in EUR but sell them to multiple countries that have different VAT
  rates.
-->

If none of a product's `Spree::Variant`s have a price value for the site's
configured currency, that product is not visible in the store frontend.

You can see a variant's price in the store's configured currency by calling the
`price` method on that instance:

```ruby
Spree::Variant.find(1).price
# => 15.99
```

You can also call the `price` method on a `Spree::Product`. If you call the
`price` method on a product, it gets the price of the product's master variant.

For a list of all of the `Spree::Price`s associated with a product or variant,
you can call the `prices` method on an instance of them:

```ruby
Spree::Product.find(1).prices
# => [#<Spree::Price id: 2 ...]
#    [#<Spree::Price id: 3 ...]

Spree::Variant.find(1).prices
# => [#<Spree::Price id: 4 ...]
#    [#<Spree::Price id: 5 ...]
```

<!-- TODO:
  Some of this article could be repurposed for a new section about Spree::Price.
-->
