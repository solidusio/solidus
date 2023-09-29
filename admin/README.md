# solidus_admin (WIP)

A Rails engine that provides an administrative interface to the Solidus ecommerce platform.

## Development

- [Customizing tailwind](docs/customizing_tailwind.md)
- [Customizing view components](docs/customizing_view_components.md)
- [Customizing the main navigation](docs/customizing_main_navigation.md)

### Adding components to Solidus Admin

When using the component generator from within the admin folder it will generate the component in the library
instead of the sandbox application.

```bash
# the `solidus_admin/` namespace is added by default
bin/rails admin g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
      create  spec/components/solidus_admin/foo/component_spec.rb
```

## Releasing

1. Update the version in `lib/solidus_admin/version.rb`
2. Commit the changes with the message `Release v1.2.3`
3. `cd admin; bundle exec rake release`
4. Manually release on GitHub
