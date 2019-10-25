# Decorators

Solidus autoloads any file in the `/app` directory that has the suffix
`_decorator.rb`, just like any other Rails models or controllers. This allows
you to [monkey patch][monkey-patch] Solidus functionality for your store.

For example, if you want to add a method to the `Spree::Order` model, you could
create `/app/models/mystore/order_decorator.rb` with the following contents:

```ruby
module MyStore::OrderDecorator
  def total
    super + BigDecimal(10.0)
  end

  Spree::Order.prepend self
end
```

This creates a new module called `MyStore::OrderDecorator` that prepends its
methods early in the method lookup chain. So, for method calls on `Spree::Order`
objects, the decorator's `total` method would override the original `total`
method.

With the code above live on your server, every call to `Spree::Order.total` will
return the original total plus $10 (or whatever your currency is).

[monkey-patch]: https://en.wikipedia.org/wiki/Monkey_patch

## Using class-level methods in decorators

You'll need to define a special method in order to access some class-level
methods

```ruby
module MyStore::ProductDecorator

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

In this example, a decorator has been used to extend the functionality of
`Spree::Product`. The decorator includes an ActiveRecord association, scope,
and delegation.

## Decorators and Solidus upgrades

Decorators can complicate your Solidus upgrades. If you depend on decorators,
ensure that you test them before upgrading in a production environment.
Note that Solidus's core classes may change with each release.
