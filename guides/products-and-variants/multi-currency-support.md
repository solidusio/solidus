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

You can see a product's price in the store's configured currency by calling the
`price` method on that instance:

```shell
product.price
=> "15.99"
```

To find a list of all the currencies that this product is available in, calling
`prices` returns all of the related `Spree::Price` objects:

```ruby
$ product.prices
=> [#<Spree::Price id: 2 ...]
   [#<Spree::Price id: 3 ...]
```

