# Monkey Patches

> If you're using a Solidus version minor than 3.2, the content on this page is
> still applicable. However, you might want to look at the previously recommended
> approach through [decorators][decorators].

You can take advantage of Ruby's meta-programming features to [monkey
patch][monkey-patch] Solidus functionality for your store.

As the first thing, you need to configure a directory where you'll place your
custom code. For instance, `app/overrides/`:

```ruby
# config/application.rb
module MyStore
  class Application < Rails::Application
    # ...
    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*.rb").each do |override|
        load override
      end
    end
  end
end
```

> If you're using the classic autoloader (the default before Rails 6), you
instead need to go with:
>
> ```ruby
> # config/application.rb
> module MyStore
>   class Application < Rails::Application
>     # ...
>     config.to_prepare do
>       Dir.glob("#{Rails.root}/app/overrides/**/*.rb").each do |override|
>         require_dependency override
>       end
>     end
>   end
> end
> ```

For example, if you want to add a method to the `Spree::Order` model, you could
create `/app/overrides/my_store/order_total_modifier.rb` with the following contents:

```ruby
module MyStore::OrderTotalModifier
  def total
    super + BigDecimal(10.0)
  end

  Spree::Order.prepend self
end
```

This creates a new module called `MyStore::OrderTotalModifier` that prepends
its methods early in the method lookup chain. So, for method calls on
`Spree::Order` objects, the monkey patch's `total` method would override the
original `total` method.

With the code above live on your server, every call to `Spree::Order.total` will
return the original total plus $10 (or whatever your currency is).

[monkey-patch]: https://en.wikipedia.org/wiki/Monkey_patch
[decorators]: decorators.html

## Using class-level methods

You'll need to define a special method in order to access some class-level
methods

```ruby
module MyStore::ProductAdditions

  # This is the place to define custom associations, delegations, scopes and
  # other ActiveRecord stuff
  def self.prepended(base)
    base.has_many :comments, dependent: :destroy
    base.scope    :sellable, -> { base.where(...).order(...) }
    base.delegate :something, to: :something
  end

  ...

  Spree::Product.prepend self
end
```

In this example, we're extending the functionality of `Spree::Product`. We
include an ActiveRecord association, scope, and delegation.

## Monkey patches and Solidus upgrades

Monkey patches can complicate your Solidus upgrades. If you depend on them,
[ensure](ensure) that you test them before upgrading in a production environment. Note
that Solidus's core classes may change with each release.
