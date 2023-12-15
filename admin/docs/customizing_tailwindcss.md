# Customizing TailwindCSS

Solidus Admin uses [Tailwind CSS](https://tailwindcss.com/) for styling. The
benefit of using Tailwind is that it allows you to customize the look and feel
of the admin without having to write any CSS. By leveraging utility classes,
you can easily change the colors, fonts, and spacing in use.

Solidus Admin provides a precompiled CSS file that includes all the necessary
Tailwind classes for the admin to work out of the box.

In case you need to customize the admin's look and feel, or create custom
components, you can do so by running Tailwind's build process in your host
application.

This process presumes that you have a working knowledge of Tailwind CSS. If you
are not familiar with Tailwind, please refer to the [Tailwind
documentation](https://tailwindcss.com/docs) for more information.

## Setting up a local TailwindCSS build for Solidus Admin

In order to customize the admin's look and feel, you'll need to set up a local
Tailwind build. This is a two-step process:

Add Tailwind configuration files to your application:

```shell
bin/rails solidus_admin:tailwindcss:install
```

This will create all the necessary files for you to customize TailwindCSS,
including:
- A `config/solidus_admin/tailwind.config.js` configuration file
  that will automatically import the Solidus Admin's default configuration.
- An `app/assets/stylesheets/solidus_admin/application.tailwind.css` file
  in which you can add your own customizations.
- Tasks to build the CSS file once or watch for changes and automatically
  rebuild the target `app/assets/builds/solidus_admin/application.css` file.

In order to manually build the CSS file, run:

```shell
bin/rails solidus_admin:tailwindcss:build
```

Or, to watch for changes and automatically rebuild the CSS file, run:

```shell
bin/rails solidus_admin:tailwindcss:watch
```

## Caveats

### Conflict with sassc-rails

Tailwind uses modern CSS features that are not recognized by the sassc-rails extension that was included by default in the Gemfile for Rails 6. In order to avoid any errors like SassC::SyntaxError, you must remove that gem from your Gemfile.

*See https://github.com/rails/tailwindcss-rails#conflict-with-sassc-rails.*
