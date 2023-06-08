# solidus_admin (WIP)

A Rails engine that provides an administrative interface to the Solidus ecommerce platform.

- [Customizing tailwind](docs/customizing_tailwind.md)

## Development

### Adding components to Solidus Admin

When using the component generator from within the admin folder it will generate the component in the library
instead of the sandbox application.

```bash
cd admin
# the `solidus_admin/` namespace is added by default
bin/rails g solidus_admin:component foo
      create  app/components/solidus_admin/foo/component.rb
      create  app/components/solidus_admin/foo/component.html.erb
      create  app/components/solidus_admin/foo/component.yml
      create  app/components/solidus_admin/foo/component.js
      create  spec/components/solidus_admin/foo/component_spec.rb
```
