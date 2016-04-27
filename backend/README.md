# solidus\_backend

Backend contains the controllers, views, and assets making up the admin interface of solidus.

## Assets

### Javascript

Can be found in [app/assets/javascripts/spree/backend/](./app/assets/javascripts/spree/backend/)

Out scripts are written in a mix of coffeescript and javascript. We can't
easily use a transpiler for ECMAScript >= 6 without adding additional steps for
applications using solidus\_admin.

As a result, we accept contributions in either plain-ol javascript or
CoffeeScript, and discourage converting existing files.

### Stylesheets

Can be found in [app/assets/stylesheets/spree/backend/](./app/assets/stylesheets/spree/backend/)

The stylesheets are written in SCSS and include all of [bourbon](http://bourbon.io/docs/) and [bootstrap 4 alpha](http://v4-alpha.getbootstrap.com/).

When running the application there is a styleguide available at:

```
/admin/style_guide
```

## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
