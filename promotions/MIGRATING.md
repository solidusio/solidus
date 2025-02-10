# Migrating from `solidus_legacy_promotions` to `solidus_promotions`

The system is designed to completely replace the legacy promotion system. This guide shows you how
to run both systems side-by-side, migrate your store's configuration to the `solidus_promotions`, and
finally remove the dependency on `solidus_legacy_promotions`.

Follow these steps to migrate your store to the gem:

## Install solidus_promotions

Add the following line to your `Gemfile`:

```rb
gem "solidus_promotions"
```

Then run

```sh
bundle install
bundle exec rails generate solidus_promotions:install
```

This will install the extension. It will add new tables, and new routes. It will also change your initializer in `config/initializers/spree.rb`.

For the time being, leave the following lines commented out:

```rb
# Make sure we use Spree::SimpleOrderContents
# Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
# Set the promotion configuration to ours
# Spree::Config.promotions = SolidusPromotions.configuration
```

This makes sure that the behavior of the current promotion system does not change - yet.

## Migrate existing promotions

Now, run the promotion migrator:

```sh
bundle exec rails solidus_promotions:migrate_existing_promotions
```

This will create equivalents of the legacy promotion configuration in SolidusPromotions.

Now, change `config/initializers/spree.rb` to use your new promotion configuration:

## Change store behavior to use SolidusPromotions

```rb
# Make sure we use Spree::SimpleOrderContents
Spree::Config.order_contents_class = "Spree::SimpleOrderContents"
# Set the promotion configuration to ours
Spree::Config.promotions = SolidusPromotions.configuration

# Sync legacy order promotions with the new promotion system
SolidusPromotions.config.sync_order_promotions = true
```

From a user's perspective, your promotions should work as before.

Before you create new promotions, migrate the adjustments and order promotions in your database:

```rb
bundle exec rails solidus_promotions:migrate_adjustments:up
bundle exec rails solidus_promotions:migrate_order_promotions:up

```

Check your `spree_adjustments` table for correctness. If things went wrong, you should be able to roll back with

```rb
bundle exec rails solidus_promotions:migrate_adjustments:down
bundle exec rails solidus_promotions:migrate_order_promotions:down
```

Both of these tasks only work if every promotion rule and promotion action have an equivalent condition or benefit in SolidusFrienndlyPromotions. Benefits are connected to their originals promotion action using the `SolidusPromotions#original_promotion_action_id`, Promotions are connected to their originals using the  `SolidusPromotions#original_promotion_id`.

Once these tasks have run and everything works, you can stop syncing legacy order promotions and new order promotions:

```rb
SolidusPromotions.config.sync_order_promotions = false
```

## Solidus Starter Frontend (and other custom frontends)

Stores that have a custom coupon codes controller, such as Solidus' starter frontend, have to change the coupon promotion handler to the one from this gem. Cange any reference to `Spree::PromotionHandler::Coupon` to `Spree::Config.promotions.coupon_code_handler_class`.

## Migrating custom rules and actions

If you have custom promotion rules or actions, you need to create new conditions and benefits, respectively.

> [!IMPORTANT]
> SolidusPromotions only supports actions that discount line items and shipments, as well as creating discounted line items. If you have actions that create order-level adjustments, we have no support for that.

In our experience, using the three actions can do almost all the things necessary, since they are customizable using calculators.

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
class MyCondition < SolidusPromotions::Condition
  include LineItemLevelCondition

  def eligible?(promotable)
    promotable.quantity > 3
  end
end
```

Now, create your own Promotion conversion map:

```rb
require 'solidus_promotions/promotion_map'

MY_PROMOTION_MAP = SolidusPromotions::PROMOTION_MAP.deep_merge(
  rules: {
    MyRule => MyCondition
  }
)
```

The value of the conversion map can also be a callable that takes the original promotion rule and should return a new condition.

```rb
require 'solidus_promotions/promotion_map'

MY_PROMOTION_MAP = SolidusPromotions::PROMOTION_MAP.deep_merge(
  rules: {
    MyRule => ->(old_promotion_rule) {
      MyCondition.new(preferred_quantity: old_promotion_rule.preferred_count)
    }
  }
)
```

You can now run our migrator with your map:

```rb
require 'solidus_promotions/promotion_migrator'
require 'my_promotion_map'

SolidusPromotions::PromotionMigrator.new(MY_PROMOTION_MAP).call
```

## Removing `solidus_legacy_promotions`

Once your store runs on `solidus_promotions`, you can now drop the dependency on `solidus_legacy_promotions`.
In order to do so, first make sure you have no ineligible promotion adjustments left in your database:

```rb
>> Spree::Adjustment.where(eligible: false)
=> 0
>>
```

If you still have ineligible adjustments in your database, run the following command:

```sh
bundle exec rails solidus_legacy_promotions:delete_ineligible_adjustments
```

Now you can safely remove `solidus_legacy_promotions` from your `Gemfile`. If your store depends on the whole `solidus` suite,
replace that dependency declaration in the `Gemfile` with the individual gems:

```diff
# Gemfile
- gem 'solidus', '~> 4,4'
+ gem 'solidus_core', '~> 4.4'
+ gem 'solidus_api', '~> 4.4'
+ gem 'solidus_backend', '~> 4.4'
+ gem 'solidus_admin', '~> 4.4'
+ gem 'solidus_promotions', '~> 4.4'
```
