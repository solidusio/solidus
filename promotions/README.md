# Solidus Promotions

This gem contains Solidus' recommended promotion system. It is slated to replace the promotion system in the `legacy_promotions` gem.

The basic architecture is very similar to the legacy promotion system, but with a few decisive tweaks, which are explained in the subsequent sections.

> [!IMPORTANT]  
> If you are upgrading from a previous version of Solidus, it is advised that you update also the promotion system to the new gem. Please consult the [Migration Guide](./MIGRATING.md).
> While the current version of Solidus still installs the legacy promotion system, we advise a migration at the earliest convinience to avoid having to rush the migration in the future. 


## Architecture

This extension centralizes promotion handling in the order updater significantly improving the performance of cart calculations. A service class, the `SolidusPromotions::OrderAdjuster` applies the current promotion configuration to the order, adjusting or removing adjustments as necessary.

`SolidusPromotions::Promotion` objects have benefits, and benefits have conditions. For example, a promotion that is "20% off shirts" would have a benefit of type "AdjustLineItem", and that benefit would have a condition of type "LineItemTaxon" that makes sure only line items with the "shirts" taxon will get the benefit.

### Promotion lanes

Promotions get applied by "lane". Promotions within a lane conflict with each other, whereas promotions that do not share a lane will apply sequentially in the order of the lanes. By default these are "pre", "default" and "post", but they can be configured using the SolidusPromotions initializer:

```rb
SolidusPromotions.configure do |config|
  config.preferred_lanes = {
    pre: 0,
    default: 1,
    grogu: 2,
    post: 3
  }
end
```

### Types of Benefits

The new Solidus Promotions Systems ships with three benefit types: `AdjustLineItem`, `AdjustShipment` and `CreateDiscountedItem`. To allow more efficient processing of returns and reduce the complexity for bookkeping and support departments fixed discount to all line items in an order can now be given through the `AdjustLineItem` benefit through the `DistributedAmount` calculator significantly reducing administration issues with refunds. 

#### `AdjustLineItem`

Benefits of this class will create promotion adjustments on line items. By default, they will create a discount on every line item in the order. If you want to restrict which line items get the discount, add line-item level conditions, such as `LineItemProduct`.

#### `AdjustShipment`

Benefits of this class will create promotion adjustments on shipments. By default, they will create a discount on every shipment in the order. If you want to restrict which shipments get a discount, add shipment-level conditions, such as `ShippingMethod`.

### Conditions

Every type of benefit has a list of rules that can be applied to them. When calculating adjustments for an order, benefits will only produce adjustments on line items or shipments if all their respective conditions are true.

### Connecting promotions to orders

When there is a join record `SolidusPromotions::OrderPromotion`, the promotion and the order will be "connected", and the promotion will be applied even if it does not `apply_automatically` (see below). This is different from Solidus' legacy promotion system here in that promotions are not automatically connected to orders when they produce an adjustment.

If you want to create an `OrderPromotion` record, the usual way to do this is via a promotion handler:

- `SolidusPromotions::PromotionHandler::Coupon`: Connects orders to promotions if a customer or service agent enters a matching promotion code.
- `SolidusPromotions::PromotionHandler::Page`: Connects orders to promotions if a customer visits a page with the correct path. This handler is not integrated in core Solidus, and must be integrated by you.
- `SolidusPromotions::PromotionHandler::Page`: Connects orders to promotions if a customer visits a page with the correct path. This handler is not integrated in core Solidus, and must be integrated by you.

### Promotion categories

Promotion categories simply allow admins to group promotions. They have no further significance with regards to the functionality of the promotion system.

### Promotion recalculation

Solidus allows changing orders up until when they are shipped. SolidusPromotions therefore will recalculate orders up until when they are shipped as well. If your admins change promotions rather than add new ones and carefully manage the start and end dates of promotions, you might want to disable this feature:

```rb
SolidusPromotions.configure do |config|
  config.recalculate_complete_orders = false
end
```

### Coupon Code Normalization

Solidus Promotions provides a configurable coupon code normalizer that controls how coupon codes are processed before saving and lookup. By default, codes are case-insensitive (e.g., "SAVE20" and "save20" are treated as the same). 
You can customize this behavior to support case-sensitive codes, remove special characters, apply formatting rules, or implement other normalization strategies based on your business requirements.

See the `coupon_code_normalizer_class` configuration option for implementation details.

## Installation

Add solidus_promotions to your Gemfile:

```ruby
gem 'solidus_promotions'
```

Once this project is out of the research phase, a proper gem release will follow.

Bundle your dependencies and run the installation generator:

```shell
bin/rails generate solidus_promotions:install
```

This will create the tables for this extension. It will also replace the promotion administration system under
`/admin/promotions` with a new one that needs `turbo-rails`. It will also create an initializer within which Solidus is configured to use `Spree::SimpleOrderContents` and this extension's `OrderAdjuster` classes. Feel free to override with your own implementations!

## Usage

Add a promotion using the admin. Add benefits with conditions, and observe promotions getting applied how you'd expect them to.

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

When testing your application's integration with this extension you may use its factories.
You can load Solidus core factories along with this extension's factories using this statement:

```ruby
SolidusDevSupport::TestingSupport::Factories.load_for(SolidusPromotions::Engine)
```


## License

Copyright (c) 2024 Martin Meyerhoff, Solidus Team, released under the [license of the parent repository](https://github.com/solidusio/solidus/blob/main/LICENSE.md).
