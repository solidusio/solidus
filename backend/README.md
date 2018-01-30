# solidus\_backend

Backend contains the controllers, views, and assets making up the admin interface of solidus.

## Assets

### Javascript

Can be found in [app/assets/javascripts/spree/backend/](./app/assets/javascripts/spree/backend/)

Our scripts are written in a mix of coffeescript and javascript (ES5). We can't
easily use a transpiler for ECMAScript >= 6 without adding additional steps for
applications using solidus\_admin.

Though we have existing CoffeeScript files, any new files should be in
javascript (ES5).

### Stylesheets

Can be found in [app/assets/stylesheets/spree/backend/](./app/assets/stylesheets/spree/backend/)

The stylesheets are written in SCSS and include all of [bourbon](http://bourbon.io/docs/) and [bootstrap 4 alpha](http://v4-alpha.getbootstrap.com/).

When running the application there is a styleguide available at:

```
/admin/style_guide
```

## Testing

Run the tests

    bundle exec rspec

Run the javascript tests (must have chromedriver installed)

    bundle exec teaspoon
