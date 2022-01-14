# Add model preferences

Solidus comes with many model-specific preferences. They are configured to have
default values that are appropriate for typical stores. Additional preferences
can be added by your application or included extensions.

Preferences can be set on any model that includes `Spree::Preferences::Persistable`.
In core Solidus, these are all classes inheriting from:

  - `Spree::Calculator`
  - `Spree::PromotionAction`
  - `Spree::PaymentMethod`
  - `Spree::PromotionRule`

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
  class User < Spree::Base
    include Spree::Preferences::Persistable
    preference :hot_salsa, :boolean
    preference :dark_chocolate, :boolean, default: true
    preference :color, :string
    preference :favorite_number, :integer
    preference :language, :string, default: "English"
  end
end
```

This will work because User includes [`Spree::Preferences::Persistable`][spree-persistable]. If found,
the preferences attribute gets serialized into a Hash and merged with the default values.

<!-- TODO:
  Let's replace this example code with something a little more realistic. What
  kind of object would a store want multiple custom preferences on?
-->

## Supported types for preferences

For each preference you define, a data type should be provided. The available
types are:

- `boolean`
- `string`
- `encrypted_string`
- `password`
- `integer`
- `text`
- `array`
- `hash`

An optional default value may be defined. (See the `:dark_chocolate` preference
in the block above.) This is the value used unless another value has been set.

### Details for encrypted_string type

We encourage the usage of environment variables for keeping your secrets,
but in case when this is not possible you can use a preference of type
`encrypted_string`.

A preference of type `encrypted_string` accepts an option named `encryption_key`,
the value of the option will be used as key for the encryption of the preference.

If no `encryption_key` is passed the application would use the value of the
environment variable `SOLIDUS_PREFERENCES_MASTER_KEY` as encryption key.

If no environment variable `SOLIDUS_PREFERENCES_MASTER_KEY` is set the application
would use the Rails master key as encryption key.

Solidus will NOT manage the rotation, or secure storage, of the key, this things
need to be handled by hand.

To access the unencrypted value of a preference of type `encrypted_string` use the method generated
by Solidus, see [Access your preferences](#access-your-preferences).

If you try to fetch the value directly from the preferences hash, you'll get the encrypted string.

### Add columns for your preferences

In order for your new preferences to persist, you need to add a column to the
relevant model using a migration:

```ruby
class AddPreferencesToSubscriptionRules < ActiveRecord::Migration[5.0]
  def change
    add_column :my_store_users, :preferences, :text
  end
end
```

Your new `preferences` column should have the type `text`.

Then, you can run the migration:

```bash
bundle exec rails db:migrate
```

### Access your preferences

Once preferences have been defined for a model, they can be accessed either using the shortcut methods that are generated for each preference or the generic methods that are not specific to a particular preference.

#### Shortcut Methods

There are several shortcut methods that are generated. They are shown below.

Reader methods:

```ruby
user.preferred_color                # => nil
user.preferred_language             # => "English"
```

Writer methods:

```ruby
user.preferred_hot_salsa = false    # => false
user.preferred_language = "English" # => "English"
```

Check if a preference is available:

```ruby
user.has_preference? :hot_salsa     # => True
```

#### Generic Methods

Each shortcut method is essentially a wrapper for the various generic methods shown below:

Query method:

```ruby
user.prefers?(:hot_salsa)           # => false
user.prefers?(:dark_chocolate)      # => false
```

Reader methods:

```ruby
user.get_preference :color                  # => nil
user.get_preference :language               # => English
user.preferences.fetch(:dark_chocolate)     # => false
```

Writer method:

```ruby
user.set_preference(:hot_salsa, false)     # => false
user.set_preference(:language, "English")  # => "English"
```

#### Accessing All Preferences

You can get a hash of all stored preferences by accessing the `preferences` helper:

```ruby
user.preferences # => {"language"=>"English", "color"=>nil}
```

This hash will contain the value for every preference that has been defined for the model instance, whether the value is the default or one that has been previously stored.

#### Default and Type

You can access the default value for a preference:

```ruby
user.preferred_color_default # => 'blue'
```

Types are used to generate forms or display the preference. You can also get the type defined for a preference:

```ruby
user.preferred_color_type # => :string
```

[app-configuration]: app-configuration.html
[spree-persistable]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/preferences/persistable.rb
