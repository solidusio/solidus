# Admin User Class Configuration

Historically Solidus used a single user model for both storefront customers and
admin users, with access to the backoffice decided purely by roles. That means a
customer record and an administrator record share one table, one set of
validations and one authentication configuration, so any weakness in customer
signup is a weakness in admin access.

`Spree.admin_user_class` lets an application separate the two:

- `Spree.user_class` is the storefront (customer) user model.
- `Spree.admin_user_class` is the admin/backoffice user model.

Separating them lets each side carry its own rules: stricter password
requirements, a restricted email domain, or a different authentication setup
entirely for admins, without imposing any of that on customers.

## Configuration

In `config/initializers/spree.rb`:

```ruby
# Storefront user model
Spree.user_class = 'YourApp::User'

# Admin/backoffice user model
Spree.admin_user_class = 'YourApp::AdminUser'
```

`Spree.admin_user_class` falls back to `Spree.user_class` when it is not set, so
existing applications keep working unchanged with a single user model. Note that
the install generator writes both settings explicitly, pointing them at the same
class.

Both settings must be assigned a String or Symbol, never a Class — they are
resolved lazily, because user models are often loaded before this initializer
runs.

## Where it's used

Admin and backoffice code resolves the user model through
`Spree.admin_user_class`, including the classic backend controllers, views and
navigation, and the Solidus Admin controllers and components. In specs, the
`:admin_user` factory builds a `Spree.admin_user_class`.

Storefront and checkout code continues to use `Spree.user_class`.

## What this does not do yet

Setting `Spree.admin_user_class` changes which model the admin interfaces read
and write. It does not by itself give that model authentication — there is no
generator for a separate admin Devise scope yet, so wiring up admin login for a
dedicated model is currently left to the application.
