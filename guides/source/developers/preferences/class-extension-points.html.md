# Class extension points

The `Spree::AppConfiguration` object includes getters and setters for Solidus
classes as extension points.

Before extending any class, study the standard implementation of it carefully.
Once you understand the implementation, you can use Solidus's provided extension
points to subclass or re-implement it for your store.

Solidus's service class extension points can be found as part of the
[`Spree::AppConfiguration`][app-configuration] object, where each line that
begins with `class_name_attribute` defines a different extension point.

[app-configuration]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/app_configuration.rb

## Example usage

When you extend a class, you can change the behavior of a single feature or your
entire store.

For example, you can change what appears in a customer's search results by
extending the [`Spree::Core::Search::Base`][search-base]. This way, you do not
need to completely rewrite Solidus's searcher. Solidus provides a class
extension point for this:

```ruby
# /core/lib/spree/app_configuration.rb
class_name_attribute :searcher_class, default: 'Spree::Core::Search::Base'
```

Note that if you do not use this extension point, then `searcher_class`
defaults to using `Spree::Core::Search::Base`.

Extending the searcher is a multi-step process:

1. Create a custom searcher for your store at `/lib/mystore/product_search.rb`.
2. Define a private `get_base_scope` method to override in classes that inherit
   from `Spree::Core::Search::Base`.
3. Connect your searcher to the `:searcher_class` extension point in the Solidus
   initializer at `config/initializers/spree.rb`.

In your `MyStore::ProductSearch` class, rewrite the
`Spree::Core::Search::Base`'s `get_base_scope` method with our desired
functionality:

```ruby
# /lib/mystore/product_search.rb
module MyStore
  class ProductSearch < Spree::Core::Search::Base

    private

    def get_base_scope
      super.where("name LIKE '%Ruby%'")
    end
  end
end
```

This searcher only displays search results that pass on to the `base_scope`
variable and have the string `Ruby` in their name.

Then, you can apply your searcher to the extension point in your
`config/initializers/spree.rb` initializer:

```ruby
# /config/initializers/spree.rb
require 'my_store/product_search'

Spree.config do |config|
  config.searcher_class = MyStore::ProductSearch
end
```

Now, when search is built it uses your extended `MyStore::ProductSearch`
functionality instead of the default functionality.

[search-base]: https://github.com/solidusio/solidus/blob/v2.4/core/lib/spree/core/search/base.rb

## Generating extension points

If you see yourself overriding a class with a definable interface, and there is
no associated extension point, [consider submitting a pull
request][contributing] for your changeable class.

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md
