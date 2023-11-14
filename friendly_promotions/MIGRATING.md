# Migrating from Solidus' promotion system to SolidusFriendlyPromotions

The system is designed to completely replace the Solidus promotion system. Follow these steps to migrate your store to the gem:

## Install solidus_friendly_promotions

Add the following line to your `Gemfile`:

```rb
gem "solidus_friendly_promotions"
```

Then run

```sh
bundle install
bundle exec rails generate solidus_friendly_promotions:install
```

This will install the extension. It will add new tables, and new routes. It will also generate an initializer in `config/initializers/solidus_friendly_promotions.rb`.

For the time being, comment out the following lines:

```rb
# Spree::Config.order_contents_class = "SolidusFriendlyPromotions::SimpleOrderContents"
# Spree::Config.promotion_adjuster_class = "SolidusFriendlyPromotions::FriendlyPromotionAdjuster"
```

This makes sure that the behavior of the current promotion system does not change - yet.

## Migrate existing promotions

Now, run the promotion migrator:

```sh
bundle exec rails solidus_friendly_promotions:migrate_existing_promotions
```

This will create equivalents of the legacy promotion configuration in SolidusFriendlyPromotions.

Now, change `config/initializers/solidus_friendly_promotions.rb` to use your new promotion configuration:

## Change store behavior to use SolidusFriendlyPromotions

```rb
# Stops running the stock `Spree::PromotionHandler::Cart`
Spree::Config.order_contents_class = "SolidusFriendlyPromotions::SimpleOrderContents"
# Adjusts all items in an order according to the currently eligible promotions
Spree::Config.promotion_adjuster_class = "SolidusFriendlyPromotions::FriendlyPromotionAdjuster"
```

From a user's perspective, your promotions should work as before.

Before you create new promotions, migrate the adjustments and order promotions in your database:

```rb
bundle exec rails solidus_friendly_promotions:migrate_adjustments:up
bundle exec rails solidus_friendly_promotions:migrate_order_promotions:up

```

Check your `spree_adjustments` table for correctness. If things went wrong, you should be able to roll back with

```rb
bundle exec rails solidus_friendly_promotions:migrate_adjustments:down
bundle exec rails solidus_friendly_promotions:migrate_order_promotions:down
```

Both of these tasks only work if every promotion and promotion action have an equivalent in SolidusFrienndlyPromotions. Promotion Actions are connected to their originals using the `SolidusFriendlyPromotions#original_promotion_action_id`, Promotions are connected to their originals using the  `SolidusFriendlyPromotions#original_promotion_id`.

## Solidus Starter Frontend (and other custom frontends)

Stores that have a custom coupon codes controller, such as Solidus' starter frontend, have to change the coupon promotion handler to the one from this gem. If you are on a very recent Solidus version, you can change any reference to `Spree::PromotionHandler::Coupon` to `Spree::Config.coupon_code_handler_class`. If your version of Solidus does not have that method yet, replace `Spree::PromotionHandler::Coupon` with `SolidusFriendlyPromotions::PromotionHandler::Coupon`

## Migrating custom rules and actions

If you have custom promotion rules or actions, you need to create new promotion rules and actions.

> [!IMPORTANT]
> SolidusFriendlyPromotions currently only supports actions that discount line items and shipments. If you have actions that add line items, or create order-level adjustments, we currently have no support for that.

In our experience, using the two actions can do almost all the things necessary, since they are customizable using calculators.

Rules share a lot of the previous API. If you make use of `#actionable?`, you might want to migrate your rule to be a line-item level rule:

```rb
class MyRule < Spree::PromotionRule
  def actionable?(promotable)
    promotable.quantity > 3
  end
end
```

would become:

```rb
class MyNewRule < SolidusFriendlyPromotions::PromotionRule
  include LineItemLevelRule
  def eligible?(promotable)
    promotable.quantity > 3
  end
end
```

Now, create your own Promotion conversion map:

```rb
require 'solidus_friendly_promotions/promotion_map'

MY_PROMOTION_MAP = SolidusFriendlyPromotions::PROMOTION_MAP.deep_merge(
  rules: {
    MyRule => MyNewRule
  }
)
```

The value of the conversion map can also be a callable that takes the original promotion rule and should return a new promotion rule.

```rb
require 'solidus_friendly_promotions/promotion_map'

MY_PROMOTION_MAP = SolidusFriendlyPromotions::PROMOTION_MAP.deep_merge(
  rules: {
    MyRule => ->(old_promotion_rule) {
      MyNewRule.new(preferred_quantity: old_promotion_rule.preferred_count)
    }
  }
)
```

You can now run our migrator with your map:

```rb
require 'solidus_friendly_promotions/promotion_migrator'
require 'my_promotion_map'

SolidusFriendlyPromotions::PromotionMigrator.new(MY_PROMOTION_MAP).call
```
