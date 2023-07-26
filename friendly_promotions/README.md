# Solidus Friendly Promotions

[![CircleCI](https://circleci.com/gh/friendlycart/solidus_friendly_promotions.svg?style=shield)](https://circleci.com/gh/friendlycart/solidus_friendly_promotions)

This extension replaces Solidus core's promotion system. It is intended as both a research project and a working alternative to how promotions work in core.

The basic architecture is very similar to the one in core Solidus, but with a few decisive tweaks, which I'll explain in the coming sections.

## Architecture

This extension centralizes promotion handling in the order updater. A service class, the `SolidusFriendlyPromotions::OrderDiscounter` applies the current promotion configuration to the order, adjusting or removing adjustments as necessary.

In Solidus Core, Promotion adjustments get recalculated twice on every change to the cart; once in `Spree::OrderContents#after_add_or_remove` and in `Spree::OrderUpdater#update_promotions`. To make things more complicated, `Spree::OrderContents` leverages the `Spree::PromotionHandler#cart`, while the order updater goes through `Spree::Adjustment#recalculate`.

The design decision here is to make the code path easier to follow, and consequently to make it more performant ("Make it easy, then make it fast").

`SolidusFriendlyShipping::Promotion` objects have rules and actions, just like `Spree::Promotion`. However, both rules and actions work slightly differently.

### Promotion Rules

Promotion rules can be applicable to either `Spree::Order`, `Spree::LineItem`, or `Spree::Shipment` objects. If they are applicable, they will be asked for eligibility. Rules applicable to orders are processed first. If a promotion has a rule that makes it ineligible for an order, line items and shipments will not be adjusted. If there are no rules that are applicable, the promotion will be considered eligible.

### Promotion Actions

There are only two actions by default that should cover most use cases: `AdjustLineItem` and `AdjustShipment`. Ther is no action that creates order-level adjustments, as this feature of core Solidus has proven to be very difficult for customer service and finance departments due to the difficulty of accruing order-level adjustments to individual line items when e.g. processing returns. In order to give a fixed discount to all line items in an order, use the `AdjustLineItem` action with the `DistributedAmount` calculator.

Both actions are calculable. By setting their `calculator` to one of the classes provided, a great range of discount possibilities is maintained.

### Connecting promotions to orders

When there is a join record `SolidusFriendlyPromotions::OrderPromotion`, the promotion and the order will be "connected", and the promotion will be applied even if it does not `apply_automatically` (see below). There's a difference to Solidus' system here in that promotions are not automatically connected to orders when they apply.

One way of connecting orders to promotions is via a promotion code.

### Promotion categories

Promotion categories simply allow admins to group promotion actions. They have no further significance with regards to the functionality of the promotion system. This is the same behavior as in core.


## Installation

Add solidus_friendly_promotions to your Gemfile:

```ruby
gem 'solidus_friendly_promotions', github: 'friendlycart/solidus_friendly_promotion', branch: 'main'
```

Once this project is out of the research phase, a proper gem release will follow.

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_friendly_promotions:install
```

This will create the tables for this extension. It will also replace the promotion administration system under
`/admin/promotions` with a new one that needs `turbo-rails`.

It will also create an initializer within which Solidus is configured to use this extension's `SimpleOrderContents` and `OrderPromotionAdjuster` classes. Feel free to override with your own implementations!

## Usage

Add a promotion using the admin. Add rules and actions, and observe promotions getting applied how you'd expect them to.

In the admin screen, you can set a number of attributes on your promotion:
- Name: The name of the promotion. The `name` attribute will also be used to generate adjustment labels. In multi-lingual stores, you probably want different promotions per language for this reason.

- Description: This is purely informative. Some stores use `description` in order display information about this promotion to customers, but there is nothing in core Solidus that does it.

- Start and End: Outside of the time range between `starts_at` and `expires_at`, the promotion will not be eligible to any order.

- Usage Limit: `usage_limit` controls to how many orders this promotion can be applied, independent of promotion code or user. This is most commonly used to limit the risk of losing too much revenue with a particular promotion.

- Path: `path` is a URL path that connects the promotion to the order upon visitation. Not currently implemented in either Solidus core or this extension.

- Per Code Usage Limit: How often each code can be used. Useful for limiting how many orders can be placed with a single promotion code.

- Apply Automatically: Whether this promotion should apply automatically. This means that the promotion is checked for eligibility every time the customer's order is recalculated. Promotion Codes and automatic applications are incompatible.

- Promotion Category: Used to group promotions in the admin view.

## Development

### Testing the extension

First bundle your dependencies, then run `bin/rake`. `bin/rake` will default to building the dummy
app if it does not exist, then it will run specs. The dummy app can be regenerated by using
`bin/rake extension:test_app`.

```shell
bin/rake
```

To run [Rubocop](https://github.com/bbatsov/rubocop) static code analysis run

```shell
bundle exec rubocop
```

When testing your application's integration with this extension you may use its factories.
You can load Solidus core factories along with this extension's factories using this statement:

```ruby
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusFriendlyPromotions::Engine)
```

### Running the sandbox

To run this extension in a sandboxed Solidus application, you can run `bin/sandbox`. The path for
the sandbox app is `./sandbox` and `bin/rails` will forward any Rails commands to
`sandbox/bin/rails`.

Here's an example:

```
$ bin/rails server
=> Booting Puma
=> Rails 6.0.2.1 application starting in development
* Listening on tcp://127.0.0.1:3000
Use Ctrl-C to stop
```

### Releasing new versions

Please refer to the [dedicated page](https://github.com/solidusio/solidus/wiki/How-to-release-extensions) in the Solidus wiki.

## License

Copyright (c) 2023 Martin Meyerhoff, released under the New BSD License.
