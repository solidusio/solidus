# Storefront Customizations

The majority of stores that use Solidus need to change the look and feel of
the provided user-facing experience, which is just a placeholder. This page
describes the best practices to build a custom storefront, also referred
to as frontend in the Solidus domain.

## Customizing Views

We strongly encourage Solidus users to create their own frontend, without
modifying the existing one. A good approach is by copying the whole frontend
views into the host application and change them when needed.

Using Deface is not recommended as it provides lots of headaches while
debugging and degrades your shop performance.

Solidus provides a generator to help with copying the right view into your host app.

Simply call the generator to copy all views into your host app.

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

This will copy all views whose directory or filename contains the string "product".

#### Handle upgrades

After upgrading solidus to a new version run the generator again and follow on
screen instructions.
