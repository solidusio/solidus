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

## Installing extensions

The Solidus ecosystem is rich in extensions that modify Solidus' behaviour. The extensions are distributed as Gems, so it's often as easy as adding the extension to your Gemfile and running an install generator. Sometimes, however, the extension needs more work, such as adding custom configuration in its own initializer. Please refer to the individual extension's README file.

We maintain an [extensions compatibility matrix](http://extensions.solidus.io/). This is a good starting point for finding out which extensions are available and whether they work with your chosen Solidus version.
