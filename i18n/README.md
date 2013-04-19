#Spree Internationalization

This is the Internationalization project for [Spree Commerce](http://spreecommerce.com/)

See the [official Internationalization documentation](http://guides.spreecommerce.com/i18n.html) for more details.

To install, simply add the Gem to your Gemfile:

1. Add the following to your Gemfile
<pre>
  gem 'spree_i18n', :git => 'git://github.com/spree/spree_i18n.git'
</pre>

2. Run `bundle install`

## Model Translations

We've added support for translating models. The feature uses the globalize3 gem.
So far the following models can have translations: Product, Promotion, OptionType, Taxonomy and Taxon.

Follow the steps to get it working.

Point to the translate-models branch:

    gem 'spree_i18n', :git => 'git://github.com/spree/spree_i18n.git', :branch => 'translate-models'

Install and run the migration to create the translations tables:

    bundle exec rake railties:install:migrations
    bundle exec rake db:migrate

Add this line to app/assets/javascript/admin/all.js on your app:

    //= require admin/spree_i18n

Add this line to app/assets/javascript/store/all.js on your app:

    //= require store/spree_i18n

You should see a TRANSLATIONS link or a flag icon on each admin section that
supports this feature.

The extension contains two configs that allow users to customize which locales
should be displayed as options on the translation forms and which should be
listed to customers on the frontend. e.g. (add to an initializer):

    # displayed on translation forms
    SpreeI18n::Config.available_locales = ["en", "es", "pt-BR"]
    # displayed on frontend select box
    SpreeI18n::Config.supported_locales = ["en", "pt-BR"]

## Running the tests 

If you would like to run the tests of this project, follow these steps:

1. Clone this repo using `git clone git://github.com/spree/spree_i18n`
2. Change into the directory and run `bundle exec rake test_app` to generate a dummy application.
3. Run `bundle exec rspec spec` to run the tests.
