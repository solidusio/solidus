# Custom frontend 

As a Rails engine, Solidus allows you to build a custom application frontend
from scratch. You can build out a frontend in the same way that you would for
any other Rails application.

This article focuses how you can build out views for your application. However,
keep in mind that you would also need to utilize Solidus's models and  create
your own controllers to create a functional storefront.

## `solidus_frontend` and `solidus_backend`

Solidus includes both a storefront ([`solidus_frontend`][solidus-frontend]) and
admin area ([`solidus_backend`][solidus-backend]). The storefront uses
[Skeleton][skeleton] for its CSS grids and the admin area is based on
[Bootstrap][bootstrap]. These gems offer the features of a typical store and
make extensive use of `solidus_core`'s features.

You may not want to use the gems for your own store. However, you may want to
use them as a reference when building out your own frontend and backend.

These gems use the following tools to create views:

- [ERB][erb] for view templates.
- [SASS][sass] for CSS preprocessing.
- Pure JavaScript for JavaScript assets.

[bootstrap]: https://getbootstrap.com
[erb]: https://apidock.com/ruby/ERB
[sass]: https://sass-lang.com
[skeleton]: http://getskeleton.com
[solidus-backend]: https://github.com/solidusio/solidus/tree/master/backend
[solidus-frontend]: https://github.com/solidusio/solidus/tree/master/frontend

## Getting started with Rails frontend development

If you intend to create your own storefront or admin area for a Solidus-based
store, we recommend that you first familiarize yourself with Rails. Solidus is a
Rails engine, so you would develop it the same way you would any other Rails
app.

If you are new to Rails, here are some resources you can use to get started
building your own application frontend:

- [Ruby on Rails Tutorial: Learn Web Development with
  Rails](https://www.railstutorial.org/book/) (Michael Hartl)
- [Getting Started with Rails](http://guides.rubyonrails.org/getting_started.html)
  (*Rails Guides*)
- [The Asset Pipeline](http://guides.rubyonrails.org/asset_pipeline.html)
  (*Rails Guides*)
- [Rails Internationalization (I18n) API](http://guides.rubyonrails.org/i18n.html)
  (*Rails Guides*)

Note that we could recommend all of the [Rails Guides][rails-guides]. But for
frontend development, pay special attention to the Rails Guides linked to above.

[rails-guides]: http://guides.rubyonrails.org

<!-- TODO:
  Uncomment the following content once #2488 is merged.

  ## Override existing views

  If you use the `solidus_frontend` or `solidus_backend` gems, you can override
  their views by creating files with the same filenames and paths in your own app.
  For more information, see the [Override views][override-views] article.

  [override-views]: override-views.html
-->

## Create your own Solidus frontend

If you choose not to use the `solidus_frontend` gem and build your own
storefront from scratch, see the list below for Solidus-specific setup
information.

### Solidus application settings

The `Solidus::Config` settings affect many values across the frontend of your
store. You can change these settings in your `/config/initializers/spree.rb`
file or any other initializer.

You can check all of the default settings of `Spree::Config` by sending this
command to your Rails console:

```ruby
Spree::Config.inspect
```

As you develop your application's frontend specifically, you may want to
initialize your own values for the following `Spree::Config` settings:

- `:layout`: Specifies a view in your `/app/view` to be used as the base layout
  for your storefront. The default value is
  `spree/layouts/spree_application[.html.erb]`, which is a file included in the
  `solidus_frontend` gem.
- `:logo`: Specifies a file in your `/app/assets/images` to be used as the logo
  on the storefront.  You can access the logo from any view using the `<%= logo
  %>` variable. The default value is `logo/solidus.svg`
- `:products_per_page`: Sets the amount of products that should be displayed on
  a single page. The default value is `12`.

### Contributing back to Solidus

If you intend to submit pull requests to Solidus, note that Solidus uses pure
JavaScript for all of its `solidus_frontend` and `solidus_backend` code. Files
written in CoffeeScript would not be accepted. For more information about
contributing to Solidus, see the [Contributing][contributing] guide.

[contributing]: https://github.com/solidusio/solidus/blob/master/CONTRIBUTING.md

