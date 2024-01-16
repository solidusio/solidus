# Changelog

## [Unreleased](https://github.com/FriendlyCart/solidus_friendly_promotions/tree/HEAD)

## [v1.0.0.rc.2](https://github.com/FriendlyCart/solidus_friendly_promotions/tree/v1.0.0.rc.3) (2024-01-16)

**Merged pull requests:**

- Add configuration option: `recalculate_complete_orders` [\#97](https://github.com/friendlycart/solidus_friendly_promotions/pull/97) ([mamhoff](https://github.com/mamhoff))
- Fix standardrb violations [\#96](https://github.com/friendlycart/solidus_friendly_promotions/pull/96) ([mamhoff](https://github.com/mamhoff))
- Fix admin sub menu entry visibility condition [\#92](https://github.com/friendlycart/solidus_friendly_promotions/pull/92) ([mickenorlen](https://github.com/mickenorlen))
- Documentation fixes [\#91](https://github.com/friendlycart/solidus_friendly_promotions/pull/91) ([mamhoff](https://github.com/mamhoff))
- Fix typo [\#89](https://github.com/friendlycart/solidus_friendly_promotions/pull/89) ([jarednorman](https://github.com/jarednorman))
- Pass untranslated strings through i18n [\#88](https://github.com/friendlycart/solidus_friendly_promotions/pull/88) ([mamhoff](https://github.com/mamhoff))

## [v1.0.0.rc.2](https://github.com/FriendlyCart/solidus_friendly_promotions/tree/v1.0.0.rc.2) (2023-11-11)

[Full Changelog](https://github.com/FriendlyCart/solidus_friendly_promotions/compare/v1.0.0.rc.1...v1.0.0.rc.2)

**Merged pull requests:**

- Refactor: Extract `Promotion#applicable_line_items` [\#86](https://github.com/friendlycart/solidus_friendly_promotions/pull/86) ([mamhoff](https://github.com/mamhoff))
- Coupon Promo Handler: Fix flaky spec [\#84](https://github.com/friendlycart/solidus_friendly_promotions/pull/84) ([mamhoff](https://github.com/mamhoff))
- Use Remix icons if Solidus' admin\_updated\_navbar is enabled [\#83](https://github.com/friendlycart/solidus_friendly_promotions/pull/83) ([tvdeyen](https://github.com/tvdeyen))
- Tiered calculators [\#82](https://github.com/friendlycart/solidus_friendly_promotions/pull/82) ([mamhoff](https://github.com/mamhoff))
- Allow changing quantity for automatic line items [\#81](https://github.com/friendlycart/solidus_friendly_promotions/pull/81) ([mamhoff](https://github.com/mamhoff))
- Update MIGRATING.md [\#80](https://github.com/friendlycart/solidus_friendly_promotions/pull/80) ([tvdeyen](https://github.com/tvdeyen))
- Promotions index improvements [\#79](https://github.com/friendlycart/solidus_friendly_promotions/pull/79) ([mamhoff](https://github.com/mamhoff))
- Lint: Fix standardrb error [\#78](https://github.com/friendlycart/solidus_friendly_promotions/pull/78) ([mamhoff](https://github.com/mamhoff))

## [v1.0.0.rc.1](https://github.com/FriendlyCart/solidus_friendly_promotions/tree/v1.0.0.rc.1) (2023-11-07)

[Full Changelog](https://github.com/FriendlyCart/solidus_friendly_promotions/compare/v1.0.0.pre...v1.0.0.rc.1)

**Merged pull requests:**

- Goodies! [\#75](https://github.com/friendlycart/solidus_friendly_promotions/pull/75) ([mamhoff](https://github.com/mamhoff))
- Add a null promotion handler [\#71](https://github.com/friendlycart/solidus_friendly_promotions/pull/71) ([mamhoff](https://github.com/mamhoff))

## [v1.0.0.pre](https://github.com/FriendlyCart/solidus_friendly_promotions/tree/v1.0.0.pre) (2023-11-07)

[Full Changelog](https://github.com/FriendlyCart/solidus_friendly_promotions/compare/e14802957fdb55d7f4e2730341e4cbb118ebf993...v1.0.0.pre)

**Merged pull requests:**

- Use new NestedClassSet for configuring calculators [\#77](https://github.com/friendlycart/solidus_friendly_promotions/pull/77) ([mamhoff](https://github.com/mamhoff))
- Refactor to FriendlyPromotion::FriendlyPromotionAdjuster [\#76](https://github.com/friendlycart/solidus_friendly_promotions/pull/76) ([mamhoff](https://github.com/mamhoff))
- Add bundler/gem\_tasks [\#74](https://github.com/friendlycart/solidus_friendly_promotions/pull/74) ([mamhoff](https://github.com/mamhoff))
- Fix order discounter spec [\#73](https://github.com/friendlycart/solidus_friendly_promotions/pull/73) ([mamhoff](https://github.com/mamhoff))
- Quantity tiered calculator [\#72](https://github.com/friendlycart/solidus_friendly_promotions/pull/72) ([mamhoff](https://github.com/mamhoff))
- Add PromotionHandler::Page [\#70](https://github.com/friendlycart/solidus_friendly_promotions/pull/70) ([mamhoff](https://github.com/mamhoff))
- Never create adjustments with a zero amount [\#69](https://github.com/friendlycart/solidus_friendly_promotions/pull/69) ([mamhoff](https://github.com/mamhoff))
- Ignore shipping rates that have no cost [\#68](https://github.com/friendlycart/solidus_friendly_promotions/pull/68) ([davecandlescience](https://github.com/davecandlescience))
- Refactor promotions eligibility [\#67](https://github.com/friendlycart/solidus_friendly_promotions/pull/67) ([mamhoff](https://github.com/mamhoff))
- Refactor order promotions migrator [\#66](https://github.com/friendlycart/solidus_friendly_promotions/pull/66) ([mamhoff](https://github.com/mamhoff))
- Add migrate order promotions rake task [\#65](https://github.com/friendlycart/solidus_friendly_promotions/pull/65) ([davecandlescience](https://github.com/davecandlescience))
- Add missing relation: SolidusFriendlyPromotions\#order\_promotions [\#64](https://github.com/friendlycart/solidus_friendly_promotions/pull/64) ([mamhoff](https://github.com/mamhoff))
- Promo Migrator: Ignore missing rules and actions [\#63](https://github.com/friendlycart/solidus_friendly_promotions/pull/63) ([mamhoff](https://github.com/mamhoff))
- Improve spec for product rule [\#62](https://github.com/friendlycart/solidus_friendly_promotions/pull/62) ([mamhoff](https://github.com/mamhoff))
- Do not call Spree::PromotionHandler::Shipping when SFP is active [\#61](https://github.com/friendlycart/solidus_friendly_promotions/pull/61) ([mamhoff](https://github.com/mamhoff))
- Add a migration guide [\#60](https://github.com/friendlycart/solidus_friendly_promotions/pull/60) ([mamhoff](https://github.com/mamhoff))
- Add a PromotionHandler::Coupon [\#59](https://github.com/friendlycart/solidus_friendly_promotions/pull/59) ([mamhoff](https://github.com/mamhoff))
- Backports minimum quantity promotion rule from Solidus [\#58](https://github.com/friendlycart/solidus_friendly_promotions/pull/58) ([mamhoff](https://github.com/mamhoff))
- Backport promotion code batch fix from Solidus [\#57](https://github.com/friendlycart/solidus_friendly_promotions/pull/57) ([mamhoff](https://github.com/mamhoff))
- Add a rake task to migrate adjustments from legacy promotions [\#56](https://github.com/friendlycart/solidus_friendly_promotions/pull/56) ([mamhoff](https://github.com/mamhoff))
- Add missing shipping\_rate translation [\#55](https://github.com/friendlycart/solidus_friendly_promotions/pull/55) ([davecandlescience](https://github.com/davecandlescience))
- Fix shipping rate discount factory [\#54](https://github.com/friendlycart/solidus_friendly_promotions/pull/54) ([mamhoff](https://github.com/mamhoff))
- Order Discounter: Create valid shipping rate discounts [\#53](https://github.com/friendlycart/solidus_friendly_promotions/pull/53) ([mamhoff](https://github.com/mamhoff))
- FriendlyPromotionDiscounter: Always return @order [\#52](https://github.com/friendlycart/solidus_friendly_promotions/pull/52) ([mamhoff](https://github.com/mamhoff))
- Line Item Product Rule: Add error messaging [\#50](https://github.com/friendlycart/solidus_friendly_promotions/pull/50) ([mamhoff](https://github.com/mamhoff))
- Fix: SolidusFriendlyPromotions, not Shipping [\#49](https://github.com/friendlycart/solidus_friendly_promotions/pull/49) ([mamhoff](https://github.com/mamhoff))
- Import eligiblity error messages from Solidus [\#48](https://github.com/friendlycart/solidus_friendly_promotions/pull/48) ([mamhoff](https://github.com/mamhoff))
- Faster promotion code migration [\#47](https://github.com/friendlycart/solidus_friendly_promotions/pull/47) ([mamhoff](https://github.com/mamhoff))
- Migrator: Store original promotion and promotion action [\#46](https://github.com/friendlycart/solidus_friendly_promotions/pull/46) ([mamhoff](https://github.com/mamhoff))
- Lint with standardrb in CI [\#45](https://github.com/friendlycart/solidus_friendly_promotions/pull/45) ([mamhoff](https://github.com/mamhoff))
- Migrator: Migrate promotion codes and promotion code batches [\#44](https://github.com/friendlycart/solidus_friendly_promotions/pull/44) ([mamhoff](https://github.com/mamhoff))
- Migrate promotion categories and association [\#43](https://github.com/friendlycart/solidus_friendly_promotions/pull/43) ([davecandlescience](https://github.com/davecandlescience))
- On the fly order promotions [\#42](https://github.com/friendlycart/solidus_friendly_promotions/pull/42) ([mamhoff](https://github.com/mamhoff))
- Add back references to promotions and actions [\#41](https://github.com/friendlycart/solidus_friendly_promotions/pull/41) ([davecandlescience](https://github.com/davecandlescience))
- Fix spec warning in promotion rules spec [\#40](https://github.com/friendlycart/solidus_friendly_promotions/pull/40) ([mamhoff](https://github.com/mamhoff))
- Transparently replace promotion adjustments [\#39](https://github.com/friendlycart/solidus_friendly_promotions/pull/39) ([mamhoff](https://github.com/mamhoff))
- Add DB comments to tables [\#38](https://github.com/friendlycart/solidus_friendly_promotions/pull/38) ([mamhoff](https://github.com/mamhoff))
- Fix Promotion Map [\#36](https://github.com/friendlycart/solidus_friendly_promotions/pull/36) ([mamhoff](https://github.com/mamhoff))
- Fix specs [\#29](https://github.com/friendlycart/solidus_friendly_promotions/pull/29) ([mamhoff](https://github.com/mamhoff))
- Add Promotion Migrator [\#28](https://github.com/friendlycart/solidus_friendly_promotions/pull/28) ([mamhoff](https://github.com/mamhoff))
- Polyvalent rules [\#27](https://github.com/friendlycart/solidus_friendly_promotions/pull/27) ([mamhoff](https://github.com/mamhoff))
- Fix Turbo frame tags for Turbo 1.5 [\#26](https://github.com/friendlycart/solidus_friendly_promotions/pull/26) ([mamhoff](https://github.com/mamhoff))
- Allow destroying promotions [\#25](https://github.com/friendlycart/solidus_friendly_promotions/pull/25) ([mamhoff](https://github.com/mamhoff))
- Fix class name option in line item taxon association [\#24](https://github.com/friendlycart/solidus_friendly_promotions/pull/24) ([mamhoff](https://github.com/mamhoff))
- Move factories to factories folder [\#23](https://github.com/friendlycart/solidus_friendly_promotions/pull/23) ([mamhoff](https://github.com/mamhoff))
- Add links to legacy promotions in Solidus 4.1 [\#22](https://github.com/friendlycart/solidus_friendly_promotions/pull/22) ([mamhoff](https://github.com/mamhoff))
- Make lanes configurable [\#21](https://github.com/friendlycart/solidus_friendly_promotions/pull/21) ([mamhoff](https://github.com/mamhoff))
- Allow order rules per lane [\#20](https://github.com/friendlycart/solidus_friendly_promotions/pull/20) ([mamhoff](https://github.com/mamhoff))
- Add PermissionSet for Friendly Promotions [\#19](https://github.com/friendlycart/solidus_friendly_promotions/pull/19) ([mamhoff](https://github.com/mamhoff))
- Add "only" match policy to product rule [\#18](https://github.com/friendlycart/solidus_friendly_promotions/pull/18) ([mamhoff](https://github.com/mamhoff))
- Require solidus [\#17](https://github.com/friendlycart/solidus_friendly_promotions/pull/17) ([mamhoff](https://github.com/mamhoff))
- Customer label [\#16](https://github.com/friendlycart/solidus_friendly_promotions/pull/16) ([mamhoff](https://github.com/mamhoff))
- System specs with turbo [\#15](https://github.com/friendlycart/solidus_friendly_promotions/pull/15) ([mamhoff](https://github.com/mamhoff))
- Reference our own I18n namespace in views [\#14](https://github.com/friendlycart/solidus_friendly_promotions/pull/14) ([mamhoff](https://github.com/mamhoff))
- Use different path for friendly promotions [\#13](https://github.com/friendlycart/solidus_friendly_promotions/pull/13) ([mamhoff](https://github.com/mamhoff))
- Add dependent: :destroy to Spree::Order\#friendly\_promotions [\#12](https://github.com/friendlycart/solidus_friendly_promotions/pull/12) ([mamhoff](https://github.com/mamhoff))
- Extract promotion loading from promo discounter [\#11](https://github.com/friendlycart/solidus_friendly_promotions/pull/11) ([mamhoff](https://github.com/mamhoff))
- Remove delegators [\#10](https://github.com/friendlycart/solidus_friendly_promotions/pull/10) ([mamhoff](https://github.com/mamhoff))
- Fix standardrb error in promotion rule spec [\#8](https://github.com/friendlycart/solidus_friendly_promotions/pull/8) ([mamhoff](https://github.com/mamhoff))
- Stacking Promotions [\#7](https://github.com/friendlycart/solidus_friendly_promotions/pull/7) ([mamhoff](https://github.com/mamhoff))
- Add "Lane" enum to Promotion [\#6](https://github.com/friendlycart/solidus_friendly_promotions/pull/6) ([mamhoff](https://github.com/mamhoff))
- Lint using standardrb gem [\#5](https://github.com/friendlycart/solidus_friendly_promotions/pull/5) ([mamhoff](https://github.com/mamhoff))
- Promotion Actions: Implement "edit" action [\#4](https://github.com/friendlycart/solidus_friendly_promotions/pull/4) ([mamhoff](https://github.com/mamhoff))
- Initializer: Use new MenuItem API from Solidus 4.2 onwards [\#3](https://github.com/friendlycart/solidus_friendly_promotions/pull/3) ([mamhoff](https://github.com/mamhoff))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
