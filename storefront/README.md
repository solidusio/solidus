# solidus\_storefront

Storefront contains the Solidus Starter Frontend, a Rails application template
that provides a modern, minimal, semantic, and easy to extend storefront for
[Solidus](https://solidus.io/).

**DISCLAIMER**: some Solidus extensions (the ones that depend on the legacy
Solidus Frontend) will not work with this storefront because they rely on
defacing views that don't exist here.

## Installation

Just run:

```bash
rails new store
cd store
bundle add solidus

mkdir -p app/assets/config
cat <<MANIFEST > app/assets/config/manifest.js
//= link_tree ../images
//= link_directory ../javascripts .js
//= link_directory ../stylesheets .css
MANIFEST

bin/rails generate solidus:install --frontend=starter
```

That will create a new Solidus application with the starter frontend as its
storefront.

Please note that [Solidus Auth Devise](https://github.com/solidusio/solidus_auth_devise)
will also be added to your application as it's required by the starter
frontend.

## Considerations

The installation of the starter frontend copies the storefront views, assets,
routes, controllers, and specs to your project. You can easily change anything
that we created; this gives you a lot of freedom of customization.

Note that since the starter frontend is a Rails application template, it
doesn't have the capability to automatically update your storefront code
whenever the template is updated.

It is not possible right now to generate a new Rails app with the template,
i.e. run `rails new --template=URL`, since the template expects Solidus to be
installed on the app.

In addition, please note that it will add Solidus Auth Devise frontend
components to your app. At the moment, you will need to manually remove the
gem and its frontend components if you don't need them.

## Compatibility

Because this component copies files over the host application, and it is
intended to be used only when Solidus is installed for the first time, we can
guarantee the latest code only works with the latest available version of
Solidus and Rails.

Each Solidus version ships with its own version of the starter frontend: the
installer applies the templates coming from the Solidus branch corresponding
to the version being installed. For example, Solidus `v4.5` will use the
templates coming from the `v4.5` branch of the Solidus repository, while
prereleases will use the ones coming from the `main` branch.

## Testing

Run the storefront test suite, which generates a sandbox application from the
templates (if it doesn't exist yet) and runs the specs against it:

```bash
bin/rspec
```

## Development

For information about contributing to this component please refer to
[docs/development.md](docs/development.md). There you'll find information on
tasks like:

* Running the sandbox
* Docker development
