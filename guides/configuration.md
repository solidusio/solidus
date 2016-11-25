# Configuration

When you first setup a Rails app with Solidus installed, you will want to customize its looks and behaviour to fit your company's needs. Solidus can be customized in six ways:

* [Configuration options](#configuration-options)
* [Overriding templates](#overriding-templates)
* [Changing assets](#changing-assets)
* [Installing extensions](#installing-extensions)
* [Custom service classes](#custom-service-classes)
* [Monkey-Patching Solidus](#monkey-patching-solidus)
* [Run a private fork](#run-a-private-fork)

You will most probably use at least methods 1-4, and most shops we know also use some combination of the last three.

As Solidus is an Engine, much of what the [Rails Guide on  Engines](http://guides.rubyonrails.org/engines.html) explains applies directly to Solidus.

## Configuration options

Since Solidus is a [Rails Engine](http://guides.rubyonrails.org/engines.html), much of its behaviour can be customized through the Solidus initializer. After you have run the `rails g spree:install` generator, this initializer will live in `config/initializers/spree.rb`. Open this file, and have a look at the first block (comments left out):

***
Solidus is a fork of the Spree Project. For reasons of backwards compatibility we are keeping the Spree namespace and some of the file names (just in case you wondered why the initializer is called `spree.rb` instead of `solidus.rb`).
***

```ruby
Spree.config do |config|
  config.use_static_preferences!

  config.currency = "USD"
  config.mails_from = "store@example.com"
end
```

This block instantiates the main configuration object for the Solidus engine. Here, you can change Solidus' behaviour to accomodate many common use cases, like using another default currency or another sender e-mail address.

If your desired change in behaviour can be accomplished with one of the configuration options available here (see the full list in [our YARD docs for the `Spree::AppConfiguration` class](http://docs.solidus.io/Spree/AppConfiguration.html), you should do this. These are tested options that allow you to implement complex behaviour with little effort and well-tested code.

## Overriding templates

If you want to change something about HTML structure of Solidus' frontend (the the customer-facing part) or the admin backend, you have two choices: Either overriding the template in question, or using the Deface Gem.  

"Overriding the template" means copying the views from Solidus' frontend or backend gem and adding them to your host app in the exact same location.

For example, if you want to change the way the product list is rendered, take the raw version of [that template](../frontend/app/views/spree/products/index.html.erb) and copy it to `app/views/spree/products/index.html.erb`. It is very important that the path and name of this file are exactly the same as in the Gem! Template files from your app will always win over template files from an imported engine.

Of course, it the template you wish to modify references other template files, you can override those, too. For example, the product list references a shared partial `app/views/spree/shared/_products.html.erb` - you can find it [here](../frontend/app/views/spree/shared/_products.html.erb) and also override it in your host app.

When you override a view from a Gem, there is the possibility of difficulties when upgrading, because Controller code within the Gem might have changed, such as for example the name of an instance variable. Be careful when upgrading, and always read `CHANGELOG.md`.

If you want to avoid upgrade difficulties, or just need a tiny change to get the feature you need, you can use the `Deface` gem. Find it [here](https://github.com/spree/deface). Deface changes your templates in-place dynamically. When using Deface extensively, it can be tricky to find out where a particular piece of HTML actually comes from.

## Changing assets

If you need to change the look and feel of your app without changing the HTML structure, you can customize the CSS, image and JavaScript assets by amending the files in `vendor/assets/*/*/all.js`. They mirror the structure of the `app/assets` folder. Have a look at the [Asset Overriding Guide](assets.md) for overriding assets.

## Installing extensions

The Solidus ecosystem is rich in extensions that modify Solidus' behaviour. The extensions are distributed as Gems, so it's often as easy as adding the extension to your Gemfile and running an install generator. Sometimes, however, the extension needs more work, such as adding custom configuration in its own initializer. Please refer to the individual extension's README file.

We maintain an [extensions compatibility matrix](http://extensions.solidus.io/). This is a good starting point for finding out which extensions are available and whether they work with your chosen Solidus version.

## Custom service classes

The Solidus configuration object from above has some getters and setters for classes as extension points. After evaluating whether you need to go down this route, take some time to study the standard implementation for the class you want to modify, and subclass or re-implement it. The service class extension points can be found [here](../core/app/models/spree/app_configuration.rb#L277-L383).

For example, you might want the Product index page to behave differently than by default. The [default search class](../core/lib/spree/core/search/base.rb) defines a private `#get_base_scope` method which we can override in a class that inherits from that default search class.

Build your own searcher in `lib/mystore/product_search.rb`:

```ruby
module MyStore
  class ProductSearch < Spree::Core::Search::Base
    private
    def get_base_scope
      super.where("name LIKE '%rails%'")
    end
  end
end
```

What this new searcher does is restricting the search results to only show products with the string "rails" in their name. Neat!

In order to integrate this searcher in your app, add the following to your Solidus initializer in `config/initializers/spree.rb`:

```ruby
require 'my_store/product_search'

Spree.config do |config|
  config.use_static_preferences!

  # code ommitted here

  config.searcher_class = MyStore::ProductSearch
end
```

Your search will now only return products that contain "rails" in their name.

This pattern is our preferred pattern for generating extension points. If you see yourself overriding a class with a definable interface, and there is no such extension point, we're very happy to accept a Pull Request implementing that changeable class.

## Monkey-Patching Solidus

Solidus is setup so that any file in the `app` directory with the suffix `_decorator.rb` will be auto-loaded like any model or controller files.

For example, if you want to add a method to the `Spree::Order` model, you would have a file called `app/models/mystore/order_decorator.rb` with the following contents:

```ruby
module MyStore
  module OrderDecorator
    def total
      super + BigDecimal.new(10.0)
    end
  end
end
```

In order to override the `total` method on `Spree::Order`, add the following to the file `app/models/spree/order_decorator.rb`:

```ruby
Spree::Order.prepend MyStore::OrderDecorator
```

This creates a new module called `MyStore::OrderDecorator` and will insert its methods so early in the method lookup chain for method calls on `Spree::Order` objects that the decorator's methods override the original methods.

From now on, every order, when asked for its total, will return the an inflated total by 10 Dollars (or whatever your currency is).

If you do this kind of thing, be very careful and test your new functionality very well. If you do upgrades, read extra carefully about changes in Solidus' core classes.

## Run a private fork

If it turns out that some functionality of Solidus is deeply embedded in core, and you need to make interrelated changes to more than one model in order to achieve your goals, it might be time to create a private fork of the solidus repository and implement your feature in that private fork. This has the advantage that you can run Solidus' test suite along with your new feature and make sure it does not break Solidus' existing functionality.

You can reference a private fork in your Gemfile this way:

```ruby
gem 'solidus', git: 'https://github.com/my_account/solidus.git', branch: "my-new-feature"
```

If you think your feature (or fix) if of interest to the wider Solidus community, please do us the favour of improving the Solidus framework by [submitting a Pull Request](../CONTRIBUTING.md).
