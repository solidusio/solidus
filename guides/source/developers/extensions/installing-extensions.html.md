# Installing extensions

Solidus extensions are gems that change or extend Solidus's functionality. Many
Solidus extensions can be installed in a few simple steps:

1. Add the extension gem to your project's `Gemfile`.
2. Run `bundle install` to install the gem and its dependencies.
3. Run any Rails generators required by the gem. This should be mentioned in the
   extension's documentation.

For example, the [`solidus_related_products`][solidus-related-products]
extension provides a generic way to define relationships between your store's
products by using `RelationTypes`. The extension's documentation clearly lays
out the installation process: add the `solidus_related_products` gem to your
`Gemfile`, then run `bundle install` and `bundle exec rails generate
solidus_related_products:install`.

Some extensions require other custom configuration before they can be
initialized.

*We strongly recommend reading the extension's documentation before attempting
to run it in a production environment.*

[solidus-related-products]: https://github.com/solidusio-contrib/solidus_related_products

## Supported extensions

You can add additional features to your store using Solidus extensions. A list
of supported extensions can be found at [solidus.io/extensions][extensions].

You can use the [`solidus_dev_support`][solidus_dev_support] gem if you want
to start creating a new Solidus extension.

[extensions]: http://solidus.io/extensions
[solidus_dev_support]: https://github.com/solidusio/solidus_dev_support

## Soliton

You can search for other Solidus extensions on GitHub using [Soliton][soliton],
a Solidus extension search engine courtesy of [Nebulab][nebulab].

[soliton]: http://soliton.nebulab.it
[nebulab]: https://nebulab.it
