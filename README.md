![Solidus Starter Frontend Rails Storefront](https://github.com/solidusio/solidus_starter_frontend/assets/167946/16c0298a-a2bd-47d9-a2eb-64bcc8d2fa74)

# Solidus Starter Frontend
[![Workflow Name](https://github.com/solidusio/solidus_starter_frontend/actions/workflows/test.yml/badge.svg)](https://github.com/solidusio/solidus_starter_frontend/actions/workflows/<WORKFLOW_FILE>)
[![codecov](https://codecov.io/gh/solidusio/solidus_starter_frontend/branch/main/graph/badge.svg?token=54gge25dNh)](https://codecov.io/gh/solidusio/solidus_starter_frontend)

`solidus_starter_frontend` is a new starter storefront for [Solidus][solidus].

This project aims to deliver a modern, minimal, semantic, and easy to extend
codebase for a more efficient bootstrapping experience.

**DISCLAIMER**: some Solidus extensions (the ones that depend on Solidus
Frontend) will not work with this project because they rely on defacing some
views items that don't exist here.

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

That will create a new Solidus application with SolidusStarterFrontend as its
storefront.

Please note that [Solidus Auth Devise](https://github.com/solidusio/solidus_auth_devise)
will also be added to your application as it's required by SolidusStarterFrontend.

## Considerations

The installation of Solidus Starter Frontend will copy the frontend views,
assets, routes, controllers, and specs to your project. You can change easily
anything that we created; this gives you a lot of freedom of customization.

Note that since the Solidus Starter Frontend is a Rails
application template, it doesn't have the capability to automatically update
your storefront code whenever the template is updated.

It is not possible right now to generate a new Rails app with the template, i.e.
run `rails new --template=URL` since the template expects Solidus to be
installed on the app.

In addition, please note that it will add Solidus Auth Devise frontend
components to your app. At the moment, you will need to manually remove the gem
and its frontend components if you don't need them.

## Compatibility

Because this project copies files over the host application, and it is intended
to be used only when Solidus is installed for the first time, we can guarantee
the latest code only works with the latest available version of Solidus and Rails.

This means that each Solidus version will have one specific supported version of
the Starter Frontend. Each version is stored in a different branch of this repository.
For example, Solidus `v3.3` will be working with Solidus Starter Frontend's templates
coming from `v3.3` branch of this repository.

This compatibility is also enforced in the Solidus installer. In fact, each Solidus
version will point its installer to the template of the corresponding branch over here.

## Security updates

To receive security announcements concerning Solidus Starter Frontend, please
subscribe to the
[Solidus Security mailing list](https://groups.google.com/forum/#!forum/solidus-security).
The mailing list is very low traffic, and it receives the public notifications
the moment the vulnerability is published. For more information, please check out
https://solidus.io/security.

## Development

For information about contributing to this project please refer to this
[document](docs/development.md). There you'll find information on tasks like:

* Testing the extension
* Running the sandbox
* Updating the changelog
* Releasing new versions
* Docker development

## CI Testing Strategy

The following parameters are considered in the CI testing strategy:

### Database

We are testing this starter kit against PostgreSQL, MySQL and SQLite.
### Ruby Version

We are testing this starter kit against the [currently supported
Ruby versions](https://endoflife.date/ruby).

### Rails version

We are testing this starter kit against the last Rails version
at the time the corresponding Solidus version has been released.
Eg. Solidus v3.3 tests against Rails 7.0

### Solidus Version

- `main` branch will test installing itself over Solidus main only.
- the branch corresponding to the latest Solidus release (with `vX.X`
  format) will only test installing itself over the corresponding
  Solidus version.
- branches targetting older Solidus versions won't be tested.

### Scheduled pipelines

Daily, we are running a scheduled test suite run against the `main`
branch and the branch corresponding to the latest Solidus release.
This scheduled test will give us more confidence that this starter
kit always works with the latest Solidus's released versions and
the development version.

## About

[![Nebulab][nebulab-logo]][nebulab]

`solidus_starter_frontend` is funded and maintained by the [Nebulab][nebulab]
team.

We firmly believe in the power of open-source. [Contact us][contact-us] if you
like our work and you need help with your project design or development.

[solidus]: https://solidus.io/
[nebulab]: https://nebulab.com/
[nebulab-logo]: https://raw.githubusercontent.com/solidusio/brand/master/partners/Nebulab/logo-dark-light.svg
[contact-us]: https://nebulab.com/contact-us/

## License
Copyright (c) 2020 Nebulab SRLs, released under the New BSD License.
