# Spree Internationalization

[![Build Status](https://travis-ci.org/spree/spree_i18n.png?branch=master)](https://travis-ci.org/spree/spree_i18n)
[![Code Climate](https://codeclimate.com/github/spree/spree_i18n.png)](https://codeclimate.com/github/spree/spree_i18n)

This is the Internationalization project for [Spree Commerce][1]

See the [official Internationalization documentation][2] for more details.

Happy translating!

## Installation

Add the following to your `Gemfile`:

```ruby
gem 'spree_i18n', github: 'spree/spree_i18n', branch: 'master'
```

Run `bundle install`

You can use the generator to install migrations and append spree_i18n assets to
your app spree manifest file.

    rails g spree_i18n:install

This will insert these lines into your spree manifest files:

    vendor/assets/javascripts/spree/backend/all.js
    //= spree/backend/spree_i18n

    vvendor/assets/javascripts/spree/frontend/all.js
    //= spree/frontend/spree_i18n

    vendor/assets/stylesheets/spree/frontend/all.css
    *= require spree/frontend/spree_i18n

## Model Translations

We've added support for translating models. The feature uses the [Globalize][3]
gem to localize model data. So far the following models are translatable:

    Product, Promotion, OptionType, Taxonomy, Taxon and Property.

Start you server and you should see a TRANSLATIONS link or a flag icon on each
admin section that supports this feature.

The extension contains two configs that allow users to customize which locales
should be displayed as options on the translation forms and which should be
listed to customers on the frontend. You can set them on an initializer. e.g.

```ruby
SpreeI18n::Config.available_locales = [:en, :es, :'pt-BR'] # displayed on translation forms
SpreeI18n::Config.supported_locales = [:en, :'pt-BR'] # displayed on frontend select box
```

ps. please use symbols, not strings. e.g. `:'pt-BR'` not just `'pt-BR'`. Otherwise
you may get unexpected errors

Or if you prefer they're also available on the admin UI general settings section.

*Every record needs to have a translation. If by any chance you remove spree_i18n
from your Gemfile, add some records and then add spree_i18n gem back you might get
errors like ``undefined method for nilClass`` because Globalize will try fetch
translations that do not exist.*

## Contributing

In the spirit of [free software][7], **everyone** is encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using prerelease versions
* by reporting [bugs][8]
* by suggesting new features
* by writing [translations][9]
* by writing or editing documentation
* by writing specifications
* by writing code (*no patch is too small*: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by resolving [issues][8]
* by reviewing patches

Starting point:

* Fork the repo
* Clone your repo
* Run `bundle install`
* Run `bundle exec rake test_app` to create the test application in `spec/test_app`
* Make your changes
* Ensure specs pass by running `bundle exec rspec spec`
* Submit your pull request

Copyright (c) 2014 [Spree Commerce Inc][3]. and other [contributors][5]. released under the [New BSD License][6]

[1]: http://spreecommerce.com
[2]: http://guides.spreecommerce.com/i18n.html
[3]: https://github.com/globalize/globalize
[4]: https://github.com/spree
[5]: https://github.com/spree/spree_i18n/graphs/contributors
[6]: https://github.com/spree/spree_i18n/blob/master/LICENSE.md
[7]: http://www.fsf.org/licensing/essays/free-sw.html
[8]: https://github.com/spree/spree_i18n/issues
[9]: http://www.localeapp.com/projects/4605
