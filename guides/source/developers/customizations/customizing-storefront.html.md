# Storefront Customizations

The majority of stores that use Solidus need to change the look and feel of the
provided user-facing experience, which is only intended as a placeholder. This
page describes the best practices to build a custom storefront, also referred to
as the frontend in the Solidus domain.

## Customizing Views

We strongly encourage Solidus users to create their own frontend without
modifying the existing one. A good approach is by copying all frontend
views into the host application and changing them as needed.

Using Deface is not recommended because it can make debugging difficult
and degrade your shop's performance.

Solidus provides a generator to help with copying the right view into your host app.

Simply call the following generator to copy all views into your host app:

```shell
$ bundle exec rails g solidus:views:override
```

If you only want to copy certain views into your host app, you can provide
the `--only` argument:

```shell
$ bundle exec rails g solidus:views:override --only products/show
```

The argument to `--only` can also be a substring of the name of the view
from the `app/views/spree` folder:

```shell
$ bundle exec rails g solidus:views:override --only product
```

This will copy all views whose directory or filename contains the string
"product".

#### Handle upgrades

After upgrading Solidus to a new version, run the generator again and follow the
on-screen instructions.
