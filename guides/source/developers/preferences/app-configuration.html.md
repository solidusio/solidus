# App configuration

Solidus includes many preferences with default settings that are appropriate for
typical stores. For a list of Solidus' preferences and their default values,
see the [`Spree::AppConfiguration`
documentation][app-configuration-documentation]. The `Spree::AppConfiguration`
class is where all of Solidus' preferences are defined.

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
Here, you can start to change Solidus' behavior to accommodate many common use
cases.

Once your application has been initialized, you can set any preferences using
`Spree::Config`, which is an instance of `Spree::AppConfiguration`. For example,
if you wanted to change your store's currency:

```ruby
Spree::Config.currency = "AUD"
```

## Do not extend application-wide preferences

We do not support changing or extending the `Spree::AppConfiguration`
preferences. However, you may be able to get the functionality you require by
adding preferences that are specific to a model. For more information see the
[Add model preferences][add-model-preferences] article.

If you're developing a Solidus plugin you may consider adding your configuration
by inheriting from the class `Spree::Preferences::Configuration` just like
Solidus does.

Another way to add configuration is by customizing `Rails.configuration`,  see the
[Rails guides](https://guides.rubyonrails.org/configuring.html#custom-configuration)
for details and examples.

[add-model-preferences]: add-model-preferences.html

## Read the current preference settings

You can read all of Solidus' currently set preferences quickly from your Rails
console:

```ruby
Spree::Config
```

Or, if you want the value of a specific preference:

```ruby
Spree::Config.currency
```

[app-configuration-model]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/app_configuration.rb
[app-configuration-documentation]: http://docs.solidus.io/Spree/AppConfiguration.html
[rails-engines]: http://guides.rubyonrails.org/engines.html
