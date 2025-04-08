# Solidus Admin

A Rails engine that provides an administrative interface to the Solidus e-commerce platform.

## Overview

- Based on ViewComponent and TailwindCSS
- Uses StimulusJS and Turbo for interactivity
- Works as a separate engine with its own routes
- Uses the same models as the main Solidus engine
- Has its own set of controllers

## Installation

`solidus_admin` is included by default in new stores generated with Solidus 4.3 or later, as well as those generated from the main branch.

`solidus_admin` can be added to existing stores by bundling it in the Gemfile and running the installer generator:

```bash
bundle add solidus_admin
bin/rails g solidus_admin:install
```

If you're using an authentication system other than `solidus_auth_devise` you'll need to manually configure authentication methods (see api documentation for `SolidusAdmin::Configuration`).

If you encounter the error `couldn't find file 'solidus_admin/tailwind.css'` when loading admin pages, you need to manually build the `solidus_admin` tailwind CSS styles.
This issue typically occurs when you bundle Solidus from a GitHub branch or from the local filesystem, or with the sandbox application.
Please see [Customizing tailwind](docs/tailwindcss.md) for more information.

### Components

See [docs/contributing/components.md](docs/components.md) for more information about components.

### Using it alongside `solidus_backend`

`solidus_backend` is the current admin interface for Solidus. `SolidusAdmin` is under development, acts as a drop-in replacement for `solidus_backend` and will eventually replace it. It's designed to gradually take over existing functions.

For now, you can use both `solidus_backend` and `SolidusAdmin` in the same application. To do this, mount the `SolidusAdmin` engine before `Spree::Core::Engine`.

You can use a route `constraint` to replace any `solidus_backend` routes with `SolidusAdmin` routes.

By default, `SolidusAdmin` routes are turned off if a cookie named `solidus_admin` is set to `false`, or if a query parameter named `solidus_admin` is set to `false`. This lets you switch between the two admin interfaces easily.

This constraint is set up in the application's routes file, so you can easily change it:

```ruby
# config/routes.rb
mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
  $redis.get('solidus_admin') == 'true' # or any other logic
}
```

### Authentication & Authorization

- Solidus Amidn delegates authentication to `solidus_backend` and relies on `solidus_core` for authorization.

## Development

- [Customizing tailwind](docs/tailwindcss.md)
- [Customizing view components](docs/customizing_components.md)
- [Customizing the main navigation](docs/menu_items.md)

### Adding components to Solidus Admin

Solidus Admin components can be generated with the `solidus_admin:component`generator:

```bash
# the `solidus_admin/` namespace is added by default
bin/rails admin g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
      create  spec/components/solidus_admin/foo/component_spec.rb
```

Please note that when using the component generator from within the admin folder it will generate the component in the library
instead of the sandbox application.

## Releasing

1. Update the version in `lib/solidus_admin/version.rb`
2. Commit the changes with the message `Release solidus_admin/v1.2.3`
3. `cd admin; bundle exec rake release`
4. Manually release on GitHub
