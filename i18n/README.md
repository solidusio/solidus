# Spree Internationalization

This is the Internationalization project for [Spree Commerce](http://spreecommerce.com/)

See the [official Internationalization documentation](http://guides.spreecommerce.com/i18n.html) for more details.

To install, simply add the Gem to your Gemfile:

Add the following to your Gemfile

    gem 'spree_i18n', :git => 'git://github.com/spree/spree_i18n.git'

Run `bundle install`

You can use the generator to install migrations and append spree_i18n assets to
your app spree manifest file.

    rails g spree_i18n:install

This will insert this lines on your spree manifest files:

    app/assets/javascripts/admin/all.js
    //= require admin/spree_i18n

    app/assets/javascripts/store/all.js
    //= require store/spree_i18n

    app/assets/stylesheets/admin/all.css
    *= require admin/spree_i18n

## Model Translations

We've added support for translating models. The feature uses the [globalize3](https://github.com/svenfuchs/globalize3)
gem to localize model data. So far the following models are translatable:

  Product, Promotion, OptionType, Taxonomy, Taxon and Property.

Start you server and you should see a TRANSLATIONS link or a flag icon on each
admin section that supports this feature.

The extension contains two configs that allow users to customize which locales
should be displayed as options on the translation forms and which should be
listed to customers on the frontend. You can set them on an initializer. e.g.

    SpreeI18n::Config.available_locales = [:en, :es, :'pt-BR'] # displayed on translation forms
    SpreeI18n::Config.supported_locales = [:en, :'pt-BR'] # displayed on frontend select box

ps. please use symbols, not strings. e.g. :'pt-BR' not just 'pt-BR'. Otherwise
you may get unexpected errors

Or if you prefer they're also available on the admin UI general settings section.

*Every record needs to have a translation. If by any chance you remove spree_i18n
from your Gemfile, add some records and then add spree_i18n gem back you might get
errors like ``undefined method for nilClass`` because Globalize will try fetch
translations that do not exist.*

## Running the tests

If you would like to run the tests of this project, follow these steps:

1. Clone this repo using `git clone git://github.com/spree/spree_i18n`
2. Change into the directory and run `bundle exec rake test_app` to generate a dummy application.
3. Run `bundle exec rspec spec` to run the tests.

# spree_i18n

A ruby translation project managed on [Locale](http://www.localeapp.com/) that's open to all!

## Contributing to spree_i18n

- Edit the translations directly on the [spree_i18n](http://www.localeapp.com/projects/public?search=spree_i18n) project on Locale.
- **That's it!**
- The maintainer will then pull translations from the Locale project and push to Github.

Happy translating!

## Support Team

First, make sure you have created the temporary directory used by the localeapp gem during pushes, etc.

```
mkdir -p .localeapp/locales
```

Next, if you're one of the community members with the necessary credentials to update the default locale file on localeapp.com then you can do so with the following command.

```
localeapp --api-key=YOURAPIKEYHERE push ../spree/core/config/locales/en.yml
```
