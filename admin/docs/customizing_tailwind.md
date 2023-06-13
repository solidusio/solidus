# Customizing tailwind

Solidus Admin uses [Tailwind CSS](https://tailwindcss.com/) for styling. The
benefit of using Tailwind is that it allows you to customize the look and feel
of the admin without having to write any CSS. By leveraging utility classes,
you can easily change the colors, fonts, and spacing in use.

Solidus Admin sets up Tailwind in a way that allows customization. When you
install `solidus_admin`, its compiled CSS file is generated at
`app/assets/builds/solidus_admin/tailwind.css`. As we'll see below, there are
different ways in which you can add your styles to it. There are a couple of
tasks you can run to recompile the CSS file:

- `bin/rails solidus_admin:tailwindcss:build` - compiles the CSS file once.
- `bin/rails solidus_admin:tailwindcss:watch` - compiles the CSS file and
  watches for changes.

When deploying to production, the build task is automatically added as part of
the assets precompilation process.

### Adding new paths to Tailwind

Tailwind generates its CSS by scanning a configured set of paths for CSS
classes. By default, Solidus Admin will add to this list the following globs
from your host application:

- `app/components/solidus_admin/**/*.rb`
- `app/views/solidus_admin/**/*.{erb,haml,html,slim}`
- `app/helpers/solidus_admin/**/*.rb`
- `app/assets/javascripts/solidus_admin/**/*.js`
- `public/solidus_admin/*.html`

If that flexibility is not enough, you can add your own paths by appending the
`SolidusAdmin::Config.tailwind_content` setting:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin::Config.tailwind_content << Rails.root.join("app/my/custom/path/**/*.rb")
```

> ⚠ Remember to re-run the `build` or `watch` tasks after changing this setting.

### Adding custom CSS

If you need advanced Tailwind customization, you can also create your own CSS
file and append it to the Solidus Admin's default one. Be aware that's
[considered a last-resort option](https://tailwindcss.com/docs/reusing-styles)
according to Tailwind's philosophy, and most of the time you should be ok by
making use of the available Tailwind classes.

In case you need to do it, you can append your CSS file by pushing it to the
`SolidusAdmin.tailwind_stylesheets` array:

```ruby
# config/initializers/solidus_admin.rb
SolidusAdmin.tailwind_stylesheets << Rails.root.join("app/my/custom/path/my_styles.css")
```

> ⚠ Remember to re-run the `build` or `watch` tasks after changing this setting.

## Acquiring full control over Tailwind configuration

For very advanced use cases, it's possible to bail out of the Solidus Admin's
managed Tailwind configuration and get a grip on it yourself. This is not
recommended, as it will make your app more brittle to future changes in Solidus
Admin, so do it at your own risk!

There are a couple of tasks you can run for that:

- `bin/rails solidus_admin:tailwindcss:override_config` - copies the default
  Tailwind configuration file to `config/solidus_admin/tailwind.config.js.erb`.
- `bin/rails solidus_admin:tailwindcss:override_stylesheet` - copies the
  default Tailwind stylesheet file to
  `app/assets/stylesheets/solidus_admin/application.tailwind.css.erb`.

Notice that, unlike in a regular Tailwind setup, the config and stylesheet
files are ERB templates. This is because they need to be able to access the
Solidus Admin and application paths.
