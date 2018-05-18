# Override views

The `solidus_frontend` and `solidus_backend` gems offer a full-featured
customer-facing store and admin area for Solidus. They are not required to run
Solidus, but they offer comprehensive defaults.

You can override any frontend or backend templates by duplicating the view in
your project path. For example, if you wanted to duplicate the
`solidus_frontend`'s [`/app/views/spree/address/_form.html.erb`
partial][address-form], you can create the same file in your project:
`/app/views/spree/address/_form_html.erb`.

You can choose to write the view from scratch or use and modify the original
view. As with any Rails application, your app's views always override a gem's
views if they have the same path and filename. 

Note that you can override CSS and JavaScript assets in a similar way. For more
information see the [Override Solidus assets][override-solidus-assets] article.

[address-form]: https://github.com/solidusio/solidus/blob/master/frontend/app/views/spree/address/_form.html.erb
[override-solidus-assets]: ../assets/override-solidus-assets.html

## Rails generator for frontend overrides

If you want to override views from the `solidus_frontend` gem, you can use the
provided Rails generator in your host application:

```bash
cd your-rails-project
bundle exec rails generate solidus:views:override
```

This command creates copies of all of the frontend views, allowing you to
customize them for your store.

If you only want to copy certain views into your host app, you can provide the
`--only` argument:

```bash
bundle exec rails generate solidus:views:override --only products/show
```

The argument to `--only` can  also be a substring of the name of the view from
the app/views/spree folder:

```bash
bundle exec rails generate solidus:views:override --only product
```

This copies all the views whose directory or filename contains the string
"product".

## Overrides and Solidus upgrades

Solidus views may change with each release. If you depend on view overrides,
always test your application's views and read Solidus's changelog before
upgrading in a production environment.

## Deface

If you want to avoid upgrade difficulties, or you just need a tiny change to get
feature you need, you can use [the Deface gem][deface]. Deface dynamically
changes your templates in-place.

However, if you use Deface extensively it can be tricky to find out where a
particular piece of HTML actually comes from.

[deface]: https://github.com/spree/deface
