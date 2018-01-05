# App configuration 

Solidus includes many preferences with default settings that are appropriate for
typical stores.  For a list of Solidus's preferences their default values, see
the [`Spree::AppConfiguration` documentation][app-configuration-documentation].
The [`Spree::AppConfiguration` class][app-configuration-class] is where all of
Solidus's preferences are defined. 

The built-in preferences are well-tested options that allow you to implement
complex ecommerce behaviors.

A limited set of these preferences can be configured by store administrators
from the `solidus_backend` admin area.

Since Solidus is a [Rails engine][rails-engines], much of its behavior can be
customized through initializers. You can modify or initialize preferences using
initializers. Some default preferences are explicitly set in the initializer at
`config/initializers/spree.rb`.

In this file's first `Spree.config` block, the `currency` and `mails_from`
preferences are given default values you may want to modify: 

```ruby
# /config/initializers/spree.rb
Spree.config do |config|
  config.currency = "USD"
  config.mails_from = "store@example.com"
end
```

This block instantiates the main configuration object for `solidus_core`.
Here, you can start to change Solidus's behavior to accommodate many common use
cases.

Once your application has been initialized, you can set any preferences using
`Spree::Config`, which is an instance of `Spree::AppConfiguration`. For example,
if you wanted to change your store's currency:

```ruby
Spree::Config.currency = "AUD"
```

## Read the current preference settings

You can read all of Solidus's currently set preferences quickly from your Rails
console:

```ruby
Spree::Config
```

Or, if you want the value of a specific preference:

```ruby
Spree::Config.currency
```

<!-- TODO:
  Spree's documentation has documentation for creating new configuration by
  inheriting from the `Spree::Preferences::Configuration` class. Should we
  recommend that developers extend the site-wide configuration at all? If so,
  let's add a section to this article.
-->

[app-configuration-model]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/app_configuration.rb
[app-configuration-documentation]: http://docs.solidus.io/Spree/AppConfiguration.html
[rails-engines]: http://guides.rubyonrails.org/engines.html
