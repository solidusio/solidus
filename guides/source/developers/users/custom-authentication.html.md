# Custom authentication

*You can use the official [`solidus_auth_devise`][solidus-auth-devise] gem
to provide a `Spree::User` model and basic authentication for Solidus. See its
documentation for additional setup instructions.*

Stores require a `User` model in order to take advantage of all of Solidus's
features. This model can have any name, and Solidus can integrate with your
existing Rails application's existing `User` model.

By default, Solidus provides a [`Spree::LegacyUser` model][legacy-user] that
offers the bare minimum functionality of a user. The model is only suitable for
testing and should not be used in a production environment.

The rest of this article outlines the steps required should you decide to create
a `User` model from scratch, use an authentication solution like
[Devise][devise], or integrate your application's existing `User` model.

Note that while your user model can have whatever name you like, this article
uses the model `MyStore::User` for its examples.

[devise]: https://github.com/plataformatec/devise
[legacy-user]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/legacy_user.rb
[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

## Set the Spree.user_class

No matter what gem or extension you use for your store's `User` model, your
application's `Spree.user_class` value needs to be set. By default, Solidus sets
the `Spree.user_class` to `Spree::LegacyUser`.

You can configure a custom `Spree.user_class` in your application's
`/config/initializers/spree.rb` file:

```ruby
# /config/initializers/spree.rb
Spree.user_class = "MyStore::User"
```

If you use the `solidus_auth_devise` gem, your `Spree.user_class` is set to
`Spree::User` when you run the gem's `solidus:auth:install` generator.

## Prepare your user model for Solidus

Once you have set the `Spree.user_class`, you can start integrating with the
features that are associated with the `user_class`.

### Custom user generator

After you have created your custom `User` model and its corresponding database
table, you can use the `spree:custom_user` generator to generate Solidus's
required `User` table columns and some authentication helpers:

```bash
bundle exec rails generate spree:custom_user MyStore::User
```

Then, you can migrate your database to add the Solidus-specific `User` table
columns:

```bash
bundle exec rails db:migrate
```

If you use the `spree:custom_user` generator:

- The `Spree.user_class` is updated to your specified class.
- Authentication helpers are set up for the `solidus_frontend` and
  `solidus_backend` views and are sent to the application controller, making it
  available throughout your application.
- The `spree_current_user` method is defined and is sent to the application
  controller and the `Spree::Api::BaseController`, making it available
  throughout your application.

### Minimum requirements

Solidus requires that your `User` model's database table includes at least the
following columns:

- `spree_api_key`: A string with a user's API key. This should be limited to 48
  characters.
- `bill_address_id`: An integer that provides the ID of the `Spree::Address`
  that should be used as the current user's billing address.
- `ship_address_id`: An integer that provides the ID of the `Spree::Address`
  that should be used as the current user's shipping address.

These three columns are generated for you by the [`spree:custom_user`
generator](#custom-user-generator).

It also requires that you have a [`spree_current_user`](#spree-current-user)
helper method.

#### User passwords

Note that if you use the stock `solidus_frontend` or `solidus_backend` gems,
your user should also have a `password` column. You can set up a password column
however you see fit.

### spree_current_user

If you use the stock `solidus_frontend` or `solidus_backend` gems, you need to
provide a `spree_current_user` helper method. Because you likely need to
reference the current user throughout your application, we recommend adding it
to your `application_controller.rb`.

If you use an authentication gem that defines a `current_user` (like Devise),
you may want to just wrap `current_user` in a `spree_current_user` method:

```ruby
# /app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  ...

  helper_method :spree_current_user

  def spree_current_user
    current_user
  end
end
```

This helper can be generated for you by the [`spree:custom_user`
generator](#custom-user-generator).

### Add authentication helpers

If you use the stock `solidus_frontend` or `solidus_backend` gems, you need to
provide authentication helpers so that users can sign up, log in, and log out.
Because you likely need to reference the current user throughout your
application, we recommend adding it to you `application_controller.rb`:

```ruby
# /app/controllers/application_controller.rb
class ApplicationController < ActionController::Base

  ...

  helper_method :spree_login_path
  helper_method :spree_signup_path
  helper_method :spree_logout_path

  def spree_login_path
    login_path
  end

  def spree_signup_path
    signup_path
  end

  def spree_logout_path
    logout_path
  end
end
```

These helpers can be generated for you by the [`spree:custom_user`
generator](#custom-user-generator).

### Add Solidus user methods

The [`Spree::UserMethods` module][solidus-user-methods] provides extensive
integration for a `User` model. User methods allow a `User` object to relate to
other major models in Solidus like `Spree::Order`s and `Spree::StoreCredit`s.

To add user methods to your `User` model, include `Spree::UserMethods` in it:

```ruby
module MyStore
  class User
    include Spree::UserMethods
  ...
```

[solidus-user-methods]: https://github.com/solidusio/solidus/blob/master/core/app/models/concerns/spree/user_methods.rb

### Give your store administrator the admin role

In order for store administrators to use the `solidus_backend` admin, you need a
user with the `Spree::Role` of `admin`. You can give any existing user the
`admin` role like this:

```ruby
user = MyStore::User.find_by(email: 'admin@example.com')
user.spree_roles << Spree::Role.find_or_create_by(name: 'admin')
```

Now, your user with the `admin@example.com` email address should be able to
access the `solidus_backend` interface at `mystore.com/admin`.
