# Customizing Permissions

Authorization in Solidus is built upon the
[CanCan(Can)](https://github.com/CanCanCommunity/cancancan) gem, which offers
an expressive DSL to
[define](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities)
and
[verify](https://github.com/CanCanCommunity/cancancan/wiki/checking-abilities)
user permissions against application resources.

CanCan allows you to prevent access control logic from being scattered
throughout the application source code. Instead, it enables you to define all
user permissions in Ability classes.

Solidus builds on this concept by allowing you to specify different permission
set classes and assign them to specific user roles.

Let's see in details what these concepts represent and how to manage them.

## Roles

Solidus comes with two preconfigured roles: *admin* and *default*. A user that
`has_spree_role?(:admin)` has access to the admin panel and can manage all
resources. A user that `has_spree_role?(:default)` represents a client or a
website visitor that can view certain resources, manage their shopping carts,
etc.  Each user can have multiple roles. Admin users can change the roles of
other users using the Admin panel under the Users section.

## Permission sets

Solidus comes with a list of ready-to-use permission sets that you can find in
[core/lib/spree/permission_sets][permissions-sets]. It also includes a
`Spree.config.roles` preference, that you can use to change or extend default
permission sets.

By default roles and permission sets are configured with the following
[code][roles-configuration]:

```ruby
# core/lib/spree/app_configuration.rb

# ...

Spree::RoleConfiguration.new.tap do |roles|
  roles.assign_permissions :default, ['Spree::PermissionSets::DefaultCustomer']
  roles.assign_permissions :admin, ['Spree::PermissionSets::SuperUser']
end

# ...
```

This maps a list of permission sets to each role that we can use:

- Users with role `default` will have
  [`Spree::PermissionSets::DefaultCustomer`][default-customer-permissions] permissions
- Users with role `admin` will have
  [`Spree::PermissionSets::SuperUser`][admin-permissions] permissions


[permissions-sets]: https://github.com/solidusio/solidus/tree/master/core/lib/spree/permission_sets
[roles-configuration]: https://github.com/solidusio/solidus/blob/3e6de0ce0c190fd7415d46557da5786c4dda13dd/core/lib/spree/app_configuration.rb#L445-L450
[default-customer-permissions]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/permission_sets/default_customer.rb
[admin-permissions]: https://github.com/solidusio/solidus/blob/master/core/lib/spree/permission_sets/super_user.rb


## Manage Roles

If we want to add a new role with its own set of permissions to our store
then first we must create a new `Spree::Role`, which can be done
in one of the following ways:

- Manually add a row in the `spree_roles` table by executing
  `Spree::Role.create(name: 'role_name')` in the Rails console
- Add the line
  `Spree::Role.find_or_create_by(name: 'role_name')` in one of the configuration
  files (`config/intializers/spree.rb`, `config/application.rb`,
  `db/migrations`, `db/seeds`) for each role you wish to create

Now that the new role has been created you can simply assign a new list of
permission sets to it in the Solidus initializer:

```ruby
# config/initializers/spree.rb

Spree.config do |config|
  config.roles.assign_permissions :role_name, ['Spree::PermissionSets::AnotherPermissionSet']
end
```

`Spree::PermissionSets::AnotherPermissionSet` can be selected from the list of
roles provided by Solidus, or alternatively can be a custom role that you
have created.


### Add a New Permission Set

New permission sets should be created in their own dedicated classes that
extend `Spree::PermissionSets::Base`. Permission rules defined with the CanCan
DSL should be created in the `activate!` method. To add a new permission set you
can simply create this new class in `lib/spree/permission_sets/`:

```ruby
# lib/spree/permission_sets/blog_management.rb

module Spree
  module PermissionSets
    class BlogManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Page
      end
    end
  end
end
```

Finally, remember to load permission set files in your application
configuration by adding the following code to `config/application.rb`:

```ruby
# config/application.rb

config.before_initialize do
  Dir.glob(File.join(File.dirname(__FILE__), "../lib/spree/permission_sets/*.rb")) do |c|
    require_dependency(c)
  end
end
```
