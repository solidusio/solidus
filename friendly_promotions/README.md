# Solidus Friendly Promotions

[![CircleCI](https://circleci.com/gh/friendlycart/solidus_friendly_promotions.svg?style=shield)](https://circleci.com/gh/friendlycart/solidus_friendly_promotions)

This extension replaces Solidus core's promotion system. It is intended as both a research project and a working alternative to how promotions work in core.

The basic architecture is very similar to the one in core Solidus, but with a few decisive tweaks, which I'll explain in the coming sections.

## Architecture

This extension centralizes promotion handling in the order updater. A service class, the `SolidusFriendlyPromotions::FriendlyPromotionAdjuster` applies the current promotion configuration to the order, adjusting or removing adjustments as necessary.

`SolidusFriendlyPromotions::Promotion` objects have benefits, and benefits have conditions. For example, a promotion that is "20% off shirts" would have a benefit of type "AdjustLineItem", and that benefit would have a condition of type "LineItemTaxon" that makes sure only line items with the "shirts" taxon will get the benefit.

### Promotion lanes

Promotions get applied by "lane". Promotions within a lane conflict with each other, whereas promotions that do not share a lane will apply sequentially in the order of the lanes. By default these are "pre", "default" and "post", but you can configure this using the SolidusFriendlyPromotions initializer:

```rb
SolidusFriendlyPromotions.configure do |config|
  config.preferred_lanes = {
    pre: 0,
    default: 1,
    grogu: 2,
    post: 3
  }
end
```

### Benefits

Solidus Friendly Promotions ships with only three benefit types by default that should cover most use cases: `AdjustLineItem`, `AdjustShipment` and `CreateDiscountedItem`. There is no benefit that creates order-level adjustments, as this feature of Solidus' legacy promotions system has proven to be very difficult for customer service and finance departments due to the difficulty of accruing order-level adjustments to individual line items when e.g. processing returns. In order to give a fixed discount to all line items in an order, use the `AdjustLineItem` benefit with the `DistributedAmount` calculator.

Alle benefits are calculable. By setting their `calculator` to one of the classes provided, a great range of discounts is possible.

#### `AdjustLineItem`

Benefits of this class will create promotion adjustments on line items. By default, they will create a discount on every line item in the order. If you want to restrict which line items get the discount, add line-item level conditions, such as `LineItemProduct`.

#### `AdjustShipment`

Benefits of this class will create promotion adjustments on shipments. By default, they will create a discount on every shipment in the order. If you want to restrict which shipments get a discount, add shipment-level conditions, such as `ShippingMethod`.

### Conditions

Every type of benefit has a list of rules that can be applied to them. When calculating adjustments for an order, benefits will only produce adjustments on line items or shipments if all their respective conditions are true.

### Connecting promotions to orders

When there is a join record `SolidusFriendlyPromotions::OrderPromotion`, the promotion and the order will be "connected", and the promotion will be applied even if it does not `apply_automatically` (see below). This is different from Solidus' legacy promotion system here in that promotions are not automatically connected to orders when they produce an adjustment.

If you want to create an `OrderPromotion` record, the usual way to do this is via a promotion handler:

- `SolidusFriendlyPromotions::PromotionHandler::Coupon`: Connects orders to promotions if a customer or service agent enters a matching promotion code.
- `SolidusFriendlyPromotions::PromotionHandler::Page`: Connects orders to promotions if a customer visits a page with the correct path. This handler is not integrated in core Solidus, and must be integrated by you.
- `SolidusFriendlyPromotions::PromotionHandler::Page`: Connects orders to promotions if a customer visits a page with the correct path. This handler is not integrated in core Solidus, and must be integrated by you.

### Promotion categories

Promotion categories simply allow admins to group promotions. They have no further significance with regards to the functionality of the promotion system.

### Promotion recalculation

Solidus allows changing orders up until when they are shipped. SolidusFriendlyPromotions therefore will recalculate orders up until when they are shipped as well. If your admins change promotions rather than add new ones and carefully manage the start and end dates of promotions, you might want to disable this feature:

```rb
SolidusFriendlyPromotions.configure do |config|
  config.recalculate_complete_orders = false
end
```

## Installation

Add solidus_friendly_promotions to your Gemfile:

```ruby
gem 'solidus_friendly_promotions'
```

Once this project is out of the research phase, a proper gem release will follow.

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_friendly_promotions:install
```

This will create the tables for this extension. It will also replace the promotion administration system under
`/admin/promotions` with a new one that needs `turbo-rails`. It will also create an initializer within which Solidus is configured to use `Spree::SimpleOrderContents` and this extension's `FriendlyPromotionAdjuster` classes. Feel free to override with your own implementations!

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
