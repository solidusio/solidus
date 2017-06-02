# Solidus Internationalization

[![Build Status](https://travis-ci.org/solidusio-contrib/solidus_i18n.svg?branch=master)](https://travis-ci.org/solidusio-contrib/solidus_i18n)
[![Code Climate](https://codeclimate.com/github/solidusio-contrib/solidus_i18n/badges/gpa.svg)](https://codeclimate.com/github/solidusio-contrib/solidus_i18n)
[![Gem Version](https://badge.fury.io/rb/solidus_i18n.svg)](https://badge.fury.io/rb/solidus_i18n)

This is the Internationalization project for [Solidus](https://solidus.io)

---

## Supported languages

We currently support the [following locales](https://github.com/solidusio-contrib/solidus_i18n/tree/master/config/locales)
by default. If you need a locale that is not in the list you can add a custom
translation file into your application by following the
[Rails translations guide](http://guides.rubyonrails.org/i18n.html#how-to-store-your-custom-translations).

## Installation

Add the following to your `Gemfile`:

```ruby
gem 'solidus_i18n', github: 'solidusio-contrib/solidus_i18n', branch: 'master'
```

Run `bundle install`

You can use the generator to install migrations and append solidus_i18n assets to
your app solidus manifest file.

    bin/rails g solidus_i18n:install

This will insert these lines into your Spree assets manifests:

In `vendor/assets/javascripts/spree/frontend/all.js`

```
//= require spree/frontend/solidus_i18n
```

In `vendor/assets/javascripts/spree/backend/all.js`

```
//= require spree/backend/solidus_i18n
```

## Set default locale

In `config/initializers/spree.rb` you will find the default locale settings
for both frontend and backend. Just replace `'en'` with your default locale
code.

## Add more languages to the frontend locale toggle

Go to Admin -> General Settings -> Localization Setting and add the locales
you want your users to be able to select from the locale toggle on the frontend.

---

## Updating Translations

If you want to improve the translations on your language, run the tasks:

    bundle exec rake solidus_i18n:update_default
    bundle exec i18n-tasks add-missing --nil-value --locale <LOCALE>

Substitute <LOCALE> with your locale code (e.g: `it`).

This will do a cleanup and prepare `<LOCALE>.yml` with all the missing keys.
You can then write the translations and open a pull request.

---

## Model Translations

We **removed** support for translating models into [a separate Gem](https://github.com/solidusio-contrib/solidus_globalize).

Please update your `Gemfile` if you still need the model translations.

```ruby
# Gemfile
gem 'solidus_globalize', github: 'solidusio-contrib/solidus_globalize', branch: 'master'
```

---

## Upgrading

**WARNING**: If you want to keep your model translations, be sure to add the `solidus_globalize` gem to your `Gemfile` **before** migrating the database. Otherwise **you will loose your translations**!

### 1. Migrate your database

    bin/rake solidus_i18n:upgrade
    bin/rake db:migrate

*Note:* The migration automatically skips the removal of the translations tables. So it's safe to run the migration without data loss. But be sure to have the `solidus_globalize` gem in your `Gemfile`, if you want to keep them.

### 2. Remove Configuration

Remove all occurrences of `SolidusI18n::Config.supported_locales` from your code.


Contributing
------------

Solidus is an open source project and we encourage contributions. Please read
[CONTRIBUTING.md](CONTRIBUTING.md) before contributing.
