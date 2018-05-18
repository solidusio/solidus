# Add model preferences

Solidus comes with many model-specific preferences. They are configured to have
default values that are appropriate for typical stores. Preferences can be set
on any model that inherits from [`Spree::Base`][spree-base].

Note that model preferences apply only to the current model. To learn more about
application-wide preferences, see the [App configuration][app-configuration]
article.

We recommend keeping preferences to the minimum necessary. However, if your
store requires additional preferences, you can create custom ones that
have any number of arguments.

## Define new preferences

You can define preferences for a model within the model itself:

```ruby
module MyStore
  class SubscriptionRules < Spree::Base
    preference :hot_salsa, :boolean
    preference :dark_chocolate, :boolean, default: true
    preference :color, :string
  end
end
```

<!-- TODO:
  Let's replace this example code with something a little more realistic. What
  kind of object would a store want multiple custom preferences on?
-->

For each preference you define, a data type should be provided. The available
types are:

- `boolean`
- `string`
- `password`
- `integer`
- `text`
- `array`
- `hash`

An optional default value may be defined. (See the `:dark_chocolate` preference
in the block above.) This is the value used unless another value has been set. 

### Add columns for your preferences

In order for your new preferences to persist, you need to add a column to the
relevant model using a migration:

```ruby
class AddPreferencesToSubscriptionRules < ActiveRecord::Migration[5.0]
  def change
    add_column :my_store_subscription_rules, :preferences, :text
  end
end
```

Your new `preferences` column should be the type `text`.

Then, you can run the migration:

```bash
bundle exec rails db:migrate
```

### Access your preferences

Now you can access their values from the model they are set on:

```ruby
MyStore::SubscriptionRules.find(1).preferences
# => {:hot_salsa => nil, :dark_chocolate => true, :color => "grey"}
```

Or, the value of a specific preference:

```ruby
MyStore::SubscriptionRules.find(1).preferences.fetch(:dark_chocolate)
# => true
```

[app-configuration]: app-configuration.html
[spree-base]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/base.rb
