## Solidus v4.6.1 (2025-10-21)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus Core

* [v4.6] Fix shipment adjustments not persisting on order recalculate by @github-actions[bot] in https://github.com/solidusio/solidus/pull/6336

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.6.0...v4.6.1


## Solidus v4.6.0 (2025-09-09)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus

* Fix typos by @jackhac in https://github.com/solidusio/solidus/pull/6207

## Solidus Core

* Fix typos by @jackhac in https://github.com/solidusio/solidus/pull/6207
* Display the store's currency in the Admin Order Index Component by @magpieuk in https://github.com/solidusio/solidus/pull/5929
* Respect Spree.user_class' table name in metadata migration by @tvdeyen in https://github.com/solidusio/solidus/pull/6157
* Better Spree::UserAddress scope deprecation warnings by @tvdeyen in https://github.com/solidusio/solidus/pull/6163
* Add new order events by @benjaminwil in https://github.com/solidusio/solidus/pull/6170
* [Docs] Fix Meta Data Restriction Comment to reflect default setting by @fthobe in https://github.com/solidusio/solidus/pull/6171
* Separate order mailer subscriber from reimbursement mailer subscriber by @benjaminwil in https://github.com/solidusio/solidus/pull/6156
* Fixed migrations so you can rollback them all by @aiperon in https://github.com/solidusio/solidus/pull/6188
* Inherit from ActiveRecord::Migration version for all supported Rails by @harmonymjb in https://github.com/solidusio/solidus/pull/6192
* Move OrderMailerSubscriber#send_confirmation_email by @benjaminwil in https://github.com/solidusio/solidus/pull/6199
* Add reverse charge status to stores by @fthobe in https://github.com/solidusio/solidus/pull/6136
* Fix flaky test errors using chrome 134 by @tvdeyen in https://github.com/solidusio/solidus/pull/6203
* Move carton shipped emails to subscriber by @benjaminwil in https://github.com/solidusio/solidus/pull/6219
* Change migration version to 7.0 by @AlistairNorman in https://github.com/solidusio/solidus/pull/6220
* Add subscribers for inventory cancellation and order cancellation emails by @benjaminwil in https://github.com/solidusio/solidus/pull/6205
* Make linters happy by @tvdeyen in https://github.com/solidusio/solidus/pull/6223
* Disallow migrations with the wrong versions by @benjaminwil in https://github.com/solidusio/solidus/pull/6221
* Add reverse charge fields to address by @fthobe in https://github.com/solidusio/solidus/pull/6168
* Dummy app generator: Only configure app/assets/javascripts if present by @mamhoff in https://github.com/solidusio/solidus/pull/6227
* Use Firefox for system specs by @mamhoff in https://github.com/solidusio/solidus/pull/6230
* Configurable Solidus event subscribers by @benjaminwil in https://github.com/solidusio/solidus/pull/6234
* Move Taxon -> Promotion Rule association to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/6243
* Require spree/config in spree/core by @mamhoff in https://github.com/solidusio/solidus/pull/6248
* Addressbook: Add foreign key, dependent/inverse_of options by @mamhoff in https://github.com/solidusio/solidus/pull/6265
* Replace `puts` in tasks and generators with Rails.logger or Logger.new by @mamhoff in https://github.com/solidusio/solidus/pull/6244

## Solidus Admin

* Fix typos by @jackhac in https://github.com/solidusio/solidus/pull/6207
* Display the store's currency in the Admin Order Index Component by @magpieuk in https://github.com/solidusio/solidus/pull/5929
* Fix flaky test errors using chrome 134 by @tvdeyen in https://github.com/solidusio/solidus/pull/6203
* Make linters happy by @tvdeyen in https://github.com/solidusio/solidus/pull/6223
* Add reverse charge fields to address by @fthobe in https://github.com/solidusio/solidus/pull/6168
* Use Firefox for system specs by @mamhoff in https://github.com/solidusio/solidus/pull/6230
* Fix install_lookbook step by @chaimann in https://github.com/solidusio/solidus/pull/6154
* Fix ui/forms/input component for tag: :textarea by @chaimann in https://github.com/solidusio/solidus/pull/6174
* [Admin] Fix Unclosed form_tag in table component by @swamp09 in https://github.com/solidusio/solidus/pull/6172
* Fix flaky specs by @mamhoff in https://github.com/solidusio/solidus/pull/6197
* [Backend] Fix issue refunding uncompleted payments by @jtapia in https://github.com/solidusio/solidus/pull/6094
* [Admin][UI] New select component by @chaimann in https://github.com/solidusio/solidus/pull/6190
* Refactor `ui/forms/address` component by @chaimann in https://github.com/solidusio/solidus/pull/6191
* Use semantic links to edit option types by @forkata in https://github.com/solidusio/solidus/pull/6201
* Admin select component performance by @chaimann in https://github.com/solidusio/solidus/pull/6213
* Refactor address form component (properly this time) by @chaimann in https://github.com/solidusio/solidus/pull/6225
* [Admin][UI] Alert component by @chaimann in https://github.com/solidusio/solidus/pull/6226
* [Admin] fix table sorting by @chaimann in https://github.com/solidusio/solidus/pull/6238
* Update importmap-rails to v2 by @tvdeyen in https://github.com/solidusio/solidus/pull/6202

## Solidus Backend

* Add reverse charge status to stores by @fthobe in https://github.com/solidusio/solidus/pull/6136
* Fix flaky test errors using chrome 134 by @tvdeyen in https://github.com/solidusio/solidus/pull/6203
* Add reverse charge fields to address by @fthobe in https://github.com/solidusio/solidus/pull/6168
* Fix flaky specs by @mamhoff in https://github.com/solidusio/solidus/pull/6197
* [Backend] Fix issue refunding uncompleted payments by @jtapia in https://github.com/solidusio/solidus/pull/6094
* Add 500ms delay before AJAX in Select2 by @mamhoff in https://github.com/solidusio/solidus/pull/6235

## Solidus API

* Add reverse charge status to stores by @fthobe in https://github.com/solidusio/solidus/pull/6136
* Add reverse charge fields to address by @fthobe in https://github.com/solidusio/solidus/pull/6168
* Refactor load_user_roles into current_user_roles helper by @mamhoff in https://github.com/solidusio/solidus/pull/6245
* Refactor "current_api_user" into instacached helper by @mamhoff in https://github.com/solidusio/solidus/pull/6246

## Solidus Promotions

* Fix typos by @jackhac in https://github.com/solidusio/solidus/pull/6207
* Fix flaky test errors using chrome 134 by @tvdeyen in https://github.com/solidusio/solidus/pull/6203
* Replace `puts` in tasks and generators with Rails.logger or Logger.new by @mamhoff in https://github.com/solidusio/solidus/pull/6244
* Fix flaky specs by @mamhoff in https://github.com/solidusio/solidus/pull/6197
* Update importmap-rails to v2 by @tvdeyen in https://github.com/solidusio/solidus/pull/6202
* [Promotions] Set Flickwerk patches in initializer by @tvdeyen in https://github.com/solidusio/solidus/pull/6161
* Fix Rubocop offense by @mamhoff in https://github.com/solidusio/solidus/pull/6196
* Use `human_attribute_name` for promo calculator labels by @mamhoff in https://github.com/solidusio/solidus/pull/6195
* Promotions: Add a PercentWithCap calculator by @mamhoff in https://github.com/solidusio/solidus/pull/6200

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.5.0...v4.6.0


## Solidus v4.5.0 (2025-02-19)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus

* Add not about sprockets manifest before running rails commands by @tvdeyen in https://github.com/solidusio/solidus/pull/6130

## Solidus Core

* Move Line Item Actions to solidus_legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5916
* Remove rails binstubs from built gems by @tvdeyen in https://github.com/solidusio/solidus/pull/5917
* [FIX] Remove spacing at top of OrderShipping#ship method by @adammathys in https://github.com/solidusio/solidus/pull/5954
* Test app task: Allow passing in user class by @mamhoff in https://github.com/solidusio/solidus/pull/5956
* Backend: Add missing error translation by @mamhoff in https://github.com/solidusio/solidus/pull/5979
* Add show all results to en.yml by @fthobe in https://github.com/solidusio/solidus/pull/5988
* Do not constantize Spree.user_class in UserClassHandle by @mamhoff in https://github.com/solidusio/solidus/pull/5999
* Allow to set Rails deprecations behavior during tests by @tvdeyen in https://github.com/solidusio/solidus/pull/6000
* Introducing product brand using taxon_brand_selector by @shahmayur001 in https://github.com/solidusio/solidus/pull/5989
* Make state machine modules auto-loadable by @mamhoff in https://github.com/solidusio/solidus/pull/6056
* Make Spree::Money autoloadable by @tvdeyen in https://github.com/solidusio/solidus/pull/6040
* Tax Categories on Line Items respect updates to Variant and Product Tax Categories by @harmonymjb in https://github.com/solidusio/solidus/pull/6059
* Unauthorized redirect handling config by @mamhoff in https://github.com/solidusio/solidus/pull/6051
* Lint: Fix Money spec by @mamhoff in https://github.com/solidusio/solidus/pull/6068
* Fix preferences serialization compatibility with Rails version check by @swamp09 in https://github.com/solidusio/solidus/pull/6083
* Make Controller Helpers autoloadable by @mamhoff in https://github.com/solidusio/solidus/pull/6062
* Move permission sets back to app/ by @mamhoff in https://github.com/solidusio/solidus/pull/6090
* Allows Rails 8, updates sqlite in Gemfile to match what CI runs by @rjacoby in https://github.com/solidusio/solidus/pull/6091
* Remove Spree::UserAddress#archived flag by @mamhoff in https://github.com/solidusio/solidus/pull/3852
* Add permalink history for taxon on friendly-id by @shahmayur001 in https://github.com/solidusio/solidus/pull/6100
* Refactor Line Item Total Calculations by @jarednorman in https://github.com/solidusio/solidus/pull/6080
* Fix DummyApp Generator by @tvdeyen in https://github.com/solidusio/solidus/pull/6121
* Rails 8: Include manifest.js in install generator by @mamhoff in https://github.com/solidusio/solidus/pull/6122
* Add Ruby 3.4 support by @tvdeyen in https://github.com/solidusio/solidus/pull/6117
* Add primary Taxon to products (#6047) by @fthobe in https://github.com/solidusio/solidus/pull/6109
* Admin promotion categories add/edit by @chaimann in https://github.com/solidusio/solidus/pull/6101
* Move line_item_comparison_hooks config to Spree::Config by @mamhoff in https://github.com/solidusio/solidus/pull/6050
* Admin and User Metadata for transactional ressources and users (#5897) by @fthobe in https://github.com/solidusio/solidus/pull/6118
* Revert "Merge pull request #6122 from mamhoff/create-manifest-js-in-g… by @mamhoff in https://github.com/solidusio/solidus/pull/6124
* Fix migration typo (missing keyword `foreign_key`) by @chaimann in https://github.com/solidusio/solidus/pull/6126
* Use Flickwerk for loading patches in solidus_promotions and solidus_legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/6049
* Added GTIN and Condition to variant for structured data use by @rahulsingh321 in https://github.com/solidusio/solidus/pull/6097

## Solidus Admin

* Remove rails binstubs from built gems by @tvdeyen in https://github.com/solidusio/solidus/pull/5917
* Unauthorized redirect handling config by @mamhoff in https://github.com/solidusio/solidus/pull/6051
* Allows Rails 8, updates sqlite in Gemfile to match what CI runs by @rjacoby in https://github.com/solidusio/solidus/pull/6091
* Admin promotion categories add/edit by @chaimann in https://github.com/solidusio/solidus/pull/6101
* Added GTIN and Condition to variant for structured data use by @rahulsingh321 in https://github.com/solidusio/solidus/pull/6097
* Fix component translation scopes by @mamhoff in https://github.com/solidusio/solidus/pull/5927
* Feat(Admin): Dynamic routing proxies by @mamhoff in https://github.com/solidusio/solidus/pull/5933
* test: Wait for modal to open before testing its content by @tvdeyen in https://github.com/solidusio/solidus/pull/5993
* [specs] Wait for modal before testing its content by @MadelineCollier in https://github.com/solidusio/solidus/pull/5998
* Use Order#email to show the order's email in new admin by @softr8 in https://github.com/solidusio/solidus/pull/5596
* [Admin][Users]Add new admin store_credits show page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5978
* [Admin][Products] Add product properties create/edit flow to admin by @MadelineCollier in https://github.com/solidusio/solidus/pull/6011
* tests: Give even more dialogs more time to open in tests by @tvdeyen in https://github.com/solidusio/solidus/pull/6017
* [Admin][Users] Add new admin store credits edit_amount flow by @MadelineCollier in https://github.com/solidusio/solidus/pull/6031
* [Admin][Users] Add new admin store credits edit_memo flow by @MadelineCollier in https://github.com/solidusio/solidus/pull/6033
* [Admin][Users] Add new admin store credits invalidate flow  by @MadelineCollier in https://github.com/solidusio/solidus/pull/6034
* Use at least solidus_support 0.12.0 by @tvdeyen in https://github.com/solidusio/solidus/pull/6037
* [Admin][Users] Add new admin store credits create flow by @MadelineCollier in https://github.com/solidusio/solidus/pull/6036
* [Admin] Add Prettier config by @tvdeyen in https://github.com/solidusio/solidus/pull/6043
* Pin view_component to < 3.21.0 by @tvdeyen in https://github.com/solidusio/solidus/pull/6048
* Fix unsafe html view component, allow ViewComponent 3.21+ by @mamhoff in https://github.com/solidusio/solidus/pull/6055
* [Admin] Use Rails.application.mounted_helpers in base component by @mamhoff in https://github.com/solidusio/solidus/pull/6039
* [Admin] Open edit and new forms in dialog with turbo frame by @tvdeyen in https://github.com/solidusio/solidus/pull/6046
* Fix missing options in select tags by @chaimann in https://github.com/solidusio/solidus/pull/6120
* Remove Display Order from side menu by @chaimann in https://github.com/solidusio/solidus/pull/6119
* [Admin] Fix tailwindcss-rails Version to v3 for Solidus Admin Compatibility by @swamp09 in https://github.com/solidusio/solidus/pull/6135
* [Admin] Allow bulk delete resources by @chaimann in https://github.com/solidusio/solidus/pull/6134

## Solidus Backend

* Remove rails binstubs from built gems by @tvdeyen in https://github.com/solidusio/solidus/pull/5917
* Backend: Add missing error translation by @mamhoff in https://github.com/solidusio/solidus/pull/5979
* Unauthorized redirect handling config by @mamhoff in https://github.com/solidusio/solidus/pull/6051
* Add primary Taxon to products (#6047) by @fthobe in https://github.com/solidusio/solidus/pull/6109
* Added GTIN and Condition to variant for structured data use by @rahulsingh321 in https://github.com/solidusio/solidus/pull/6097
* Fix field container identifier on admin stock location by @forkata in https://github.com/solidusio/solidus/pull/6107

## Solidus API

* Remove rails binstubs from built gems by @tvdeyen in https://github.com/solidusio/solidus/pull/5917
* Allows Rails 8, updates sqlite in Gemfile to match what CI runs by @rjacoby in https://github.com/solidusio/solidus/pull/6091
* Remove Spree::UserAddress#archived flag by @mamhoff in https://github.com/solidusio/solidus/pull/3852
* Add primary Taxon to products (#6047) by @fthobe in https://github.com/solidusio/solidus/pull/6109
* Admin and User Metadata for transactional ressources and users (#5897) by @fthobe in https://github.com/solidusio/solidus/pull/6118
* Added GTIN and Condition to variant for structured data use by @rahulsingh321 in https://github.com/solidusio/solidus/pull/6097

## Solidus Sample

* Introducing product brand using taxon_brand_selector by @shahmayur001 in https://github.com/solidusio/solidus/pull/5989
* Added GTIN and Condition to variant for structured data use by @rahulsingh321 in https://github.com/solidusio/solidus/pull/6097

## Solidus Promotions

* Add Ruby 3.4 support by @tvdeyen in https://github.com/solidusio/solidus/pull/6117
* Admin promotion categories add/edit by @chaimann in https://github.com/solidusio/solidus/pull/6101
* Move line_item_comparison_hooks config to Spree::Config by @mamhoff in https://github.com/solidusio/solidus/pull/6050
* Use Flickwerk for loading patches in solidus_promotions and solidus_legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/6049
* Fix component translation scopes by @mamhoff in https://github.com/solidusio/solidus/pull/5927
* test: Wait for modal to open before testing its content by @tvdeyen in https://github.com/solidusio/solidus/pull/5993
* Use at least solidus_support 0.12.0 by @tvdeyen in https://github.com/solidusio/solidus/pull/6037
* [Admin] Allow bulk delete resources by @chaimann in https://github.com/solidusio/solidus/pull/6134
* Better promotion menus by @mamhoff in https://github.com/solidusio/solidus/pull/5934
* Fix admin promotions controller by @mamhoff in https://github.com/solidusio/solidus/pull/5943
* [FIX] A few small tweaks for the new promotion admin by @adammathys in https://github.com/solidusio/solidus/pull/5953
* Fix(promotions): Validate benefits on save by @mamhoff in https://github.com/solidusio/solidus/pull/5981
* Fix(Promotions): Return 200 on benefits#edit by @mamhoff in https://github.com/solidusio/solidus/pull/5997
* Add can apply to promotions by @mamhoff in https://github.com/solidusio/solidus/pull/6013
* Fixed wording, typos, license notice & linked to migration guide by @fthobe in https://github.com/solidusio/solidus/pull/6106

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.4.0...v4.5.0


## Solidus v4.4.0 (2024-11-12)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus

* Fix link to the community guidelines document by @rainerdema in https://github.com/solidusio/solidus/pull/5656
* Add Admin Tailwind build when generating sandbox  by @spaghetticode in https://github.com/solidusio/solidus/pull/5636
* Add Legacy promotions gem by @mamhoff in https://github.com/solidusio/solidus/pull/5678
* Solidus gem: Require `solidus_legacy_promotions` by @mamhoff in https://github.com/solidusio/solidus/pull/5726
* Add missing `the` to README by @DemoYeti in https://github.com/solidusio/solidus/pull/5847
* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891

## Solidus Core

* Add Admin Tailwind build when generating sandbox  by @spaghetticode in https://github.com/solidusio/solidus/pull/5636
* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891
* Add support for Sprockets v4 to the DummyApp by @kennyadsl in https://github.com/solidusio/solidus/pull/3379
* [admin] Order adjustments by @elia in https://github.com/solidusio/solidus/pull/5513
* Disable admin preview for extensions test apps by @tvdeyen in https://github.com/solidusio/solidus/pull/5600
* Bundle solidus_admin >= 0.2 in Solidus installer by @spaghetticode in https://github.com/solidusio/solidus/pull/5607
* Fix minor sandbox generation issues by @spaghetticode in https://github.com/solidusio/solidus/pull/5618
* Remove call to private method `#update_cancellations` from `OrderUpdater#recalculate_adjustments` by @mamhoff in https://github.com/solidusio/solidus/pull/5633
* Explicitly require URI in app configuration by @tvdeyen in https://github.com/solidusio/solidus/pull/5644
* Fix down migration for promotion_orders promotions foreign key by @rabbitbike in https://github.com/solidusio/solidus/pull/5642
* Nested Class Set extension, Promotion configuration object by @mamhoff in https://github.com/solidusio/solidus/pull/5658
* Configurable promotion adjustment sources by @mamhoff in https://github.com/solidusio/solidus/pull/5665
* Promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5635
* Remove promotion from cancellations spec by @mamhoff in https://github.com/solidusio/solidus/pull/5639
* Introduce a null promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5667
* Make shared examples and DummyAbility require-able from outside of core by @mamhoff in https://github.com/solidusio/solidus/pull/5640
* Deprecate Spree::Adjustment#recalculate by @mamhoff in https://github.com/solidusio/solidus/pull/5632
* Improve test coverage for Spree::Adjustment to 100% by @mamhoff in https://github.com/solidusio/solidus/pull/5672
* Push spec coverage for Spree::Order to 100% by @mamhoff in https://github.com/solidusio/solidus/pull/5673
* Fix specs failing after Money 6.18.0 release by @spaghetticode in https://github.com/solidusio/solidus/pull/5680
* Add extension point: Promotion finder by @mamhoff in https://github.com/solidusio/solidus/pull/5677
* [Admin] Create new Tax Categories by @spaghetticode in https://github.com/solidusio/solidus/pull/5674
* Make API independent of promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5686
* Move promotion backend controllers and views to legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5685
* Fix flaky admin stock items spec by @mamhoff in https://github.com/solidusio/solidus/pull/5701
* Let promotion handler decide whether it can add a coupon to an order by @mamhoff in https://github.com/solidusio/solidus/pull/5684
* Add `shipping_promotion_handler_class` attribute to null promo config by @mamhoff in https://github.com/solidusio/solidus/pull/5729
* Fix case statement in database config template by @nvandoorn in https://github.com/solidusio/solidus/pull/5736
* Promotion advertiser by @mamhoff in https://github.com/solidusio/solidus/pull/5739
* Configure promotions via a configuration instance by @mamhoff in https://github.com/solidusio/solidus/pull/5738
* fix(StoreCredit): Add display_number method by @tvdeyen in https://github.com/solidusio/solidus/pull/5741
* [Admin] adding new shipping category by @loicginoux in https://github.com/solidusio/solidus/pull/5718
* Rename Spree::Config.promotions.promotion_adjuster_class by @mamhoff in https://github.com/solidusio/solidus/pull/5752
* Move shipping promotion handling to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5753
* Create Spree::SimpleOrderContents by @mamhoff in https://github.com/solidusio/solidus/pull/5755
* Clear order promotions in Omnes event by @mamhoff in https://github.com/solidusio/solidus/pull/5754
* Add missing methods to null promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5756
* Re-add translation for `match_choices` by @mamhoff in https://github.com/solidusio/solidus/pull/5765
* Deprecated Configurable Class: Allow class methods by @mamhoff in https://github.com/solidusio/solidus/pull/5762
* Move legacy integration specs by @mamhoff in https://github.com/solidusio/solidus/pull/5773
* Rename PromotionConfiguration to LegacyPromotionConfiguration by @mamhoff in https://github.com/solidusio/solidus/pull/5769
* NullPromotionHandler: return self from #apply by @mamhoff in https://github.com/solidusio/solidus/pull/5767
* Disallow sprockets-rails 3.5.0 by @mamhoff in https://github.com/solidusio/solidus/pull/5778
* Use Null Promotion Configuration in core by @mamhoff in https://github.com/solidusio/solidus/pull/5744
* App configuration: Use SimpleOrderContents by default by @mamhoff in https://github.com/solidusio/solidus/pull/5775
* Move promotion code batch services by @mamhoff in https://github.com/solidusio/solidus/pull/5787
* Move Legacy Promotions Service Objects to `solidus_legacy_promotions` by @mamhoff in https://github.com/solidusio/solidus/pull/5786
* Allow Psych 5 by @tvdeyen in https://github.com/solidusio/solidus/pull/5788
* Require legacy promotion configuration in legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5796
* Extract Legacy Promotion System: Move ActiveRecord Models and Factories by @mamhoff in https://github.com/solidusio/solidus/pull/5634
* Move adjustment promotion code id to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5800
* Remove spree_orders_promotions from core migration by @mamhoff in https://github.com/solidusio/solidus/pull/5803
* Lock solidus_core.gemspec to ransack '< 4.2' by @MadelineCollier in https://github.com/solidusio/solidus/pull/5812
* Use new extension point in order updater spec by @mamhoff in https://github.com/solidusio/solidus/pull/5814
* Raise on deprecation when `SOLIDUS_RAISE_DEPRECATIONS` set by @forkata in https://github.com/solidusio/solidus/pull/5813
* Destroy wallet payment source on source destroy by @tvdeyen in https://github.com/solidusio/solidus/pull/5836
* Move eligible column to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5802
* [Admin] Add new migrations and validations in `core` to support new `admin` `Spree::Role` interface  by @MadelineCollier in https://github.com/solidusio/solidus/pull/5833
* Decorate Default Return Refund Amount Calculator in LegacyPromotions by @mamhoff in https://github.com/solidusio/solidus/pull/5845
* [Admin] Allow assignment of permission sets when creating/editing admin roles by @MadelineCollier in https://github.com/solidusio/solidus/pull/5846
* [Admin] Display `last_sign_in_at` in users admin, change default scope by @MadelineCollier in https://github.com/solidusio/solidus/pull/5850
* Add Ransack 4.2 support by @tvdeyen in https://github.com/solidusio/solidus/pull/5853
* Spree::Variant.in_stock: Only show distinct variants by @mamhoff in https://github.com/solidusio/solidus/pull/5860
* [Admin] New admin user edit page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5856
* Performance: Remove includes from Spree::Variant#options_text by @mamhoff in https://github.com/solidusio/solidus/pull/5867
* Add template variants scope by @mamhoff in https://github.com/solidusio/solidus/pull/5866
* Allow Rails 7.2 by @tvdeyen in https://github.com/solidusio/solidus/pull/5843
* Deprecate and remove dashboard code by @nvandoorn in https://github.com/solidusio/solidus/pull/5883
* Legacy Promotions: Move ransackable promo associations from core by @mamhoff in https://github.com/solidusio/solidus/pull/5893
* FixUpdate return_reasons.rb by @fthobe in https://github.com/solidusio/solidus/pull/5901

## Solidus Admin

* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891
* [admin] Order adjustments by @elia in https://github.com/solidusio/solidus/pull/5513
* Fix minor sandbox generation issues by @spaghetticode in https://github.com/solidusio/solidus/pull/5618
* [Admin] Create new Tax Categories by @spaghetticode in https://github.com/solidusio/solidus/pull/5674
* Move promotion backend controllers and views to legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5685
* Fix flaky admin stock items spec by @mamhoff in https://github.com/solidusio/solidus/pull/5701
* [Admin] adding new shipping category by @loicginoux in https://github.com/solidusio/solidus/pull/5718
* Move adjustment promotion code id to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5800
* Lock solidus_core.gemspec to ransack '< 4.2' by @MadelineCollier in https://github.com/solidusio/solidus/pull/5812
* Move eligible column to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5802
* [Admin] Allow assignment of permission sets when creating/editing admin roles by @MadelineCollier in https://github.com/solidusio/solidus/pull/5846
* [Admin] Display `last_sign_in_at` in users admin, change default scope by @MadelineCollier in https://github.com/solidusio/solidus/pull/5850
* Add Ransack 4.2 support by @tvdeyen in https://github.com/solidusio/solidus/pull/5853
* [Admin] New admin user edit page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5856
* Fix property destroy - use destroy instead of discard by @tonxyx in https://github.com/solidusio/solidus/pull/5577
* [Admin] Introduce base Index Component by @rainerdema in https://github.com/solidusio/solidus/pull/5561
* Restore coverage tracking by @elia in https://github.com/solidusio/solidus/pull/5580
* [admin] Fix mock components reported location by @elia in https://github.com/solidusio/solidus/pull/5589
* [admin] Require ViewComponent v3.9 with inheritable translations by @elia in https://github.com/solidusio/solidus/pull/5590
* [admin] Remove previews for non-UI components that didn't add much value by @elia in https://github.com/solidusio/solidus/pull/5592
* [admin] Consistently use `label` for providing text for table scopes, batch actions and filters by @elia in https://github.com/solidusio/solidus/pull/5593
* [admin] Reduce the size of the panels title by @elia in https://github.com/solidusio/solidus/pull/5594
* fix(admin stock items spec): Wait for tab to be active by @tvdeyen in https://github.com/solidusio/solidus/pull/5601
* [admin] Document SolidusAdmin intended usage and how to contribute by @elia in https://github.com/solidusio/solidus/pull/5595
* [ADMIN] Fix flash messages coloring by @spaghetticode in https://github.com/solidusio/solidus/pull/5681
* Convert existing Admin modals to Turbo frames by @spaghetticode in https://github.com/solidusio/solidus/pull/5688
* [admin] fix docs links in README by @ccarruitero in https://github.com/solidusio/solidus/pull/5703
* Make SolidusAdmin's testing support code require-able by @mamhoff in https://github.com/solidusio/solidus/pull/5700
* [Admin] Add the ability to configure batch action confirmation by @forkata in https://github.com/solidusio/solidus/pull/5702
* Show the page action for creating a new shipping method by @forkata in https://github.com/solidusio/solidus/pull/5719
* [Admin] Create new Refund Reasons by @spaghetticode in https://github.com/solidusio/solidus/pull/5696
* [Admin] Add Update Tax Category feature by @spaghetticode in https://github.com/solidusio/solidus/pull/5697
* Move solidus admin promotion to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5724
* Show "Unavailable" status for products with a future `Available On` date by @forkata in https://github.com/solidusio/solidus/pull/5734
* Docker development environment improvements by @nvandoorn in https://github.com/solidusio/solidus/pull/5735
* Create custom orders index component for solidus_legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5779
* Use configurable adjustment promotion source types in Thumbnail.for by @mamhoff in https://github.com/solidusio/solidus/pull/5781
* Fix flaky spec with sleep by @mamhoff in https://github.com/solidusio/solidus/pull/5783
* Components registry safe reload by @mamhoff in https://github.com/solidusio/solidus/pull/5780
* SolidusAdmin: Components per Adjustment Source by @mamhoff in https://github.com/solidusio/solidus/pull/5789
* Support Tailwind CSS in core dummy app by @mamhoff in https://github.com/solidusio/solidus/pull/5798
* Admin adjustable components by @mamhoff in https://github.com/solidusio/solidus/pull/5791
* [Admin] Create new Adjustment Reasons by @MadelineCollier in https://github.com/solidusio/solidus/pull/5811
* Add before action to handle option type params by @nvandoorn in https://github.com/solidusio/solidus/pull/5816
* [Admin] Adjustment Reasons edit/update by @MadelineCollier in https://github.com/solidusio/solidus/pull/5815
* [Admin] Shipping Categories edit/update by @MadelineCollier in https://github.com/solidusio/solidus/pull/5817
* [Admin] Refund Reasons edit/update by @MadelineCollier in https://github.com/solidusio/solidus/pull/5819
* [Admin] Create new Store Credit Reasons by @MadelineCollier in https://github.com/solidusio/solidus/pull/5820
* [Admin] Store Credit Reasons edit/update & New request specs to appease Codecov by @MadelineCollier in https://github.com/solidusio/solidus/pull/5821
* [Admin] Add request spec for Refund Reasons & other minor edits by @MadelineCollier in https://github.com/solidusio/solidus/pull/5822
* Remove unused load methods & Add more request spec coverage by @MadelineCollier in https://github.com/solidusio/solidus/pull/5825
* [Admin] Introduce RMA reasons creation & modification capability  by @MadelineCollier in https://github.com/solidusio/solidus/pull/5829
* [Admin] Introduce role creation by @MadelineCollier in https://github.com/solidusio/solidus/pull/5831
* [SolidusAdmin] Remove inaccessible details/summary element by @mamhoff in https://github.com/solidusio/solidus/pull/5835
* [Admin] Edit/Update roles via new admin UI by @MadelineCollier in https://github.com/solidusio/solidus/pull/5828
* Standardize admin controller setup methods by @MadelineCollier in https://github.com/solidusio/solidus/pull/5842
* [Admin] Update Spree::Role admin UI with descriptions & required names by @MadelineCollier in https://github.com/solidusio/solidus/pull/5844
* [Admin] Add new users admin addresses page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5865
* [Admin] Add new users admin order history page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5869
* [Admin] Handle states_required? in admin address component by @MadelineCollier in https://github.com/solidusio/solidus/pull/5871
* Add filtering by store to orders index component by @forkata in https://github.com/solidusio/solidus/pull/5870
* [Admin] Add new users admin items page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5874
* Update Tailwind executable call for v3.0 by @forkata in https://github.com/solidusio/solidus/pull/5877
* Admin installer fixes by @tvdeyen in https://github.com/solidusio/solidus/pull/5880
* [Admin] Add new users admin store credits page by @MadelineCollier in https://github.com/solidusio/solidus/pull/5887
* Exclude 'remixicon.symbol.svg' from asset pipeline by @stewart in https://github.com/solidusio/solidus/pull/5878

## Solidus Backend

* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891
* Nested Class Set extension, Promotion configuration object by @mamhoff in https://github.com/solidusio/solidus/pull/5658
* Promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5635
* Move promotion backend controllers and views to legacy_promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5685
* App configuration: Use SimpleOrderContents by default by @mamhoff in https://github.com/solidusio/solidus/pull/5775
* Move eligible column to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5802
* Allow Rails 7.2 by @tvdeyen in https://github.com/solidusio/solidus/pull/5843
* Deprecate and remove dashboard code by @nvandoorn in https://github.com/solidusio/solidus/pull/5883
* Docker development environment improvements by @nvandoorn in https://github.com/solidusio/solidus/pull/5735
* Fix the check on select2 translations asset existence by @elia in https://github.com/solidusio/solidus/pull/5582
* Use `spree` routing proxy in theme selection partial by @mamhoff in https://github.com/solidusio/solidus/pull/5599
* Theme selection for Solidus Admin: Use spree routing proxy by @mamhoff in https://github.com/solidusio/solidus/pull/5604
* Menu item should not match url if match_path is set by @sascha-karnatz in https://github.com/solidusio/solidus/pull/5643
* Fix search by variant on stock items by @nvandoorn in https://github.com/solidusio/solidus/pull/5660
* Use routing proxy in locale selection by @mamhoff in https://github.com/solidusio/solidus/pull/5611
* Fix JS locale data for release of Money 6.19 by @mamhoff in https://github.com/solidusio/solidus/pull/5683
* Do not show theme selector if only one theme is configured by @tvdeyen in https://github.com/solidusio/solidus/pull/5705
* Move promotion admin assets by @mamhoff in https://github.com/solidusio/solidus/pull/5699
* Add routes proxy to locale selection path helper by @mamhoff in https://github.com/solidusio/solidus/pull/5716
* Fix flaky admin customer return spec by @mamhoff in https://github.com/solidusio/solidus/pull/5757
* Fix deprecation warning from Ransack by @mamhoff in https://github.com/solidusio/solidus/pull/5764
* Backend: Make order search fields configurable by @mamhoff in https://github.com/solidusio/solidus/pull/5776
* Call empty only on incomplete orders by @nvandoorn in https://github.com/solidusio/solidus/pull/5827
* Format date with #to_fs by @alepore in https://github.com/solidusio/solidus/pull/5863
* Variant Autocomplete: Allow passing select2 options by @mamhoff in https://github.com/solidusio/solidus/pull/5861
* Render variant shipping category by @nvandoorn in https://github.com/solidusio/solidus/pull/5882

## Solidus API

* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891
* Promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5635
* Add extension point: Promotion finder by @mamhoff in https://github.com/solidusio/solidus/pull/5677
* Make API independent of promotion configuration by @mamhoff in https://github.com/solidusio/solidus/pull/5686
* Use Null Promotion Configuration in core by @mamhoff in https://github.com/solidusio/solidus/pull/5744
* App configuration: Use SimpleOrderContents by default by @mamhoff in https://github.com/solidusio/solidus/pull/5775
* Move adjustment promotion code id to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5800
* Move eligible column to legacy promotions by @mamhoff in https://github.com/solidusio/solidus/pull/5802
* Call empty only on incomplete orders by @nvandoorn in https://github.com/solidusio/solidus/pull/5827
* SolidusLegacyPromotion extraction: Move and fix remaining API specs by @mamhoff in https://github.com/solidusio/solidus/pull/5694
* Do not initialize promotions object on startup by @mamhoff in https://github.com/solidusio/solidus/pull/5728
* Fix failing API promotions specs by @MadelineCollier in https://github.com/solidusio/solidus/pull/5859

## Solidus Sample

* Bump minimum Ruby version to 3.1 by @tvdeyen in https://github.com/solidusio/solidus/pull/5891
* Add missing option types to product sample data by @spaghetticode in https://github.com/solidusio/solidus/pull/5638

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.3.0...v4.4.0


## Solidus v4.3.3 (2024-03-11)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus

* [v4.3] Add Admin Tailwind build when generating sandbox  by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5689

## Solidus Core

* [v4.3] Add Admin Tailwind build when generating sandbox  by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5689
* [v4.3] Explicitly require URI in app configuration by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5648
* [v4.3] Fix minor sandbox generation issues by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5676
* [v4.3] Fix specs failing after Money 6.18.0 release by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5691

## Solidus Admin

* [v4.3] Fix minor sandbox generation issues by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5676

## Solidus Backend

* [v4.3] Fix JS locale data for release of Money 6.19 by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5690

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.3.2...v4.3.3


## Solidus v4.3.2 (2024-01-22)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus Core

* [v4.3] Disable admin preview for extensions test apps by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5602
* [v4.3] Bundle solidus_admin >= 0.2 in Solidus installer by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5608

## Solidus Backend

* [v4.3] Use &#x60;spree&#x60; routing proxy in theme selection partial by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5603
* [v4.3] Theme selection for Solidus Admin: Use spree routing proxy by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5605

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.3.1...v4.3.2


## Solidus v4.3.1 (2024-01-05)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus Backend

* [v4.3] Fix the check on select2 translations asset existence by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5584

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.3.0...v4.3.1


## Solidus v4.3.0 (2023-12-22)

<!-- Please, don't edit manually. The content is automatically generated. -->

## Solidus

* Fix the link to customization guides by @pokonski in https://github.com/solidusio/solidus/pull/5404

## Solidus Core

* Skip `ActionCable` for dummy apps by @mamhoff in https://github.com/solidusio/solidus/pull/5420
* Do not require `ActiveStorage` in core by @tvdeyen in https://github.com/solidusio/solidus/pull/5450
* Fix issues raised by ERB and JS linting by @elia in https://github.com/solidusio/solidus/pull/5457
* Fix `deactivate_unsupported_payment_methods` name in error message by @kennyadsl in https://github.com/solidusio/solidus/pull/5458
* Make promotion handler classes configurable by @mamhoff in https://github.com/solidusio/solidus/pull/5466
* Add `dependent: :destroy` to `Spree::Order#order_promotions` by @mamhoff in https://github.com/solidusio/solidus/pull/5411
* Add `ActiveStorage` as a core dependency by @tvdeyen in https://github.com/solidusio/solidus/pull/5479
* Add foreign key constraint between `order_promotions` and `promotions` by @mamhoff in https://github.com/solidusio/solidus/pull/5469
* Minimum Quantity promotion rule by @adammathys in https://github.com/solidusio/solidus/pull/5452
* Add `Order#use_shipping` and address management to the admin dashboard by @rainerdema in https://github.com/solidusio/solidus/pull/5461
* set_position conflicts with acts_as_list by @tkimi in https://github.com/solidusio/solidus/pull/5509
* Add dark themes to the backend and a theme switching support by @MassimilianoLattanzio in https://github.com/solidusio/solidus/pull/4999
* Add a `TaxRate#display_amount` and a tax categories & rates admin index by @elia in https://github.com/solidusio/solidus/pull/5529
* Fix rubocop violations after the latest release by @elia in https://github.com/solidusio/solidus/pull/5535
* Allow to choose a custom routes' mount point during install by @kennyadsl in https://github.com/solidusio/solidus/pull/5533
* Cleanup the database configuration by @elia in https://github.com/solidusio/solidus/pull/5545
* Update the `spree.rb.tt` stripe configuration instructions for `SolidusStripe` v5+ by @thomasbromehead in https://github.com/solidusio/solidus/pull/5505
* Fix the down step of the `DropDeprecatedAddressIdFromShipments` migration by @DanielePalombo in https://github.com/solidusio/solidus/pull/5557
* Deprecate `Spree::NamedType` Concern by @elia in https://github.com/solidusio/solidus/pull/5541
* Enhance log message for Bogus payments by @nirnaeth in https://github.com/solidusio/solidus/pull/5422
* Rails 7.1 support by @peterberkenbosch in https://github.com/solidusio/solidus/pull/5359
* Use configurable promo adjuster in callback by @mamhoff in https://github.com/solidusio/solidus/pull/5498
* Enable the admin preview by default for new installations by @elia in https://github.com/solidusio/solidus/pull/5563
* Remove unused action in controller callbacks by @kennyadsl in https://github.com/solidusio/solidus/pull/5566

## Solidus Admin

* Fix issues raised by ERB and JS linting by @elia in https://github.com/solidusio/solidus/pull/5457
* Add `Order#use_shipping` and address management to the admin dashboard by @rainerdema in https://github.com/solidusio/solidus/pull/5461
* Add a `TaxRate#display_amount` and a tax categories & rates admin index by @elia in https://github.com/solidusio/solidus/pull/5529
* Allow to choose a custom routes' mount point during install by @kennyadsl in https://github.com/solidusio/solidus/pull/5533
* Rails 7.1 support by @peterberkenbosch in https://github.com/solidusio/solidus/pull/5359
* Remove unused action in controller callbacks by @kennyadsl in https://github.com/solidusio/solidus/pull/5566
* [Admin] Ensure `action_name` is passed as symbol for `cancancan` authorization by @rainerdema in https://github.com/solidusio/solidus/pull/5399
* [Admin] Add dynamic filters to `ui/table` component by @rainerdema in https://github.com/solidusio/solidus/pull/5376
* Don't show missing order shipment and payment states by @elia in https://github.com/solidusio/solidus/pull/5427
* Fix `/admin/product/new` in SolidusAdmin by @elia in https://github.com/solidusio/solidus/pull/5426
* [Admin] Ensure labels are clickable by parameterizing ids by @rainerdema in https://github.com/solidusio/solidus/pull/5429
* Extract the table search field to a component by @elia in https://github.com/solidusio/solidus/pull/5428
* Don't capture `NameError` if its not a missing component by @elia in https://github.com/solidusio/solidus/pull/5432
* Add a `ui/thumbnail` component by @elia in https://github.com/solidusio/solidus/pull/5431
* [Admin] Enhance `ui/table` component with clickable rows and URL navigation by @rainerdema in https://github.com/solidusio/solidus/pull/5397
* [Admin] Enhance toast message positioning and layering by @rainerdema in https://github.com/solidusio/solidus/pull/5436
* Extract a `products/stock` component by @elia in https://github.com/solidusio/solidus/pull/5433
* [Admin] Construct base components for order creation in admin interface by @rainerdema in https://github.com/solidusio/solidus/pull/5434
* Admin tooltip improvements by @elia in https://github.com/solidusio/solidus/pull/5439
* SolidusAdmin `products/stock` component fixes by @elia in https://github.com/solidusio/solidus/pull/5443
* Update hints and remove them where not needed by @mfrecchiami in https://github.com/solidusio/solidus/pull/5435
* [Admin] Enhance toast component: Background color and animations by @rainerdema in https://github.com/solidusio/solidus/pull/5442
* SolidusAdmin: Extract page layout helpers by @elia in https://github.com/solidusio/solidus/pull/5445
* SolidusAdmin misc. component fixes by @elia in https://github.com/solidusio/solidus/pull/5444
* [Admin] Fix `ui/table/toolbar` & restore `clearSearch` & Streamline `feedback` rendering by @rainerdema in https://github.com/solidusio/solidus/pull/5449
* Add an `orders/cart` component by @elia in https://github.com/solidusio/solidus/pull/5441
* Dynamic `ui/toggletip` positioning by @elia in https://github.com/solidusio/solidus/pull/5451
* [Admin] Add modal component by @the-krg in https://github.com/solidusio/solidus/pull/5364
* [Admin] Extract a `ui/search_panel` component from `orders/cart` by @elia in https://github.com/solidusio/solidus/pull/5467
* [Admin] Introduce `ui/forms/address` component for order admin checkout by @rainerdema in https://github.com/solidusio/solidus/pull/5468
* [admin] Add the customer sidebar to the orders page by @elia in https://github.com/solidusio/solidus/pull/5499
* [admin] Allow editing the order contact email by @elia in https://github.com/solidusio/solidus/pull/5500
* SolidusAdmin customer picker for order by @elia in https://github.com/solidusio/solidus/pull/5462
* [admin] Move layout related components under `layout/` by @elia in https://github.com/solidusio/solidus/pull/5510
* [admin] dark mode by @elia in https://github.com/solidusio/solidus/pull/5511
* [Admin] Add `Select address` dropdown feature to billing and shipping forms by @rainerdema in https://github.com/solidusio/solidus/pull/5507
* [Admin] Add `order/show/summary` component by @rainerdema in https://github.com/solidusio/solidus/pull/5512
* [admin] Update the admin preview toggle label by @elia in https://github.com/solidusio/solidus/pull/5515
* [admin] Add scopes and controller helpers for `ui/table` by @elia in https://github.com/solidusio/solidus/pull/5516
* [admin] Fix menu styles & add a backend menu items importer by @elia in https://github.com/solidusio/solidus/pull/5518
* [admin] Add users index by @elia in https://github.com/solidusio/solidus/pull/5519
* [admin] Add a `promotions/index` component by @elia in https://github.com/solidusio/solidus/pull/5517
* [Admin] Add sortable rows in `ui/table` component by @rainerdema in https://github.com/solidusio/solidus/pull/5522
*  [Admin] Add `Properties` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5527
* [Admin] Add `Option Types` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5525
* [Admin] Add `Promotion Categories` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5528
* [admin] Move the feedback link to the bottom of the page by @elia in https://github.com/solidusio/solidus/pull/5524
* [Admin] Add `Taxonomies` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5526
* [admin] Add scopes to the products page by @elia in https://github.com/solidusio/solidus/pull/5531
* [Admin] Add `Payment Methods` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5530
* [admin] Extract common admin resources patterns to a helper by @elia in https://github.com/solidusio/solidus/pull/5534
* [Admin] Add `Stock Items` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5532
* [admin] Add index pages for the settings / shipping area by @elia in https://github.com/solidusio/solidus/pull/5536
* [Admin] Add `Stores` index component by @rainerdema in https://github.com/solidusio/solidus/pull/5537
* [admin] Add index pages for `zones` by @elia in https://github.com/solidusio/solidus/pull/5538
* [Admin] Add `Refunds and Returns` section with correlated index pages by @rainerdema in https://github.com/solidusio/solidus/pull/5539
* [Admin] Add `stock_items/edit` modal component by @elia in https://github.com/solidusio/solidus/pull/5543
* [Admin] Refactor index page settings: Ransack search and pagination by @rainerdema in https://github.com/solidusio/solidus/pull/5546
* [admin] Cleanup TW classes by @elia in https://github.com/solidusio/solidus/pull/5550
* [Admin] Enhancements to filter toolbar and dropdown visibility by @rainerdema in https://github.com/solidusio/solidus/pull/5548
* [admin] Relax the SolidusAdmin dependency on Solidus core by @elia in https://github.com/solidusio/solidus/pull/5547
* [admin] Performance fixes by @elia in https://github.com/solidusio/solidus/pull/5552
* [Admin] Implement `enable_alpha_features?` preference config for selective feature access by @rainerdema in https://github.com/solidusio/solidus/pull/5549
* [admin] Provide a pre-built CSS file and a script to customize TW for local modifications by @elia in https://github.com/solidusio/solidus/pull/5554
* [admin] Build the admin CSS before running the specs by @elia in https://github.com/solidusio/solidus/pull/5558
* [admin] Reuse the same class name as Backend for MenuItem by @elia in https://github.com/solidusio/solidus/pull/5555
* [Admin] Refactor admin components for consistent code style by @rainerdema in https://github.com/solidusio/solidus/pull/5559
* [Admin] Include pagination in `payment_methods/index` component by @rainerdema in https://github.com/solidusio/solidus/pull/5562

## Solidus Backend

* Fix issues raised by ERB and JS linting by @elia in https://github.com/solidusio/solidus/pull/5457
* Minimum Quantity promotion rule by @adammathys in https://github.com/solidusio/solidus/pull/5452
* Add dark themes to the backend and a theme switching support by @MassimilianoLattanzio in https://github.com/solidusio/solidus/pull/4999
* Fix rubocop violations after the latest release by @elia in https://github.com/solidusio/solidus/pull/5535
* Rails 7.1 support by @peterberkenbosch in https://github.com/solidusio/solidus/pull/5359
* Remove unused action in controller callbacks by @kennyadsl in https://github.com/solidusio/solidus/pull/5566
* [admin] Fix menu styles & add a backend menu items importer by @elia in https://github.com/solidusio/solidus/pull/5518
* Update backend configuration for solidus `v4.2` by @rainerdema in https://github.com/solidusio/solidus/pull/5405
* Restore using `MenuItem#sections` for matching paths by @elia in https://github.com/solidusio/solidus/pull/5406
* Fix the content navbar being hidden under the navbar when the window is narrow by @elia in https://github.com/solidusio/solidus/pull/5423
* Solidus legacy color hierarchy by @mfrecchiami in https://github.com/solidusio/solidus/pull/5446
* Drop autoprefixer-rails from dependencies by @elia in https://github.com/solidusio/solidus/pull/5521
* Restyle backend UI flash message to not overlap buttons by @brettchalupa in https://github.com/solidusio/solidus/pull/5540

## Solidus API

* Make promotion handler classes configurable by @mamhoff in https://github.com/solidusio/solidus/pull/5466
* Add `Order#use_shipping` and address management to the admin dashboard by @rainerdema in https://github.com/solidusio/solidus/pull/5461
* Fix rubocop violations after the latest release by @elia in https://github.com/solidusio/solidus/pull/5535
* Remove unused action in controller callbacks by @kennyadsl in https://github.com/solidusio/solidus/pull/5566

## Solidus Sample

* Fix rubocop violations after the latest release by @elia in https://github.com/solidusio/solidus/pull/5535
* Rails 7.1 support by @peterberkenbosch in https://github.com/solidusio/solidus/pull/5359
* Update samples to match new SSF style by @aleph1ow in https://github.com/solidusio/solidus/pull/5437
* Update sample images by @kennyadsl in https://github.com/solidusio/solidus/pull/5560

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.2.0...v4.3.0


## Solidus v4.2.3 (2023-11-02)

## Solidus Core
* [v4.2] Add activestorage as dependency by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5483

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.2.2...v4.2.3


## Solidus v4.2.2 (2023-11-01)

## Solidus Core
* [v4.2] Do not require active_storage/engine by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5456

## Solidus Backend
* [v4.2] Skip all the navbar hiding logic when using the new version by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5424

## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.2.1...v4.2.2


## Solidus v4.2.1 (2023-10-04)

## Solidus Core


## Solidus Backend
* [v4.2] Update backend configuration for solidus `v4.2` by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5407
* [v4.2] Restore using `MenuItem#sections` for matching paths by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5409

## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.2.0...v4.2.1


## Solidus v4.2.0 (2023-09-29)


## Solidus Core

* Allow filtering option values by variant for the Option Value promotion rule by @mamhoff in https://github.com/solidusio/solidus/pull/5200
* Ensure `current_store` always comes with a `url` set by @elia in https://github.com/solidusio/solidus/pull/5224
* Remove unused ActiveRecord join class `Spree::PromotionRuleRole` by @mamhoff in https://github.com/solidusio/solidus/pull/5217
* Improving stock items management by @softr8 in https://github.com/solidusio/solidus/pull/3626
* Load `stock_items` with a deterministic order in `OrderInventory#determine_target_shipment` by @elia in https://github.com/solidusio/solidus/pull/5288
* Use the new Solidus logo by @elia in https://github.com/solidusio/solidus/pull/5314
* Reorganize `Stock::SimpleCoordinator` for improved debugging by @BenMorganIO in https://github.com/solidusio/solidus/pull/5249
* Bump the minimum required Psych version by @elia in https://github.com/solidusio/solidus/pull/5322
* Fix `Order#restart_checkout_flow` for empty orders by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5330
* Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @elia in https://github.com/solidusio/solidus/pull/5380
* Cleanup `MenuItem` API and deprecate using partials for second level menus by @elia in https://github.com/solidusio/solidus/pull/5309
* Deprecate the `Spree::Adjustment.return_authorization` scope by @mamhoff in https://github.com/solidusio/solidus/pull/5138
* Update the `Spree::Backend` navigation menu to match the upcoming `SolidusAdmin` by @elia in https://github.com/solidusio/solidus/pull/5392
* Deprecate `Spree::Deprecation` in favor of `Spree.deprecator` by @kennyadsl in https://github.com/solidusio/solidus/pull/5289
* Enhance product model with `variants_option_values` ransacker by @rainerdema in https://github.com/solidusio/solidus/pull/5395
* Add `SolidusAdmin`support by @elia in https://github.com/solidusio/solidus/pull/5068

## Solidus Backend

* Allow filtering option values by variant for the Option Value promotion rule by @mamhoff in https://github.com/solidusio/solidus/pull/5200
* Improving stock items management by @softr8 in https://github.com/solidusio/solidus/pull/3626
* Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @elia in https://github.com/solidusio/solidus/pull/5380
* Cleanup `MenuItem` API and deprecate using partials for second level menus by @elia in https://github.com/solidusio/solidus/pull/5309
* Update the `Spree::Backend` navigation menu to match the upcoming `SolidusAdmin` by @elia in https://github.com/solidusio/solidus/pull/5392
* Deprecate `Spree::Deprecation` in favor of `Spree.deprecator` by @kennyadsl in https://github.com/solidusio/solidus/pull/5289
* Add `SolidusAdmin` support by @elia in https://github.com/solidusio/solidus/pull/5068
* Allow overriding the routes proxy in the `ResourceController` by @mamhoff in https://github.com/solidusio/solidus/pull/5219
* Add Armenian language translations for `Select2` plugin by @arman-h in https://github.com/solidusio/solidus/pull/5285
* Add Cilean Spanish language support for `Select2` plugin by @MauricioTRP in https://github.com/solidusio/solidus/pull/5377

## Solidus API

* Allow filtering option values by variant for the Option Value promotion rule by @mamhoff in https://github.com/solidusio/solidus/pull/5200
* Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @elia in https://github.com/solidusio/solidus/pull/5380
* Fix `Spree::Api:LineItemsController#create` handling of validation errors by @RyanofWoods in https://github.com/solidusio/solidus/pull/4177

## Solidus Sample

* Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @elia in https://github.com/solidusio/solidus/pull/5380

**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.1.0...v4.2.0


## Solidus v4.1.4 (2024-01-05)

## Solidus Core
* [4.1] Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @tvdeyen in https://github.com/solidusio/solidus/pull/5484

## Solidus Backend
* [4.1] Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @tvdeyen in https://github.com/solidusio/solidus/pull/5484

## Solidus API
* [4.1] Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @tvdeyen in https://github.com/solidusio/solidus/pull/5484

## Solidus Sample
* [4.1] Use ActiveRecord's `.find_each` instead of `.each` whenever possible by @tvdeyen in https://github.com/solidusio/solidus/pull/5484

## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.1.3...v4.1.4


## Solidus v4.1.3 (2023-11-02)

## Solidus Core
* [v4.1] Add activestorage as dependency by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5482

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.1.2...v4.1.3


## Solidus v4.1.2 (2023-11-01)

## Solidus Core
* [v4.1] Do not require active_storage/engine by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5455

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.1.1...v4.1.2


## Solidus v4.1.1 (2023-08-14)

## Solidus Core
* [v4.1] Update deprecation horizon by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5307
* [v4.1] Fix offense after RuboCop 1.56 by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5328
* [v4.1] Bump the minimum required Psych version by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5327
* [v4.1] Fix error added when resetting order flow on an empty order by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5336

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.1.0...v4.1.1


## Solidus v4.1.0 (2023-06-29)

## Solidus Core
* Don't gsub attachment comment during solidus installation by @RyanofWoods in https://github.com/solidusio/solidus/pull/5087
* Update Taxon PaperClip attributes on attachment destroy by @RyanofWoods in https://github.com/solidusio/solidus/pull/5086
* Remove frontend related code from the core dummy app by @kennyadsl in https://github.com/solidusio/solidus/pull/5058
* Make Spree::MigrationHelpers Ruby 3.0 compatible by @RyanofWoods in https://github.com/solidusio/solidus/pull/5072
* Relax rubocop version requirement and add it to the CI by @elia in https://github.com/solidusio/solidus/pull/5075
* Allow changing the order recalculator by @mamhoff in https://github.com/solidusio/solidus/pull/5110
* Ensure to return false on Paperclip attachment destroy failure by @RyanofWoods in https://github.com/solidusio/solidus/pull/5101
* Prefer delegating recalculate without a method by @kennyadsl in https://github.com/solidusio/solidus/pull/5120
* Move install generator spec in the proper directory by @kennyadsl in https://github.com/solidusio/solidus/pull/5114
* Remove references to legacy :general_settings resource by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5128
* Document available permission sets by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5141
* Rename Order#ensure_updated_shipments method by @spaghetticode in https://github.com/solidusio/solidus/pull/4173
* Fix solidus_core making use of responders API by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5158
* Allow running bin/rails from Solidus engines by @elia in https://github.com/solidusio/solidus/pull/5164
* Fix rubocop violation enabled by a rubocop bugfix by @elia in https://github.com/solidusio/solidus/pull/5183
* Fix Taxon taxonomy id validation regression by @RyanofWoods in https://github.com/solidusio/solidus/pull/5189

## Solidus Backend
* Remove the blue_steel theme by @elia in https://github.com/solidusio/solidus/pull/5084
* Relax rubocop version requirement and add it to the CI by @elia in https://github.com/solidusio/solidus/pull/5075
* Add support for admin themes by @elia in https://github.com/solidusio/solidus/pull/5091
* Improve the CSS of the admin locale selection and login nav by @elia in https://github.com/solidusio/solidus/pull/5113
* Fix locale selection with a hidden admin navbar by @elia in https://github.com/solidusio/solidus/pull/5119
* Remove references to legacy :general_settings resource by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5128
* Get fresh data for update_positions by @julienanne in https://github.com/solidusio/solidus/pull/5040
* [backend] Disable customer returns buttons after first click by @AlessioRocco in https://github.com/solidusio/solidus/pull/3550
* Add a new admin theme by @elia in https://github.com/solidusio/solidus/pull/5092
* Fix solidus_core making use of responders API by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5158
* Allow running bin/rails from Solidus engines by @elia in https://github.com/solidusio/solidus/pull/5164
* Allow lambda in menu item :match_path option and URL by @mamhoff in https://github.com/solidusio/solidus/pull/5152

## Solidus API
* Relax rubocop version requirement and add it to the CI by @elia in https://github.com/solidusio/solidus/pull/5075
* Allow running bin/rails from Solidus engines by @elia in https://github.com/solidusio/solidus/pull/5164

## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.0.0...v4.1.0


## Solidus v4.0.4 (2023-11-02)

## Solidus Core
* [v4.0] Add activestorage as dependency by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5481

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.0.3...v4.0.4


## Solidus v4.0.3 (2023-11-01)

## Solidus Core
* [v4.0] Do not require active_storage/engine by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5454

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.0.2...v4.0.3


## Solidus v4.0.2 (2023-08-14)

## Solidus Core
* [v4.0] Update deprecation horizon by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5306
* [v4.0] Bump the minimum required Psych version by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5326
* [v4.0] Fix error added when resetting order flow on an empty order by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5335

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.0.1...v4.0.2


## Solidus v4.0.1 (2023-06-30)

## Solidus Core
* [v4.0] Don't gsub attachment comment during solidus installation by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5090
* [v4.0] Make Spree::MigrationHelpers Ruby 3.0 compatible by @github-actions[bot] in https://github.com/solidusio/solidus/pull/5098
* [v4.0] Fix Taxon taxonomy id validation regression @github-actions[bot] in https://github.com/solidusio/solidus/pull/5191

## Solidus Backend


## Solidus API


## Solidus Sample


## Solidus


**Full Changelog**: https://github.com/solidusio/solidus/compare/v4.0.0...v4.0.1


## Solidus v4.0.0 (2023-05-04)

## Solidus Core
* Remove `solidus_frontend` from the meta gem by @elia in https://github.com/solidusio/solidus/pull/5026
* Remove support for deprecated promo rules matching policy by @kennyadsl in https://github.com/solidusio/solidus/pull/5019
* Remove Deprecated code from API component by @kennyadsl in https://github.com/solidusio/solidus/pull/5020
* Remove Deprecated Preferences by @kennyadsl in https://github.com/solidusio/solidus/pull/5022
* Remove Deprecated code from Core component by @kennyadsl in https://github.com/solidusio/solidus/pull/4989
* Remove deprecated order updater promotions code by @mamhoff in https://github.com/solidusio/solidus/pull/4890
* Remove support for the legacy frontend names by @elia in https://github.com/solidusio/solidus/pull/5031
* Remove support for legacy event system by @kennyadsl in https://github.com/solidusio/solidus/pull/5024
* Remove deprecated factories usage by @kennyadsl in https://github.com/solidusio/solidus/pull/5023
* Only support for Ruby v3 and Rails v7 by @elia in https://github.com/solidusio/solidus/pull/5012
* Add `stripe` to payment methods by @elia in https://github.com/solidusio/solidus/pull/5007
* Remove stale warning about paypal not being fully supported by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5044
* Remove solidus_frontend option from the installer by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5047
* Drop unused table promotion_action_line_items by @mamhoff in https://github.com/solidusio/solidus/pull/4882
* Remove unused columns from spree_promotion_rules by @mamhoff in https://github.com/solidusio/solidus/pull/4881
* Remove position column from spree_taxons by @mamhoff in https://github.com/solidusio/solidus/pull/4754
* Make option value to variant association unique by @jarednorman in https://github.com/solidusio/solidus/pull/4146
* Allow to disable track inventory for product without variants by @tvdeyen in https://github.com/solidusio/solidus/pull/5039
* Remove deprecated_address_id column from shipments by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4379
* Deprecate other code related to old factories loading by @kennyadsl in https://github.com/solidusio/solidus/pull/5059
* Fix generating the dummy app for extensions using solidus_frontend by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5060
* Remove deprecated spree/testing_support file by @kennyadsl in https://github.com/solidusio/solidus/pull/5063

## Solidus Backend
* Remove support for deprecated promo rules matching policy by @kennyadsl in https://github.com/solidusio/solidus/pull/5019
* Remove Deprecated code from Backend component by @kennyadsl in https://github.com/solidusio/solidus/pull/5021
* Only support for Ruby v3 and Rails v7 by @elia in https://github.com/solidusio/solidus/pull/5012
* Allow to disable track inventory for product without variants by @tvdeyen in https://github.com/solidusio/solidus/pull/5039

## Solidus API
* Remove support for deprecated promo rules matching policy by @kennyadsl in https://github.com/solidusio/solidus/pull/5019
* Remove Deprecated code from API component by @kennyadsl in https://github.com/solidusio/solidus/pull/5020
* Only support for Ruby v3 and Rails v7 by @elia in https://github.com/solidusio/solidus/pull/5012
* Skip two randomly failing tests on SQLite by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5046

## Solidus Sample
* Only support for Ruby v3 and Rails v7 by @elia in https://github.com/solidusio/solidus/pull/5012
* Remove position column from spree_taxons by @mamhoff in https://github.com/solidusio/solidus/pull/4754

## Solidus
* Remove `solidus_frontend` from the meta gem by @elia in https://github.com/solidusio/solidus/pull/5026
* Only support for Ruby v3 and Rails v7 by @elia in https://github.com/solidusio/solidus/pull/5012

**Full Changelog**: https://github.com/solidusio/solidus/compare/v3.4.0...v4.0.0


## Solidus v3.4.0 (2023-04-21)

## Solidus Core
* Stop using RSpec is_expected with block expectations by @kennyadsl in https://github.com/solidusio/solidus/pull/4870
* Fetch solidus_frontend from RubyGems instead of GitHub by @gsmendoza in https://github.com/solidusio/solidus/pull/4885
* Fix CI only testing with the legacy event system adapter by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4880
* Update the SolidusFrontend dependency to 3.4.0.dev by @gsmendoza in https://github.com/solidusio/solidus/pull/4889
* Retry flaky specs automatically by @kennyadsl in https://github.com/solidusio/solidus/pull/4893
* Fix publishing events responding to #to_hash on Ruby 2.7 by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4875
* ERB fixes for the backend (🐛+💅) by @elia in https://github.com/solidusio/solidus/pull/4891
* Risk analysis box update by @elia in https://github.com/solidusio/solidus/pull/4883
* Fix CI only testing with the paperclip adapter by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4905
* Fix AddPaymentSourcesToWallet changing default when reused by @RyanofWoods in https://github.com/solidusio/solidus/pull/4198
* Fix duplicate context name in spec by @FrancescoAiello01 in https://github.com/solidusio/solidus/pull/4925
* Apply store credits before creating payments by @ccarruitero in https://github.com/solidusio/solidus/pull/4667
* Use i18n for datepicker format by @coorasse in https://github.com/solidusio/solidus/pull/3321
* Fix flaky spec helper for local testing by @kennyadsl in https://github.com/solidusio/solidus/pull/4948
* Ensure LogEntry only saves safe data by @elia in https://github.com/solidusio/solidus/pull/4950
* Allow bad payloads to be saved in payment log entries by @elia in https://github.com/solidusio/solidus/pull/4953
* Add back Variant#find_or_build_default_price by @spaghetticode in https://github.com/solidusio/solidus/pull/4960
* Ensure target shipments are evaluated in order of creation (fix flakey) by @elia in https://github.com/solidusio/solidus/pull/4954
* Introduce allowed_ransackable_scopes by @RyanofWoods in https://github.com/solidusio/solidus/pull/4956
* Copy new migrations as part of the update task by @kennyadsl in https://github.com/solidusio/solidus/pull/4957
* Update Spree::Product scopes.rb to fix issue with 'descend_by_popularity' scope by @cmbaldwin in https://github.com/solidusio/solidus/pull/4969
* Spree::ProductDuplicator bug on price by @Roddoric in https://github.com/solidusio/solidus/pull/4971
* Update descend_by_popularity scope spec by @kennyadsl in https://github.com/solidusio/solidus/pull/4979
* Allow splitting shipments when not tracking inventory by @nspinazz89 in https://github.com/solidusio/solidus/pull/3338
* Fix rake error testing the update generator by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4980
* Improve Taxon validations and factory by @RyanofWoods in https://github.com/solidusio/solidus/pull/4851
* Add a deprecation warning for allow_promotions_any_match_policy = true by @kennyadsl in https://github.com/solidusio/solidus/pull/4991
* Add Braintree to the installer as a payment method option by @gsmendoza in https://github.com/solidusio/solidus/pull/4961
* Fix typo in shipmnent.rb by @seand7565 in https://github.com/solidusio/solidus/pull/5004
* Deprecate `Spree::Payment` offsets by @waiting-for-dev in https://github.com/solidusio/solidus/pull/5008
* Add a tooltip for default currency in store settings by @kennyadsl in https://github.com/solidusio/solidus/pull/5009
* Allow to set order_update_attributes_class by @tvdeyen in https://github.com/solidusio/solidus/pull/4955
* Remove automatic propagation of generators options by @kennyadsl in https://github.com/solidusio/solidus/pull/5011
* Mark FulfilmentChanger::TRACK_INVENTORY_NOT_PROVIDED as private by @kennyadsl in https://github.com/solidusio/solidus/pull/5028

## Solidus Backend
* Fix sticky admin nav on long menu by @MassimilianoLattanzio in https://github.com/solidusio/solidus/pull/4884
* Deprecate `Admin::OrdersHelper#line_item_shipment_price` by @elia in https://github.com/solidusio/solidus/pull/4876
* Improve Product Details tab layout by @davidedistefano in https://github.com/solidusio/solidus/pull/4892
* Retry flaky specs automatically by @kennyadsl in https://github.com/solidusio/solidus/pull/4893
* Add the `/admin/orders/:number` route by @elia in https://github.com/solidusio/solidus/pull/4886
* ERB fixes for the backend (🐛+💅) by @elia in https://github.com/solidusio/solidus/pull/4891
* Risk analysis box update by @elia in https://github.com/solidusio/solidus/pull/4883
* Mark another spec as flaky by @kennyadsl in https://github.com/solidusio/solidus/pull/4946
* Use i18n for datepicker format by @coorasse in https://github.com/solidusio/solidus/pull/3321
* Improve REST OpenAPI documentation for auth by @kennyadsl in https://github.com/solidusio/solidus/pull/4951
* Allow splitting shipments when not tracking inventory by @nspinazz89 in https://github.com/solidusio/solidus/pull/3338
* Authorize uuid for update_positions on ResourceController by @julienanne in https://github.com/solidusio/solidus/pull/4992
* Add a tooltip for default currency in store settings by @kennyadsl in https://github.com/solidusio/solidus/pull/5009

## Solidus API
* Add a better description for the api key to Stoplight  by @vassalloandrea in https://github.com/solidusio/solidus/pull/4847
* Link to how to sign in the API with solidus_auth_devise by @waiting-for-dev in https://github.com/solidusio/solidus/pull/4900
* Ensure LogEntry only saves safe data by @elia in https://github.com/solidusio/solidus/pull/4950
* Improve REST OpenAPI documentation for auth by @kennyadsl in https://github.com/solidusio/solidus/pull/4951
* Remove order token authorization option from current order API documentation by @Jackwitwicky in https://github.com/solidusio/solidus/pull/4958
* Allow splitting shipments when not tracking inventory by @nspinazz89 in https://github.com/solidusio/solidus/pull/3338
* Allow to set order_update_attributes_class by @tvdeyen in https://github.com/solidusio/solidus/pull/4955

## Solidus Sample
* Reduce size of sample images by @F-Hamid in https://github.com/solidusio/solidus/pull/4924

## Solidus
* Update the SolidusFrontend dependency to 3.4.0.dev by @gsmendoza in https://github.com/solidusio/solidus/pull/4889
* fix: update Nebulab missing logo asset reference by @Agostin in https://github.com/solidusio/solidus/pull/5025

**Full Changelog**: https://github.com/solidusio/solidus/compare/v3.3.0...v3.4.0


## Solidus v3.3.0 (2023-01-24)

## Solidus Core
- Add coverage report badge using Codecov [#3136](https://github.com/solidusio/solidus/pull/3136) ([@rubenochiavone](https://github.com/rubenochiavone))
- Prevent UI crash on FileNotFound errors with Active Storage [#4103](https://github.com/solidusio/solidus/pull/4103) ([@cpfergus1](https://github.com/cpfergus1))
- Fix Country factory states_required attribute [#4272](https://github.com/solidusio/solidus/pull/4272) ([@RyanofWoods](https://github.com/RyanofWoods))
- Configurable promotion adjuster [#4460](https://github.com/solidusio/solidus/pull/4460) ([@mamhoff](https://github.com/mamhoff))
- Support for Colorado Delivery Fee (flat fee and order-level taxes) [#4491](https://github.com/solidusio/solidus/pull/4491) ([@adammathys](https://github.com/adammathys))
- Add eligibility check to free shipping action [#4515](https://github.com/solidusio/solidus/pull/4515) ([@seand7565](https://github.com/seand7565))
- Add a SQLite job to the CI [#4525](https://github.com/solidusio/solidus/pull/4525) ([@elia](https://github.com/elia))
- Deprecate method #redirect_back_or_default [#4533](https://github.com/solidusio/solidus/pull/4533) ([@cpfergus1](https://github.com/cpfergus1))
- Cleanup Gemfile groups [#4537](https://github.com/solidusio/solidus/pull/4537) ([@elia](https://github.com/elia))
- Only default to activestorage adapter if Rails version is supported [#4563](https://github.com/solidusio/solidus/pull/4563) ([@tvdeyen](https://github.com/tvdeyen))
- Delegate `--auto-accept` installer option to solidus_frontend [#4608](https://github.com/solidusio/solidus/pull/4608) ([@waiting-for-dev](https://github.com/waiting-for-dev))
- Don't remove non-accessible roles when assigning new accessible roles [#4609](https://github.com/solidusio/solidus/pull/4609) ([@waiting-for-dev](https://github.com/waiting-for-dev))
- Frontend installers with app-templates [#4629](https://github.com/solidusio/solidus/pull/4629) ([@elia](https://github.com/elia))
- `solidus:install` improvements [#4637](https://github.com/solidusio/solidus/pull/4637) ([@elia](https://github.com/elia))
- Fix variant price performance regressions  [#4639](https://github.com/solidusio/solidus/pull/4639) ([@mamhoff](https://github.com/mamhoff))
- Improve variant spec coverage [#4642](https://github.com/solidusio/solidus/pull/4642) ([@mamhoff](https://github.com/mamhoff))
- Fix the dummy app usage of the generator [#4646](https://github.com/solidusio/solidus/pull/4646) ([@elia](https://github.com/elia))
- Use app-templates to handle authentication options in the installer [#4654](https://github.com/solidusio/solidus/pull/4654) ([@elia](https://github.com/elia))
- Add back the `--payment-method` option for `solidus:install` [#4659](https://github.com/solidusio/solidus/pull/4659) ([@elia](https://github.com/elia))
- Make --authentication=none the same as --with-authentication=false [#4670](https://github.com/solidusio/solidus/pull/4670) ([@elia](https://github.com/elia))
- Installer UI improvements [#4675](https://github.com/solidusio/solidus/pull/4675) ([@elia](https://github.com/elia))
- Add support for sorting store credits with different algorithms [#4677](https://github.com/solidusio/solidus/pull/4677) ([@tmtrademarked](https://github.com/tmtrademarked))
- Add flexible with_adjustable_action trait to Promotion factory [#4682](https://github.com/solidusio/solidus/pull/4682) ([@RyanofWoods](https://github.com/RyanofWoods))
- Install and set up Buildkite Test Analytics [#4688](https://github.com/solidusio/solidus/pull/4688) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove typo from warning about solidus migration check [#4704](https://github.com/solidusio/solidus/pull/4704) ([@jacobherrington](https://github.com/jacobherrington))
- Deprecate unused `Spree::Config#mails_from` [#4712](https://github.com/solidusio/solidus/pull/4712) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Fix call context when a preference default is a proc [#4721](https://github.com/solidusio/solidus/pull/4721) ([@Roddoric](https://github.com/Roddoric))
- Improve Spree::Order::NumberGenerator speed [#4722](https://github.com/solidusio/solidus/pull/4722) ([@RyanofWoods](https://github.com/RyanofWoods))
- Allow shipping category on variants [#4739](https://github.com/solidusio/solidus/pull/4739) ([@tvdeyen](https://github.com/tvdeyen))
- Do not require 'mail' [#4740](https://github.com/solidusio/solidus/pull/4740) ([@tvdeyen](https://github.com/tvdeyen))
- Add back PayPal as a payment method for the starter frontend [#4743](https://github.com/solidusio/solidus/pull/4743) ([@elia](https://github.com/elia))
- Remove trailing zeroes in tax amount [#4758](https://github.com/solidusio/solidus/pull/4758) ([@Naokimi](https://github.com/Naokimi))
- Fix typo s/loout/logout/ [#4825](https://github.com/solidusio/solidus/pull/4825) ([@chrean](https://github.com/chrean))
- Revert "Remove trailing zeroes in tax amount" [#4824](https://github.com/solidusio/solidus/pull/4824) ([@tvdeyen](https://github.com/tvdeyen))
- Add a default implementation for PaymentMethod#try_void [#4843](https://github.com/solidusio/solidus/pull/4843) ([@kennyadsl](https://github.com/kennyadsl))
- Remove Ruby v2.5 support [#4845](https://github.com/solidusio/solidus/pull/4845) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Ruby v2.6 support [#4848](https://github.com/solidusio/solidus/pull/4848) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Rails v5.2 support [#4850](https://github.com/solidusio/solidus/pull/4850) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Use `call` in the adjustments recalculator's interface [#4855](https://github.com/solidusio/solidus/pull/4855) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Improve ransackable attribute class method names [#4853](https://github.com/solidusio/solidus/pull/4853) ([@RyanofWoods](https://github.com/RyanofWoods))
- Revert the deprecation of `#redirect_back_or_default` method [#4856](https://github.com/solidusio/solidus/pull/4856) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Raise a custom extension passing invalid search params [#4844](https://github.com/solidusio/solidus/pull/4844) ([@kennyadsl](https://github.com/kennyadsl))
- Provide transaction_id and source in try_void [#4859](https://github.com/solidusio/solidus/pull/4859) ([@kennyadsl](https://github.com/kennyadsl))
- Improve Ransackable attribute class methods usage [#4857](https://github.com/solidusio/solidus/pull/4857) ([@RyanofWoods](https://github.com/RyanofWoods))
- Add available to Product.ransackable_scopes [#4852](https://github.com/solidusio/solidus/pull/4852) ([@RyanofWoods](https://github.com/RyanofWoods))
- Spree::Payment::Processing refactor [#4823](https://github.com/solidusio/solidus/pull/4823) ([@elia](https://github.com/elia))
- Improve Bogus (test) Credit Card voiding [#4861](https://github.com/solidusio/solidus/pull/4861) ([@kennyadsl](https://github.com/kennyadsl))
- Allow storing static preferences using string class names [#4858](https://github.com/solidusio/solidus/pull/4858) ([@elia](https://github.com/elia))
- Get the paypal payment method option out of pre-release [#4865](https://github.com/solidusio/solidus/pull/4865) ([@elia](https://github.com/elia))

## Solidus Backend
- Add coverage report badge using Codecov [#3136](https://github.com/solidusio/solidus/pull/3136) ([@rubenochiavone](https://github.com/rubenochiavone))
- Support for Colorado Delivery Fee (flat fee and order-level taxes) [#4491](https://github.com/solidusio/solidus/pull/4491) ([@adammathys](https://github.com/adammathys))
- Don't remove non-accessible roles when assigning new accessible roles [#4609](https://github.com/solidusio/solidus/pull/4609) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Update deprecated jQuery methods [#4625](https://github.com/solidusio/solidus/pull/4625) ([@cpfergus1](https://github.com/cpfergus1))
- Fix variant price performance regressions  [#4639](https://github.com/solidusio/solidus/pull/4639) ([@mamhoff](https://github.com/mamhoff))
- [FIX] Emptying cart will update the order summary [#4655](https://github.com/solidusio/solidus/pull/4655) ([@maniSHarma7575](https://github.com/maniSHarma7575))
- Update underscore.js [#4660](https://github.com/solidusio/solidus/pull/4660) ([@ccarruitero](https://github.com/ccarruitero))
- Paginate variant autocomplete [#4661](https://github.com/solidusio/solidus/pull/4661) ([@tvdeyen](https://github.com/tvdeyen))
- Install and set up Buildkite Test Analytics [#4688](https://github.com/solidusio/solidus/pull/4688) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Do not pass arrays to can? [#4705](https://github.com/solidusio/solidus/pull/4705) ([@jacobherrington](https://github.com/jacobherrington))
- Revert jQuery changes to xhr var in image upload [#4707](https://github.com/solidusio/solidus/pull/4707) ([@cpfergus1](https://github.com/cpfergus1))
- Allow shipping category on variants [#4739](https://github.com/solidusio/solidus/pull/4739) ([@tvdeyen](https://github.com/tvdeyen))
- Remove trailing zeroes in tax amount [#4758](https://github.com/solidusio/solidus/pull/4758) ([@Naokimi](https://github.com/Naokimi))
- Improve variant and product autocomplete functions flexibility with Ransack [#4767](https://github.com/solidusio/solidus/pull/4767) ([@RyanofWoods](https://github.com/RyanofWoods))
- Fix styling of table rows for deleted records [#4833](https://github.com/solidusio/solidus/pull/4833) ([@tvdeyen](https://github.com/tvdeyen))
- Hide soft deleted prices from admin product view [#4832](https://github.com/solidusio/solidus/pull/4832) ([@tvdeyen](https://github.com/tvdeyen))
- Pre-add the default store to new payment methods [#4828](https://github.com/solidusio/solidus/pull/4828) ([@elia](https://github.com/elia))
- Remove Ruby v2.5 support [#4845](https://github.com/solidusio/solidus/pull/4845) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Ruby v2.6 support [#4848](https://github.com/solidusio/solidus/pull/4848) ([@waiting-for-dev](https://github.io/waiting-for-dev))

## Solidus API
- Add coverage report badge using Codecov [#3136](https://github.com/solidusio/solidus/pull/3136) ([@rubenochiavone](https://github.com/rubenochiavone))
- Prevent UI crash on FileNotFound errors with Active Storage [#4103](https://github.com/solidusio/solidus/pull/4103) ([@cpfergus1](https://github.com/cpfergus1))
- Fix Country factory states_required attribute [#4272](https://github.com/solidusio/solidus/pull/4272) ([@RyanofWoods](https://github.com/RyanofWoods))
- Add a SQLite job to the CI [#4525](https://github.com/solidusio/solidus/pull/4525) ([@elia](https://github.com/elia))
- `solidus:install` improvements [#4637](https://github.com/solidusio/solidus/pull/4637) ([@elia](https://github.com/elia))
- [FIX] Emptying cart will update the order summary [#4655](https://github.com/solidusio/solidus/pull/4655) ([@maniSHarma7575](https://github.com/maniSHarma7575))
- Install and set up Buildkite Test Analytics [#4688](https://github.com/solidusio/solidus/pull/4688) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Deprecate unused `Spree::Config#mails_from` [#4712](https://github.com/solidusio/solidus/pull/4712) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Allow shipping category on variants [#4739](https://github.com/solidusio/solidus/pull/4739) ([@tvdeyen](https://github.com/tvdeyen))
- Improve variant and product autocomplete functions flexibility with Ransack [#4767](https://github.com/solidusio/solidus/pull/4767) ([@RyanofWoods](https://github.com/RyanofWoods))
- Remove Ruby v2.5 support [#4845](https://github.com/solidusio/solidus/pull/4845) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Ruby v2.6 support [#4848](https://github.com/solidusio/solidus/pull/4848) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Rails v5.2 support [#4850](https://github.com/solidusio/solidus/pull/4850) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Improve ransackable attribute class method names [#4853](https://github.com/solidusio/solidus/pull/4853) ([@RyanofWoods](https://github.com/RyanofWoods))

## Solidus Sample
- Fix occasional "database is locked" errors while loading sample data [#4648](https://github.com/solidusio/solidus/pull/4648) ([@elia](https://github.com/elia))
- Update product_option_types Seed File [#4680](https://github.com/solidusio/solidus/pull/4680) ([@Naokimi](https://github.com/Naokimi))
- Remove Ruby v2.5 support [#4845](https://github.com/solidusio/solidus/pull/4845) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Ruby v2.6 support [#4848](https://github.com/solidusio/solidus/pull/4848) ([@waiting-for-dev](https://github.io/waiting-for-dev))

## Solidus
- Be explicit about the solidus_frontend gemspec dependency [#4818](https://github.com/solidusio/solidus/pull/4818) ([@kennyadsl](https://github.com/kennyadsl))
- Remove Ruby v2.5 support [#4845](https://github.com/solidusio/solidus/pull/4845) ([@waiting-for-dev](https://github.io/waiting-for-dev))
- Remove Ruby v2.6 support [#4848](https://github.com/solidusio/solidus/pull/4848) ([@waiting-for-dev](https://github.io/waiting-for-dev))

**Full Changelog**: https://github.com/solidusio/solidus/compare/v3.2.0...v3.3.0


## Solidus 3.2.4 (v3.2, 2022-11-09)

- Revert jQuery changes to xhr var in image upload [#4708](https://github.com/solidusio/solidus/pull/4708) ([@cpfergus1](https://github.com/cpfergus1))
- Fix variant price performance regressions [#4690](https://github.com/solidusio/solidus/pull/4690) ([@mamhoff](https://github.com/mamhoff))

## Solidus 3.2.3 (v3.2, 2022-11-03)

- Paginate variant autocomplete [#4662](https://github.com/solidusio/solidus/pull/4662) ([@tvdeyen](https://github.com/tvdeyen))
- Update deprecated jQuery methods [#4674](https://github.com/solidusio/solidus/pull/4674) ([@elia](https://github.com/elia))
- Restore `--payment-method=` for `solidus:install` on v3.2 [#4673](https://github.com/solidusio/solidus/pull/4673) ([@elia](https://github.com/elia))
- Ensure puma 6 is not used in development [#4692](https://github.com/solidusio/solidus/pull/4692) ([@elia](https://github.com/elia))
- make frontend installer shell-out commands more compatible [#4694](https://github.com/solidusio/solidus/pull/4694) ([@elia](https://github.com/elia))
- Fix `nil` bundle_path while installing solidus_frontend [#4697](https://github.com/solidusio/solidus/pull/4697) ([@elia](https://github.com/elia))

## Solidus 3.2.2 (v3.2, 2022-09-09)

- Don't remove non-accessible roles when assigning new accessible roles ([waiting-for-dev](https://github.com/waiting-for-dev))
- Delegate `--auto-accept` installer option to solidus_frontend ([waiting-for-dev](https://github.com/waiting-for-dev))

## Solidus 3.2.1 (v3.2, 2022-09-09)

- [v3.2] Only default to activestorage adapter if Rails version is supported [#4564](https://github.com/solidusio/solidus/pull/4564) ([tvdeyen](https://github.com/tvdeyen))
- Remove duplicated attributes from API docs ([kennyadsl](https://github.com/kennyadsl))

## Solidus 3.2.0 (v3.2, 2022-08-18)

Remember to run `bin/rails g solidus:update` to support you during the upgrade
process.

You can read more about how to [upgrade
solidus](https://edgeguides.solidus.io/getting-started/upgrading-solidus/) in
our guides.

### Major changes

#### New Event Bus

A completely new Event Bus has been introduced. It has better support for async
subscribers, testability, observability, and many other features. It's been
developed as a separated gem, [omnes](https://github.com/nebulab/omnes). Check
its README for everything it supports!

Don't forget to consult the [upgrade guide from the legacy event system to
omnes](https://edgeguides.solidus.io/customization/subscribing-to-events#upgrading-from-the-legacy-event-system).

While the legacy event system is still supported, it'll be removed on Solidus
v4.

#### New Solidus' starter frontend

For fresh Solidus applications, we now recommend you use
[solidus_starter_frontend](https://github.com/solidusio/solidus_starter_frontend).

solidus_frontend will be removed from the solidus meta-package gem in Solidus
v4. Furthermore, its code has been extracted from
https://github.com/solidusio/solidus to
https://github.com/solidusio/solidus_frontend. Once removed, you'll need to
explicitly add `solidus_frontend` to your Gemfile in order to continue using
it.

Meanwhile, the Solidus installer allows you to choose which one you want to use
as the storefront.

#### New guides

The guides that used to live at `solidusio/solidus` have been deprecated. You
can still find them at https://github.com/solidusio/legacy-guides, but a great
effort is in progress to make first-class documentation on
https://github.com/solidusio/edgeguides.

You can check them live in https://edgeguides.solidus.io/.

### Other important changes

#### No more autoload of decorators in fresh applications

New Solidus applications won't autoload files matching `app/**/*_decorator*.rb`
pattern anymore. For previous Solidus applications, it's something that will
keep working as the responsible code was added to your `config/application.rb`
when Solidus was installed. That code is intended to work with Rails' classic
autoloader, deprecated on Rails 6 and removed on Rails 7. It keeps working
because of a [compatibility
layer](https://github.com/rails/rails/blob/296ef7a17221e81881e38b51aa2b014d7a28bac5/activesupport/lib/active_support/dependencies/require_dependency.rb)
which is also deprecated. However, it may be eventually removed, so you're
better off updating your `application.rb`  file. You should substitute:

```ruby
config.to_prepare do
  Dir.glob(Rails.root.join('app/**/*_decorator*.rb')) do |path|
    require_dependency(path)
  end
end
```

With:

```ruby
overrides = "#{Rails.root}/app/overrides" # use your actual directory here
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_decorator*.rb").each do |override|
    load override
  end
end
```

You may also want to stop using the `decorator` naming, as it's no longer part
of Solidus recommendations (that files are monkey patches; they don't use the
[decorator pattern](https://en.wikipedia.org/wiki/Decorator_pattern)). E.g.,
you can place those files in `app/overrides/` and remove the `decorator`
suffix.

> ## 🚧 **WARNING** 🚧
>
> If you have [deface](https://github.com/spree/deface) as one of your dependencies, the `app/overrides` path
> interferes with the directory it uses to load its overrides. To avoid
> double-loading and other issues, you should use a different directory. A
> good candidate could be `app/monkey_patches`.

#### Changes to the promotion system

Promotions with a `match_policy` of `any` are deprecated. If you have promotions
with such a match policy, try running the following rake task:

```bash
bin/rake solidus:split_promotions_with_any_match_policy
```

This will create separate promotions for each of the rules of your promotions with `any`
match policy, which should have the same outcome for customers.

Creating new promotions with `any` match policy is turned off by default. If you still want
to create promotions like that (knowing they will not be supported in the future), you can
set a temporary flag in your `config/initializers/spree.rb` file:

```ruby
# Allow creating new promotions with an `any` match policy. Unsupported in the future.
config.allow_promotions_any_match_policy = true
```

#### Static preference sources configured within `.to_prepare` blocks

[Rails 7 no longer supports referring autoloadable classes within an
initializer](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoload-on-boot-and-on-each-reload).

Because of that, we need to change the way we configure static preference sources.

Before:

```ruby
# config/initializers/spree.rb
Spree.config do |config|
  config.static_model_preferences.add(
    AmazingStore::AmazingPaymentMethod,
    'amazing_payment_method_credentials',
    credentials: ENV['AMAZING_PAYMENT_METHOD_CREDENTIALS'],
    server: Rails.env.production? ? 'production' : 'test',
    test_mode: !Rails.env.production?
  )
end
```

Now:

```ruby
# config/initializers/spree.rb
Rails.application.config.to_prepare do
  Spree::Config.static_model_preferences.add(
    AmazingStore::AmazingPaymentMethod,
    'amazing_payment_method_credentials',
    credentials: ENV['AMAZING_PAYMENT_METHOD_CREDENTIALS'],
    server: Rails.env.production? ? 'production' : 'test',
    test_mode: !Rails.env.production?
  )
end
```

### Core

- Monkey patch Authentication Bypass by CSRF Weakness vulnerability on solidus_auth_devise for extra security [GHSA-5629-8855-gf4g](https://github.com/solidusio/solidus/security/advisories/GHSA-5629-8855-gf4g)
- Fix ReDos vulnerability on Spree::EmailValidator::EMAIL_REGEXP [GHSA-qxmr-qxh6-2cc9](https://github.com/solidusio/solidus/security/advisories/GHSA-qxmr-qxh6-2cc9)
- Fix CSRF forgery protection bypass for Spree::OrdersController#populate [GHSA-h3fg-h5v3-vf8m](https://github.com/solidusio/solidus/security/advisories/GHSA-h3fg-h5v3-vf8m)
- Introduce a configuration value for `migration_path` [#4190](https://github.com/solidusio/solidus/pull/4190) ([forkata](https://github.com/forkata))
- Deprecate Promotion `any` Match Policy [#4304](https://github.com/solidusio/solidus/pull/4304) ([mamhoff](https://github.com/mamhoff))
- Fix key in the locale file [#4512](https://github.com/solidusio/solidus/pull/4512) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Run auth generator when starter frontend installs the gem [#4511](https://github.com/solidusio/solidus/pull/4511) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Translate price country names [#4508](https://github.com/solidusio/solidus/pull/4508) ([tvdeyen](https://github.com/tvdeyen))
- Tweaks for the Solidus installer [#4504](https://github.com/solidusio/solidus/pull/4504) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Include discarded prices in delete_prices_with_nil_amount task [#4495](https://github.com/solidusio/solidus/pull/4495) ([spaghetticode](https://github.com/spaghetticode))
- Remove PayPal as an option during the installation process [#4494](https://github.com/solidusio/solidus/pull/4494) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Deprecate solidus_frontend & allow installing solidus_starter_frontend [#4490](https://github.com/solidusio/solidus/pull/4490) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix incorrect validation message for missing store credit category [#4481](https://github.com/solidusio/solidus/pull/4481) ([johnpitchko](https://github.com/johnpitchko))
- Add basic support for order-level taxes [#4477](https://github.com/solidusio/solidus/pull/4477) ([adammathys](https://github.com/adammathys))
- Allow to extend user deletion logic [#4471](https://github.com/solidusio/solidus/pull/4471) ([tvdeyen](https://github.com/tvdeyen))
- Fix stores with no authentication [#4456](https://github.com/solidusio/solidus/pull/4456) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Support CVE-2022-32224 Rails security updates [#4451](https://github.com/solidusio/solidus/pull/4451) ([gsmendoza](https://github.com/gsmendoza))
- Support code reloading when configuring static preferences sources [#4449](https://github.com/solidusio/solidus/pull/4449) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Deprecate Ruby 2.5 & Ruby 2.6 [#4442](https://github.com/solidusio/solidus/pull/4442) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Deprecate Rails 5.2 [#4439](https://github.com/solidusio/solidus/pull/4439) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Sanitize i18n keys using i18n-tasks gem issue: #3978 [#4437](https://github.com/solidusio/solidus/pull/4437) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Update CircleCI configuration [#4435](https://github.com/solidusio/solidus/pull/4435) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fail with `raise` when the storage adapter is not supported [#4434](https://github.com/solidusio/solidus/pull/4434) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Skip failing test because of unsupported feature on Rails < 6.1 [#4432](https://github.com/solidusio/solidus/pull/4432) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix Order#tax_address method [#4429](https://github.com/solidusio/solidus/pull/4429) ([spaghetticode](https://github.com/spaghetticode))
- Add display shipment total before tax [#4423](https://github.com/solidusio/solidus/pull/4423) ([mamhoff](https://github.com/mamhoff))
- Fix deprecation of active payment methods [#4414](https://github.com/solidusio/solidus/pull/4414) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix: common:test_app should change Rails.env to test [#4411](https://github.com/solidusio/solidus/pull/4411) ([gsmendoza](https://github.com/gsmendoza))
- Only install ActiveStorage adapter on supported Rails versions [#4402](https://github.com/solidusio/solidus/pull/4402) ([tvdeyen](https://github.com/tvdeyen))
- Fix user restricted stock management v3.1 [#4400](https://github.com/solidusio/solidus/pull/4400) ([rmparr](https://github.com/rmparr))
- Make more stock classes configurable [#4395](https://github.com/solidusio/solidus/pull/4395) ([jarednorman](https://github.com/jarednorman))
- Fix creating store credit with amount in foreign format [#4390](https://github.com/solidusio/solidus/pull/4390) ([tvdeyen](https://github.com/tvdeyen))
- Allow user stock locations to be deleted [#4389](https://github.com/solidusio/solidus/pull/4389) ([rmparr](https://github.com/rmparr))
- Deprecate duplicated variant routes [#4388](https://github.com/solidusio/solidus/pull/4388) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Add missing sprockets-rails dependency [#4382](https://github.com/solidusio/solidus/pull/4382) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix issues loading serialized logs [#4376](https://github.com/solidusio/solidus/pull/4376) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix update generator taking non-comparable values as changes in a default [#4375](https://github.com/solidusio/solidus/pull/4375) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Add flexibility to `Spree::Order#restart_checkout_flow` [#4369](https://github.com/solidusio/solidus/pull/4369) ([spaghetticode](https://github.com/spaghetticode))
- Support for Ruby 3.1 [#4366](https://github.com/solidusio/solidus/pull/4366) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Readd `config.cache_classes` on test env and remove `with_model` dep [#4358](https://github.com/solidusio/solidus/pull/4358) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix creating refund with amount in foreign format [#4344](https://github.com/solidusio/solidus/pull/4344) ([tvdeyen](https://github.com/tvdeyen))
- Use Omnes for pub/sub [#4342](https://github.com/solidusio/solidus/pull/4342) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Respect new preloader API in Rails 7 [#4338](https://github.com/solidusio/solidus/pull/4338) ([mamhoff](https://github.com/mamhoff))
- Update in-memory shipments of order in order_shipping [#4334](https://github.com/solidusio/solidus/pull/4334) ([tvdeyen](https://github.com/tvdeyen))
- Bugfix: Changing Default Addresses [#4332](https://github.com/solidusio/solidus/pull/4332) ([mamhoff](https://github.com/mamhoff))
- Fix install generator on namespaced extensions [#4327](https://github.com/solidusio/solidus/pull/4327) ([nvandoorn](https://github.com/nvandoorn))
- Fixes defining thumbnail sizes through ActiveStorage adapter [#4318](https://github.com/solidusio/solidus/pull/4318) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fixes using ActiveStorage adapter with libvips as variant processor [#4317](https://github.com/solidusio/solidus/pull/4317) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix flaky spec for Spree::ShippingMethod#available_to_store [#4313](https://github.com/solidusio/solidus/pull/4313) ([mamhoff](https://github.com/mamhoff))
- Allow kt-paperclip v7 [#4310](https://github.com/solidusio/solidus/pull/4310) ([tvdeyen](https://github.com/tvdeyen))
- Refactor promotion usage counts [#4307](https://github.com/solidusio/solidus/pull/4307) ([mamhoff](https://github.com/mamhoff))
- OrderInventory: Use variant stock items [#4303](https://github.com/solidusio/solidus/pull/4303) ([mamhoff](https://github.com/mamhoff))
- Fix: `extension:test_app` rake task should detect if Solidus engines are available [#4302](https://github.com/solidusio/solidus/pull/4302) ([gsmendoza](https://github.com/gsmendoza))
- OrderContents: Initialize line item with empty adjustments [#4286](https://github.com/solidusio/solidus/pull/4286) ([mamhoff](https://github.com/mamhoff))
- Promotion Rule CreateItemAdjustments: Use in-memory objects [#4285](https://github.com/solidusio/solidus/pull/4285) ([mamhoff](https://github.com/mamhoff))
- Deprecate Spree::PromotionRule.for [#4284](https://github.com/solidusio/solidus/pull/4284) ([mamhoff](https://github.com/mamhoff))
- Product Promotion Rule: Use in-memory objects [#4282](https://github.com/solidusio/solidus/pull/4282) ([mamhoff](https://github.com/mamhoff))
- Optimize Spree::PromotionHandler::Cart [#4281](https://github.com/solidusio/solidus/pull/4281) ([mamhoff](https://github.com/mamhoff))
- Remove n+1 in Spree::Tax::TaxLocation class [#4280](https://github.com/solidusio/solidus/pull/4280) ([mamhoff](https://github.com/mamhoff))
- Fix n+1 possibilities in Promotion#blacklisted? [#4275](https://github.com/solidusio/solidus/pull/4275) ([mamhoff](https://github.com/mamhoff))
- Replace expired GPG key for mysql install in dev Dockerfile [#4274](https://github.com/solidusio/solidus/pull/4274) ([nemeth](https://github.com/nemeth))
- Fix order create permissions [#4261](https://github.com/solidusio/solidus/pull/4261) ([spaghetticode](https://github.com/spaghetticode))
- Deprecate public visibility of order#finalize! [#4260](https://github.com/solidusio/solidus/pull/4260) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix test assertion due to staled cache [#4259](https://github.com/solidusio/solidus/pull/4259) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Relax Factory Bot version constraint [#4255](https://github.com/solidusio/solidus/pull/4255) ([jarednorman](https://github.com/jarednorman))
- Add public interface to fetch registered events [#4252](https://github.com/solidusio/solidus/pull/4252) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix: solidus:install adds the frontend assets even if the repo does not have solidus_frontend [#4251](https://github.com/solidusio/solidus/pull/4251) ([gsmendoza](https://github.com/gsmendoza))
- Cosmetic changes to the unknown event message [#4246](https://github.com/solidusio/solidus/pull/4246) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Stop generating code to autoload overrides [#4231](https://github.com/solidusio/solidus/pull/4231) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Accept nested addresses attributes for User [#4229](https://github.com/solidusio/solidus/pull/4229) ([kennyadsl](https://github.com/kennyadsl))
- Ensure promotion codes don't trigger ActiveRecord::RecordNotUnique errors on save [#4228](https://github.com/solidusio/solidus/pull/4228) ([jcsanti](https://github.com/jcsanti))
- Reintroduce inverse_of: :product for variants association [#4227](https://github.com/solidusio/solidus/pull/4227) ([spaghetticode](https://github.com/spaghetticode))
- Enforce event registration [#4226](https://github.com/solidusio/solidus/pull/4226) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Add Rails 7 support [#4220](https://github.com/solidusio/solidus/pull/4220) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Use default spree event adapter [#4216](https://github.com/solidusio/solidus/pull/4216) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Update warning with copy/pastable code [#4215](https://github.com/solidusio/solidus/pull/4215) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Add stubbing test helpers for the event bus [#4214](https://github.com/solidusio/solidus/pull/4214) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Use SSL on fonts.googleapis.com scss import [#4209](https://github.com/solidusio/solidus/pull/4209) ([RyanofWoods](https://github.com/RyanofWoods))
- Enable rubygems_mfa_required on solidus [#4206](https://github.com/solidusio/solidus/pull/4206) ([gsmendoza](https://github.com/gsmendoza))
- A couple of small fixes [#4205](https://github.com/solidusio/solidus/pull/4205) ([elia](https://github.com/elia))
- Introduce Spree::Event's test interface to run only selected listeners [#4204](https://github.com/solidusio/solidus/pull/4204) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Adds observability to the new event bus [#4203](https://github.com/solidusio/solidus/pull/4203) ([waiting-for-dev](https://github.com/waiting-for-dev))
- List order customer returns only once [#4196](https://github.com/solidusio/solidus/pull/4196) ([spaghetticode](https://github.com/spaghetticode))
- Fix discarded duplicated products bug [#4189](https://github.com/solidusio/solidus/pull/4189) ([Azeem838](https://github.com/Azeem838))
- Fix loading core on Rails < 6.1 [#4179](https://github.com/solidusio/solidus/pull/4179) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Centralize legacy event bus deprecation and test legacy on CI [#4176](https://github.com/solidusio/solidus/pull/4176) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Recalculate promotions after destroying/refreshing shipments [#4172](https://github.com/solidusio/solidus/pull/4172) ([spaghetticode](https://github.com/spaghetticode))
- Add deprecation path for arity-zero preference defaults [#4170](https://github.com/solidusio/solidus/pull/4170) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix shipping_method_spec test flakiness [#4169](https://github.com/solidusio/solidus/pull/4169) ([DianeLooney](https://github.com/DianeLooney))
- Respect completed_at timestamp in order factories [#4168](https://github.com/solidusio/solidus/pull/4168) ([DianeLooney](https://github.com/DianeLooney))
- Update install templates to use jquery3 (vulnerability fix) [#4167](https://github.com/solidusio/solidus/pull/4167) ([cpfergus1](https://github.com/cpfergus1))
- Fix staled upgrade instructions on the Gemfile's post-install message [#4166](https://github.com/solidusio/solidus/pull/4166) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix searching deleted products by SKU [#4164](https://github.com/solidusio/solidus/pull/4164) ([adammathys](https://github.com/adammathys))
- Change application-template generation script to use main branch [#4163](https://github.com/solidusio/solidus/pull/4163) ([kennyadsl](https://github.com/kennyadsl))
- Get Solidus ready for 3.2 [#4162](https://github.com/solidusio/solidus/pull/4162) ([kennyadsl](https://github.com/kennyadsl))
- Introduce new EventBus adapter [#4130](https://github.com/solidusio/solidus/pull/4130) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Adds conditional validation to `ReturnItem` [#4121](https://github.com/solidusio/solidus/pull/4121) ([Brian-Demon](https://github.com/Brian-Demon))
- Add global Spree::Config.default_email_regexp [#4022](https://github.com/solidusio/solidus/pull/4022) ([cesartalves](https://github.com/cesartalves))
- Deprecate try_spree_current_user [#3923](https://github.com/solidusio/solidus/pull/3923) ([elia](https://github.com/elia))
- Improve payment service providers switching errors [#3837](https://github.com/solidusio/solidus/pull/3837) ([luca-landa](https://github.com/luca-landa))

### API

- Sanitize i18n keys using i18n-tasks gem issue: #3978 [#4437](https://github.com/solidusio/solidus/pull/4437) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix option_values nested attributes behavior on the API [#4409](https://github.com/solidusio/solidus/pull/4409) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Add tax_category_id to variant's permitted attributes [#4406](https://github.com/solidusio/solidus/pull/4406) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Deprecate creating new shipment with an item via API [#4387](https://github.com/solidusio/solidus/pull/4387) ([kennyadsl](https://github.com/kennyadsl))
- Deprecate dangling option_values and duplicated routes [#4385](https://github.com/solidusio/solidus/pull/4385) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Bugfix: Changing Default Addresses [#4332](https://github.com/solidusio/solidus/pull/4332) ([mamhoff](https://github.com/mamhoff))
- Allow OrderWalkThrough to take a user [#4292](https://github.com/solidusio/solidus/pull/4292) ([mamhoff](https://github.com/mamhoff))
- Refactor Stock Quantifier to use Enumerable [#4291](https://github.com/solidusio/solidus/pull/4291) ([mamhoff](https://github.com/mamhoff))
- Fix(OrderMerger): Do not carry line item adjustments to new order [#4290](https://github.com/solidusio/solidus/pull/4290) ([mamhoff](https://github.com/mamhoff))
- Add additional info for developers in docker logs [#4288](https://github.com/solidusio/solidus/pull/4288) ([Palid](https://github.com/Palid))
- Use Variant Searcher for Autocomplete [#4197](https://github.com/solidusio/solidus/pull/4197) ([adammathys](https://github.com/adammathys))
- Clean request specs [#4158](https://github.com/solidusio/solidus/pull/4158) ([biximilien](https://github.com/biximilien))

### Admin

- Switch orders name search to use contains instead of starts with [#4496](https://github.com/solidusio/solidus/pull/4496) ([sbader](https://github.com/sbader))
- Provide support to fix locale selection in admin login page [#4493](https://github.com/solidusio/solidus/pull/4493) ([gsmendoza](https://github.com/gsmendoza))
- Fix expectations about solidus_auth_devise order in the Gemfile [#4465](https://github.com/solidusio/solidus/pull/4465) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Translate price country names [#4508](https://github.com/solidusio/solidus/pull/4508) ([tvdeyen](https://github.com/tvdeyen))
- Sanitize i18n keys using i18n-tasks gem issue: #3978 [#4437](https://github.com/solidusio/solidus/pull/4437) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Remove N+1 from admin users [#4419](https://github.com/solidusio/solidus/pull/4419) ([tvdeyen](https://github.com/tvdeyen))
- Fix delete response in admin users controller [#4415](https://github.com/solidusio/solidus/pull/4415) ([tvdeyen](https://github.com/tvdeyen))
- Remove unutilized coffee-rails dependency [#4405](https://github.com/solidusio/solidus/pull/4405) ([cpfergus1](https://github.com/cpfergus1))
- Make more room for long values in Order Summary [#4352](https://github.com/solidusio/solidus/pull/4352) ([tvdeyen](https://github.com/tvdeyen))
- Enhance refund admin UI [#4348](https://github.com/solidusio/solidus/pull/4348) ([tvdeyen](https://github.com/tvdeyen))
- feat(Variants Form): Add some visual structure [#4323](https://github.com/solidusio/solidus/pull/4323) ([tvdeyen](https://github.com/tvdeyen))
- Fix admin variants table UX [#4322](https://github.com/solidusio/solidus/pull/4322) ([tvdeyen](https://github.com/tvdeyen))
- Authorize uuid for existing object in sortable table [#4287](https://github.com/solidusio/solidus/pull/4287) ([julienanne](https://github.com/julienanne))
- Check for existence of `product_path` instead of `Spree::Frontend::Engine` [#4278](https://github.com/solidusio/solidus/pull/4278) ([gsmendoza](https://github.com/gsmendoza))
- Admin permission fixes [#4276](https://github.com/solidusio/solidus/pull/4276) ([spaghetticode](https://github.com/spaghetticode))
- Incorrect display store credit reason [#4268](https://github.com/solidusio/solidus/pull/4268) ([nbelzer](https://github.com/nbelzer))
- Fix for advancing carts correctly in admin checkout [#4253](https://github.com/solidusio/solidus/pull/4253) ([tmtrademarked](https://github.com/tmtrademarked))
- fix backbone shipment item view when split [#4250](https://github.com/solidusio/solidus/pull/4250) ([ccarruitero](https://github.com/ccarruitero))
- Fix tests after two conflicting merges [#4249](https://github.com/solidusio/solidus/pull/4249) ([waiting-for-dev](https://github.com/waiting-for-dev))
- [Admin] Fix permission checks on some links [#4244](https://github.com/solidusio/solidus/pull/4244) ([spaghetticode](https://github.com/spaghetticode))
- Fix product prices table pagination [#4243](https://github.com/solidusio/solidus/pull/4243) ([tvdeyen](https://github.com/tvdeyen))
- Admin users did not work with custom user models [#4238](https://github.com/solidusio/solidus/pull/4238) ([softr8](https://github.com/softr8))
- Adds the missing en-CA localization for the select2 dropdown in admin [#4223](https://github.com/solidusio/solidus/pull/4223) ([jzisser9](https://github.com/jzisser9))
- Add filter and pagination to tax rates admin view [#4222](https://github.com/solidusio/solidus/pull/4222) ([tvdeyen](https://github.com/tvdeyen))
- Make display_price optional on admin variants list [#4213](https://github.com/solidusio/solidus/pull/4213) ([luca-landa](https://github.com/luca-landa))
- Use SSL on fonts.googleapis.com scss import [#4209](https://github.com/solidusio/solidus/pull/4209) ([RyanofWoods](https://github.com/RyanofWoods))
- Use Variant Searcher for Autocomplete [#4197](https://github.com/solidusio/solidus/pull/4197) ([adammathys](https://github.com/adammathys))
- Update install templates to use jquery3 (vulnerability fix) [#4167](https://github.com/solidusio/solidus/pull/4167) ([cpfergus1](https://github.com/cpfergus1))
- Fix searching deleted products by SKU [#4164](https://github.com/solidusio/solidus/pull/4164) ([adammathys](https://github.com/adammathys))
- Refactor and add specs to stock locations helper [#3827](https://github.com/solidusio/solidus/pull/3827) ([gabrielbaldao](https://github.com/gabrielbaldao))

### Frontend

- Remove frontend directory [#4497](https://github.com/solidusio/solidus/pull/4497) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix expectations about solidus_auth_devise order in the Gemfile [#4465](https://github.com/solidusio/solidus/pull/4465) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Make API docs deprecation warnings consistent [#4397](https://github.com/solidusio/solidus/pull/4397) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Deprecate SolidusFrontend [#4320](https://github.com/solidusio/solidus/pull/4320) ([gsmendoza](https://github.com/gsmendoza))
- Bump follow-redirects from 1.14.7 to 1.14.8 in /guides [#4269](https://github.com/solidusio/solidus/pull/4269) ([dependabot](https://github.com/apps/dependabot))
- Use SSL on fonts.googleapis.com scss import [#4209](https://github.com/solidusio/solidus/pull/4209) ([RyanofWoods](https://github.com/RyanofWoods))

### Docs & Guides

- Add explicit information about DB_\* env variables to the README [#4461](https://github.com/solidusio/solidus/pull/4461) ([chrean](https://github.com/chrean))
- Move legacy guides to a separate repository [#4459](https://github.com/solidusio/solidus/pull/4459) ([aldesantis](https://github.com/aldesantis))
- Bump minimist from 1.2.0 to 1.2.6 in /guides [#4314](https://github.com/solidusio/solidus/pull/4314) ([dependabot](https://github.com/apps/dependabot))
- Update customizing-assets.html.md [#4312](https://github.com/solidusio/solidus/pull/4312) ([mapreal19](https://github.com/mapreal19))
- Removes Stoplight API docu auto build orb. [#4311](https://github.com/solidusio/solidus/pull/4311) ([wintermeyer](https://github.com/wintermeyer))
- Update README.md chromedriver link [#4294](https://github.com/solidusio/solidus/pull/4294) ([Palid](https://github.com/Palid))
- Update API docs link to point to the new domain [#4279](https://github.com/solidusio/solidus/pull/4279) ([kennyadsl](https://github.com/kennyadsl))
- Update the Super Good logo [#4258](https://github.com/solidusio/solidus/pull/4258) ([jarednorman](https://github.com/jarednorman))
- Update contributor logo on README.md [#4257](https://github.com/solidusio/solidus/pull/4257) ([mfrecchiami](https://github.com/mfrecchiami))
- Update image settings documentation [#4245](https://github.com/solidusio/solidus/pull/4245) ([nbelzer](https://github.com/nbelzer))
- Bump follow-redirects from 1.13.1 to 1.14.7 in /guides [#4242](https://github.com/solidusio/solidus/pull/4242) ([dependabot](https://github.com/apps/dependabot))
- Documentation fixes [#4241](https://github.com/solidusio/solidus/pull/4241) ([nbelzer](https://github.com/nbelzer))
- Make minor improvements to the "Payments" developer guides [#4208](https://github.com/solidusio/solidus/pull/4208) ([benjaminwil](https://github.com/benjaminwil))
- Fix typo in Payments Overview guide [#4195](https://github.com/solidusio/solidus/pull/4195) ([nerfologist](https://github.com/nerfologist))
- [Doc] Good commit message link fixed [#4186](https://github.com/solidusio/solidus/pull/4186) ([shubham9411](https://github.com/shubham9411))
- Bump axios from 0.21.1 to 0.21.2 in /guides [#4171](https://github.com/solidusio/solidus/pull/4171) ([dependabot](https://github.com/apps/dependabot))

## Solidus 3.1.8 (v3.1, 2022-09-22)

- [v3.1] Only default to activestorage adapter if Rails version is supported [#4565](https://github.com/solidusio/solidus/pull/4565) ([tvdeyen](https://github.com/tvdeyen))
- Fix key in the locale file [#4513](https://github.com/solidusio/solidus/pull/4513) ([waiting-for-dev](https://github.com/waiting-for-dev))
- [v3.1] Translate price country names [#4509](https://github.com/solidusio/solidus/pull/4509) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Fix admin variants table UX [#4506](https://github.com/solidusio/solidus/pull/4506) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Allow to extend user deletion logic [#4472](https://github.com/solidusio/solidus/pull/4472) ([tvdeyen](https://github.com/tvdeyen))

## Solidus 3.1.7 (v3.1, 2022-07-15)

- Support CVE-2022-32224 Rails security updates - backport to v3.1 [#4453](https://github.com/solidusio/solidus/pull/4453) ([gsmendoza](https://github.com/gsmendoza))
- [v3.1] Remove N+1 from admin users [#4420](https://github.com/solidusio/solidus/pull/4420) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Fix delete response in admin users controller [#4416](https://github.com/solidusio/solidus/pull/4416) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Only install ActiveStorage adapter on supported Rails versions [#4403](https://github.com/solidusio/solidus/pull/4403) ([tvdeyen](https://github.com/tvdeyen))
- Fix user restricted stock management v3.1 [#4400](https://github.com/solidusio/solidus/pull/4400) ([rmparr](https://github.com/rmparr))

## Solidus 3.1.6 (v3.1, 2022-06-01)

- [v3.1] Fix creating store credit with amount in foreign format [#4391](https://github.com/solidusio/solidus/pull/4391) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Replace expired GPG key for mysql install in dev Dockerfile [#4381](https://github.com/solidusio/solidus/pull/4381) ([waiting-for-dev](https://github.com/waiting-for-dev))
- [v3.1] Fix refund form (again) [#4360](https://github.com/solidusio/solidus/pull/4360) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Make more room for long values in Order Summary [#4353](https://github.com/solidusio/solidus/pull/4353) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Enhance refund admin UI [#4349](https://github.com/solidusio/solidus/pull/4349) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Fix creating refund with amount in foreign format [#4345](https://github.com/solidusio/solidus/pull/4345) ([tvdeyen](https://github.com/tvdeyen))
- [v3.1] Update in-memory shipments of order in order_shipping [#4335](https://github.com/solidusio/solidus/pull/4335) ([tvdeyen](https://github.com/tvdeyen))
- [3.1] Fixes using ActiveStorage adapter with libvips as variant processor [#4324](https://github.com/solidusio/solidus/pull/4324) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Authorize uuid for existing object in sortable table [#4301](https://github.com/solidusio/solidus/pull/4301) ([julienanne](https://github.com/julienanne))
- Backport #4228 to V3.1 [#4237](https://github.com/solidusio/solidus/pull/4237) ([jcsanti](https://github.com/jcsanti))
- [BACKPORT] Reintroduce inverse_of: :product for variants association [#4236](https://github.com/solidusio/solidus/pull/4236) ([spaghetticode](https://github.com/spaghetticode))

## Solidus 3.1.5 (v3.1, 2021-12-20)

- Fix CSRF forgery protection bypass for Spree::OrdersController#populate [GHSA-h3fg-h5v3-vf8m](https://github.com/solidusio/solidus/security/advisories/GHSA-h3fg-h5v3-vf8m)

## Solidus 3.1.4 (v3.1, 2021-12-07)

- Fix ReDos vulnerability on Spree::EmailValidator::EMAIL_REGEXP [GHSA-qxmr-qxh6-2cc9](https://github.com/solidusio/solidus/security/advisories/GHSA-qxmr-qxh6-2cc9)
- Use SSL on fonts.googleapis.com scss import [#4210](https://github.com/solidusio/solidus/pull/4210) [RyanofWoods](https://github.com/RyanofWoods)

## Solidus 3.1.3 (v3.1, 2021-11-17)

- Monkey patch Authentication Bypass by CSRF Weakness vulnerability on solidus_auth_devise for extra security [GHSA-5629-8855-gf4g](https://github.com/solidusio/solidus/security/advisories/GHSA-5629-8855-gf4g)

## Solidus 3.1.1 (v3.1, 2021-09-20)

- Add deprecation path for arity-zero preference defaults [#4170](https://github.com/solidusio/solidus/pull/4170) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix staled upgrade instructions on the Gemfile's post-install message [#4166](https://github.com/solidusio/solidus/pull/4166) ([waiting-for-dev](https://github.com/waiting-for-dev))

## Solidus 3.1.0 (v3.1, 2021-09-10)

### Major changes

**`Spree.load_defaults`: preference defaults depending on the Solidus version**

Solidus 3.1 brings a new feature where preference defaults can take different
values depending on a specified Solidus version. It makes it possible to stop
deprecating old defaults every time we introduce a change in the recommended
value for a setting. After all, they're just that; recommendations. Instead,
now users can explicitly ask for a given Solidus version defaults and, as
before, override the preferences they want.

When upgrading to 3.1, you have to take action to adopt the new behavior.
You'll need to add `Spree.load_defaults('3.1')` on the very top of your
`spree.rb` initializer. As we're not changing any preference default on this
release, nothing will break. A warning will be emitted on boot-up until you do
it!

However, bumping the version given to `load_defaults` straight away for future
upgrades will not be a safe option. Instead, you'll have to go through the new
update process detailed below.

- Allow using different preference defaults depending on a Solidus version [#4064](https://github.com/solidusio/solidus/pull/4064) ([waiting-for-dev](https://github.com/waiting-for-dev))

**New update process**

As aforementioned, preference defaults can change after a Solidus release. Once
you have your defaults locked to the current Solidus version, a new upgrade
won't break your application because of them. However, it's a good idea to
adapt your application to the updated recommended settings. To help with this
process, Solidus comes with a generator that you can execute like this:

```bash
bin/rails g solidus:update
```

That generator will create a new initializer called `new_solidus_defaults.rb`,
which will preview all the defaults that have changed between versions, each on
a commented line. From that point, you can activate the new defaults one by one
and adapt your application incrementally. Once you're done with all of them,
you can bump the version given to `Spree.load_defaults` in the `spree.rb`
initializer and remove the `new_solidus_defaults.rb` initializer altogether.

You can read in more detail about [this process on our
guides](https://edgeguides.solidus.io/getting-started/upgrading-solidus#updating-preferences).

- Introduce Solidus update process [#4087](https://github.com/solidusio/solidus/pull/4087) ([waiting-for-dev](https://github.com/waiting-for-dev))

**Other important changes**

`Spree::Price#amount` field can no longer be `nil`. Besides adding the
validation at the model layer, we ship with a task that will remove records
where the amount is `NULL` in the database. You should run the task before
executing the new migrations:

```ruby
bin/rails solidus:delete_prices_with_nil_amount
bin/rails railties:install:migrations
bin/rails db:migrate
```

If you're running migrations automatically on deploy, you should run the task
before rolling out the new code. In that case, you first should make sure that
you have affected records:

```ruby
Spree::Price.where(amount: nil).any?
```

If the above code returns `false`, you don't need to do anything else.
Otherwise, copy [the
task](https://github.com/solidusio/solidus/blob/main/core/lib/tasks/solidus/delete_prices_with_nil_amount.rake)
into your code, and deploy & execute it. Another option is to execute it
manually in your console in production. However, be extremely careful when
doing that!! :warning: :warning: :warning:

```ruby
Spree::Price.where(amount: nil).delete_all
```

- Do not allow prices with nil amount [#3987](https://github.com/solidusio/solidus/pull/3987) ([waiting-for-dev](https://github.com/waiting-for-dev))

### Core

- Remove the upgrade task and point to additional steps from the update generator [#4157](https://github.com/solidusio/solidus/pull/4157) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Make order-related service objects configurable [#4138](https://github.com/solidusio/solidus/pull/4138) ([aldesantis](https://github.com/aldesantis))
- Remove unused `ShippingRateTaxer` service object [#4136](https://github.com/solidusio/solidus/pull/4136) ([aldesantis](https://github.com/aldesantis))
- Fix Ransack error when searching for orders by customer name [#4135](https://github.com/solidusio/solidus/pull/4135) ([aldesantis](https://github.com/aldesantis))
- Exclude canceled orders in the #usage_count of promotions and promotion codes [#4123](https://github.com/solidusio/solidus/pull/4123) ([ikraamg](https://github.com/ikraamg))
- Make clearer default answer in prompt [#4101](https://github.com/solidusio/solidus/pull/4101) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Permit return_items_attributes return_reason_id [#4080](https://github.com/solidusio/solidus/pull/4080) ([spaghetticode](https://github.com/spaghetticode))
- Simplify `Variant#default_price` logic [#4076](https://github.com/solidusio/solidus/pull/4076) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Move currently_valid_prices to a method [#4073](https://github.com/solidusio/solidus/pull/4073) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Support Ruby 3 [#4072](https://github.com/solidusio/solidus/pull/4072) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix customer return validation for return items without inventory units [#4068](https://github.com/solidusio/solidus/pull/4068) ([willianveiga](https://github.com/willianveiga))
- Add preferences to configure product and taxon images style [#4062](https://github.com/solidusio/solidus/pull/4062) ([cpfergus1](https://github.com/cpfergus1))
- Add UUID to StoreCredit#generate_authorization_code [#4060](https://github.com/solidusio/solidus/pull/4060) ([spaghetticode](https://github.com/spaghetticode))
- Fix Spree::Promotion.has_actions scope [#4056](https://github.com/solidusio/solidus/pull/4056) ([mamhoff](https://github.com/mamhoff))
- Update defaults in dummy application [#4047](https://github.com/solidusio/solidus/pull/4047) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Load defaults for the latest Rails minor version in the dummy app [#4035](https://github.com/solidusio/solidus/pull/4035) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Handle permalink attribute on product create [#4024](https://github.com/solidusio/solidus/pull/4024) ([nandita2010](https://github.com/nandita2010))
- Don't hack into ActionMailer to add our mail previews path [#3961](https://github.com/solidusio/solidus/pull/3961) ([elia](https://github.com/elia))
- Fix solidus stock locations sorting [#3954](https://github.com/solidusio/solidus/pull/3954) ([ikraamg](https://github.com/ikraamg))
- Fix order checkout flow completion with custom steps [#3950](https://github.com/solidusio/solidus/pull/3950) ([nerfologist](https://github.com/nerfologist))
- Add docker-compose development environment [#3947](https://github.com/solidusio/solidus/pull/3947) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Allow Variant to check stock by stock_location [#3884](https://github.com/solidusio/solidus/pull/3884) ([MadelineCollier](https://github.com/MadelineCollier))
- Normalize email required checks [#3879](https://github.com/solidusio/solidus/pull/3879) ([elia](https://github.com/elia))
- Improve the extensibility of Rules::ItemTotal [#3431](https://github.com/solidusio/solidus/pull/3431) ([elia](https://github.com/elia))

### API

- Remove Pending Request Spec: Api Admin update payment state expectations. [#4149](https://github.com/solidusio/solidus/pull/4149) ([jcowhigjr](https://github.com/jcowhigjr))
- Fix gateway_error when no order is defined [#4156](https://github.com/solidusio/solidus/pull/4156) ([alexblackie](https://github.com/alexblackie))
- Moving API attribute helpers to API config [#4039](https://github.com/solidusio/solidus/pull/4039) ([snada](https://github.com/snada))
- Allow customer returns to reference existing `ReturnItem`s on create through API [#4007](https://github.com/solidusio/solidus/pull/4007) ([forkata](https://github.com/forkata))
- Let the PriceSelector return a Spree::Price [#3925](https://github.com/solidusio/solidus/pull/3925) ([swively](https://github.com/swively))

### Admin

- Fix displaying of discarded variants in admin [#4148](https://github.com/solidusio/solidus/pull/4148) ([luca-landa](https://github.com/luca-landa))
- Hide the master variants from stock management [#4155](https://github.com/solidusio/solidus/pull/4155) ([tmtrademarked](https://github.com/tmtrademarked))
- Refactor frontend and backend locale_controllers [#4126](https://github.com/solidusio/solidus/pull/4126) ([RyanofWoods](https://github.com/RyanofWoods))
- Fix admin portugues locale [#4107](https://github.com/solidusio/solidus/pull/4107) ([ruipbarata](https://github.com/ruipbarata))
- Add an HTML select element to filter orders by the shipment state [#4089](https://github.com/solidusio/solidus/pull/4089) ([willianveiga](https://github.com/willianveiga))
- Fix detecting exec js version by adding minimal requirement for autoprefixer-rails [#4077](https://github.com/solidusio/solidus/pull/4077) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Unhardcode admin base url in 'stock_location_stock_item' template [#4063](https://github.com/solidusio/solidus/pull/4063) ([ok32](https://github.com/ok32))
- Fix "Cancel" URL link on reimbursement edit page [#4061](https://github.com/solidusio/solidus/pull/4061) ([spaghetticode](https://github.com/spaghetticode))
- [ADMIN] Properly format flash error message [#3996](https://github.com/solidusio/solidus/pull/3996) ([spaghetticode](https://github.com/spaghetticode))
- Consolidation of promotion code batch form fields into partial. [#3957](https://github.com/solidusio/solidus/pull/3957) ([cpfergus1](https://github.com/cpfergus1))
- Promotion rule product limit improvements [#3934](https://github.com/solidusio/solidus/pull/3934) ([nirnaeth](https://github.com/nirnaeth))
- eager load records instead of n+1 for update_positions [#3875](https://github.com/solidusio/solidus/pull/3875) ([BenMorganIO](https://github.com/BenMorganIO))
- Update order_tabs Order number format [#3835](https://github.com/solidusio/solidus/pull/3835) ([brchristian](https://github.com/brchristian))

### Frontend

- Move frontend locale_controller_spec to correct directory [#4127](https://github.com/solidusio/solidus/pull/4127) ([RyanofWoods](https://github.com/RyanofWoods))
- Refactor frontend and backend locale_controllers [#4126](https://github.com/solidusio/solidus/pull/4126) ([RyanofWoods](https://github.com/RyanofWoods))
- Fix flaky product feature spec [#4118](https://github.com/solidusio/solidus/pull/4118) ([gsmendoza](https://github.com/gsmendoza))
- Use symbols in polymorphic path for event_links [#4048](https://github.com/solidusio/solidus/pull/4048) ([tvdeyen](https://github.com/tvdeyen))

### Docs & Guides

- Fix small typo in the 'customizing permissions' guide [#4147](https://github.com/solidusio/solidus/pull/4147) ([nerfologist](https://github.com/nerfologist))
- Bump tar from 2.2.1 to 2.2.2 in /guides [#4142](https://github.com/solidusio/solidus/pull/4142) ([dependabot](https://github.com/apps/dependabot))
- Document REST API params to control nested taxons [#4131](https://github.com/solidusio/solidus/pull/4131) ([kennyadsl](https://github.com/kennyadsl))
- Bump addressable from 2.5.2 to 2.8.0 in /guides [#4129](https://github.com/solidusio/solidus/pull/4129) ([dependabot](https://github.com/apps/dependabot))
- Document REST API filtering with Ransack [#4128](https://github.com/solidusio/solidus/pull/4128) ([kennyadsl](https://github.com/kennyadsl))
- Guides typo corrections [#4120](https://github.com/solidusio/solidus/pull/4120) ([cesartalves](https://github.com/cesartalves))
- Shipment Setup Examples documentation - small correction to the amount of shipping categories needed [#4115](https://github.com/solidusio/solidus/pull/4115) ([cesartalves](https://github.com/cesartalves))
- Fix broken URL in customer-flow guide [#4096](https://github.com/solidusio/solidus/pull/4096) ([RyanofWoods](https://github.com/RyanofWoods))
- Fix the dark mode issue with the logo on README.md [#4093](https://github.com/solidusio/solidus/pull/4093) ([mfrecchiami](https://github.com/mfrecchiami))
- Small English correction on Payments overview PSP doc [#4088](https://github.com/solidusio/solidus/pull/4088) ([cesartalves](https://github.com/cesartalves))
- Update the Nebulab's logo on README.md [#4079](https://github.com/solidusio/solidus/pull/4079) ([mfrecchiami](https://github.com/mfrecchiami))
- Fix Request Bodies in API Documentation [#4066](https://github.com/solidusio/solidus/pull/4066) ([kennyadsl](https://github.com/kennyadsl))
- Fix links in CHANGELOG.md [#4057](https://github.com/solidusio/solidus/pull/4057) ([bogdanvlviv](https://github.com/bogdanvlviv))
- Bump hosted-git-info from 2.7.1 to 2.8.9 in /guides [#4053](https://github.com/solidusio/solidus/pull/4053) ([dependabot](https://github.com/apps/dependabot))
- Bump lodash from 4.17.19 to 4.17.21 in /guides [#4051](https://github.com/solidusio/solidus/pull/4051) ([dependabot](https://github.com/apps/dependabot))
- Review install instructions in README and Guides [#4034](https://github.com/solidusio/solidus/pull/4034) ([kennyadsl](https://github.com/kennyadsl))
- Use more appropriate language for woman's t-shirt in sample data [#4031](https://github.com/solidusio/solidus/pull/4031) ([Noah-Silvera](https://github.com/Noah-Silvera))
- Improve Customizing Attributes documentation [#3979](https://github.com/solidusio/solidus/pull/3979) ([dhughesbc](https://github.com/dhughesbc))
- Improve Solidus events documentation [#3819](https://github.com/solidusio/solidus/pull/3819) ([spaghetticode](https://github.com/spaghetticode))

## Solidus 3.0.8 (v3.0, 2022-09-22)

- [v3.0] Only default to activestorage adapter if Rails version is supported [#4568](https://github.com/solidusio/solidus/pull/4568) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Fix Ransack error when searching for orders by customer name [#4521](https://github.com/solidusio/solidus/pull/4521) ([tvdeyen](https://github.com/tvdeyen))
- Fix key in the locale file [#4514](https://github.com/solidusio/solidus/pull/4514) ([waiting-for-dev](https://github.com/waiting-for-dev))
- [v3.0] Translate price country names [#4510](https://github.com/solidusio/solidus/pull/4510) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Fix admin variants table UX [#4507](https://github.com/solidusio/solidus/pull/4507) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Allow to extend user deletion logic [#4473](https://github.com/solidusio/solidus/pull/4473) ([tvdeyen](https://github.com/tvdeyen))

## Solidus 3.0.7 (v3.0, 2022-07-15)

- Support CVE-2022-32224 Rails security updates - backport to v3.0  [#4454](https://github.com/solidusio/solidus/pull/4454) ([gsmendoza](https://github.com/gsmendoza))
- [v3.0] Remove N+1 from admin users [#4421](https://github.com/solidusio/solidus/pull/4421) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Fix delete response in admin users controller [#4417](https://github.com/solidusio/solidus/pull/4417) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Backport docker development environment [#4407](https://github.com/solidusio/solidus/pull/4407) ([waiting-for-dev](https://github.com/waiting-for-dev))
- [v3.0] Only install ActiveStorage adapter on supported Rails versions [#4404](https://github.com/solidusio/solidus/pull/4404) ([tvdeyen](https://github.com/tvdeyen))
- Fix user restricted stock management v3.0 [#4399](https://github.com/solidusio/solidus/pull/4399) ([rmparr](https://github.com/rmparr))

## Solidus 3.0.6 (v3.0, 2022-06-01)

- Fix user restricted stock management v3.0 [#4399](https://github.com/solidusio/solidus/pull/4399) ([rmparr](https://github.com/rmparr))
- [v3.0] Fix creating store credit with amount in foreign format [#4392](https://github.com/solidusio/solidus/pull/4392) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Fix refund form (again) [#4361](https://github.com/solidusio/solidus/pull/4361) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Make more room for long values in Order Summary [#4354](https://github.com/solidusio/solidus/pull/4354) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Enhance refund admin UI [#4350](https://github.com/solidusio/solidus/pull/4350) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Fix creating refund with amount in foreign format [#4346](https://github.com/solidusio/solidus/pull/4346) ([tvdeyen](https://github.com/tvdeyen))
- [v3.0] Update in-memory shipments of order in order_shipping [#4336](https://github.com/solidusio/solidus/pull/4336) ([tvdeyen](https://github.com/tvdeyen))
- [3.0] Fixes using ActiveStorage adapter with libvips as variant processor [#4325](https://github.com/solidusio/solidus/pull/4325) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Authorize uuid for existing object in sortable table [#4300](https://github.com/solidusio/solidus/pull/4300) ([julienanne](https://github.com/julienanne))
- [BACKPORT] Reintroduce inverse_of: :product for variants association [#4235](https://github.com/solidusio/solidus/pull/4235) ([spaghetticode](https://github.com/spaghetticode))
- Backport #4228 to V3.0 [#4232](https://github.com/solidusio/solidus/pull/4232) ([jcsanti](https://github.com/jcsanti))

## Solidus 3.0.5 (v3.0, 2021-12-20)

- Fix CSRF forgery protection bypass for Spree::OrdersController#populate [GHSA-h3fg-h5v3-vf8m](https://github.com/solidusio/solidus/security/advisories/GHSA-h3fg-h5v3-vf8m)

## Solidus 3.0.4 (v3.0, 2021-12-07)

- Fix ReDos vulnerability on Spree::EmailValidator::EMAIL_REGEXP [GHSA-qxmr-qxh6-2cc9](https://github.com/solidusio/solidus/security/advisories/GHSA-qxmr-qxh6-2cc9)
- Use SSL on fonts.googleapis.com scss import [#4211](https://github.com/solidusio/solidus/pull/4211) [RyanofWoods](https://github.com/RyanofWoods)

## Solidus 3.0.3 (v3.0, 2021-11-17)

- Monkey patch Authentication Bypass by CSRF Weakness vulnerability on solidus_auth_devise for extra security [GHSA-5629-8855-gf4g](https://github.com/solidusio/solidus/security/advisories/GHSA-5629-8855-gf4g)

## Solidus 3.0.2 (v3.0, 2021-09-10)

- Permit return_items_attributes return_reason_id [#4091](https://github.com/solidusio/solidus/pull/4091) ([spaghetticode](https://github.com/spaghetticode))
- Fix app and tests to work with ActiveRecord.has_many_inverse [#4098](https://github.com/solidusio/solidus/pull/4098) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Support Ruby 3 [#4072](https://github.com/solidusio/solidus/pull/4072) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Fix detecting exec js version by adding minimal requirement for autoprefixer-rails [#4077](https://github.com/solidusio/solidus/pull/4077) ([waiting-for-dev](https://github.com/waiting-for-dev))

## Solidus 3.0.1 (v3.0, 2021-05-10)

- Use symbols in polymorphic path for event_links [#4048](https://github.com/solidusio/solidus/pull/4048) ([tvdeyen](https://github.com/tvdeyen))
## Solidus 3.0.0 (v3.0, 2021-04-20)

### Major Changes

**Removal of all code deprecated during the 2.x series**

The main change in this major version is the removal of all deprecated code that
we introduced during the 2.x series. This means that if any code that was deprecated
is still being used, the application will break. Following the deprecation messages
in the application logs, it should be quite easy to spot what code needs to be changed.

The main things that could break a Solidus application are:

***Paranoia gem has been replaced by Discard gem***

All references to methods added to models by Paranoia will raise a NoMethodError exception now.
Some of those methods are:

- `paranoia_destroy`
- `paranoia_delete`
- `with_deleted`
- `only_deleted`
- `really_destroy!`
- `after_real_destroy`

Pull Requests:

- Discard Paranoia [#3488](https://github.com/solidusio/solidus/pull/3488) ([cedum](https://github.com/cedum))

***Removed core support to first_name and last_name in Spree::Address***

In Solidus v2.11, we added a `name` attribute to `Spree::Address`, which is being populated combining
`first_name` and `last_name` values every time a new address is added to the system. We also provided
a rake tasks to update all existing records in order to get applications ready for Solidus 3.0.

With this major version, `name` is the only supported attributes. `first_name` and `last_name` fields are already in the database
so if needed, a store can revert this change implementing their own logic.

See [3234](https://github.com/solidusio/solidus/issues/3234) for the rationale behind this change.

Pull Requests:

- Move Spree::Address#name attribute to the db [#3908](https://github.com/solidusio/solidus/pull/3908) ([filippoliverani](https://github.com/filippoliverani))
- Remove deprecated name-related Address fields [#3820](https://github.com/solidusio/solidus/pull/3820) ([filippoliverani](https://github.com/filippoliverani))

***All the other deprecations removal***

For a complete reference to rest of the code removed, these PRs can be taken as reference:

- Remove deprecated attachment_partial_name [#3974](https://github.com/solidusio/solidus/pull/3974) ([kennyadsl](https://github.com/kennyadsl))
- Remove legacy address state validation logic [#3847](https://github.com/solidusio/solidus/pull/3847) ([cedum](https://github.com/cedum))
- Raise canceling a payment when try_void is not implemented [#3844](https://github.com/solidusio/solidus/pull/3844) ([kennyadsl](https://github.com/kennyadsl))
- Remove all code deprecated in Solidus v2.x [#3818](https://github.com/solidusio/solidus/pull/3818) ([kennyadsl](https://github.com/kennyadsl))

***Removal without deprecations***

We also removed some code that didn't need a deprecation warning. Be sure that your
codebase doesn't use any of the following:

- `Spree::LineItem::CurrencyMismatch` exception: we are not using it anymore since the behavior we had with `Spree::Config.raise_with_invalid_currency = true` has been removed.
- `Spree::Order::Checkout` is not used anymore. `Spree::Core::StateMachines::Order` is identical.
- `Spree::Admin::PaymentsHelper` module is empty after removing all deprecated methods inside it.
- `UserPaymentSource` is empty after removing all deprecated methods inside it.
- `Spree::Refund#perform_after_create` attribute, it was into a deprecated path. If you are still using it, please stop, it does nothing now.
- `Spree::TaxCalculator#ShippingRate`: it is always `nil` now.
- `Spree::Money::RUBY_NUMERIC_STRING`: was only used in a deprecated code path.

We also removed the following preferences without deprecations. They were just controlling a deprecated
flow and have no effect so, assuming you already switched to the only accepted value, you can safely
remove them from your initializer. You'll probably notice that because your app won't start.

- `Spree::Config.raise_with_invalid_currency`
- `Spree::Config.redirect_back_on_unauthorized preference`
- `Spree::Config.run_order_validations_on_order_updater preference `
- `Spree::Config.use_legacy_order_state_machine`
- `Spree::Config.use_legacy_store_credit_reimbursement_category_name`
- `Spree::Config.consider_actionless_promotion_active`
- `Spree::Config.use_legacy_address_state_validator`
- `Spree::Config.use_combined_first_and_last_name_in_address`

**By default, do not require the whole Rails framework**

This shouldn't give any issue in host applications, but if that happens,
it can be easily fixable opening `config/application.rb` and add `require 'rails/all'` or
the specific part of Rails needed by the application.

- Only require the necessary Rails frameworks [#3478](https://github.com/solidusio/solidus/pull/3478) ([elia](https://github.com/elia))

**Switch Paperclip dependency to its maintained version**

We recently added support for Active Support, which will be the default in Solidus 3.0.
Paperclip will still be around and supported for a while because we don't want to force
existing stores to accomplish the assets migration. While we support it, we want to use
the maintained fork.

- Switch to maintained Paperclip fork [#3913](https://github.com/solidusio/solidus/pull/3913) ([filippoliverani](https://github.com/filippoliverani))

### Misc

- Bump removal horizon for 3.x deprecations [#4025](https://github.com/solidusio/solidus/pull/4025) ([kennyadsl](https://github.com/kennyadsl))
- Add Post-Install message to Solidus 3.0 [#3985](https://github.com/solidusio/solidus/pull/3985) ([kennyadsl](https://github.com/kennyadsl))
- Add Active Storage in Dummy App for extensions [#3969](https://github.com/solidusio/solidus/pull/3969) ([kennyadsl](https://github.com/kennyadsl))
- Improve Active Storage configuration for in-memory Dummy App [#3970](https://github.com/solidusio/solidus/pull/3970) ([kennyadsl](https://github.com/kennyadsl))
- Allow users to create blank issues in GitHub [#3943](https://github.com/solidusio/solidus/pull/3943) ([kennyadsl](https://github.com/kennyadsl))
- Install Active Storage by default on new stores [#3938](https://github.com/solidusio/solidus/pull/3938) ([kennyadsl](https://github.com/kennyadsl))
- Avoid too many prompts during solidus:install generator [#3937](https://github.com/solidusio/solidus/pull/3937) ([kennyadsl](https://github.com/kennyadsl))
- Align Rubocop ruby version to gemspec [#3935](https://github.com/solidusio/solidus/pull/3935) ([spaghetticode](https://github.com/spaghetticode))
- Skip adding webpacker gem when generating dummyapp [#3922](https://github.com/solidusio/solidus/pull/3922) ([SamuelMartini](https://github.com/SamuelMartini))
- allow customize database credentials for test app [#3921](https://github.com/solidusio/solidus/pull/3921) ([ccarruitero](https://github.com/ccarruitero))
- Bump redcarpet from 3.4.0 to 3.5.1 in /guides [#3890](https://github.com/solidusio/solidus/pull/3890) ([dependabot](https://github.com/apps/dependabot))
- Adjust CircleCI config to reflect Rails versions that we support [#3885](https://github.com/solidusio/solidus/pull/3885) ([kennyadsl](https://github.com/kennyadsl))
- Bump axios from 0.18.1 to 0.21.1 in /guides [#3881](https://github.com/solidusio/solidus/pull/3881) ([dependabot](https://github.com/apps/dependabot))
- Bump ini from 1.3.5 to 1.3.7 in /guides [#3861](https://github.com/solidusio/solidus/pull/3861) ([dependabot](https://github.com/apps/dependabot))
- Drive community to GitHub Discussions when opening issues [#3857](https://github.com/solidusio/solidus/pull/3857) ([kennyadsl](https://github.com/kennyadsl))
- Update governance with latest changes to the organization [#3836](https://github.com/solidusio/solidus/pull/3836) ([kennyadsl](https://github.com/kennyadsl))
- Fix install instructions in Solidus Guides [#3833](https://github.com/solidusio/solidus/pull/3833) ([ikraamg](https://github.com/ikraamg))
- Update install instructions after 2.11 release [#3825](https://github.com/solidusio/solidus/pull/3825) ([kennyadsl](https://github.com/kennyadsl))
- Move "thinking cat" fixture to lib folder [#3824](https://github.com/solidusio/solidus/pull/3824) ([mamhoff](https://github.com/mamhoff))
- Update readme with Solidus demo URL [#3822](https://github.com/solidusio/solidus/pull/3822) ([seand7565](https://github.com/seand7565))
- Fix headers in changelog [#3812](https://github.com/solidusio/solidus/pull/3812) ([jarednorman](https://github.com/jarednorman))
- Fixed typo with misspell [#3811](https://github.com/solidusio/solidus/pull/3811) ([hsbt](https://github.com/hsbt))

## Solidus 2.11.17 (v2.11, 2022-07-11)

- Fixed user restricted stock management in [#4398](https://github.com/solidusio/solidus/pull/4398) by [@rmparr](https://github.com/rmparr)
- Backported docker development environment in [#4408](https://github.com/solidusio/solidus/pull/4408) by [@waiting-for-dev](https://github.com/waiting-for-dev)
- Removed N+1 from admin users in [#4422](https://github.com/solidusio/solidus/pull/4422) by [@tvdeyen](https://github.com/tvdeyen)
- Fixed delete response in admin users controller in [#4418](https://github.com/solidusio/solidus/pull/4418) by [@tvdeyen](https://github.com/tvdeyen)
- Support CVE-2022-32224 Rails security updates in [#4455](https://github.com/solidusio/solidus/pull/4455) backport by [@gsmendoza](https://github.com/gsmendoza)

### Breaking changes

**NOTE:** This release contains a breaking change due to the backport of the
fixes for CVE-2022-32224 in
[#4455](https://github.com/solidusio/solidus/pull/4455), specifically due to the
switch to `YAML.safe_load` in `Spree::LogEntry`
[here](https://github.com/solidusio/solidus/pull/4455/commits/d2b05aa1a9ec6903027a880f5d466c5abd5b8f05).
To ensure compatibility with this change, you may need to update your app
configuration for `Spree::AppConfiguration#log_entry_permitted_classes` and
ensure it includes any constants that may be serialized in YAML in addition to
the already allowed ones by
[core](https://github.com/solidusio/solidus/pull/4455/files#diff-96cc27eba934e1e96a1ffc0e5574406061f5b4f48770faeba62a062544b8633bR11)
or any extensions you may use.

## Solidus 2.11.15 (v2.11, 2022-03-10)

- V2.11 - Fix non auto populated customer info [#4247](https://github.com/solidusio/solidus/pull/4247) ([nbelzer](https://github.com/nbelzer))
- [BACKPORT] Reintroduce inverse_of: :product for variants association [#4234](https://github.com/solidusio/solidus/pull/4234) ([spaghetticode](https://github.com/spaghetticode))
- Backport #4228 to V2.11 [#4230](https://github.com/solidusio/solidus/pull/4230) ([jcsanti](https://github.com/jcsanti))
- v2.11 fix(Address): Set name from firstname and lastname on update [#4224](https://github.com/solidusio/solidus/pull/4224) ([tvdeyen](https://github.com/tvdeyen))
- Backport #3913 to V2.11 [#4174](https://github.com/solidusio/solidus/pull/4174) ([spaghetticode](https://github.com/spaghetticode))

## Solidus 2.11.14 (v2.11, 2021-12-20)

- Fix CSRF forgery protection bypass for Spree::OrdersController#populate [GHSA-h3fg-h5v3-vf8m](https://github.com/solidusio/solidus/security/advisories/GHSA-h3fg-h5v3-vf8m)

## Solidus 2.11.13 (v2.11, 2021-12-07)

- Fix ReDos vulnerability on Spree::EmailValidator::EMAIL_REGEXP [GHSA-qxmr-qxh6-2cc9](https://github.com/solidusio/solidus/security/advisories/GHSA-qxmr-qxh6-2cc9)
- Use SSL on fonts.googleapis.com scss import [#4212](https://github.com/solidusio/solidus/pull/4212) [RyanofWoods](https://github.com/RyanofWoods)

## Solidus 2.11.12 (v2.11, 2021-11-17)

- Monkey patch Authentication Bypass by CSRF Weakness vulnerability on solidus_auth_devise for extra security [GHSA-5629-8855-gf4g](https://github.com/solidusio/solidus/security/advisories/GHSA-5629-8855-gf4g)

## Solidus 2.11.11 (v2.11, 2021-09-10)

- Revert "Raise canceling a payment when try_void" [#4134](https://github.com/solidusio/solidus/pull/4134) ([senemsoy](https://github.com/senemsoy))
- Fix app and tests to work with ActiveRecord.has_many_inverse [#4099](https://github.com/solidusio/solidus/pull/4099) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Update billing address migration tasks with batch limit [#4104](https://github.com/solidusio/solidus/pull/4104) ([spaghetticode](https://github.com/spaghetticode))
- Permit return_items_attributes return_reason_id [#4090](https://github.com/solidusio/solidus/pull/4090) ([spaghetticode](https://github.com/spaghetticode))

## Solidus 2.11.10 (v2.11, 2021-05-10)

- Use symbols in polymorphic path for event_links [#4048](https://github.com/solidusio/solidus/pull/4048) ([tvdeyen](https://github.com/tvdeyen))
## Solidus 2.11.9 (v2.11, 2021-04-20)

- Rescue FileNotFoundError exception on failed image downloads [#4026](https://github.com/solidusio/solidus/pull/4026) ([cpfergus1](https://github.com/cpfergus1))
- Image attachment content type validation fix for ActiveStorage [#4021](https://github.com/solidusio/solidus/pull/4021) ([cpfergus1](https://github.com/cpfergus1))
- Switch to the correct ActiveStorage variant syntax [#4003](https://github.com/solidusio/solidus/pull/4003) ([filippoliverani](https://github.com/filippoliverani))
- Only run spring stop in install generator if spring is available [#3999](https://github.com/solidusio/solidus/pull/3999) ([Noah-Silvera](https://github.com/Noah-Silvera))
- Fix double store credits creation when performing refunds [#3989](https://github.com/solidusio/solidus/pull/3989) ([spaghetticode](https://github.com/spaghetticode))
- Fix default billing address migration on sqlite [#4020](https://github.com/solidusio/solidus/pull/4020) ([waiting-for-dev](https://github.com/waiting-for-dev))

## Solidus 2.11.8 (v2.11, 2021-04-01)

- Deprecate calling preferences without serialization [#4013](https://github.com/solidusio/solidus/pull/4013) ([mamhoff](https://github.com/mamhoff))

## Solidus 2.11.7 (v2.11, 2021-03-18)

- Use Spree.user_class instead of Spree::LegacyUser in production code [#3995](https://github.com/solidusio/solidus/pull/3995) ([mamhoff](https://github.com/mamhoff))
## Solidus 2.11.6 (v2.11, 2021-03-18)

- Allow accessing preferences on models that do not have any set [#3998](https://github.com/solidusio/solidus/pull/3998) ([kennyadsl](https://github.com/kennyadsl))
- Fix for incorrect deprecation class [#3991](https://github.com/solidusio/solidus/pull/3991) ([tmtrademarked](https://github.com/tmtrademarked))
## Solidus 2.11.5 (v2.11, 2021-03-09)

- Improve address name migration task output [#3982](https://github.com/solidusio/solidus/pull/3982) ([kennyadsl](https://github.com/kennyadsl))
- Add Address name data migration rake task [#3933](https://github.com/solidusio/solidus/pull/3933) ([spaghetticode](https://github.com/spaghetticode))
- Add and start populating `spree_addresses.name` field [#3962](https://github.com/solidusio/solidus/pull/3962) ([spaghetticode](https://github.com/spaghetticode))
- Fix circular reference in factory [#3959](https://github.com/solidusio/solidus/pull/3959) ([waiting-for-dev](https://github.com/waiting-for-dev))
- Remove Deprecation Warning in ActiveModel Errors [#3946](https://github.com/solidusio/solidus/pull/3946) ([Azeem838](https://github.com/Azeem838))
- Only use #original_message in Api::BaseController#parameter_missing_error if defined [#3940](https://github.com/solidusio/solidus/pull/3940) ([dividedharmony](https://github.com/dividedharmony))
- Pre-select current tax category on product form [#3936](https://github.com/solidusio/solidus/pull/3936) ([spaghetticode](https://github.com/spaghetticode))
- Inline the attachment form for taxon icons [#3932](https://github.com/solidusio/solidus/pull/3932) ([elia](https://github.com/elia))
- Show 'guest' correctly in order customer details [#3910](https://github.com/solidusio/solidus/pull/3910) ([nirebu](https://github.com/nirebu))
- Relax Money dependency in development [#3958](https://github.com/solidusio/solidus/pull/3958) ([kennyadsl](https://github.com/kennyadsl))
- Lock money gem in development until next release [#3909](https://github.com/solidusio/solidus/pull/3909) ([kennyadsl](https://github.com/kennyadsl))
- Fix factory loading [#3907](https://github.com/solidusio/solidus/pull/3907) ([elia](https://github.com/elia))
- [Admin] Automatically check edited return items in RMA form [#3904](https://github.com/solidusio/solidus/pull/3904) ([spaghetticode](https://github.com/spaghetticode))
- Fix ActionMailer preview loading [#3901](https://github.com/solidusio/solidus/pull/3901) ([aldesantis](https://github.com/aldesantis))
- Convert jQuery data attribute to number [#3899](https://github.com/solidusio/solidus/pull/3899) ([spaghetticode](https://github.com/spaghetticode))
- Add English variants to select2_local directory [#3895](https://github.com/solidusio/solidus/pull/3895) ([michaelmichael](https://github.com/michaelmichael))
- Remove awesome_nested_set override for Rails 6.1 compatibility [#3893](https://github.com/solidusio/solidus/pull/3893) ([kennyadsl](https://github.com/kennyadsl))
- Set dummy app forgery protection to false [#3887](https://github.com/solidusio/solidus/pull/3887) ([FrancescoAiello01](https://github.com/FrancescoAiello01))
- Enable ActiveStorage specs against Rails 6.1 [#3886](https://github.com/solidusio/solidus/pull/3886) ([kennyadsl](https://github.com/kennyadsl))
- Migrate default billing addresses to address book [#3838](https://github.com/solidusio/solidus/pull/3838) ([mamhoff](https://github.com/mamhoff))

## Solidus 2.11.4 (2021-01-19)

- Update taxon icon to use present instead of exists [#3869](https://github.com/solidusio/solidus/pull/3869) ([seand7565](https://github.com/seand7565))
- Update canonical-rails syntax for latest version [#3865](https://github.com/solidusio/solidus/pull/3865) ([brchristian](https://github.com/brchristian))
- Add Rails 6.1 support [#3862](https://github.com/solidusio/solidus/pull/3862) ([filippoliverani](https://github.com/filippoliverani))
- Deprecate unused calculators [#3863](https://github.com/solidusio/solidus/pull/3863) ([DanielePalombo](https://github.com/DanielePalombo))
- Remove ability to void invalid payments [#3858](https://github.com/solidusio/solidus/pull/3858) ([vl3](https://github.com/vl3))
- Add soft-delete support for Api::ResourceController [#3854](https://github.com/solidusio/solidus/pull/3854) ([cedum](https://github.com/cedum))
- Remove deprecated sass color-#{state} variables usage [#3853](https://github.com/solidusio/solidus/pull/3853) ([kennyadsl](https://github.com/kennyadsl))
- Remove the gray border inside a product image [#3851](https://github.com/solidusio/solidus/pull/3851) ([mfrecchiami](https://github.com/mfrecchiami))
- Remove all usage of FooAbility and BarAbility when testing abilities [#3850](https://github.com/solidusio/solidus/pull/3850) ([kennyadsl](https://github.com/kennyadsl))
- Rename all occurrences of emails with spree username to solidus [#3849](https://github.com/solidusio/solidus/pull/3849) https://github.com/rubenochiavone
- Avoid `#method` shadowing [#3846](https://github.com/solidusio/solidus/pull/3846) ([spaghetticode](https://github.com/spaghetticode))
- Move UserClassHandle to lib/ [#3813](https://github.com/solidusio/solidus/pull/3813) ([elia](https://github.com/elia))
- Fix use_legacy_address_state_validator deprecation message [#3845](https://github.com/solidusio/solidus/pull/3845) ([kennyadsl](https://github.com/kennyadsl))
- Fix the factories loading mechanism [#3814](https://github.com/solidusio/solidus/pull/3814) ([elia](https://github.com/elia))

## Solidus 2.11.3 (2020-11-18)

- Fix reassign image to another variant in admin [#3810](https://github.com/solidusio/solidus/pull/3810) ([felixyz](https://github.com/felixyz))
- Remove seeds for images associated to master variant [#3805](https://github.com/solidusio/solidus/pull/3805) ([aleph1ow](https://github.com/aleph1ow))
- Check for edit permission when showing store credit edit link [#3843](https://github.com/solidusio/solidus/pull/3843) ([spaghetticode](https://github.com/spaghetticode))
- Use the right method in the AddApplyToAllToVariantPropertyRule migration [#3815](https://github.com/solidusio/solidus/pull/3815) ([ok32](https://github.com/ok32))
- Fix permissions to see admin menu items [#3840](https://github.com/solidusio/solidus/pull/3840) ([kennyadsl](https://github.com/kennyadsl))
- Avoid asking user to run migration creating the sandbox [#3839](https://github.com/solidusio/solidus/pull/3839) ([kennyadsl](https://github.com/kennyadsl))

## Solidus 2.11.2 (2020-11-12)

- Fix ability to perform refunds after a first failed attempt [#3831](https://github.com/solidusio/solidus/pull/3831) ([kennyadsl](https://github.com/kennyadsl))

## Solidus 2.11.1 (2020-11-6)

- Lock Rails version to < 6.1.x [#3832](https://github.com/solidusio/solidus/pull/3832) ([kennyadsl](https://github.com/kennyadsl))

## Solidus 2.11.0 (2020-10-23)

### Major Changes

**Removed support for Rails 5.1**

Rails 5.1 is not maintained anymore, we deprecated it in 2.10 so it's time to
remove it entirely.

- Remove Rails 5.1 support [#3328](https://github.com/solidusio/solidus/pull/3328) ([kennyadsl](https://github.com/kennyadsl))

**Add `billing_address_required` preference**

The new preference controls whether validations will require the presence of
the billing address.

- Allow to specify if billing address is required for orders [#3658](https://github.com/solidusio/solidus/pull/3658) ([softr8](https://github.com/softr8))

**Add BCC email to order confirmation emails**

Spree::Store model now accepts a BCC email field that, when present, will be
used in order confirmation emails.

- Add BCC email to spree_store [#3646](https://github.com/solidusio/solidus/pull/3646) ([seand7565](https://github.com/seand7565))

**Order merger and order updater now require valid order**

The order merger and order updater will complete successfully only on valid
orders. This new behavior is opt-in with this release, but will become the
default from Solidus 3.0.

You can enable this feature right now by setting the preference with
`Spree::Config.run_order_validations_on_order_updater = true`

- Add ability to run validations in order updater [#3645](https://github.com/solidusio/solidus/pull/3645) ([kennyadsl](https://github.com/kennyadsl))

**Stop calling `Spree::Refund#perform!` after creating a refund**

From Solidus v3.0 onwards, #perform! will need to be explicitly called when
creating new refunds. Please, change your code from:

`Spree::Refund.create(your: attributes)`

to:

`Spree::Refund.create(your: attributes, perform_after_creation: false).perform!`

The `perform_after_creation` attribute will be deprecated in Solidus 3.x.

- Stop calling perform! as Spree::Refund after_create callback  [#3641](https://github.com/solidusio/solidus/pull/3641) ([kennyadsl](https://github.com/kennyadsl))

**Allow to configure guest_token cookie options**

The guest_token cookie is currently always only allowed for the current domain,
including subdomain. If you want to use the cookie on a different subdomain you
can use the preference `guest_token_cookie_options`.

- Allow to configure guest_token cookie options [#3621](https://github.com/solidusio/solidus/pull/3621) ([tvdeyen](https://github.com/tvdeyen))

**Add event subscribers automatically**

Event subscribers are now loaded automatically when their source file
is placed under the directory `app/subscribers` and filename ends with
`_subscriber.rb`. This works both for Solidus core, Solidus extensions
and the store app.

If you have any custom subscribers with an explicit subscription (i.e. `MyCustomSubscriber.subscribe!`) ensure they're under `app/subscribers` path and remove the explicit subscriptions from your app initializer (i.e `MyCustomSubscriber.subscribe!`).

- [Events] Add subscribers automatically [#3571](https://github.com/solidusio/solidus/pull/3571) ([spaghetticode](https://github.com/spaghetticode))
- [Events] Change internal mapping for event subscriber registrations [#3758](https://github.com/solidusio/solidus/pull/3758) ([spaghetticode](https://github.com/spaghetticode))

**Add address default for billing as well**

It's now possible to mark an address as default for billing with the
column `default_billing`.

- Uniform bill_address and ship_address behaviour in Spree::UserAddressBook module [#3563](https://github.com/solidusio/solidus/pull/3563) ([oldjackson](https://github.com/oldjackson))

**Getting closer to completely replace Paranoia with Discard**

We're getting closer to fully replace Paranoia with Discard. Paranoia
methods have been fully deprecated, so you're encouraged to switch to
Discard also in your store codebase.

- DRY paranoia and discard inclusion into models [#3555](https://github.com/solidusio/solidus/pull/3555) ([cedum](https://github.com/cedum))
- Replace Paranoia methods with Discard equivalents [#3554](https://github.com/solidusio/solidus/pull/3554) ([cedum](https://github.com/cedum))

**Add ActiveStorage adapter**

From Rails 6.1 ActiveStorage will support public blob URLs and Solidus
should be ready to offer an ActiveStorage adapter to new stores.

- Always set ActiveStorage::Current.host in base controllers [#3613](https://github.com/solidusio/solidus/pull/3613) ([filippoliverani](https://github.com/filippoliverani))
- Add ActiveStorage adapter [#3501](https://github.com/solidusio/solidus/pull/3501) ([filippoliverani](https://github.com/filippoliverani))

**Introduce Address#name**

We're going to introduce the new column `name` for addresses that will
replace the existing `first_name` and `last_name`. In preparation of
this, we're now introducing a virtual attribute name that works like
and replaces #full_name.

- Add name to Spree::Address [#3458](https://github.com/solidusio/solidus/pull/3458) ([filippoliverani](https://github.com/filippoliverani))
- Use Address name attribute in views and APIs [#3524](https://github.com/solidusio/solidus/pull/3524) ([filippoliverani](https://github.com/filippoliverani))

**Replace Spree.routes with Spree.pathFor**
The use of `Spree.routes` is now deprecated. You can check in your
browser developer tools console for deprecation messages.

- Replace Spree.routes with Spree.pathFor [#3605](https://github.com/solidusio/solidus/pull/3605) ([seand7565](https://github.com/seand7565))

**Configurable order state machine with new default**
The order state machine class is now configurable, just like other models  state machines. Also, a simplified version of the current state machine will
be the new default in Solidus 3.x.

- Configurable order state machine and reduce the number of possible transitions [#3542](https://github.com/solidusio/solidus/pull/3542) ([mamhoff](https://github.com/mamhoff))

**Include payment methods in installer**
Solidus installer has now a section for installing payment method gems out of the box.
Currently, the only available gem is `solidus_paypal_commerce_platform`.

- Add payment method selection to the install generator [#3731](https://github.com/solidusio/solidus/pull/3731) ([elia](https://github.com/elia))

**Remove CanCanCan custom actions aliases**
CanCanCan custom action aliases have been deprecated and replaced with default ones to make it easier upgrading to newer versions of CanCanCan.
A new application preference has been introduced: `use_custom_cancancan_actions` which when set to:
- `true` will still accept using custom aliases (default for existing applications);
- `false` any custom aliases defined previously won't be handled anymore by Solidus.

Ensure double-checking all the custom defined permissions in your application before switching to `use_custom_cancancan_actions` preference to `false`.

- Remove CanCanCan custom actions aliases (cont.) [#3701](https://github.com/solidusio/solidus/pull/3701) ([filippoliverani](https://github.com/filippoliverani))

**Introduce encrypted preference type**
A new preference type `encrypted_string` has been introduced allowing to encrypt the value assigned to the preference to avoid exposing it in case a malicious user gets access to the DB or a dump.
Check the related guide for more details https://guides.solidus.io/developers/preferences/add-model-preferences.html#details-for-encrypted_string-type .

- Add new type encrypted_string for preferences [#3676](https://github.com/solidusio/solidus/pull/3676) ([stefano-sarioli](https://github.com/stefano-sarioli))

**Add "discontinue on" attribute to products**
Adds a `discontinue_on` attribute to products. This accompanies the `available_on` attribute to complete the "Time Based Availability" feature. The `Product.available` scope and `Product#avaliable?` method take this new date field into account to calculate the availability of products.

- Add discontinue on to products [#3793](https://github.com/solidusio/solidus/pull/3793) ([tvdeyen](https://github.com/tvdeyen))

**Fixed how the default reimbursement store-credit category is fetched**
Before this change the store-credit category for reimbursement was fetched by name using a missing translation (i.e. `en.spree.store_credit_category.default`) that resulted in the name "Default". If no category was found the code fell back on the first category from the database, which wasn't guaranteed to be the right one. Trying to update the translation to the desired category name was also useless due to how code was loaded.
Now it's possible to disable this legacy behavior and switch to a simpler one, in which the code will look for a CreditCategory named "Reimbursement". Here's a list of checks and fixes you can perform to ensure you can enable the correct implementation:

* If you don't use reimbursements you're good to go, skip below to _Disabling the legacy behavior_
* Ensure you didn't decorate or patched any of the involved code, especially:
  * `Spree::StoreCreditCategory.reimbursement_category`
  * `Spree::StoreCreditCategory.reimbursement_category_name`
* Ensure your "production" environment is already returning the correct category, you can assess that by running this in your "production" console: `Spree::StoreCreditCategory.reimbursement_category(nil).name == "Reimbursement"`

_Disabling the legacy behavior_
If everything is sound, or you are ok with a different category name for newly created reimbursement store credits you can switch to the new behavior by configuring this Solidus preference in your spree.rb initializer:

```ruby
Spree.config do |config|
  config.use_legacy_store_credit_reimbursement_category_name = false
end
```

If you had modifications in your codebase consider disabling the legacy behavior and porting them to a simple overwrite of `Spree::Reimbursement#store_credit_category`.
The legacy behavior will be removed in the next major version of Solidus.

- Fix reimbursement_category_name ending up in a translation missing error [#3507](https://github.com/solidusio/solidus/pull/3507) ([elia](https://github.com/elia))

**Do not consider promotions without actions as active**

When considering to apply a promotion to an order we use the `active` scope.
This scope was including promotions without actions and we no longer are taking them into account.

To switch to the new behaviour which will be the only one accepted in Solidus 3.0 change the following preference `Spree::Config.consider_actionless_promotion_active` to `false`.

If you need to consider actionless promotions as active for any reason please implement your own scope for that.

- Do not consider promotions without actions as active [#3749](https://github.com/solidusio/solidus/pull/3749) ([DanielePalombo](https://github.com/DanielePalombo))

### Core

- Don't combine splat and hash, just use the attribute form [#3742](https://github.com/solidusio/solidus/pull/3742) ([marcrohloff](https://github.com/marcrohloff))
- Fix rails 61 deprecations [#3740](https://github.com/solidusio/solidus/pull/3740) ([marcrohloff](https://github.com/marcrohloff))
- Fix ruby 2.7 warnings on core [#3737](https://github.com/solidusio/solidus/pull/3737) ([stefano-sarioli](https://github.com/stefano-sarioli))
- Make payment.rb methods more concise [#3734](https://github.com/solidusio/solidus/pull/3734) ([brchristian](https://github.com/brchristian))
- Refactor Product#available? to match docs [#3733](https://github.com/solidusio/solidus/pull/3733) ([brchristian](https://github.com/brchristian))
- Show a deprecation message for PaymentMethod::DISPLAY [#3716](https://github.com/solidusio/solidus/pull/3716) ([cedum](https://github.com/cedum))
- Make Spree::Payment::Processing#handle_void_response public [#3708](https://github.com/solidusio/solidus/pull/3708) ([spaghetticode](https://github.com/spaghetticode))
- Fix typo in comment in promotion.rb [#3693](https://github.com/solidusio/solidus/pull/3693) ([brchristian](https://github.com/brchristian))
- Add Refund#perform_response and reintroduce @response ivar [#3672](https://github.com/solidusio/solidus/pull/3672) ([spaghetticode](https://github.com/spaghetticode))
- Fix bug related to free shipping not being applied correctly [#3671](https://github.com/solidusio/solidus/pull/3671) ([jacquesporveau](https://github.com/jacquesporveau))
- Cancel authorized (pending) payments when cancelling an order (cont.) [#3662](https://github.com/solidusio/solidus/pull/3662) ([filippoliverani](https://github.com/filippoliverani))
- Allow Importer::Order to accept array of line items and stock_location_id [#3655](https://github.com/solidusio/solidus/pull/3655) ([ccarruitero](https://github.com/ccarruitero))
- Make Order#shipping_discount consider only credits [#3640](https://github.com/solidusio/solidus/pull/3640) ([spaghetticode](https://github.com/spaghetticode))
- Fixing mark default billing address [#3634](https://github.com/solidusio/solidus/pull/3634) ([softr8](https://github.com/softr8))
- Remove the duplicated active scope and name validations [#3629](https://github.com/solidusio/solidus/pull/3629) ([halilim](https://github.com/halilim))
- Added select on product's scopes for price sorting [#3620](https://github.com/solidusio/solidus/pull/3620) ([thomasrossetto](https://github.com/thomasrossetto))
- Fix in_taxons scope when taxon is an ActiveRecord::Base [#3617](https://github.com/solidusio/solidus/pull/3617) ([kennyadsl](https://github.com/kennyadsl))
- Only perform regexes on Strings [#3616](https://github.com/solidusio/solidus/pull/3616) ([jacquesporveau](https://github.com/jacquesporveau))
- Set canceled_at date when canceling an order with cancel (issue #3608) [#3610](https://github.com/solidusio/solidus/pull/3610) ([gugaiz](https://github.com/gugaiz))
- Fix error message on email preview [#3607](https://github.com/solidusio/solidus/pull/3607) ([coorasse](https://github.com/coorasse))
- Remove Deface overrides initializer [#3587](https://github.com/solidusio/solidus/pull/3587) ([aldesantis](https://github.com/aldesantis))
- Make Payment#gateway_order_id public [#3583](https://github.com/solidusio/solidus/pull/3583) ([spaghetticode](https://github.com/spaghetticode))
- Making simple coordinator insufficient stock to include a message [#3577](https://github.com/solidusio/solidus/pull/3577) ([softr8](https://github.com/softr8))
- [Events] Add subscribers automatically [#3571](https://github.com/solidusio/solidus/pull/3571) ([spaghetticode](https://github.com/spaghetticode))
- Validate uniqueness with case_sensitive: true explicitly [#3569](https://github.com/solidusio/solidus/pull/3569) ([kennyadsl](https://github.com/kennyadsl))
- Add order_recalculated event [#3553](https://github.com/solidusio/solidus/pull/3553) ([spaghetticode](https://github.com/spaghetticode))
- Build default address with an existing method in checkout address [#3548](https://github.com/solidusio/solidus/pull/3548) ([kennyadsl](https://github.com/kennyadsl))
- Replace `Spree::Event#name_with_suffix` with `adapter#normalize_name` [#3519](https://github.com/solidusio/solidus/pull/3519) ([spaghetticode](https://github.com/spaghetticode))
- Spree::OptionValue#name delegates to Spree::OptionType even when nil [#3517](https://github.com/solidusio/solidus/pull/3517) ([SamuelMartini](https://github.com/SamuelMartini))
- Improve unstocking inventory units from stock locations [#3514](https://github.com/solidusio/solidus/pull/3514) ([AlessioRocco](https://github.com/AlessioRocco))
- Memoize Spree::User#wallet method [#3513](https://github.com/solidusio/solidus/pull/3513) ([AlessioRocco](https://github.com/AlessioRocco))
- Allow multiple events subscription with regexp [#3512](https://github.com/solidusio/solidus/pull/3512) ([spaghetticode](https://github.com/spaghetticode))
- Only log basic response information [#3508](https://github.com/solidusio/solidus/pull/3508) ([JDutil](https://github.com/JDutil))
- Remove conditional code that targets Rails 5.1 [#3505](https://github.com/solidusio/solidus/pull/3505) ([kennyadsl](https://github.com/kennyadsl))
- Disable codes on apply automatically promo [#3502](https://github.com/solidusio/solidus/pull/3502) ([MassimilianoLattanzio](https://github.com/MassimilianoLattanzio))
- Replace map.sum with sum [#3498](https://github.com/solidusio/solidus/pull/3498) ([grzegorz-jakubiak](https://github.com/grzegorz-jakubiak))
- Calling to_proc is faster than argumentless method [#3497](https://github.com/solidusio/solidus/pull/3497) ([grzegorz-jakubiak](https://github.com/grzegorz-jakubiak))
- Use create_if_necessary instead of a simple find_or_initialize [#3494](https://github.com/solidusio/solidus/pull/3494) ([elia](https://github.com/elia))
- Replace map.flatten with flat_map [#3491](https://github.com/solidusio/solidus/pull/3491) ([grzegorz-jakubiak](https://github.com/grzegorz-jakubiak))
- Reintroduce and deprecate Order#deliver_order_confirmation_email [#3485](https://github.com/solidusio/solidus/pull/3485) ([elia](https://github.com/elia))
- Fix order state with customer returns when receiving return items [#3483](https://github.com/solidusio/solidus/pull/3483) ([elia](https://github.com/elia))
- Remove user address reference when removing address from the address [#3482](https://github.com/solidusio/solidus/pull/3482) ([SamuelMartini](https://github.com/SamuelMartini))
- Use Spree::Base as models base class [#3476](https://github.com/solidusio/solidus/pull/3476) ([filippoliverani](https://github.com/filippoliverani))
- Deprecate raising an exception when order and line item currencies mismatch [#3456](https://github.com/solidusio/solidus/pull/3456) ([kennyadsl](https://github.com/kennyadsl))
- When a controller action fails to be authorized, redirect back or default to /unauthorized [#3118](https://github.com/solidusio/solidus/pull/3118) ([genarorg](https://github.com/genarorg))
- Add make_default method on AddPaymentSourcesToWallet class [#2913](https://github.com/solidusio/solidus/pull/2913) ([vassalloandrea](https://github.com/vassalloandrea))
- Permit passing an address via payment source parameters [#3713](https://github.com/solidusio/solidus/pull/3713) ([kennyadsl](https://github.com/kennyadsl))
- Allow capturing or voiding payments only with positive amount [#3761](https://github.com/solidusio/solidus/pull/3761) ([spaghetticode](https://github.com/spaghetticode))
- Fix address validation having a country w/o states [#3763](https://github.com/solidusio/solidus/pull/3763) ([cedum](https://github.com/cedum))
- Remove a N+1 query on shipment model [#3598](https://github.com/solidusio/solidus/pull/3598) ([albanv](https://github.com/albanv))
- Fix Italy state seed generation [#3722](https://github.com/solidusio/solidus/pull/3722) ([seand7565](https://github.com/seand7565))
- Add preference for phone validation [#3685](https://github.com/solidusio/solidus/pull/3685) ([seand7565](https://github.com/seand7565))
- Refactor address state validation [#3129](https://github.com/solidusio/solidus/pull/3129) ([cedum](https://github.com/cedum))
- Fix the singular translation for Spree::Role [#3799](https://github.com/solidusio/solidus/pull/3799) ([elia](https://github.com/elia))
- Fix the install generator [#3777](https://github.com/solidusio/solidus/pull/3777) ([seand7565](https://github.com/seand7565))
- TaxHelpers#rates_for_item now respects the validity period of tax rates [#3768](https://github.com/solidusio/solidus/pull/3768) ([jugglinghobo](https://github.com/jugglinghobo))

### Backend

- Fix Ruby 2.7 warnings on backend [#3746](https://github.com/solidusio/solidus/pull/3746) ([stefano-sarioli](https://github.com/stefano-sarioli))
- Respect current ability in users controllers [#3732](https://github.com/solidusio/solidus/pull/3732) ([igorbp](https://github.com/igorbp))
- [Admin] Disallow promotions with empty action type and discount rule [#3724](https://github.com/solidusio/solidus/pull/3724) ([cnorm35](https://github.com/cnorm35))
- Replace duplicate data-hook name [#3705](https://github.com/solidusio/solidus/pull/3705) ([seand7565](https://github.com/seand7565))
- Change to true/false to yes/no in Auto Capture Select Text [#3703](https://github.com/solidusio/solidus/pull/3703) ([michaelmichael](https://github.com/michaelmichael))
- [Admin] Fix Square Logos appearance [#3702](https://github.com/solidusio/solidus/pull/3702) ([michaelmichael](https://github.com/michaelmichael))
- [Admin] Add filter feature for stock movements [#3680](https://github.com/solidusio/solidus/pull/3680) ([jacquesporveau](https://github.com/jacquesporveau))
- Display originator email in stock movement admin [#3673](https://github.com/solidusio/solidus/pull/3673) ([jacquesporveau](https://github.com/jacquesporveau))
- [Backend] More precise cancan validations for some resource links [#3654](https://github.com/solidusio/solidus/pull/3654) ([spaghetticode](https://github.com/spaghetticode))
- Variant property rules to optionally match all conditions (cont.) [#3653](https://github.com/solidusio/solidus/pull/3653) ([filippoliverani](https://github.com/filippoliverani))
- Eager loading countries when creating a new zone [#3649](https://github.com/solidusio/solidus/pull/3649) ([softr8](https://github.com/softr8))
- Remove unused XHR code [#3642](https://github.com/solidusio/solidus/pull/3642) ([halilim](https://github.com/halilim))
- Admin UI for shipping methods - stock locations association [#3624](https://github.com/solidusio/solidus/pull/3624) ([cedum](https://github.com/cedum))
- Refactoring Admin::ProductsController to use ResourcesController#update [#3603](https://github.com/solidusio/solidus/pull/3603) ([softr8](https://github.com/softr8))
- Rescuing from ActiveRecord::RecordInvalid in ResourcesController [#3602](https://github.com/solidusio/solidus/pull/3602) ([softr8](https://github.com/softr8))
- Adding missing paginator when listing all stock locations [#3600](https://github.com/solidusio/solidus/pull/3600) ([softr8](https://github.com/softr8))
- Show only active promotions filter [#3595](https://github.com/solidusio/solidus/pull/3595) ([wildbillcat](https://github.com/wildbillcat))
- Unified Handling of Option Values and Product Properties List [#3592](https://github.com/solidusio/solidus/pull/3592) ([hefan](https://github.com/hefan))
- Do not pass non persistent new records when sorting tables by removing non numeric ids [#3591](https://github.com/solidusio/solidus/pull/3591) ([hefan](https://github.com/hefan))
- Check if promotions exist without extra db query [#3586](https://github.com/solidusio/solidus/pull/3586) ([katafrakt](https://github.com/katafrakt))
- Do not display non-eligible adjustments in the admin cart overview [#3585](https://github.com/solidusio/solidus/pull/3585) ([coorasse](https://github.com/coorasse))
- Backend: more robust update_positions for resource controller [#3581](https://github.com/solidusio/solidus/pull/3581) ([hefan](https://github.com/hefan))
- [Backend] Handle errors and flash messages editing a taxon [#3574](https://github.com/solidusio/solidus/pull/3574) ([softr8](https://github.com/softr8))
- Remove non-existing middleware [#3570](https://github.com/solidusio/solidus/pull/3570) ([coorasse](https://github.com/coorasse))
- Add ability to select multiple rows on Admin Tables [#3565](https://github.com/solidusio/solidus/pull/3565) ([DanielePalombo](https://github.com/DanielePalombo))
- Add support for prefill user address in new order [#3558](https://github.com/solidusio/solidus/pull/3558) ([jaimelr](https://github.com/jaimelr))
- replace link_to_add_fields usage and deprecate helper function [#3547](https://github.com/solidusio/solidus/pull/3547) ([hefan](https://github.com/hefan))
- Convert ES6 arrow syntax to ES5 for compatibility [#3511](https://github.com/solidusio/solidus/pull/3511) ([pelargir](https://github.com/pelargir))
- Ensure payment methods are ordered correctly [#3506](https://github.com/solidusio/solidus/pull/3506) ([AlistairNorman](https://github.com/AlistairNorman))
- [Admin] Change shipment email checkbox label [#3490](https://github.com/solidusio/solidus/pull/3490) ([kennyadsl](https://github.com/kennyadsl))
- Use RESTful routing for users' API key management [#3442](https://github.com/solidusio/solidus/pull/3442) ([kennyadsl](https://github.com/kennyadsl))
- Fix issue 3164 - generate shipments for backend-added products when necessary [#3197](https://github.com/solidusio/solidus/pull/3197) ([spaghetticode](https://github.com/spaghetticode))
- Fixes for consistent handling of resource errors on admin  [#3728](https://github.com/solidusio/solidus/pull/3728) ([ikraamg](https://github.com/ikraamg))
- Expose js function: Spree.SortableTable.refresh [#3754](https://github.com/solidusio/solidus/pull/3754) ([brunoao86](https://github.com/brunoao86))
- Fix TaxCategory default not showing up in admin [#3759](https://github.com/solidusio/solidus/pull/3759) ([vl3](https://github.com/vl3))
- Make order customer email links consistent [#3767](https://github.com/solidusio/solidus/pull/3767) ([brchristian](https://github.com/brchristian))
- Fix typo in comment in navigation_helper.rb [#3770](https://github.com/solidusio/solidus/pull/3770) ([brchristian](https://github.com/brchristian))
- Make admin order event_links translatable [#3772](https://github.com/solidusio/solidus/pull/3772) ([tvdeyen](https://github.com/tvdeyen))
- Display billing address to left of shipping address [#3773](https://github.com/solidusio/solidus/pull/3773) ([brchristian](https://github.com/brchristian))
- Add hint to tax category default checkbox [#3778](https://github.com/solidusio/solidus/pull/3778) ([pelargir](https://github.com/pelargir))
- Add link to stock movements page from variant stock display [#3779](https://github.com/solidusio/solidus/pull/3779) ([seand7565](https://github.com/seand7565))
- Update backend New Image link for consistency [#3786](https://github.com/solidusio/solidus/pull/3786) ([brchristian](https://github.com/brchristian))
- Show the admin/settings menu for any of its elements [#3783](https://github.com/solidusio/solidus/pull/3783) ([elia](https://github.com/elia))
- Improve the developer experience with the new Ability deprecations [#3801](https://github.com/solidusio/solidus/pull/3801) ([elia](https://github.com/elia))
- Ensure #resource_not_found mentions the right model [#3798](https://github.com/solidusio/solidus/pull/3798) ([elia](https://github.com/elia))
- Add CSS selector for datetime-local [#3792](https://github.com/solidusio/solidus/pull/3792) ([jacobherrington](https://github.com/jacobherrington))
- Remove CSS resizing logo when menu collapses [#3791](https://github.com/solidusio/solidus/pull/3791) ([jacobherrington](https://github.com/jacobherrington))

### Frontend

- Allow for HTML options on image partial [#3741](https://github.com/solidusio/solidus/pull/3741) ([markmead](https://github.com/markmead))
- Use a better name for CheckoutController#set_state_if_present [#3496](https://github.com/solidusio/solidus/pull/3496) ([elia](https://github.com/elia))
- Replace with :all_adjustments.nonzero.any? [#3787](https://github.com/solidusio/solidus/pull/3787) ([duartemvix](https://github.com/duartemvix))

### API

- Return API Users with distinct result when using Ransack [#3674](https://github.com/solidusio/solidus/pull/3674) ([hefan](https://github.com/hefan))
- Revert "API uploads images via URL" (#3573) [#3622](https://github.com/solidusio/solidus/pull/3622) ([kennyadsl](https://github.com/kennyadsl))
- [API] Remove country and state input from address-input doc [#3589](https://github.com/solidusio/solidus/pull/3589) ([SamuelMartini](https://github.com/SamuelMartini))
- [API] Upgrade API docs to OpenAPI Specification 3.0 [#3588](https://github.com/solidusio/solidus/pull/3588) ([filippoliverani](https://github.com/filippoliverani))
- Add API endpoint for customer returns [#3579](https://github.com/solidusio/solidus/pull/3579) ([seand7565](https://github.com/seand7565))
- API uploads images via URL [#3573](https://github.com/solidusio/solidus/pull/3573) ([calebhaye](https://github.com/calebhaye))
- Enable api checkout spec that was skipped [#3551](https://github.com/solidusio/solidus/pull/3551) ([SamuelMartini](https://github.com/SamuelMartini))
- Remove code from Spree::Api::PromotionsController [#3529](https://github.com/solidusio/solidus/pull/3529) ([SamuelMartini](https://github.com/SamuelMartini))
- [API] Add bang method when finding product property [#3528](https://github.com/solidusio/solidus/pull/3528) ([SamuelMartini](https://github.com/SamuelMartini))
- Rescue state machine exception from api base controller [#3520](https://github.com/solidusio/solidus/pull/3520) ([SamuelMartini](https://github.com/SamuelMartini))
- Scope image by product_id or variant_id in ImagesController [#3510](https://github.com/solidusio/solidus/pull/3510) ([SamuelMartini](https://github.com/SamuelMartini))
- Api: move address books specs in the right folder [#3499](https://github.com/solidusio/solidus/pull/3499) ([kennyadsl](https://github.com/kennyadsl))

### Deprecations & Removals

- Deprecate Spree::Address firstname, lastname and full_name [#3584](https://github.com/solidusio/solidus/pull/3584) ([filippoliverani](https://github.com/filippoliverani))
- Deprecate reimbursement hooks [#3541](https://github.com/solidusio/solidus/pull/3541) ([spaghetticode](https://github.com/spaghetticode))

### Misc

- Explicit deprecation warning mocks [#3753](https://github.com/solidusio/solidus/pull/3753) ([cedum](https://github.com/cedum))
- Set payment method to none [#3751](https://github.com/solidusio/solidus/pull/3751) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Use CircleCI contexts in jobs that require secrets [#3747](https://github.com/solidusio/solidus/pull/3747) ([kennyadsl](https://github.com/kennyadsl))
- The install generator is no longer using Bundler::CLI [#3739](https://github.com/solidusio/solidus/pull/3739) ([elia](https://github.com/elia))
- Upgrade acts_as_list gem dependency to allow v1.x [#3736](https://github.com/solidusio/solidus/pull/3736) ([marcrohloff](https://github.com/marcrohloff))
- Speedup the CI [#3699](https://github.com/solidusio/solidus/pull/3699) ([elia](https://github.com/elia))
- Do not attempt to create multiple records with `global_zone` factory [#3688](https://github.com/solidusio/solidus/pull/3688) ([spaghetticode](https://github.com/spaghetticode))
- Add changelog for v2.10.1 [#3659](https://github.com/solidusio/solidus/pull/3659) ([tvdeyen](https://github.com/tvdeyen))
- Add webdrivers gem [#3657](https://github.com/solidusio/solidus/pull/3657) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Add factory_bot lint test to core [#3647](https://github.com/solidusio/solidus/pull/3647) ([seand7565](https://github.com/seand7565))
- Fix specs on Rails master/6.1.0.alpha [#3614](https://github.com/solidusio/solidus/pull/3614) ([filippoliverani](https://github.com/filippoliverani))
- Bump required Ruby version to 2.5 [#3594](https://github.com/solidusio/solidus/pull/3594) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Fix Ambassadors formatting in README [#3567](https://github.com/solidusio/solidus/pull/3567) ([kennyadsl](https://github.com/kennyadsl))
- Add CircleCI job to run tests against Rails master [#3557](https://github.com/solidusio/solidus/pull/3557) ([filippoliverani](https://github.com/filippoliverani))
- Re-alphabetize app configuration prefs [#3556](https://github.com/solidusio/solidus/pull/3556) ([elia](https://github.com/elia))
- Add system specs configuration [#3552](https://github.com/solidusio/solidus/pull/3552) ([blocknotes](https://github.com/blocknotes))
- Fix install generator auth option in common rake tasks [#3549](https://github.com/solidusio/solidus/pull/3549) ([kennyadsl](https://github.com/kennyadsl))
- Improve gemspecs of solidus and subcomponents [#3546](https://github.com/solidusio/solidus/pull/3546) ([kennyadsl](https://github.com/kennyadsl))
- Simplify Solidus installation steps [#3545](https://github.com/solidusio/solidus/pull/3545) ([kennyadsl](https://github.com/kennyadsl))
- Replace ActiveJob::TestHelper with own module. [#3543](https://github.com/solidusio/solidus/pull/3543) ([jessetilro](https://github.com/jessetilro))
- Rename the installation generator to solidus:install [#3538](https://github.com/solidusio/solidus/pull/3538) ([kennyadsl](https://github.com/kennyadsl))
- Remove Engine from Ambassadors [#3536](https://github.com/solidusio/solidus/pull/3536) ([kennyadsl](https://github.com/kennyadsl))
- Add Rails 6.1.0.alpha/master support [#3515](https://github.com/solidusio/solidus/pull/3515) ([filippoliverani](https://github.com/filippoliverani))
- Improve sample data for the returned/reimbursed order [#3495](https://github.com/solidusio/solidus/pull/3495) ([kennyadsl](https://github.com/kennyadsl))
- Add some bin/ helpers [#3489](https://github.com/solidusio/solidus/pull/3489) ([elia](https://github.com/elia))
- Silence log messages from the capybara server [#3484](https://github.com/solidusio/solidus/pull/3484) ([elia](https://github.com/elia))
- Preparation for v2.11 [#3479](https://github.com/solidusio/solidus/pull/3479) ([kennyadsl](https://github.com/kennyadsl))
- Adjust Open Collective badges to display correctly [#3764](https://github.com/solidusio/solidus/pull/3764) ([kennyadsl](https://github.com/kennyadsl))
- Make spelling of 'email' consistent [#3780](https://github.com/solidusio/solidus/pull/3780) ([brchristian](https://github.com/brchristian))
- Add missing space to deprecation message [#3790](https://github.com/solidusio/solidus/pull/3790) ([jacobherrington](https://github.com/jacobherrington))
- Disable Rails master builds on CircleCI [#3796](https://github.com/solidusio/solidus/pull/3796) ([tvdeyen](https://github.com/tvdeyen))

### Docs & Guides

- Bump elliptic from 6.4.1 to 6.5.3 in /guides [#3723](https://github.com/solidusio/solidus/pull/3723) ([dependabot](https://github.com/apps/dependabot))
- Bump lodash from 4.17.14 to 4.17.19 in /guides [#3714](https://github.com/solidusio/solidus/pull/3714) ([dependabot](https://github.com/apps/dependabot))
- Updating documentation around ransack [#3709](https://github.com/solidusio/solidus/pull/3709) ([tmtrademarked](https://github.com/tmtrademarked))
- Fix minor typo in order overview docs [#3665](https://github.com/solidusio/solidus/pull/3665) ([albertoalmagro](https://github.com/albertoalmagro))
- Fix typos in guides [#3660](https://github.com/solidusio/solidus/pull/3660) ([RoelandMatthijssens](https://github.com/RoelandMatthijssens))
- [guides] Fix awesome nested set gem link [#3643](https://github.com/solidusio/solidus/pull/3643) ([spaghetticode](https://github.com/spaghetticode))
- Generate stoplight doc on version with multiple digits [#3632](https://github.com/solidusio/solidus/pull/3632) ([kennyadsl](https://github.com/kennyadsl))
- Add missing link to RMAs docs in Inventory overview [#3590](https://github.com/solidusio/solidus/pull/3590) ([cedum](https://github.com/cedum))
- Guides: add basic Google Analytics integration [#3582](https://github.com/solidusio/solidus/pull/3582) ([kennyadsl](https://github.com/kennyadsl))
- Fix api checkout flow documentation [#3575](https://github.com/solidusio/solidus/pull/3575) ([SamuelMartini](https://github.com/SamuelMartini))
- Show v2.10 install instructions along with new ones [#3562](https://github.com/solidusio/solidus/pull/3562) ([kennyadsl](https://github.com/kennyadsl))
- [Guides] Add System Requirements page [#3540](https://github.com/solidusio/solidus/pull/3540) ([kennyadsl](https://github.com/kennyadsl))
- Replace wrong key and add parameters in product taxons endpoint doc [#3531](https://github.com/solidusio/solidus/pull/3531) ([SamuelMartini](https://github.com/SamuelMartini))
- Replace http method in api doc [#3530](https://github.com/solidusio/solidus/pull/3530) ([SamuelMartini](https://github.com/SamuelMartini))
- Fix typo in documentation [#3525](https://github.com/solidusio/solidus/pull/3525) ([spaghetticode](https://github.com/spaghetticode))
- Bump nokogiri from 1.10.4 to 1.10.8 in /guides [#3523](https://github.com/solidusio/solidus/pull/3523) ([dependabot](https://github.com/apps/dependabot))
- [Guides] Improve extensions pages [#3522](https://github.com/solidusio/solidus/pull/3522) ([kennyadsl](https://github.com/kennyadsl))
- Link to solidus_dev_support instead of solidus_cmd [#3521](https://github.com/solidusio/solidus/pull/3521) ([MFRWDesign](https://github.com/MFRWDesign))
- Improve endpoint description of some API endpoints [#3509](https://github.com/solidusio/solidus/pull/3509) ([SamuelMartini](https://github.com/SamuelMartini))
- Add a missing link to the 2.10 changelog [#3503](https://github.com/solidusio/solidus/pull/3503) ([elia](https://github.com/elia))
- Update images sizes to the new defaults [#3493](https://github.com/solidusio/solidus/pull/3493) ([elia](https://github.com/elia))
- Fix stock configuration examples in documentation [#3487](https://github.com/solidusio/solidus/pull/3487) ([gugaiz](https://github.com/gugaiz))
- Add links to the community guidelines [#3437](https://github.com/solidusio/solidus/pull/3437) ([jacobherrington](https://github.com/jacobherrington))
- Update custom search sample query [#3396](https://github.com/solidusio/solidus/pull/3396) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Guides (API): Some additional API token info [#3368](https://github.com/solidusio/solidus/pull/3368) ([felixyz](https://github.com/felixyz))
- Add discontinue on to products guides [#3795](https://github.com/solidusio/solidus/pull/3795) ([tvdeyen](https://github.com/tvdeyen))

## Solidus 2.10.5 (v2.10, 2021-05-10)

- Use symbols in polymorphic path for event_links [#4048](https://github.com/solidusio/solidus/pull/4048) ([tvdeyen](https://github.com/tvdeyen))

## Solidus 2.10.1 (2020-05-14)

- Fix in_taxons scope when taxon is an ActiveRecord::Base [3617](https://github.com/solidusio/solidus/pull/3617) ([kennyadsl](https://github.com/kennyadsl))

## Solidus 2.10.0 (2020-01-15)

### Major Changes

**Added support for Rails 6**

Solidus core now fully support Rails 6! After upgrading to the 2.10 you can
follow the official Rails Upgrading Guide here:
https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-5-2-to-rails-6-0
Please note that Rails 6 requires Ruby 2.5.0 or newer.

- Add support for Rails 6 [#3236](https://github.com/solidusio/solidus/pull/3236) ([aldesantis](https://github.com/aldesantis))
- Fix dummy app generator to skip Bootsnap and Webpack in Rails 6 [#3327](https://github.com/solidusio/solidus/pull/3327) ([aldesantis](https://github.com/aldesantis))
- Handle deprecation for Rails 6 in DummyApp [#3352](https://github.com/solidusio/solidus/pull/3352) ([cedum](https://github.com/cedum))

**Deprecated support for Rails 5.1**

Rails 5.1 is deprecated and we'll remove support to 5.1 on the next version.
If you are still using it, a deprecation warning will be printed in your logs
when the application boots.

- Deprecate Rails 5.1 [#3333](https://github.com/solidusio/solidus/pull/3333) ([kennyadsl](https://github.com/kennyadsl))

**Changed default images sizes**

We update the images used by Solidus demo in the `sample` gem. To update
those images we needed to change the default sizes of Spree::Image. They
changed from:

```
mini: '48x48>', small: '100x100>', product: '240x240>', large: '600x600>'
```

to

```
mini: '48x48>', small: '400x400>', product: '680x680>', large: '1200x1200>'
```

If your store relies on these sizes, you should change them back following
the guide here: https://guides.solidus.io/developers/products-and-variants/product-images.html#paperclip-settings.

- Upload new sample images [#3270](https://github.com/solidusio/solidus/pull/3270) ([mfrecchiami](https://github.com/mfrecchiami))
- Remove unused sample images [#3397](https://github.com/solidusio/solidus/pull/3397) ([JDutil](https://github.com/JDutil))
- Update sample imgs with wrong file extension [#3343](https://github.com/solidusio/solidus/pull/3343) ([mfrecchiami](https://github.com/mfrecchiami))

**State machines extracted into their own replaceable modules**

This allows stores to replace the state machine completely with their own
implementation, even with different gems or using custom code without any
state machine gem. All the customizations previously made to the state machine
should work smoothly, but it could be a good idea to check twice. You can read
more about the suggested way to customize the state machine here:
https://guides.solidus.io/developers/customizations/state-machines.html#state-machines

- Extract the state machines into replaceable modules [#3356](https://github.com/solidusio/solidus/pull/3356) ([cedum](https://github.com/cedum))

**Display error if editing non-current order**

In Solidus frontend users were able to input any `order_id` in the
`/orders/:order_id/edit` route and they were simply seeing the cart
(showing the current order and not the requested one) without any notice.
With this Solidus version we print an flash message and redirect users to
their cart.

- Display error if editing non-current order [#3391](https://github.com/solidusio/solidus/pull/3391) ([JDutil](https://github.com/JDutil))

**Solidus now requires Ruby 2.4 or newer**

Ruby 2.2 and 2.3 support has ended, Rubocop support for 2.2 ended and
they are also about to drop 2.3. Also, we already introduced code that
is not compliant with 2.2 anymore.

- Bump required ruby version to 2.4 [#3337](https://github.com/solidusio/solidus/pull/3337) ([kennyadsl](https://github.com/kennyadsl))

### Core

- Fix product discard and classifications issue [#3439](https://github.com/solidusio/solidus/pull/3439) ([softr8](https://github.com/softr8))
- Let Address#build_default accept args and block [#3429](https://github.com/solidusio/solidus/pull/3429) ([elia](https://github.com/elia))
- Several small refactors to promotions code [#3416](https://github.com/solidusio/solidus/pull/3416) ([kennyadsl](https://github.com/kennyadsl))
- Document the real meaning of checkout#set_state_if_present [#3406](https://github.com/solidusio/solidus/pull/3406) ([elia](https://github.com/elia))
- Pass stock location to inventory unit factory [#3375](https://github.com/solidusio/solidus/pull/3375) ([pelargir](https://github.com/pelargir))
- Allow to easily extend `Auth#store_location` behavior [#3369](https://github.com/solidusio/solidus/pull/3369) ([spaghetticode](https://github.com/spaghetticode))
- Replace update_attributes with update [#3334](https://github.com/solidusio/solidus/pull/3334) ([aldesantis](https://github.com/aldesantis))
- Added location_filter_class as a writable attribute [#3330](https://github.com/solidusio/solidus/pull/3330) ([ericsaupe](https://github.com/ericsaupe))
- Make all belongs_to associations optional [#3309](https://github.com/solidusio/solidus/pull/3309) ([tvdeyen](https://github.com/tvdeyen))
- Raise exception if dividing by 0 [#3305](https://github.com/solidusio/solidus/pull/3305) ([ericsaupe](https://github.com/ericsaupe))
- Remove a duplicate method call [#3295](https://github.com/solidusio/solidus/pull/3295) ([jacobherrington](https://github.com/jacobherrington))
- Change nil check to use safe navigation operator [#3293](https://github.com/solidusio/solidus/pull/3293) ([jacobherrington](https://github.com/jacobherrington))
- Ensure cartons find soft deleted shipping methods [#3165](https://github.com/solidusio/solidus/pull/3165) ([pelargir](https://github.com/pelargir))
- Allow orders with different shipping categories [#3130](https://github.com/solidusio/solidus/pull/3130) ([aitbw](https://github.com/aitbw))
- Allow configuring VAT Price Generator class [#3451](https://github.com/solidusio/solidus/pull/3451) ([kennyadsl](https://github.com/kennyadsl))
- Refactor Spree::Address value_attributes [#3465](https://github.com/solidusio/solidus/pull/3465) ([filippoliverani](https://github.com/filippoliverani))
- Revert method removal and replace it with a deprecation [#3477](https://github.com/solidusio/solidus/pull/3477) ([elia](https://github.com/elia))

### Backend

- Fix  bug for billing address state value not changing with customer [#3435](https://github.com/solidusio/solidus/pull/3435) ([spaghetticode](https://github.com/spaghetticode))
- Set error flash when unsuccesful destroy using HTML format [#3428](https://github.com/solidusio/solidus/pull/3428) ([mamhoff](https://github.com/mamhoff))
- Use proper fixture path for Backend file fixtures [#3424](https://github.com/solidusio/solidus/pull/3424) ([JuanCrg90](https://github.com/JuanCrg90))
- Fixing admin store credit reasons tab not expanded [#3401](https://github.com/solidusio/solidus/pull/3401) ([softr8](https://github.com/softr8))
- Add permission check for admins updating user passwords [#3394](https://github.com/solidusio/solidus/pull/3394) ([JDutil](https://github.com/JDutil))
- Add tooltips to admin calculators [#3382](https://github.com/solidusio/solidus/pull/3382) ([codykaup](https://github.com/codykaup))
- Add initial value to reduce function for tab widths [#3377](https://github.com/solidusio/solidus/pull/3377) ([fastjames](https://github.com/fastjames))
- Paginate master prices [#3353](https://github.com/solidusio/solidus/pull/3353) ([mamhoff](https://github.com/mamhoff))
- Disable submit buttons after first click [#3342](https://github.com/solidusio/solidus/pull/3342) ([spaghetticode](https://github.com/spaghetticode))
- Add information about the variable_override file [#3341](https://github.com/solidusio/solidus/pull/3341) ([mfrecchiami](https://github.com/mfrecchiami))
- Use relative path to specify layouts path [#3335](https://github.com/solidusio/solidus/pull/3335) ([kennyadsl](https://github.com/kennyadsl))
- Use default sass function to lighten colors [#3331](https://github.com/solidusio/solidus/pull/3331) ([mfrecchiami](https://github.com/mfrecchiami))
- Style collapsing sidebar [#3322](https://github.com/solidusio/solidus/pull/3322) ([mfrecchiami](https://github.com/mfrecchiami))
- Fix tab background color, too dark [#3320](https://github.com/solidusio/solidus/pull/3320) ([Ajmal](https://github.com/Ajmal))
- Added empty cart button in admin cart [#3316](https://github.com/solidusio/solidus/pull/3316) ([ericsaupe](https://github.com/ericsaupe))
- Making taxon form to render attachment definitions dynamically [#3308](https://github.com/solidusio/solidus/pull/3308) ([softr8](https://github.com/softr8))
- Fix hook attr name for settings tab item in admin [#3301](https://github.com/solidusio/solidus/pull/3301) ([cedum](https://github.com/cedum))
- Update usage count in Promotion eligibility check [#3297](https://github.com/solidusio/solidus/pull/3297) ([filippoliverani](https://github.com/filippoliverani))
- Update cancel inventory tab for consistency [#3289](https://github.com/solidusio/solidus/pull/3289) ([ericsaupe](https://github.com/ericsaupe))
- Rename `_mixins.css` file to `.scss` [#3286](https://github.com/solidusio/solidus/pull/3286) ([mamhoff](https://github.com/mamhoff))
- Use pluck(:value).first to avoid loading entire row and using try! [#3282](https://github.com/solidusio/solidus/pull/3282) ([JDutil](https://github.com/JDutil))
- Only display Store Credit links with permission [#3276](https://github.com/solidusio/solidus/pull/3276) ([JDutil](https://github.com/JDutil))
- Update Tab colors with its own variables [#3274](https://github.com/solidusio/solidus/pull/3274) ([mfrecchiami](https://github.com/mfrecchiami))
- Remove "Add product" in admin order shipments page [#3214](https://github.com/solidusio/solidus/pull/3214) ([spaghetticode](https://github.com/spaghetticode))
- Add explicit closing div to admin order edit [#3473](https://github.com/solidusio/solidus/pull/3473) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Fix issue with user breadcrumbs [#3152](https://github.com/solidusio/solidus/pull/3152) ([jtapia](https://github.com/jtapia))

### Frontend

- Fix Coupon Code Field's Length in Firefox [#3387](https://github.com/solidusio/solidus/pull/3387) ([amree](https://github.com/amree))

### API

- Remove RABL remnants [#3425](https://github.com/solidusio/solidus/pull/3425) ([JuanCrg90](https://github.com/JuanCrg90))
- Mention solidus-sdk in the API readme [#3409](https://github.com/solidusio/solidus/pull/3409) ([aldesantis](https://github.com/aldesantis))
- Use Kaminari's limit_value in API pagniation [#3287](https://github.com/solidusio/solidus/pull/3287) ([ericsaupe](https://github.com/ericsaupe))

### Deprecations & Removals

- Remove unused route [#3443](https://github.com/solidusio/solidus/pull/3443) ([kennyadsl](https://github.com/kennyadsl))
- Remove Deprecated EmailValidator [#3395](https://github.com/solidusio/solidus/pull/3395) ([JDutil](https://github.com/JDutil))
- Fix deprecation message for Spree::CreditCard [#3388](https://github.com/solidusio/solidus/pull/3388) ([spaghetticode](https://github.com/spaghetticode))

### Misc

- Fix Money gem deprecations [#3453](https://github.com/solidusio/solidus/pull/3453) ([kennyadsl](https://github.com/kennyadsl))
- update rubocop version [#3449](https://github.com/solidusio/solidus/pull/3449) ([hmtanbir](https://github.com/hmtanbir))
- Relax Paperclip dependency [#3438](https://github.com/solidusio/solidus/pull/3438) ([mamhoff](https://github.com/mamhoff))
- Remove last migration's spec file [#3415](https://github.com/solidusio/solidus/pull/3415) ([kennyadsl](https://github.com/kennyadsl))
- Update one letter variables to be more descriptive [#3400](https://github.com/solidusio/solidus/pull/3400) ([JDutil](https://github.com/JDutil))
- Change variable names to enhance readability in helpers [#3399](https://github.com/solidusio/solidus/pull/3399) ([juliannatetreault](https://github.com/juliannatetreault))
- Rename one letter variables [#3292](https://github.com/solidusio/solidus/pull/3292) ([jacobherrington](https://github.com/jacobherrington))
- More eager loading in admin and api [#3398](https://github.com/solidusio/solidus/pull/3398) ([softr8](https://github.com/softr8))
- Reload product before assigning images to variants [#3389](https://github.com/solidusio/solidus/pull/3389) ([JDutil](https://github.com/JDutil))
- Ask to provide screenshots for PRs with visual changes [#3385](https://github.com/solidusio/solidus/pull/3385) ([spaghetticode](https://github.com/spaghetticode))
- Lock Sprockets to v3.x in development [#3378](https://github.com/solidusio/solidus/pull/3378) ([spaghetticode](https://github.com/spaghetticode))
- Fix Sprockets 4 support for extensions [#3373](https://github.com/solidusio/solidus/pull/3373) ([aldesantis](https://github.com/aldesantis))
- Officialize new taxation system [#3354](https://github.com/solidusio/solidus/pull/3354) ([kennyadsl](https://github.com/kennyadsl))
- fix spelling of locale logged_in_successfully [#3346](https://github.com/solidusio/solidus/pull/3346) ([nspinazz89](https://github.com/nspinazz89))
- Remove duplicate Spree::Order.register_update_hook specs [#3340](https://github.com/solidusio/solidus/pull/3340) ([kennyadsl](https://github.com/kennyadsl))
- Fix responders gem dependency [#3336](https://github.com/solidusio/solidus/pull/3336) ([kennyadsl](https://github.com/kennyadsl))
- Avoid installing webpacker in sandbox [#3326](https://github.com/solidusio/solidus/pull/3326) ([kennyadsl](https://github.com/kennyadsl))
- Remove sqlite3 version lock in sandbox/development [#3325](https://github.com/solidusio/solidus/pull/3325) ([kennyadsl](https://github.com/kennyadsl))
- Add missing entries to en yml [#3313](https://github.com/solidusio/solidus/pull/3313) ([delphaber](https://github.com/delphaber))
- Add docs for partials that need to be provided [#3300](https://github.com/solidusio/solidus/pull/3300) ([skukx](https://github.com/skukx))
- Add dimensions and weight to product samples [#3291](https://github.com/solidusio/solidus/pull/3291) ([BravoSimone](https://github.com/BravoSimone))
- Remove zombie promotion specs variables [#3280](https://github.com/solidusio/solidus/pull/3280) ([cedum](https://github.com/cedum))
- Attempt to fix flaky specs [#3278](https://github.com/solidusio/solidus/pull/3278) ([kennyadsl](https://github.com/kennyadsl))
- Freeze preferences for Backend, Frontend and Api specs as well [#3275](https://github.com/solidusio/solidus/pull/3275) ([kennyadsl](https://github.com/kennyadsl))
- Make preferences usage uniform across all Solidus gems [#3267](https://github.com/solidusio/solidus/pull/3267) ([kennyadsl](https://github.com/kennyadsl))

### Docs & Guides

- Improve line items params in the API documentation [#3445](https://github.com/solidusio/solidus/pull/3445) ([kennyadsl](https://github.com/kennyadsl))
- Updates Guides: Security and simple installation [#3436](https://github.com/solidusio/solidus/pull/3436) ([kennyadsl](https://github.com/kennyadsl))
- Update Slack links in README. [#3433](https://github.com/solidusio/solidus/pull/3433) ([jrgifford](https://github.com/jrgifford))
- Guides: do not escape markdown headers in custom renderer [#3432](https://github.com/solidusio/solidus/pull/3432) ([filippoliverani](https://github.com/filippoliverani))
- Add list of events fired by default to Guides/Events [#3430](https://github.com/solidusio/solidus/pull/3430) ([j-sm-n](https://github.com/j-sm-n))
- Fix a typo in one old CHANGELOG entry [#3419](https://github.com/solidusio/solidus/pull/3419) ([elia](https://github.com/elia))
- Several Guides improvements [#3418](https://github.com/solidusio/solidus/pull/3418) ([kennyadsl](https://github.com/kennyadsl))
- Add max_line_length for Markdown files [#3410](https://github.com/solidusio/solidus/pull/3410) ([aldesantis](https://github.com/aldesantis))
- Update guides and add mailer customization guide [#3403](https://github.com/solidusio/solidus/pull/3403) ([michaelmichael](https://github.com/michaelmichael))
- Update CONTRIBUTING.md [#3402](https://github.com/solidusio/solidus/pull/3402) ([juliannatetreault](https://github.com/juliannatetreault))
- Document the config assigment for vat_country_iso [#3386](https://github.com/solidusio/solidus/pull/3386) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Document contribution guidelines for API docs [#3384](https://github.com/solidusio/solidus/pull/3384) ([aldesantis](https://github.com/aldesantis))
- Add steps for installing database gems in README [#3380](https://github.com/solidusio/solidus/pull/3380) ([codykaup](https://github.com/codykaup))
- Link to guides after installation instructions [#3372](https://github.com/solidusio/solidus/pull/3372) ([jarednorman](https://github.com/jarednorman))
- Correct misspelling in API Documentation for Create Product [#3370](https://github.com/solidusio/solidus/pull/3370) ([octoxan](https://github.com/octoxan))
- Added a new page to the documentation for customizing model attributes [#3360](https://github.com/solidusio/solidus/pull/3360) ([octoxan](https://github.com/octoxan))
- Update guides node-sass dependency to be compatible with Node versions > v10 [#3359](https://github.com/solidusio/solidus/pull/3359) ([octoxan](https://github.com/octoxan))
- Update Open Collective info in the README [#3332](https://github.com/solidusio/solidus/pull/3332) ([kennyadsl](https://github.com/kennyadsl))
- Add Algolia Docsearch on Guides [#3324](https://github.com/solidusio/solidus/pull/3324) ([tvdeyen](https://github.com/tvdeyen))
- Move API documentation to solidus_api [#3323](https://github.com/solidusio/solidus/pull/3323) ([aldesantis](https://github.com/aldesantis))
- Document contribution guidelines for API documentation [#3318](https://github.com/solidusio/solidus/pull/3318) ([aldesantis](https://github.com/aldesantis))
- Bump/Lock a couple of npm libraries in /guides [#3317](https://github.com/solidusio/solidus/pull/3317) ([kennyadsl](https://github.com/kennyadsl))
- Lock js-yaml and debug packages versions in guides [#3312](https://github.com/solidusio/solidus/pull/3312) ([kennyadsl](https://github.com/kennyadsl))
- Bump bootstrap from 4.1.3 to 4.3.1 in /guides [#3310](https://github.com/solidusio/solidus/pull/3310) ([dependabot](https://github.com/apps/dependabot))
- Bump nokogiri from 1.8.5 to 1.10.4 in /guides [#3306](https://github.com/solidusio/solidus/pull/3306) ([dependabot](https://github.com/apps/dependabot))
- Bump JS libs for security vulnerabilities [#3281](https://github.com/solidusio/solidus/pull/3281) ([jacobherrington](https://github.com/jacobherrington))
- Link to documentation after sandbox task [#3277](https://github.com/solidusio/solidus/pull/3277) ([jacobeubanks](https://github.com/jacobeubanks))
- Bump lodash for a security vulnerability [#3273](https://github.com/solidusio/solidus/pull/3273) ([kennyadsl](https://github.com/kennyadsl))
- Document security policy location [#3266](https://github.com/solidusio/solidus/pull/3266) ([aldesantis](https://github.com/aldesantis))
- Update README.md header [#3251](https://github.com/solidusio/solidus/pull/3251) ([davidedistefano](https://github.com/davidedistefano))
- Add zone link in taxation guides page [#3247](https://github.com/solidusio/solidus/pull/3247) ([jacobherrington](https://github.com/jacobherrington))

## Solidus 2.9.0 (2019-07-16)

### Major Changes

**Added Spree::Event**

Solidus now includes an event library that allows to use different adapters.
The default adapter is based on `ActiveSupport::Notifications` library.
Events should allow developers to customize and extend Solidus behavior
more easily by simply subscribing to certain events. Sending emails may be a
simple use case for this new feature.

- ActiveSupport notifications for Events Handling  [#3081](https://github.com/solidusio/solidus/pull/3081) ([spaghetticode](https://github.com/spaghetticode))
- Support class reloading for Event Subscribers [#3232](https://github.com/solidusio/solidus/pull/3232) ([elia](https://github.com/elia))

**Attachment adapters**

This is the first step to support other files attachment libraries since
Paperclip is no more maintained. Solidus will release the ActiveStorage
support in core in the next releases or via an extension.

- Attachment adapters [#3237](https://github.com/solidusio/solidus/pull/3237) ([elia](https://github.com/elia))

**Add more fields to the API json response for shipments**

This change adds more fields to the API endpoints that return a shipment
object. We had two partials to represent shipments:
[`small`](https://github.com/solidusio/solidus/blob/e7260a27a7c292908a835f374d5ba73fe7284cd0/api/app/views/spree/api/shipments/_big.json.jbuilder)
and
[`big`](https://github.com/solidusio/solidus/blob/e7260a27a7c292908a835f374d5ba73fe7284cd0/api/app/views/spree/api/shipments/_small.json.jbuilder)
but some of the `small` fields were not present in the `big` partial. Now they
are aligned but users that were using those partials could notice some
difference in how the API endpoints involved respond.

- Complete Shipments Big json with small json fields [#3221](https://github.com/solidusio/solidus/pull/3221) ([JuanCrg90](https://github.com/JuanCrg90))

**Deprecate reset_spree_preferences in test**

Changing preferences and resetting them after any example is not a good
practice and it's error-prone. The new standard is stubbing preferences and
it's enforced with a deprecation of reset_spree_preferences. This way we can
gradually align stores and extensions.

- Allow only stubbed changes to `Spree::Config` in specs [#3220](https://github.com/solidusio/solidus/pull/3220) ([spaghetticode](https://github.com/spaghetticode))

**Changed payment method partials name convention**

Payment methods partials filename are now expected to be the
Spree::PaymentMethod class underscored instead of downcased. This means that,
for example, for `Spree::PaymentMethod::StoreCredit` the corresponding partial
files would be named `_store_credit` and not `_storecredit`. If you overrode
one of the following files, you should rename it now:

```
api/app/views/spree/api/payments/source_views/_storecredit.json.jbuilder → api/app/views/spree/api/payments/source_views/_store_credit.json.jbuilder
backend/app/views/spree/admin/payments/source_forms/_storecredit.html.erb → backend/app/views/spree/admin/payments/source_forms/_store_credit.html.erb
backend/app/views/spree/admin/payments/source_views/_storecredit.html.erb → backend/app/views/spree/admin/payments/source_views/_store_credit.html.erb
```

Also, if you've built your own payment method you may need to change the
corresponding partials filename.

- Change payment method partial name convention [#3217](https://github.com/solidusio/solidus/pull/3217) ([bitberryru](https://github.com/bitberryru))

**Fix non thread safe gateway initialization**

`ActiveMerchant::Billing::Base.mode` is a global `ActiveMerchant` preference
and we were setting it into each payment gateway initialization. This means
that if the last instantiated payment method's mode was different from the
other ones, the last one's mode will be applied to all of them. To fix this
issue we changed how we tell ActiveMerchant that one gateway is in test mode.
Please double check your production configuration for payment methods: only
payment methods where `server` preference set to production and `test_mode`
turned off will work in "production" mode.

- Fix non thread safe gateway initialization [#3216](https://github.com/solidusio/solidus/pull/3216) ([bitberryru](https://github.com/bitberryru))

**Remove name from default ransackable attributes**

Ransack needs a whitelist of attributes to perform a search against for security
reasons. We used to whitelist `id` and `name` for all the models but not all
models have the `name` attribute/column making ransack search raise an error.
If you have a custom model and you are performing search against its `name`,
now you have to manually add it to the ransackable whitelist for that resource.

- Remove name column from default ransackable attributes [#3180](https://github.com/solidusio/solidus/pull/3180) ([mdesantis](https://github.com/mdesantis))

**Admin restyle**

Solidus has a fresh Admin UI! Your eyes will thank you and this would not
impact your store but if you added some custom CSS that matches the old Admin
UI, you probaly have to make some change at it now.

- Update admin color palette and font [#3192](https://github.com/solidusio/solidus/pull/3192) ([mfrecchiami](https://github.com/mfrecchiami))
- Add a color to menu selected items [#3269](https://github.com/solidusio/solidus/pull/3269) ([mfrecchiami](https://github.com/mfrecchiami))

**Changes to how returns are processed from a return item**

It you are programmatically calling `Spree::ReturnItem#process_inventory_unit!`
please notice that it doesn't automatically process return anymore. To remove
the deprecation warning you have to set an attribute on your `return_item`
instance before calling `process_inventory_unit!`:

```ruby
return_item.skip_customer_return_processing = true
return_item.process_inventory_unit!
# here you should process the customer return manually
```

- Allow order with multiple line items to be marked as "Returned" [#3199](https://github.com/solidusio/solidus/pull/3199) ([spaghetticode](https://github.com/spaghetticode))

**New REST API documentation**

Our REST API is now documented using the Open API Specification. The
documentation is part of the repository and published on
https://solidus.docs.stoplight.io/.

- Document the API via OpenAPI [#3252](https://github.com/solidusio/solidus/pull/3252) ([aldesantis](https://github.com/aldesantis))

### Core

- Refactor Promotions Environment Configuration [#3239](https://github.com/solidusio/solidus/pull/3239) ([kennyadsl](https://github.com/kennyadsl))
- Add preferred_reimbursement_type_id as permitted attributes for ReturnAuthorization [#3215](https://github.com/solidusio/solidus/pull/3215) ([ibudiallo](https://github.com/ibudiallo))
- Add OriginalPayment reimbursement type in seeds [#3213](https://github.com/solidusio/solidus/pull/3213) ([kennyadsl](https://github.com/kennyadsl))
- Fixes for discard 1.1.0 [#3202](https://github.com/solidusio/solidus/pull/3202) ([kennyadsl](https://github.com/kennyadsl))
- Improve error messages for wallet payment source [#3196](https://github.com/solidusio/solidus/pull/3196) ([kennyadsl](https://github.com/kennyadsl))
- Use taxon children when searching classification [#3168](https://github.com/solidusio/solidus/pull/3168) ([fkoessler](https://github.com/fkoessler))
- Improve promotion statuses [#3157](https://github.com/solidusio/solidus/pull/3157) ([JuanCrg90](https://github.com/JuanCrg90))
- Fix DB-specific, query-related exceptions [#3156](https://github.com/solidusio/solidus/pull/3156) ([aitbw](https://github.com/aitbw))
- Convert Tax Categories to discard [#3154](https://github.com/solidusio/solidus/pull/3154) ([kennyadsl](https://github.com/kennyadsl))
- Don't run validations in Order#record_ip_address [#3145](https://github.com/solidusio/solidus/pull/3145) ([cedum](https://github.com/cedum))
- Align some deprecation messages in Order model [#3135](https://github.com/solidusio/solidus/pull/3135) ([elia](https://github.com/elia))
- Refactor order #refund_total [#3134](https://github.com/solidusio/solidus/pull/3134) ([twist900](https://github.com/twist900))
- Remove code setter/getter from Spree::Promotion [#3127](https://github.com/solidusio/solidus/pull/3127) ([kennyadsl](https://github.com/kennyadsl))
- Do not allow successful checkout when order has only a void payment [#3123](https://github.com/solidusio/solidus/pull/3123) ([spaghetticode](https://github.com/spaghetticode))
- Add a stock locations filter configurable class [#3116](https://github.com/solidusio/solidus/pull/3116) ([kennyadsl](https://github.com/kennyadsl))
- Add migration to drop table/column from `20180710170104` [#3114](https://github.com/solidusio/solidus/pull/3114) ([spaghetticode](https://github.com/spaghetticode))
- Fix migration `20161123154034` and `20120411123334` [#3113](https://github.com/solidusio/solidus/pull/3113) ([spaghetticode](https://github.com/spaghetticode))
- Remove destructive actions from migration 20180710170104 [#3109](https://github.com/solidusio/solidus/pull/3109) ([spaghetticode](https://github.com/spaghetticode))
- Fix remove code from promotions migration [#3108](https://github.com/solidusio/solidus/pull/3108) ([kennyadsl](https://github.com/kennyadsl))
- Fixing inventory unit finalizer [#3094](https://github.com/solidusio/solidus/pull/3094) ([seand7565](https://github.com/seand7565))
- Parameterize taxon's permalink also on update [#3090](https://github.com/solidusio/solidus/pull/3090) ([loicginoux](https://github.com/loicginoux))
- Exclude line item additional taxes from unit cancel adjustment amount [#3072](https://github.com/solidusio/solidus/pull/3072) ([mdesantis](https://github.com/mdesantis))
- Products at multiple Stock Locations appear as unique variants [#3063](https://github.com/solidusio/solidus/pull/3063) ([mayanktap](https://github.com/mayanktap))
- Verify ownership of payment_source when creating WalletPaymentSource [#3007](https://github.com/solidusio/solidus/pull/3007) ([ericsaupe](https://github.com/ericsaupe))
- Remove user prereq from First Order promorule [#2928](https://github.com/solidusio/solidus/pull/2928) ([fastjames](https://github.com/fastjames))
- Remove belongs_to :return_authorization from InventoryUnit [#2753](https://github.com/solidusio/solidus/pull/2753) ([snarfmason](https://github.com/snarfmason))
- Improve pricing options flexibility [#2504](https://github.com/solidusio/solidus/pull/2504) ([softr8](https://github.com/softr8))

### Backend

- Use `.take` in admin promotion index template [#3224](https://github.com/solidusio/solidus/pull/3224) ([DianeLooney](https://github.com/DianeLooney))
- Remove unused variable assignment from Admin::OrdersController#index action [#3170](https://github.com/solidusio/solidus/pull/3170) ([aitbw](https://github.com/aitbw))
- Remove conditional when searching an order when creating a shipment [#3169](https://github.com/solidusio/solidus/pull/3169) ([aitbw](https://github.com/aitbw))
- Disable adjust stock field when user does not have the correct permission [#3163](https://github.com/solidusio/solidus/pull/3163) ([seand7565](https://github.com/seand7565))
- Fix stock item form to allow changing backorder value [#3159](https://github.com/solidusio/solidus/pull/3159) ([kennyadsl](https://github.com/kennyadsl))
- Promotion start/expiration times [#3158](https://github.com/solidusio/solidus/pull/3158) ([aldesantis](https://github.com/aldesantis))
- Hide Master Price input when there's no default price [#3155](https://github.com/solidusio/solidus/pull/3155) ([kennyadsl](https://github.com/kennyadsl))
- When editing prices keep the currency locked. [#3150](https://github.com/solidusio/solidus/pull/3150) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Hide link to delete users if they have orders [#3139](https://github.com/solidusio/solidus/pull/3139) ([aitbw](https://github.com/aitbw))
- Count only users completed orders in admin users page [#3125](https://github.com/solidusio/solidus/pull/3125) ([brchristian](https://github.com/brchristian))
- Remove unnecessary decimal conversion [#3124](https://github.com/solidusio/solidus/pull/3124) ([brchristian](https://github.com/brchristian))
- Set mininum line item quantity in admin cart [#3115](https://github.com/solidusio/solidus/pull/3115) ([mamhoff](https://github.com/mamhoff))
- Adding else statement back in to show weight and dimensions on no-var… [#3112](https://github.com/solidusio/solidus/pull/3112) ([seand7565](https://github.com/seand7565))
- Admin payments UI cleanup [#3101](https://github.com/solidusio/solidus/pull/3101) ([tvdeyen](https://github.com/tvdeyen))
- Fix fieldset legend position in Firefox [#3100](https://github.com/solidusio/solidus/pull/3100) ([tvdeyen](https://github.com/tvdeyen))
- Add tests for locale switch on backend [#3083](https://github.com/solidusio/solidus/pull/3083) ([coorasse](https://github.com/coorasse))
- Add countries to state selection for zones [#3037](https://github.com/solidusio/solidus/pull/3037) ([jacobherrington](https://github.com/jacobherrington))

### API

- Improve jbuilder serialization for Oj gem [#3210](https://github.com/solidusio/solidus/pull/3210) ([kennyadsl](https://github.com/kennyadsl))
- More error codes to apply_coupon_code api response [#3193](https://github.com/solidusio/solidus/pull/3193) ([fkoessler](https://github.com/fkoessler))

### Frontend

- Use classes alongside data-hook attributes for gateway partial [#3182](https://github.com/solidusio/solidus/pull/3182) ([aitbw](https://github.com/aitbw))

### Deprecations

- Deprecate @payment_sources ivar in checkout controller [#3128](https://github.com/solidusio/solidus/pull/3128) ([kennyadsl](https://github.com/kennyadsl))
- Deprecate core tasks and migration scripts [#3080](https://github.com/solidusio/solidus/pull/3080) ([kennyadsl](https://github.com/kennyadsl))

### Misc

- Move Spree::AppConfiguration specs from app/ to lib/ [#3238](https://github.com/solidusio/solidus/pull/3238) ([kennyadsl](https://github.com/kennyadsl))
- Add a Sponsor button to our repository [#3228](https://github.com/solidusio/solidus/pull/3228) ([kennyadsl](https://github.com/kennyadsl))
- Improve JS linting, pt. 2 [#3225](https://github.com/solidusio/solidus/pull/3225) ([aitbw](https://github.com/aitbw))
- Improve JS linting [#3212](https://github.com/solidusio/solidus/pull/3212) ([aitbw](https://github.com/aitbw))
- Add basic tooling for JS linting [#3167](https://github.com/solidusio/solidus/pull/3167) ([aitbw](https://github.com/aitbw))
- Use a rails application template for Heroku + example-app [#3206](https://github.com/solidusio/solidus/pull/3206) ([elia](https://github.com/elia))
- Eval the custom Gemfile with file and line number [#3204](https://github.com/solidusio/solidus/pull/3204) ([elia](https://github.com/elia))
- Improve translation [#3200](https://github.com/solidusio/solidus/pull/3200) ([spaghetticode](https://github.com/spaghetticode))
- Increase Capybara window width size [#3171](https://github.com/solidusio/solidus/pull/3171) ([aitbw](https://github.com/aitbw))
- Enable extension developers to customize the namespace [#3161](https://github.com/solidusio/solidus/pull/3161) ([mdesantis](https://github.com/mdesantis))
- Fix flaky specs around admin credit card filling [#3160](https://github.com/solidusio/solidus/pull/3160) ([kennyadsl](https://github.com/kennyadsl))
- Ensure return from CSS function [#3146](https://github.com/solidusio/solidus/pull/3146) ([fastjames](https://github.com/fastjames))
- Add missing I18n namespace [#3144](https://github.com/solidusio/solidus/pull/3144) ([aitbw](https://github.com/aitbw))
- Tentative fix for flaky specs [#3141](https://github.com/solidusio/solidus/pull/3141) ([kennyadsl](https://github.com/kennyadsl))
- Remove Devise translations [#3132](https://github.com/solidusio/solidus/pull/3132) ([aitbw](https://github.com/aitbw))
- Tenative fix for flaky spec [#3110](https://github.com/solidusio/solidus/pull/3110) ([spaghetticode](https://github.com/spaghetticode))
- Enable Docker for demoing purposes [#3106](https://github.com/solidusio/solidus/pull/3106) ([kinduff](https://github.com/kinduff))
- Fix sed call so it works on mac [#3091](https://github.com/solidusio/solidus/pull/3091) ([peterberkenbosch](https://github.com/peterberkenbosch))
- Fix flaky specs in `backend/spec/features/admin/users_spec.rb` [#3089](https://github.com/solidusio/solidus/pull/3089) ([spaghetticode](https://github.com/spaghetticode))
- Lock sqlite3 version to 1.3 [#3088](https://github.com/solidusio/solidus/pull/3088) ([mdesantis](https://github.com/mdesantis))
- Accept source as permitted attribute importing orders [#3066](https://github.com/solidusio/solidus/pull/3066) ([jtapia](https://github.com/jtapia))
- Testing tools improvements [#3062](https://github.com/solidusio/solidus/pull/3062) ([kennyadsl](https://github.com/kennyadsl))
- Add gem-release [#3060](https://github.com/solidusio/solidus/pull/3060) ([kennyadsl](https://github.com/kennyadsl))
- Normalize API I18n keys [#2988](https://github.com/solidusio/solidus/pull/2988) ([aitbw](https://github.com/aitbw))

### Docs & Guides

- Document our governance model [#3240](https://github.com/solidusio/solidus/pull/3240) ([aldesantis](https://github.com/aldesantis))
- Clarify README instructions for Sandbox [#3231](https://github.com/solidusio/solidus/pull/3231) ([k1bs](https://github.com/k1bs))
- Purify guides search terms before using them [#3230](https://github.com/solidusio/solidus/pull/3230) ([kennyadsl](https://github.com/kennyadsl))
- Add new Key Stakeholder in the README [#3229](https://github.com/solidusio/solidus/pull/3229) ([davidedistefano](https://github.com/davidedistefano))
- Bump fstream from 1.0.11 to 1.0.12 in /guides [#3218](https://github.com/solidusio/solidus/pull/3218) ([dependabot](https://github.com/apps/dependabot))
- Add CodeTriage badge and fix OpenCollective badges links [#3211](https://github.com/solidusio/solidus/pull/3211) ([mdesantis](https://github.com/mdesantis))
- Fix partner image [#3203](https://github.com/solidusio/solidus/pull/3203) ([jarednorman](https://github.com/jarednorman))
- Add active merchant reference URL in Guides [#3188](https://github.com/solidusio/solidus/pull/3188) ([jacquesporveau](https://github.com/jacquesporveau))
- Add promotion rules article for Solidus admins [#3185](https://github.com/solidusio/solidus/pull/3185) ([benjaminwil](https://github.com/benjaminwil))
- Update class methods to be instance methods. [#3173](https://github.com/solidusio/solidus/pull/3173) ([jacquesporveau](https://github.com/jacquesporveau))
- Correct adjustment type application order in guide [#3153](https://github.com/solidusio/solidus/pull/3153) ([BenAkroyd](https://github.com/BenAkroyd))
- Fix typo in "Addresses" developers guide [#3147](https://github.com/solidusio/solidus/pull/3147) ([cedum](https://github.com/cedum))
- Update TaxLocation Namespace [#3142](https://github.com/solidusio/solidus/pull/3142) ([JuanCrg90](https://github.com/JuanCrg90))
- Add Adjustment documentation reference links [#3122](https://github.com/solidusio/solidus/pull/3122) ([JuanCrg90](https://github.com/JuanCrg90))
- Minor updates in promotions overview documentation [#3121](https://github.com/solidusio/solidus/pull/3121) ([JuanCrg90](https://github.com/JuanCrg90))
- Add initial order documentation for end users [#3105](https://github.com/solidusio/solidus/pull/3105) ([benjaminwil](https://github.com/benjaminwil))
- Move misplaced end-user documentation [#3104](https://github.com/solidusio/solidus/pull/3104) ([benjaminwil](https://github.com/benjaminwil))
- Remove CHANGELOG entry from PR's template [#3102](https://github.com/solidusio/solidus/pull/3102) ([kennyadsl](https://github.com/kennyadsl))
- Update Solidus Guide footer  [#3097](https://github.com/solidusio/solidus/pull/3097) ([davidedistefano](https://github.com/davidedistefano))
- Add support for multiple tables of contents in the Solidus Guides [#3093](https://github.com/solidusio/solidus/pull/3093) ([kennyadsl](https://github.com/kennyadsl))
- Add initial shipments documentation for end users [#3092](https://github.com/solidusio/solidus/pull/3092) ([kennyadsl](https://github.com/kennyadsl))
- Add payment state link in orders overview docs [#3084](https://github.com/solidusio/solidus/pull/3084) ([JuanCrg90](https://github.com/JuanCrg90))
- Bug report template improvements [#3069](https://github.com/solidusio/solidus/pull/3069) ([mdesantis](https://github.com/mdesantis))
- Improve Pull Request template [#3058](https://github.com/solidusio/solidus/pull/3058) ([kennyadsl](https://github.com/kennyadsl))
- Extend Decorator documentation [#3045](https://github.com/solidusio/solidus/pull/3045) ([jacobherrington](https://github.com/jacobherrington))
- Updating readme to include OpenCollective information [#3042](https://github.com/solidusio/solidus/pull/3042) ([seand7565](https://github.com/seand7565))
- Add documentation about taxons for end users [#2760](https://github.com/solidusio/solidus/pull/2760) ([benjaminwil](https://github.com/benjaminwil))

## Solidus 2.8.0 (2019-01-29)

### Major Changes

**Added Api::CouponCodesController#destroy endpoint**

A new endpoint has been added to Solidus API. It allows to remove a coupon code
from an order. It has currently no backend or frontend implementation but
it's common for custom stores to require it.

- Add Api::CouponCodesController#destroy endpoint [#3047](https://github.com/solidusio/solidus/pull/3047) ([aitbw](https://github.com/aitbw))

**Moved Reports into an extension**

We removed the reports section from admin to an extension. If you use it you
have to add it back manually by adding

    gem 'solidus_reports', github: "solidusio-contrib/solidus_reports"

- Move reports from backend into an extension [#2814](https://github.com/solidusio/solidus/pull/2814) ([jtapia](https://github.com/jtapia))

**Add a store credit reasons UI in Admin**

The only way to manage store credit reasons was via console or using a data
migration.

- Add a store credit reasons Admin UI [#2798](https://github.com/solidusio/solidus/pull/2798) ([jtapia](https://github.com/jtapia))

**Skip forgery protection in api controllers**

Rails is now enabling forgery protection by default so we need to explicitly
disable it for api requests, as described here:

http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection.html

This PR also enables forgery protection by default in the specs dummy app so
that we can really test that the api code is working in a real Rails 5.2+
environment.

- Skip forgery protection in api controllers [#2800](https://github.com/solidusio/solidus/pull/2800) ([kennyadsl](https://github.com/kennyadsl))

**Add a Gallery to handle variants and products images**

All images that we send to the view layer is now using these classes that
contain the logic to retrieve images and are easier to extend. If you have
a lot of customization on how you display images you probably need to take
a look at how this has been implemented.

- Add `#gallery` to `Variant` and `Product` [#2337](https://github.com/solidusio/solidus/pull/2337) ([swcraig](https://github.com/swcraig))

**Replace jquery_ujs with rails-ujs**

This is the Rails standard now. There could be some action required, depending
on if the manifest provided by solidus has been changed. Please read the
PR description for more info.

- Replace jquery_ujs with rails-ujs in frontend and backend [#3027](https://github.com/solidusio/solidus/pull/3027) ([kennyadsl](https://github.com/kennyadsl))

**Removed code from Spree::Promotion**

Previously Solidus used `code` column on `spree_promotions` to add a code
to promotions that could be used as coupon code by users. This is no more a
thing since we support multiple coupon codes associated to a single promotion.

This change is important because it's quite common for old stores to have some
promotion with `code` field still present in the database, even if it's not used.
When performing the migration present in this PR it will raise an exception if
there are records in the `spree_promotions` table with that field present.
It's up to each store to understand how to handle this scenario before running
this migration. We also provide other two ways to handle this, and users can
just change the migration after it has been copied into their store.
It's just matter of changing the content of the
`RemoveCodeFromSpreePromotions.promotions_with_code_handler` method and make it
return one of the following:

- `Solidus::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode`:
  it will convert Spree::Promotion#code to a `Spree::PromotionCode` before
  removing the `code` column.
- `Solidus::Migrations::PromotionWithCodeHandlers::DoNothing`: it will print
  a message to track what we are deleting.

Alternatively users can create their own class to handle data and return that
class. The new class could inherit from `PromotionsWithCodeHandler` and
should respond to `call`.

- Remove `code` column from `spree_promotions` table.
[#3028](https://github.com/solidusio/solidus/pull/3028) ([kennyadsl](https://github.com/kennyadsl))

### Core

- Fix Spree::Variant inconsistency due to lack of product association [#3043](https://github.com/solidusio/solidus/pull/3043) ([rubenochiavone](https://github.com/rubenochiavone))
- Make seed file fully idempotent [#3033](https://github.com/solidusio/solidus/pull/3033) ([jontarg](https://github.com/jontarg))
- Fix multiple Money deprecation warnings. Now using html_wrap option which causes each piece of the price to be wrapped in span tags with specific classes for easier styling, but this may break existing stores' custom styles.
[#2912](https://github.com/solidusio/solidus/pull/2912) ([JDutil](https://github.com/JDutil))
- Remove update_totals/persist_totals delegation [#3012](https://github.com/solidusio/solidus/pull/3012) ([jarednorman](https://github.com/jarednorman))
- Fix autoload issue. Replace require/load with require_dependency. [#3008](https://github.com/solidusio/solidus/pull/3008) ([bitberryru](https://github.com/bitberryru))
- Enable partial doubles verification for RSpec [#3005](https://github.com/solidusio/solidus/pull/3005) ([cedum](https://github.com/cedum))
- [v2.7] Fix deprecations to make Solidus work with Rails 5.2.2 [#2992](https://github.com/solidusio/solidus/pull/2992) ([kennyadsl](https://github.com/kennyadsl))
- Add acts_as_list to Spree::StockLocation [#2953](https://github.com/solidusio/solidus/pull/2953) ([rymai](https://github.com/rymai))
- Add missing i18n English values [#2942](https://github.com/solidusio/solidus/pull/2942) ([jacobherrington](https://github.com/jacobherrington))
- Allow to bypass SKU validation [#2937](https://github.com/solidusio/solidus/pull/2937) ([fastjames](https://github.com/fastjames))
- Add translation for details attribute of LogEntry model [#2925](https://github.com/solidusio/solidus/pull/2925) ([bitberryru](https://github.com/bitberryru))
- Spree::FulfilmentChanger stock allocation fix [#2908](https://github.com/solidusio/solidus/pull/2908) ([spaghetticode](https://github.com/spaghetticode))
- DRY Spree::OrderContents [#2907](https://github.com/solidusio/solidus/pull/2907) ([spaghetticode](https://github.com/spaghetticode))
- Improve trustworthiness of a content items price. [#2897](https://github.com/solidusio/solidus/pull/2897) ([jacquesporveau](https://github.com/jacquesporveau))
- Use ActiveRecord relation for Spree::Shipment#line_items [#2886](https://github.com/solidusio/solidus/pull/2886) ([spaghetticode](https://github.com/spaghetticode))
- Round calculator values based on order currency [#2877](https://github.com/solidusio/solidus/pull/2877) ([ericsaupe](https://github.com/ericsaupe))
- Add an allocator class to extend the Solidus initial allocation logic [#2810](https://github.com/solidusio/solidus/pull/2810) ([vassalloandrea](https://github.com/vassalloandrea))
- Remove default address dependency part 2 [#2802](https://github.com/solidusio/solidus/pull/2802) ([kennyadsl](https://github.com/kennyadsl))
- Stock location sorters [#2783](https://github.com/solidusio/solidus/pull/2783) ([aldesantis](https://github.com/aldesantis))
- Recalculate order after reimbursement creation [#2711](https://github.com/solidusio/solidus/pull/2711) ([DanielePalombo](https://github.com/DanielePalombo))
- Finalize shipment after inventory units are added to completed order [#2331](https://github.com/solidusio/solidus/pull/2331) ([DanielePalombo](https://github.com/DanielePalombo))

### Backend

- Use right language_locale_key [#3044](https://github.com/solidusio/solidus/pull/3044) ([DanielePalombo](https://github.com/DanielePalombo))
- Fix missing image in autocomplete variant [#3032](https://github.com/solidusio/solidus/pull/3032) ([rubenochiavone](https://github.com/rubenochiavone))
- Skip populating states select on default country not included in available countries [#3030](https://github.com/solidusio/solidus/pull/3030) ([mdesantis](https://github.com/mdesantis))
- Add favicon to the admin layout [#3025](https://github.com/solidusio/solidus/pull/3025) ([mdesantis](https://github.com/mdesantis))
- Standardize shared resource links [#2997](https://github.com/solidusio/solidus/pull/2997) ([brchristian](https://github.com/brchristian))
- Use Spree::Variant#should_track_inventory? to disable 'Count on hand' input [#2977](https://github.com/solidusio/solidus/pull/2977) ([aitbw](https://github.com/aitbw))
- Disable 'count on hand' input when 'track inventory' option is set to false [#2960](https://github.com/solidusio/solidus/pull/2960) ([aitbw](https://github.com/aitbw))
- Bug/remove mini image from admin view [#2976](https://github.com/solidusio/solidus/pull/2976) ([nvh0412](https://github.com/nvh0412))
- Prevent multiple refund creations with accidental double clicks [#2970](https://github.com/solidusio/solidus/pull/2970) ([spaghetticode](https://github.com/spaghetticode))
- Fix "Stock" admin nav double highlight [#2969](https://github.com/solidusio/solidus/pull/2969) ([tvdeyen](https://github.com/tvdeyen))
- Added a link to the frontend product from the backend product edit page [#2956](https://github.com/solidusio/solidus/pull/2956) ([seand7565](https://github.com/seand7565))
- Use filter over search for filter options [#2940](https://github.com/solidusio/solidus/pull/2940) ([jacobherrington](https://github.com/jacobherrington))
- Add ordering to menu items [#2939](https://github.com/solidusio/solidus/pull/2939) ([jacobherrington](https://github.com/jacobherrington))
- Change new order creation link [#2936](https://github.com/solidusio/solidus/pull/2936) ([jacobherrington](https://github.com/jacobherrington))
- remove unused routes and actions from return authorizations [#2929](https://github.com/solidusio/solidus/pull/2929) ([ccarruitero](https://github.com/ccarruitero))
- Add response with error message on failure destroy action [#2920](https://github.com/solidusio/solidus/pull/2920) ([bitberryru](https://github.com/bitberryru))
- Fix tab selection in sidebar navigation [#2918](https://github.com/solidusio/solidus/pull/2918) ([bitberryru](https://github.com/bitberryru))
- Improve text in "new promotions" form for better usability [#2917](https://github.com/solidusio/solidus/pull/2917) ([michaelmichael](https://github.com/michaelmichael))
- fix closing tag mismatch [#2901](https://github.com/solidusio/solidus/pull/2901) ([bitberryru](https://github.com/bitberryru))
- Fix a N+1 query problem in the orders controller [#2894](https://github.com/solidusio/solidus/pull/2894) ([rymai](https://github.com/rymai))
- Show errors on admin shipment line item destroy failure [#2892](https://github.com/solidusio/solidus/pull/2892) ([spaghetticode](https://github.com/spaghetticode))
- Revert tooltip observer change as it does not work properly. [#2890](https://github.com/solidusio/solidus/pull/2890) ([JDutil](https://github.com/JDutil))
- Add a Master SKU field to the products form [#2875](https://github.com/solidusio/solidus/pull/2875) ([jacobherrington](https://github.com/jacobherrington))
- Create a new promotion code inside an existing promotion [#2872](https://github.com/solidusio/solidus/pull/2872) ([stem](https://github.com/stem))
- New stock management [#2862](https://github.com/solidusio/solidus/pull/2862) ([tvdeyen](https://github.com/tvdeyen))
- Fix highlighting on tax sub menu [#2854](https://github.com/solidusio/solidus/pull/2854) ([jacobherrington](https://github.com/jacobherrington))
- Fix a bug with the settings subnav  [#2853](https://github.com/solidusio/solidus/pull/2853) ([jacobherrington](https://github.com/jacobherrington))
- allow multiple taxons on product creation [#2840](https://github.com/solidusio/solidus/pull/2840) ([jacobherrington](https://github.com/jacobherrington))
- add en-US locale to select2 [#2805](https://github.com/solidusio/solidus/pull/2805) ([afdev82](https://github.com/afdev82))
- Use two column layout for stock location form [#2727](https://github.com/solidusio/solidus/pull/2727) ([tvdeyen](https://github.com/tvdeyen))

### API

- Fix N+1 problem on Api::TaxonsController#index [#3011](https://github.com/solidusio/solidus/pull/3011) ([stem](https://github.com/stem))
- Include records on API Order / Product queries [#3002](https://github.com/solidusio/solidus/pull/3002) ([fastjames](https://github.com/fastjames))

### Frontend

- Rescue from `Spree::Order::InsufficientStock` on `frontend` checkout flow [#3023](https://github.com/solidusio/solidus/pull/3023) ([spaghetticode](https://github.com/spaghetticode))
- Fix coupon code placeholder value. [#3009](https://github.com/solidusio/solidus/pull/3009) ([bitberryru](https://github.com/bitberryru))
- Fix closing td [#2999](https://github.com/solidusio/solidus/pull/2999) ([lukasbischof](https://github.com/lukasbischof))
- Add padding to the order summary [#2903](https://github.com/solidusio/solidus/pull/2903) ([jacobherrington](https://github.com/jacobherrington))

### Deprecations

- Deprecate 'X-SPREE-TOKEN' header 2 [#3029](https://github.com/solidusio/solidus/pull/3029) ([twist900](https://github.com/twist900))
- Update Jbuilder to v2.8 to fix deprecation warnings [#2962](https://github.com/solidusio/solidus/pull/2962) ([aitbw](https://github.com/aitbw))
- Deprecate existing coupon codes methods [#2958](https://github.com/solidusio/solidus/pull/2958) ([aitbw](https://github.com/aitbw))
- Fix deprecation warning for Spree::Shipment#reverse_chronological scope [#2921](https://github.com/solidusio/solidus/pull/2921) ([aitbw](https://github.com/aitbw))
- Add deprecation warning for Spree.t [#2915](https://github.com/solidusio/solidus/pull/2915) ([JDutil](https://github.com/JDutil))

### Misc

- Update issues/PRs templates [#3026](https://github.com/solidusio/solidus/pull/3026) ([kennyadsl](https://github.com/kennyadsl))
- Explicitly require Bundler within Rakefile [#3022](https://github.com/solidusio/solidus/pull/3022) ([mdesantis](https://github.com/mdesantis))
- Enable partial doubles verification for RSpec (part 2) [#3015](https://github.com/solidusio/solidus/pull/3015) ([cedum](https://github.com/cedum))
- SVG images [#2995](https://github.com/solidusio/solidus/pull/2995) ([elia](https://github.com/elia))
- Add margin to billing fields [#2985](https://github.com/solidusio/solidus/pull/2985) ([jacobherrington](https://github.com/jacobherrington))
- Add criteria for merging a PR [#2983](https://github.com/solidusio/solidus/pull/2983) ([jacobherrington](https://github.com/jacobherrington))
- Lint ERB files via HoundCI [#2982](https://github.com/solidusio/solidus/pull/2982) ([kennyadsl](https://github.com/kennyadsl))
- Move script files to bin + documentation [#2971](https://github.com/solidusio/solidus/pull/2971) ([elia](https://github.com/elia))
- Upgrade rack to 2.0.6 for security reasons [#2964](https://github.com/solidusio/solidus/pull/2964) ([tvdeyen](https://github.com/tvdeyen))
- Add i18n-tasks and normalize translations [#2963](https://github.com/solidusio/solidus/pull/2963) ([afdev82](https://github.com/afdev82))
- Add script to skip CircleCI on guides [#2955](https://github.com/solidusio/solidus/pull/2955) ([jacobherrington](https://github.com/jacobherrington))
- Dont need to lockdown autoprefixer-rails. [#2916](https://github.com/solidusio/solidus/pull/2916) ([JDutil](https://github.com/JDutil))
- fix translations keys [#2902](https://github.com/solidusio/solidus/pull/2902) ([bitberryru](https://github.com/bitberryru))
- symbol can't be argument for :count in east slavic locales [#2900](https://github.com/solidusio/solidus/pull/2900) ([bitberryru](https://github.com/bitberryru))
- Fix reference to logo on heroku template [#2896](https://github.com/solidusio/solidus/pull/2896) ([chukitow](https://github.com/chukitow))
- Move to sassc-rails [#2883](https://github.com/solidusio/solidus/pull/2883) ([jacobherrington](https://github.com/jacobherrington))
- Update .travis.yml example to non EOL versions [#2867](https://github.com/solidusio/solidus/pull/2867) ([jacobherrington](https://github.com/jacobherrington))

### Docs & Guides

- Setup Netlify site for yard docs [#3019](https://github.com/solidusio/solidus/pull/3019) ([tvdeyen](https://github.com/tvdeyen))
- Update `add-configuration` guide page [#3001](https://github.com/solidusio/solidus/pull/3001) ([spaghetticode](https://github.com/spaghetticode))
- Expand the promotion rules implementation example [#2954](https://github.com/solidusio/solidus/pull/2954) ([jacobherrington](https://github.com/jacobherrington))
- Add missing doc links [#2948](https://github.com/solidusio/solidus/pull/2948) ([jacobherrington](https://github.com/jacobherrington))
- Add a table of contents to the readme [#2945](https://github.com/solidusio/solidus/pull/2945) ([jacobherrington](https://github.com/jacobherrington))
- Standardize capitalization [#2943](https://github.com/solidusio/solidus/pull/2943) ([jacobherrington](https://github.com/jacobherrington))
- improve decorators / contributing docs [#2933](https://github.com/solidusio/solidus/pull/2933) ([elia](https://github.com/elia))
- Guides improvements [#2923](https://github.com/solidusio/solidus/pull/2923) ([kennyadsl](https://github.com/kennyadsl))
- Add API section to developer guide table of contents [#2909](https://github.com/solidusio/solidus/pull/2909) ([benjaminwil](https://github.com/benjaminwil))
- Add a Netlify configuration for deploying guides site [#2893](https://github.com/solidusio/solidus/pull/2893) ([tvdeyen](https://github.com/tvdeyen))
- Use logo.svg in the README [#2887](https://github.com/solidusio/solidus/pull/2887) ([jacobherrington](https://github.com/jacobherrington))
- Fix a security vulnerability in guides [#2885](https://github.com/solidusio/solidus/pull/2885) ([kennyadsl](https://github.com/kennyadsl))
- Add comments to the issue template [#2884](https://github.com/solidusio/solidus/pull/2884) ([jacobherrington](https://github.com/jacobherrington))
- Update promotion actions documentation [#2871](https://github.com/solidusio/solidus/pull/2871) ([jacobherrington](https://github.com/jacobherrington))
- Add a reference to the Writing Extensions doc [#2851](https://github.com/solidusio/solidus/pull/2851) ([jacobherrington](https://github.com/jacobherrington))
- Add article that documents a Spree::Order journey [#2803](https://github.com/solidusio/solidus/pull/2803) ([benjaminwil](https://github.com/benjaminwil))


## Solidus 2.7.0 (2018-09-14)

### Major Changes

**Rails 5.2.1**

Added support for Rails 5.2.1. Solidus 2.7.0 supports either Rails 5.2.x or 5.1.

**Guides**

Added the [new guides website](https://guides.solidus.io/) code directly into
the main repository. This way it should be simpler to keep guides up to date.

### Guides

- Update guides ffi gem
[#2838](https://github.com/solidusio/solidus/pull/2838) ([kennyadsl](https://github.com/kennyadsl))
- add documentation for making new Solidus extensions [#2813](https://github.com/solidusio/solidus/pull/2813) ([jacobherrington](https://github.com/jacobherrington))
- Fix guides typos and clean up example code blocks  [#2785](https://github.com/solidusio/solidus/pull/2785) ([benjaminwil](https://github.com/benjaminwil))
- Update promotion-rules.md [#2764](https://github.com/solidusio/solidus/pull/2764) ([bazfer](https://github.com/bazfer))
- Add links to guides.solidus.io in Solidus's README.md and clean up README formatting [#2763](https://github.com/solidusio/solidus/pull/2763) ([benjaminwil](https://github.com/benjaminwil))
- Tweak documentation site Middleman configuration [#2762](https://github.com/solidusio/solidus/pull/2762) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation about variants for end users [#2761](https://github.com/solidusio/solidus/pull/2761) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation about product properties for end users [#2759](https://github.com/solidusio/solidus/pull/2759) ([benjaminwil](https://github.com/benjaminwil))
- Add initial stock documentation for end users [#2757](https://github.com/solidusio/solidus/pull/2757) ([benjaminwil](https://github.com/benjaminwil))
- Add promotion actions and promotion calculators documentation for end users [#2755](https://github.com/solidusio/solidus/pull/2755) ([benjaminwil](https://github.com/benjaminwil))
- Add Gemfile.lock to docs site project [#2752](https://github.com/solidusio/solidus/pull/2752) ([jgayfer](https://github.com/jgayfer))
- Add initial zones documentation for end users [#2750](https://github.com/solidusio/solidus/pull/2750) ([benjaminwil](https://github.com/benjaminwil))
- Add initial taxation documentation for end users [#2749](https://github.com/solidusio/solidus/pull/2749) ([benjaminwil](https://github.com/benjaminwil))
- Fix security vulnerabilities in docs site [#2747](https://github.com/solidusio/solidus/pull/2747) ([jgayfer](https://github.com/jgayfer))
- Add initial user management documentation for end users [#2745](https://github.com/solidusio/solidus/pull/2745) ([benjaminwil](https://github.com/benjaminwil))
- Update promotion-rules.md [#2742](https://github.com/solidusio/solidus/pull/2742) ([bazfer](https://github.com/bazfer))
- Move guides to new docs site [#2740](https://github.com/solidusio/solidus/pull/2740) ([jgayfer](https://github.com/jgayfer))
- Add docs site shell [#2739](https://github.com/solidusio/solidus/pull/2739) ([jgayfer](https://github.com/jgayfer))
- Add initial promotions documentation for end users [#2735](https://github.com/solidusio/solidus/pull/2735) ([benjaminwil](https://github.com/benjaminwil))
- Add initial product documentation for end users  [#2723](https://github.com/solidusio/solidus/pull/2723) ([benjaminwil](https://github.com/benjaminwil))
- Overview documentation for the Solidus API [#2714](https://github.com/solidusio/solidus/pull/2714) ([benjaminwil](https://github.com/benjaminwil))

### Core

- Set correct quantity on order import
[#2837](https://github.com/solidusio/solidus/pull/2837) ([fastjames](https://github.com/fastjames))
- Money#allocate calculates weights already
[#2836](https://github.com/solidusio/solidus/pull/2836) ([huoxito](https://github.com/huoxito))
- Update user_class_handle.rb
[#2832](https://github.com/solidusio/solidus/pull/2832) ([bazfer](https://github.com/bazfer))
- Allow customizing the promotion code batch mailer class [#2796](https://github.com/solidusio/solidus/pull/2796) ([jtapia](https://github.com/jtapia))
- Allow customizing the reimbursement mailer class [#2795](https://github.com/solidusio/solidus/pull/2795) ([jtapia](https://github.com/jtapia))
- Allow customizing the order mailer class [#2792](https://github.com/solidusio/solidus/pull/2792) ([jtapia](https://github.com/jtapia))
- Compatibility with Rails 5.2.1 & Ransack [#2826](https://github.com/solidusio/solidus/pull/2826) ([kennyadsl](https://github.com/kennyadsl))
- Move factory_bot static attrs to dynamic
[#2831](https://github.com/solidusio/solidus/pull/2831) ([fastjames](https://github.com/fastjames))
- Use Spree.user_class.table_name instead of spree_users [#2815](https://github.com/solidusio/solidus/pull/2815) ([masatooba](https://github.com/masatooba))
- Fix a store credit spec that is time zone dependent [#2778](https://github.com/solidusio/solidus/pull/2778) ([kennyadsl](https://github.com/kennyadsl))
- Making sure order by columns do not collide with other tables [#2774](https://github.com/solidusio/solidus/pull/2774) ([softr8](https://github.com/softr8))
- Fix permissions for users to change their own orders  [#2787](https://github.com/solidusio/solidus/pull/2787) ([kennyadsl](https://github.com/kennyadsl))

### Admin

- Fix space between taxons on admin taxonomies [#2812](https://github.com/solidusio/solidus/pull/2812) ([jtapia](https://github.com/jtapia))
- Fix issue not updating payment method type on admin [#2788](https://github.com/solidusio/solidus/pull/2788) ([jtapia](https://github.com/jtapia))
- Tracking Number link to Tracking URL page
[#2829](https://github.com/solidusio/solidus/pull/2829) ([JuanCrg90](https://github.com/JuanCrg90))
- make customer email field required when an admin is making a new order [#2771](https://github.com/solidusio/solidus/pull/2771) ([jacobherrington](https://github.com/jacobherrington))
- Fix bug with user address forms [#2766](https://github.com/solidusio/solidus/pull/2766) ([jacobeubanks](https://github.com/jacobeubanks))
- Dynamically render ReportsController translations [#2751](https://github.com/solidusio/solidus/pull/2751) ([stewart](https://github.com/stewart))
- Add missing data-hook on customer_returns tab [#2738](https://github.com/solidusio/solidus/pull/2738) ([fkoessler](https://github.com/fkoessler))
- Require sass >= 3.5.2 [#2734](https://github.com/solidusio/solidus/pull/2734) ([gmacdougall](https://github.com/gmacdougall))
- The promotions "Advertise" checkbox and the "URL Path" promotion activation method have been removed from the admin UI because the features are not implemented in solidus_frontend [#2737](https://github.com/solidusio/solidus/pull/2737) ([benjaminwil](https://github.com/benjaminwil))
- Use a different session key for admin locale [#2685](https://github.com/solidusio/solidus/pull/2685) ([jhawthorn](https://github.com/jhawthorn))
- Disable backend footer profile edit link if role cannot edit users [#2646](https://github.com/solidusio/solidus/pull/2646) ([gianlucarizzo](https://github.com/gianlucarizzo))
- Improve admin return authorization controller [#2420](https://github.com/solidusio/solidus/pull/2420) ([kennyadsl](https://github.com/kennyadsl))

### Frontend

- The `TaxonsController#show` action loads now the `@taxon` in a `before_action` callback. This means that if you overrode the `show` method you may be loading the `@taxon` variable twice. You can now change the behaviour of how the `@taxon` is loaded overriding the `load_taxon` method instead. [#2782](https://github.com/solidusio/solidus/pull/2782) ([coorasse](https://github.com/coorasse))
- Move checkout coupon code section into summary. Now passing [:order][:coupon_code] into any controller of the frontend will not perform any action, while it was trying to add a new coupon code before. It now only works in checkout and orders controller. [#2327](https://github.com/solidusio/solidus/pull/2327) ([kennyadsl](https://github.com/kennyadsl))

## Solidus 2.6.0 (2018-05-16)

### Major changes

**Rails 5.2**

This is the first version of Solidus to support [Rails 5.2](http://guides.rubyonrails.org/5_2_release_notes.html). Solidus 2.6.0 supports either Rails 5.1 or 5.2. We're hoping this makes both upgrades as easy as possible since they can be done separately.

**Merged solidus_i18n functionality**

Much of solidus_i18n's functionality has been merged into Solidus itself. Solidus now allows configuring one or more locales per-store in the admin. Both users and admins can select their preferred locales on the frontend or admin respectively. More information on how to upgrade can be found in the [solidus_i18n README](https://github.com/solidusio/solidus_i18n).

**Guides**

A lot of work has gone into guides, which are now much more comprehensive. A website to host them is in the works but for now they can be seen [on github](https://github.com/solidusio/solidus/blob/v2.6/guides/index.md)

### Core
- Upgrade cancancan to 2.x [#2731](https://github.com/solidusio/solidus/pull/2731) ([jhawthorn](https://github.com/jhawthorn))
- Replace `uniq` with `distinct` for cartons association [#2710](https://github.com/solidusio/solidus/pull/2710) ([DanielePalombo](https://github.com/DanielePalombo))
- Allow #try_spree_current_user to search for private methods [#2694](https://github.com/solidusio/solidus/pull/2694) ([spaghetticode](https://github.com/spaghetticode))
- Remove assert_written_to_cache [#2691](https://github.com/solidusio/solidus/pull/2691) ([jhawthorn](https://github.com/jhawthorn))
- cleanup order validate_payments_attributes [#2696](https://github.com/solidusio/solidus/pull/2696) ([ccarruitero](https://github.com/ccarruitero))
- Load email validator from core instead of order [#2669](https://github.com/solidusio/solidus/pull/2669) ([jhawthorn](https://github.com/jhawthorn))
- Promo code batch join chars [#2662](https://github.com/solidusio/solidus/pull/2662) ([gevann](https://github.com/gevann))
- Move EmailValidator under Spree namespace [#2635](https://github.com/solidusio/solidus/pull/2635) ([tvdeyen](https://github.com/tvdeyen))
- Remove protected_attributes warning [#2615](https://github.com/solidusio/solidus/pull/2615) ([jhawthorn](https://github.com/jhawthorn))
- Namespace all testing_support/ files under Spree::TestingSupport namespace [#2629](https://github.com/solidusio/solidus/pull/2629) ([jhawthorn](https://github.com/jhawthorn))
- Remove foreign key from promotion_rules_stores [#2603](https://github.com/solidusio/solidus/pull/2603) ([jhawthorn](https://github.com/jhawthorn))
- Generate new stores with MySQL timestamp precision 6 [#2598](https://github.com/solidusio/solidus/pull/2598) ([jhawthorn](https://github.com/jhawthorn))
- Add frozen_string_literal: true to all files [#2586](https://github.com/solidusio/solidus/pull/2586) ([jhawthorn](https://github.com/jhawthorn))
- Distribute over eligible line items [#2582](https://github.com/solidusio/solidus/pull/2582) ([Sinetheta](https://github.com/Sinetheta))
- Add mutable false to default refund reason record [#2574](https://github.com/solidusio/solidus/pull/2574) ([mdesantis](https://github.com/mdesantis))
- Specify inheritance for Spree::Promotion [#2572](https://github.com/solidusio/solidus/pull/2572) ([SamuelMartini](https://github.com/SamuelMartini))
- Remove foreign key from store_shipping_methods [#2596](https://github.com/solidusio/solidus/pull/2596) ([jhawthorn](https://github.com/jhawthorn))
- Add options to PromotionCode::BatchBuilder and spec for unique promotion code contention [#2579](https://github.com/solidusio/solidus/pull/2579) ([jhawthorn](https://github.com/jhawthorn))
- Set HttpOnly flag when sending guest_token cookie [#2633](https://github.com/solidusio/solidus/pull/2633) ([luukveenis](https://github.com/luukveenis))
- Splitting shipment should update order totals/payment status [#2555](https://github.com/solidusio/solidus/pull/2555) ([VzqzAc](https://github.com/VzqzAc))
- Add store promotion rule [#2552](https://github.com/solidusio/solidus/pull/2552) ([adammathys](https://github.com/adammathys))
- Add association between stores and shipping [#2557](https://github.com/solidusio/solidus/pull/2557) ([adammathys](https://github.com/adammathys))
- Make partially shipped shipment able to be ready [#2634](https://github.com/solidusio/solidus/pull/2634) ([jhawthorn](https://github.com/jhawthorn))
- Remove order_stock_locations association [#2672](https://github.com/solidusio/solidus/pull/2672) ([jhawthorn](https://github.com/jhawthorn))
- Generate correct number of codes in BatchBuilder [#2578](https://github.com/solidusio/solidus/pull/2578) ([jhawthorn](https://github.com/jhawthorn))
- Add amount_remaining for Spree::StoreCreditEvent [#1512](https://github.com/solidusio/solidus/pull/1512) ([mtylty](https://github.com/mtylty))
- Add per-store configurable locales [#2674](https://github.com/solidusio/solidus/pull/2674) ([jhawthorn](https://github.com/jhawthorn))
- Move Spree::Taxon#applicable_filters (rebase) [#2670](https://github.com/solidusio/solidus/pull/2670) ([jhawthorn](https://github.com/jhawthorn))
- Translate reception states and fix translation key [#2283](https://github.com/solidusio/solidus/pull/2283) ([rbngzlv](https://github.com/rbngzlv))

### Admin
- Remove hardcoded admin store attributes [#2713](https://github.com/solidusio/solidus/pull/2713) ([jtapia](https://github.com/jtapia))
- Improve the admin UX for a product's "Available On" field [#2704](https://github.com/solidusio/solidus/pull/2704) ([benjaminwil](https://github.com/benjaminwil))
- UI fixes for admin locale select [#2684](https://github.com/solidusio/solidus/pull/2684) ([tvdeyen](https://github.com/tvdeyen))
- Set model_class on admin promotion rules controller [#2623](https://github.com/solidusio/solidus/pull/2623) ([luukveenis](https://github.com/luukveenis))
- Fix admin payment actions style table issue [#2589](https://github.com/solidusio/solidus/pull/2589) ([jtapia](https://github.com/jtapia))
- Allowing admin to show all countries regardless checkout zone [#2588](https://github.com/solidusio/solidus/pull/2588) ([softr8](https://github.com/softr8))
- Add locale chooser to admin [#2559](https://github.com/solidusio/solidus/pull/2559) ([jhawthorn](https://github.com/jhawthorn))
- Fix css class in taxons [#2705](https://github.com/solidusio/solidus/pull/2705) ([yono](https://github.com/yono))
- Backend stock movements improvements [#2612](https://github.com/solidusio/solidus/pull/2612) ([kennyadsl](https://github.com/kennyadsl))
- adding link to product in backend order summary [#2609](https://github.com/solidusio/solidus/pull/2609) ([loicginoux](https://github.com/loicginoux))
- Properly limit per-quantity calculator types [#2590](https://github.com/solidusio/solidus/pull/2590) ([Sinetheta](https://github.com/Sinetheta))
- Avoid frozen string error in button helper [#2592](https://github.com/solidusio/solidus/pull/2592) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate payment_method_name helper [#2657](https://github.com/solidusio/solidus/pull/2657) ([jhawthorn](https://github.com/jhawthorn))
- Fix API url when editing image alt text [#2625](https://github.com/solidusio/solidus/pull/2625) ([loicginoux](https://github.com/loicginoux))
- Replace button_link_to with either button_to or link_to [#2601](https://github.com/solidusio/solidus/pull/2601) ([jhawthorn](https://github.com/jhawthorn))
- Replace button helper with standard button_tag [#2600](https://github.com/solidusio/solidus/pull/2600) ([jhawthorn](https://github.com/jhawthorn))
- Negative count on hand red [#2682](https://github.com/solidusio/solidus/pull/2682) ([gevann](https://github.com/gevann))
- Match a closing tag in order_summary [#2681](https://github.com/solidusio/solidus/pull/2681) ([shikolay](https://github.com/shikolay))
- Fixing the promotion categories error message [#1346](https://github.com/solidusio/solidus/pull/1346) ([mgharbik](https://github.com/mgharbik))

### API
- Remove promotion_code from adjustment_attributes [#2663](https://github.com/solidusio/solidus/pull/2663) ([gevann](https://github.com/gevann))
- Clean CheckoutsController routes [#2649](https://github.com/solidusio/solidus/pull/2649) ([gevann](https://github.com/gevann))
- Update no_objects_found partial to allow not show new resource link [#2289](https://github.com/solidusio/solidus/pull/2289) ([ccarruitero](https://github.com/ccarruitero))
- Fix view for orders api (Fixes Issue #2512) [#2513](https://github.com/solidusio/solidus/pull/2513) ([skukx](https://github.com/skukx))
- Add meta_title to product response [#2480](https://github.com/solidusio/solidus/pull/2480) ([loicginoux](https://github.com/loicginoux))
- Creating an order should activate promotions [#2576](https://github.com/solidusio/solidus/pull/2576) ([loicginoux](https://github.com/loicginoux))
- Render shipment json when payment source is nil [#2611](https://github.com/solidusio/solidus/pull/2611) ([loicginoux](https://github.com/loicginoux))

### Frontend
- Fix `<td>` closing tag [#2703](https://github.com/solidusio/solidus/pull/2703) ([dportalesr](https://github.com/dportalesr))
- Fix duplicate variants on product page [#2630](https://github.com/solidusio/solidus/pull/2630) ([mamhoff](https://github.com/mamhoff))
- Fix error when listing products without price [#2605](https://github.com/solidusio/solidus/pull/2605) ([jhawthorn](https://github.com/jhawthorn))
- Fix redirect to cart [#2585](https://github.com/solidusio/solidus/pull/2585) ([matteocellucci](https://github.com/matteocellucci))
- Add locale selector to frontend nav bar [#2683](https://github.com/solidusio/solidus/pull/2683) ([jhawthorn](https://github.com/jhawthorn))
- Filter unpriced products in taxon_preview [#2604](https://github.com/solidusio/solidus/pull/2604) ([jhawthorn](https://github.com/jhawthorn))
- Improve frontend checkout forms html [#2416](https://github.com/solidusio/solidus/pull/2416) ([kennyadsl](https://github.com/kennyadsl))
- Make frontend's LocaleController compatible with solidus_i18n [#2626](https://github.com/solidusio/solidus/pull/2626) ([jhawthorn](https://github.com/jhawthorn))
- Indent nested taxon menues and highlight the selected taxons. [#2316](https://github.com/solidusio/solidus/pull/2316) ([bofrede](https://github.com/bofrede))

### Documentation
- Fix typos and formatting in Solidus guides [#2729](https://github.com/solidusio/solidus/pull/2729) ([benjaminwil](https://github.com/benjaminwil))
- Add a documentation contributors guide [#2718](https://github.com/solidusio/solidus/pull/2718) ([benjaminwil](https://github.com/benjaminwil))
- Make documentation clearer and fix invalid links  [#2717](https://github.com/solidusio/solidus/pull/2717) ([benjaminwil](https://github.com/benjaminwil))
- Add multiple typo fixes in the guides [#2716](https://github.com/solidusio/solidus/pull/2716) ([Shkrt](https://github.com/Shkrt))
- Add documentation for Spree::Reimbursements and Spree::ReimbursementTypes [#2678](https://github.com/solidusio/solidus/pull/2678) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation for Spree::CustomerReturn model [#2677](https://github.com/solidusio/solidus/pull/2677) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation of Spree::ReturnItem model [#2676](https://github.com/solidusio/solidus/pull/2676) ([benjaminwil](https://github.com/benjaminwil))
- Add initial Solidus upgrades documentation [#2641](https://github.com/solidusio/solidus/pull/2641) ([benjaminwil](https://github.com/benjaminwil))
- Add initial Spree migration article [#2640](https://github.com/solidusio/solidus/pull/2640) ([benjaminwil](https://github.com/benjaminwil))
- Fix YARD warnings throughout core [#2636](https://github.com/solidusio/solidus/pull/2636) ([jhawthorn](https://github.com/jhawthorn))
- Add yard rake task [#2632](https://github.com/solidusio/solidus/pull/2632) ([jhawthorn](https://github.com/jhawthorn))
- Fix typo in CheckoutController comment [#2631](https://github.com/solidusio/solidus/pull/2631) ([jgayfer](https://github.com/jgayfer))
- Rewrite payment processing documentation; add Spree::Order#payment_states documentation [#2624](https://github.com/solidusio/solidus/pull/2624) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation introducing payment service providers [#2620](https://github.com/solidusio/solidus/pull/2620) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation for the Spree::Payment model [#2619](https://github.com/solidusio/solidus/pull/2619) ([benjaminwil](https://github.com/benjaminwil))
- Rewrite article documenting payment methods [#2618](https://github.com/solidusio/solidus/pull/2618) ([benjaminwil](https://github.com/benjaminwil))
- Add initial documentation about payment sources [#2617](https://github.com/solidusio/solidus/pull/2617) ([benjaminwil](https://github.com/benjaminwil))
- Rewrite payments overview documentation [#2613](https://github.com/solidusio/solidus/pull/2613) ([benjaminwil](https://github.com/benjaminwil))
- Documentation touchup [#2591](https://github.com/solidusio/solidus/pull/2591) ([jormon](https://github.com/jormon))
- Add documentation for stock items and stock movements [#2539](https://github.com/solidusio/solidus/pull/2539) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation overview of inventory [#2538](https://github.com/solidusio/solidus/pull/2538) ([benjaminwil](https://github.com/benjaminwil))
- Add a stub article that summarizes Solidus's built-in tax calculator [#2526](https://github.com/solidusio/solidus/pull/2526) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation that summarizes Solidus's built-in shipping calculators [#2525](https://github.com/solidusio/solidus/pull/2525) ([benjaminwil](https://github.com/benjaminwil))
- Add documentation that summarizes Solidus's built-in promotion calculators [#2524](https://github.com/solidusio/solidus/pull/2524) ([benjaminwil](https://github.com/benjaminwil))
- Initial calculators documentation [#2511](https://github.com/solidusio/solidus/pull/2511) ([benjaminwil](https://github.com/benjaminwil))
- Initial orders documentation [#2498](https://github.com/solidusio/solidus/pull/2498) ([benjaminwil](https://github.com/benjaminwil))
- Addresses documentation [#2471](https://github.com/solidusio/solidus/pull/2471) ([benjaminwil](https://github.com/benjaminwil))
- Initial promotions documentation [#2467](https://github.com/solidusio/solidus/pull/2467) ([benjaminwil](https://github.com/benjaminwil))
- Adjustments documentation [#2459](https://github.com/solidusio/solidus/pull/2459) ([benjaminwil](https://github.com/benjaminwil))
- Guides: Links and syntax fixes [#2709](https://github.com/solidusio/solidus/pull/2709) ([tvdeyen](https://github.com/tvdeyen))
- Fix markdown link syntax in payment service provider guide [#2708](https://github.com/solidusio/solidus/pull/2708) ([tvdeyen](https://github.com/tvdeyen))
- Fix the code syntax in installation options guide [#2707](https://github.com/solidusio/solidus/pull/2707) ([tvdeyen](https://github.com/tvdeyen))
- Add a guides index and generator [#2671](https://github.com/solidusio/solidus/pull/2671) ([tvdeyen](https://github.com/tvdeyen))
- Split existing configuration guide [#2488](https://github.com/solidusio/solidus/pull/2488) ([benjaminwil](https://github.com/benjaminwil))
- add payments guide [#2388](https://github.com/solidusio/solidus/pull/2388) ([ccarruitero](https://github.com/ccarruitero))
- Add overview of returns system [#2675](https://github.com/solidusio/solidus/pull/2675) ([benjaminwil](https://github.com/benjaminwil))
- Port extension testing document from wiki [#2642](https://github.com/solidusio/solidus/pull/2642) ([benjaminwil](https://github.com/benjaminwil))
- Update Orders state machine doc removing confirmation_required text [#2658](https://github.com/solidusio/solidus/pull/2658) ([kennyadsl](https://github.com/kennyadsl))
- Improve PaymentMethod docs and add some deprecations [#2650](https://github.com/solidusio/solidus/pull/2650) ([jhawthorn](https://github.com/jhawthorn))
- Remove generators from YARD docs [#2651](https://github.com/solidusio/solidus/pull/2651) ([jhawthorn](https://github.com/jhawthorn))
- Add custom authentication (User model) setup article [#2581](https://github.com/solidusio/solidus/pull/2581) ([benjaminwil](https://github.com/benjaminwil))
- Add article about views for new Rails developers [#2560](https://github.com/solidusio/solidus/pull/2560) ([benjaminwil](https://github.com/benjaminwil))

## Solidus 2.5.0 (2018-03-27)

## Major Changes
### Migrate to discard from paranoia

Previously Solidus used [`paranoia`](https://github.com/rubysherpas/paranoia) to handle soft-deletion.

`paranoia`, on `acts_as_paranoid` models, replaces ActiveRecord's `delete` and `destroy` methods and instead of deleting the record sets the `deleted_at` column.
This has been the cause of some surprising behaviour for users old and new.

In this version we are beginning to deprecate this using the [`discard`](https://github.com/jhawthorn/discard) gem.

- Use paranoia\_ prefixed methods [#2350](https://github.com/solidusio/solidus/pull/2350) ([jhawthorn](https://github.com/jhawthorn))
- Convert store credits to discard [#2489](https://github.com/solidusio/solidus/pull/2489) ([jhawthorn](https://github.com/jhawthorn))
- Convert shipping methods, payment methods, and tax rates to discard [#2487](https://github.com/solidusio/solidus/pull/2487) ([jhawthorn](https://github.com/jhawthorn))
- Convert promotion actions from paranoia to discard [#2398](https://github.com/solidusio/solidus/pull/2398) ([jhawthorn](https://github.com/jhawthorn))
- Convert product, variant, stock item, prices to discard [#2396](https://github.com/solidusio/solidus/pull/2396) ([jhawthorn](https://github.com/jhawthorn))

### solidus_stock_transfers extracted to gem

[solidus_stock_transfers](https://github.com/solidusio-contrib/solidus_stock_transfers) provides an admin interface to transfer stock between two locations. This used to be included in core but has been extracted to a gem.
- Extract stock transfers to the [solidus_stock_transfers](https://github.com/solidusio-contrib/solidus_stock_transfers) gem. [#2379](https://github.com/solidusio/solidus/pull/2379) ([jhawthorn](https://github.com/jhawthorn))


## Misc

- Generate correct number of codes in BatchBuilder [#2578](https://github.com/solidusio/solidus/pull/2578) ([jhawthorn](https://github.com/jhawthorn))
- Add mutable false to default refund reason record [#2574](https://github.com/solidusio/solidus/pull/2574) ([mdesantis](https://github.com/mdesantis))
- Use carmen to translate `available_countries` helper [#2537](https://github.com/solidusio/solidus/pull/2537) ([jhawthorn](https://github.com/jhawthorn))
- Introduce "suppliable" scope to represent any variant which can_supply?(1) [#2536](https://github.com/solidusio/solidus/pull/2536) ([jhawthorn](https://github.com/jhawthorn))
- Fix calculator class check bug [#2501](https://github.com/solidusio/solidus/pull/2501) ([pelargir](https://github.com/pelargir))
- Allow `remove_default_tax` migration to be reversible [#2496](https://github.com/solidusio/solidus/pull/2496) ([brchristian](https://github.com/brchristian))
- Make credit card parameter filtering more specific [#2481](https://github.com/solidusio/solidus/pull/2481) ([jordan-brough](https://github.com/jordan-brough))
- Improve product -> master attributes delegation [#2474](https://github.com/solidusio/solidus/pull/2474) ([kennyadsl](https://github.com/kennyadsl))
- Make the install generator idempotent [#2472](https://github.com/solidusio/solidus/pull/2472) ([tvdeyen](https://github.com/tvdeyen))
- Update totals after order_with_totals create [#2470](https://github.com/solidusio/solidus/pull/2470) ([BravoSimone](https://github.com/BravoSimone))
- Fixes for MySQL [#2468](https://github.com/solidusio/solidus/pull/2468) ([jhawthorn](https://github.com/jhawthorn))
- Prepare for Rails 5.2 [#2465](https://github.com/solidusio/solidus/pull/2465) ([jhawthorn](https://github.com/jhawthorn))
- New preference to control available currencies [#2461](https://github.com/solidusio/solidus/pull/2461) ([softr8](https://github.com/softr8))
- Avoid changing method visibility when deprecating a method [#2449](https://github.com/solidusio/solidus/pull/2449) ([jordan-brough](https://github.com/jordan-brough))
- Require kaminari ~> 1.1 and some related improvements [#2443](https://github.com/solidusio/solidus/pull/2443) ([jhawthorn](https://github.com/jhawthorn))
- remove redundant delegation from product model [#2427](https://github.com/solidusio/solidus/pull/2427) ([brchristian](https://github.com/brchristian))
- Use I18n date format for `pretty_time` helper [#2419](https://github.com/solidusio/solidus/pull/2419) ([tvdeyen](https://github.com/tvdeyen))
- Use a single top-level Gemfile for test dependencies [#2407](https://github.com/solidusio/solidus/pull/2407) ([jhawthorn](https://github.com/jhawthorn))
- Unify how we create sample store in default and sample data [#2405](https://github.com/solidusio/solidus/pull/2405) ([kennyadsl](https://github.com/kennyadsl))
- Update `updated_at` timestamp on eligibility change [#2390](https://github.com/solidusio/solidus/pull/2390) ([adaddeo](https://github.com/adaddeo))
- Remove stringex as a dependency of core [#2383](https://github.com/solidusio/solidus/pull/2383) ([swcraig](https://github.com/swcraig))
- Fixes for custom user generator [#2382](https://github.com/solidusio/solidus/pull/2382) ([tvdeyen](https://github.com/tvdeyen))
- Remove order association from inventory units [#2377](https://github.com/solidusio/solidus/pull/2377) ([mamhoff](https://github.com/mamhoff))
- Move role configuration into Spree::Config [#2374](https://github.com/solidusio/solidus/pull/2374) ([jhawthorn](https://github.com/jhawthorn))
- Avoid loading models when requiring factories [#2369](https://github.com/solidusio/solidus/pull/2369) ([jhawthorn](https://github.com/jhawthorn))
- Allow loading solidus_core without Sprockets [#2358](https://github.com/solidusio/solidus/pull/2358) ([jhawthorn](https://github.com/jhawthorn))
- Improve `selected_shipping_rate_id=` [#2355](https://github.com/solidusio/solidus/pull/2355) ([jhawthorn](https://github.com/jhawthorn))
- Change `make_permalink` behaviour [#2341](https://github.com/solidusio/solidus/pull/2341) ([jhawthorn](https://github.com/jhawthorn))
- Follow FactoryBot rename [#2315](https://github.com/solidusio/solidus/pull/2315) ([mamhoff](https://github.com/mamhoff))
- Fix module/class nesting in calculator/\* [#2312](https://github.com/solidusio/solidus/pull/2312) ([cbrunsdon](https://github.com/cbrunsdon))
- Require only part of activemerchant [#2311](https://github.com/solidusio/solidus/pull/2311) ([mamhoff](https://github.com/mamhoff))
- Replace Spree.t with plain I18n.t [#2309](https://github.com/solidusio/solidus/pull/2309) ([jhawthorn](https://github.com/jhawthorn))
- Improve `ShippingRate#display_price` with taxes [#2306](https://github.com/solidusio/solidus/pull/2306) ([jhawthorn](https://github.com/jhawthorn))
- Allow access to `Spree::Core::Environment` through `Spree::Config` [#2291](https://github.com/solidusio/solidus/pull/2291) ([cbrunsdon](https://github.com/cbrunsdon))
- Explicitly require cancan where used [#2290](https://github.com/solidusio/solidus/pull/2290) ([cbrunsdon](https://github.com/cbrunsdon))
- Update translation for Adjustment Label [#2287](https://github.com/solidusio/solidus/pull/2287) ([gregdaynes](https://github.com/gregdaynes))
- Fix restocking and unstocking backordered items in FulfilmentChanger [#2286](https://github.com/solidusio/solidus/pull/2286) ([DanielePalombo](https://github.com/DanielePalombo))
- Fix return url after fire in return_authorizations controller [#2284](https://github.com/solidusio/solidus/pull/2284) ([rbngzlv](https://github.com/rbngzlv))
- Remove `after_rollback` from LogEntry [#2280](https://github.com/solidusio/solidus/pull/2280) [#2277](https://github.com/solidusio/solidus/pull/2277) ([reidcooper](https://github.com/reidcooper) [jhawthorn](https://github.com/jhawthorn))
- Make `solidus_core` depend on actionmailer and activerecord instead of rails [#2272](https://github.com/solidusio/solidus/pull/2272) ([BenMorganIO](https://github.com/BenMorganIO))
- Improve performance of Taxon promotion rule [#2258](https://github.com/solidusio/solidus/pull/2258) ([gmacdougall](https://github.com/gmacdougall))
- Fix class definition of variant [#2248](https://github.com/solidusio/solidus/pull/2248) ([cbrunsdon](https://github.com/cbrunsdon))
- Updating classification should touch product [#2238](https://github.com/solidusio/solidus/pull/2238) ([loicginoux](https://github.com/loicginoux))
- Avoid duplicate queries when running estimator taxation. [#2219](https://github.com/solidusio/solidus/pull/2219) ([jhawthorn](https://github.com/jhawthorn))
- Add eligibility checking to automatic free shipping promotions [#2187](https://github.com/solidusio/solidus/pull/2187) ([fylooi](https://github.com/fylooi))
- Strip whitespace surrounding promotion codes. [#1796](https://github.com/solidusio/solidus/pull/1796) ([eric1234](https://github.com/eric1234))
- Add missing indexes for `Spree::Taxon` lft and rgt columns [#1779](https://github.com/solidusio/solidus/pull/1779) ([vfonic](https://github.com/vfonic))
- Methods for `Spree::Taxon` for all products/variants from descendants [#1761](https://github.com/solidusio/solidus/pull/1761) ([dgra](https://github.com/dgra))
- Fix RMA amount calculator [#1590](https://github.com/solidusio/solidus/pull/1590) ([DanielePalombo](https://github.com/DanielePalombo))
- Allow cancelling orders that have been fully refunded [#1355](https://github.com/solidusio/solidus/pull/1355) ([Sinetheta](https://github.com/Sinetheta))
- Simplify Coupon PromotionHandler [#521](https://github.com/solidusio/solidus/pull/521) ([jhawthorn](https://github.com/jhawthorn))
- Splitting shipment should update order totals and payment status [#2555](https://github.com/solidusio/solidus/pull/2555) ([VzqzAc](https://github.com/VzqzAc)
- Add mutable false to default refund reason record [#2574](https://github.com/solidusio/solidus/pull/2574) ([mdesantis](https://github.com/mdesantis))
- Generate correct number of codes in BatchBuilder [#2578](https://github.com/solidusio/solidus/pull/2578) ([jhawthorn](https://github.com/jhawthorn))

## Deprecations and removals
- Remove `Spree::OrderUpdater#round_money` [#2344](https://github.com/solidusio/solidus/pull/2344) ([swcraig](https://github.com/swcraig))
- Remove testing_support/i18n [#2340](https://github.com/solidusio/solidus/pull/2340) ([jhawthorn](https://github.com/jhawthorn))
- Remove ffaker [#2339](https://github.com/solidusio/solidus/pull/2339) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate AdjustmentSource#deals_with_adjustments_for_deleted_source [#2259](https://github.com/solidusio/solidus/pull/2259) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove remnants of location configured packages [#2270](https://github.com/solidusio/solidus/pull/2270) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate class method in `Calculator::FlexiRate` [#2305](https://github.com/solidusio/solidus/pull/2305) ([swcraig](https://github.com/swcraig))
- Improve deprecation message for 'deprecated_method_type_override' [#2494](https://github.com/solidusio/solidus/pull/2494) ([jordan-brough](https://github.com/jordan-brough))
- Deprecate Searcher::Base method_missing properties magic [#2464](https://github.com/solidusio/solidus/pull/2464) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate weird taxon product filters [#2408](https://github.com/solidusio/solidus/pull/2408) ([cbrunsdon](https://github.com/cbrunsdon))

## Frontend
- Replace frontend jquery validations with html5 [#2264](https://github.com/solidusio/solidus/pull/2264) ([cbrunsdon](https://github.com/cbrunsdon), [jhawthorn](https://github.com/jhawthorn))

  We've removed jquery validations on checkout address form, replacing them with
  html5 input validations. If your store relies on jquery validation you should
  re-add that library in your store. Otherwise, if you use the old view version
  (without `required: true` attributes on input) your address form will not be
  validated on client side.

- Remove render_404 from frontend [#2329](https://github.com/solidusio/solidus/pull/2329) ([jhawthorn](https://github.com/jhawthorn))
- Add frontend login_bar_items placeholder partial [#2308](https://github.com/solidusio/solidus/pull/2308) ([jhawthorn](https://github.com/jhawthorn))
- Use product image template in frontend [#2300](https://github.com/solidusio/solidus/pull/2300) ([swcraig](https://github.com/swcraig))
- Remove required attribute from address lastname [#2393](https://github.com/solidusio/solidus/pull/2393) ([kennyadsl](https://github.com/kennyadsl))
- Convert frontend's CoffeeScript to javascript [#2378](https://github.com/solidusio/solidus/pull/2378) ([jhawthorn](https://github.com/jhawthorn))
- Convert Cart total/subtotal CSS colors to vars [#2288](https://github.com/solidusio/solidus/pull/2288) ([gregdaynes](https://github.com/gregdaynes))
- Fixed caching of taxon menu. [#2317](https://github.com/solidusio/solidus/pull/2317) ([bofrede](https://github.com/bofrede))
- Use empty? instead of length == 0 [#2282](https://github.com/solidusio/solidus/pull/2282) ([brchristian](https://github.com/brchristian))
- Use `line_item_adjustments` in `spree/shared/_order_details` [#2257](https://github.com/solidusio/solidus/pull/2257) ([cbrunsdon](https://github.com/cbrunsdon))
- Filter unpriced products in taxon_preview [#2604](https://github.com/solidusio/solidus/pull/2604) ([jhawthorn](https://github.com/jhawthorn))
- Fix error when listing products without price [#2605](https://github.com/solidusio/solidus/pull/2605) ([jhawthorn](https://github.com/jhawthorn))

## Documentation
- Change instances of "udpate" to "update" [#2533](https://github.com/solidusio/solidus/pull/2533) ([dsojevic](https://github.com/dsojevic))
- Add default to address_requires_state [#2532](https://github.com/solidusio/solidus/pull/2532) ([brchristian](https://github.com/brchristian))
- Standardize documentation [#2531](https://github.com/solidusio/solidus/pull/2531) ([brchristian](https://github.com/brchristian))
- Shipments documentation [#2353](https://github.com/solidusio/solidus/pull/2353) ([benjaminwil](https://github.com/benjaminwil))
- Add initial RMA and return authorization documentation [#2540](https://github.com/solidusio/solidus/pull/2540) ([benjaminwil](https://github.com/benjaminwil))
- Update README.md summary about testing [#2442](https://github.com/solidusio/solidus/pull/2442) ([benjaminwil](https://github.com/benjaminwil))
- Improve master variant documentation [#2521](https://github.com/solidusio/solidus/pull/2521) ([benjaminwil](https://github.com/benjaminwil))
- Products and variants documentation [#2437](https://github.com/solidusio/solidus/pull/2437) ([benjaminwil](https://github.com/benjaminwil))
- Getting started documentation [#2433](https://github.com/solidusio/solidus/pull/2433) ([benjaminwil](https://github.com/benjaminwil))
- Assets documentation [#2418](https://github.com/solidusio/solidus/pull/2418) ([benjaminwil](https://github.com/benjaminwil))
- Taxation documentation [#2403](https://github.com/solidusio/solidus/pull/2403) ([benjaminwil](https://github.com/benjaminwil))
- Locations documentation [#2375](https://github.com/solidusio/solidus/pull/2375) ([benjaminwil](https://github.com/benjaminwil))
- Tweaks to override-solidus-assets.md [#2482](https://github.com/solidusio/solidus/pull/2482) ([jhawthorn](https://github.com/jhawthorn))
- Simplify instructions in README.md for testing all projects [#2444](https://github.com/solidusio/solidus/pull/2444) ([jhawthorn](https://github.com/jhawthorn))
- Add a reference to solidus_cmd in README [#2349](https://github.com/solidusio/solidus/pull/2349) ([afdev82](https://github.com/afdev82))

## API
- Remove duplication in API variants controller [#2301](https://github.com/solidusio/solidus/pull/2301) ([swcraig](https://github.com/swcraig))
- Remove versioncake [#2307](https://github.com/solidusio/solidus/pull/2307) ([jhawthorn](https://github.com/jhawthorn))
- Reference full Spree::StockLocation class name in stock_items_controller.rb [#2543](https://github.com/solidusio/solidus/pull/2543) ([VitaliyAdamkov](https://github.com/VitaliyAdamkov))
- Deprecate JSTree api routes [#2254](https://github.com/solidusio/solidus/pull/2254) ([kennyadsl](https://github.com/kennyadsl))
- Avoid JSON serializing Float::INFINITY  [#2495](https://github.com/solidusio/solidus/pull/2495) ([jhawthorn](https://github.com/jhawthorn))
- Creating an order should activate promotions [#2565](https://github.com/solidusio/solidus/issues/2565) ([mathportillo](https://github.com/mathportillo))

## Admin
- Add store select to payment method admin [#2550](https://github.com/solidusio/solidus/pull/2550) ([adammathys](https://github.com/adammathys))
- Refactor and convert Tabs component from CoffeeScript to JS [#2549](https://github.com/solidusio/solidus/pull/2549) ([jhawthorn](https://github.com/jhawthorn))
- Better organize stock management JS and convert from coffeescript [#2548](https://github.com/solidusio/solidus/pull/2548) ([jhawthorn](https://github.com/jhawthorn))
- Simplify store_credit memo edit JS [#2547](https://github.com/solidusio/solidus/pull/2547) ([jhawthorn](https://github.com/jhawthorn))
- Convert trivial coffee to plain JS [#2546](https://github.com/solidusio/solidus/pull/2546) ([jhawthorn](https://github.com/jhawthorn))
- Use backbone StateSelect view for stock locations form [#2542](https://github.com/solidusio/solidus/pull/2542) ([jhawthorn](https://github.com/jhawthorn))
- Simplify and improve stock locations form [#1523](https://github.com/solidusio/solidus/pull/1523) ([jhawthorn](https://github.com/jhawthorn))
- Allow use of Turbolinks in admin [#1863](https://github.com/solidusio/solidus/pull/1863) ([tvdeyen](https://github.com/tvdeyen))
- Change order search to using starts over cont [#1660](https://github.com/solidusio/solidus/pull/1660) ([gmacdougall](https://github.com/gmacdougall))
- Exclude canceled orders from sales report [#2131](https://github.com/solidusio/solidus/pull/2131) ([brchristian](https://github.com/brchristian))
- Default backend navigation footer [#2261](https://github.com/solidusio/solidus/pull/2261) ([gregdaynes](https://github.com/gregdaynes))
- Provide a default `_navigation_footer.html.erb` [#1450](https://github.com/solidusio/solidus/pull/1450) ([jrochkind](https://github.com/jrochkind))
- Improve HTTP usage in update_positions [#2528](https://github.com/solidusio/solidus/pull/2528) ([jhawthorn](https://github.com/jhawthorn))
- Add form submit events to several backbone views [#2244](https://github.com/solidusio/solidus/pull/2244) ([tvdeyen](https://github.com/tvdeyen))
- Add required to product master price field [#2262](https://github.com/solidusio/solidus/pull/2262) ([gregdaynes](https://github.com/gregdaynes))
- Upgrade bootstrap to 4.0.0 [#2516](https://github.com/solidusio/solidus/pull/2516) [#2310](https://github.com/solidusio/solidus/pull/2310) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused admin helpers [#2515](https://github.com/solidusio/solidus/pull/2515) ([jhawthorn](https://github.com/jhawthorn))
- Remove jquery-ui datepicker [#2510](https://github.com/solidusio/solidus/pull/2510) ([jhawthorn](https://github.com/jhawthorn))
- Use datalist instead of jquery-ui/autocomplete [#2509](https://github.com/solidusio/solidus/pull/2509) ([jhawthorn](https://github.com/jhawthorn))
- Switch from jQuery UI datepicker to flatpickr [#2506](https://github.com/solidusio/solidus/pull/2506) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused extra data in products controller [#2505](https://github.com/solidusio/solidus/pull/2505) ([jhawthorn](https://github.com/jhawthorn))
- Allow selecting admin-only shipping methods [#2499](https://github.com/solidusio/solidus/pull/2499) ([jhawthorn](https://github.com/jhawthorn))
- Use nested checkboxes and radio buttons all over admin [#2429](https://github.com/solidusio/solidus/pull/2429) ([tvdeyen](https://github.com/tvdeyen))
- Restore field for editing promotion per_code_usage_limit in admin [#2497](https://github.com/solidusio/solidus/pull/2497) ([jordan-brough](https://github.com/jordan-brough))
- Replace new product inline form with normal form [#2493](https://github.com/solidusio/solidus/pull/2493) ([jhawthorn](https://github.com/jhawthorn))
- Fix `preference_field_tag` when given no type [#2278](https://github.com/solidusio/solidus/pull/2278) ([jhawthorn](https://github.com/jhawthorn))
- Generate `js_locale_data` using `JSON.dump` [#2304](https://github.com/solidusio/solidus/pull/2304) ([jhawthorn](https://github.com/jhawthorn))
- Improve API key on user edit page [#2243](https://github.com/solidusio/solidus/pull/2243) ([jhawthorn](https://github.com/jhawthorn))
- Fix closing thead tag on store credit table [#2274](https://github.com/solidusio/solidus/pull/2274) ([luukveenis](https://github.com/luukveenis))
- Create multiple page states for stock transfers [#2263](https://github.com/solidusio/solidus/pull/2263) ([jtapia](https://github.com/jtapia))
- Remove zombie tooltips with MutationObserver [#2421](https://github.com/solidusio/solidus/pull/2421) ([kennyadsl](https://github.com/kennyadsl))
- Simplify "inline" new image form [#2391](https://github.com/solidusio/solidus/pull/2391) ([jhawthorn](https://github.com/jhawthorn))
- Remove state.coffee [#2392](https://github.com/solidusio/solidus/pull/2392) ([jhawthorn](https://github.com/jhawthorn))
- Remove jQuery UI [#2527](https://github.com/solidusio/solidus/pull/2527) ([jhawthorn](https://github.com/jhawthorn))
- Replace jQuery ui's sortable with Sortable.js [#2523](https://github.com/solidusio/solidus/pull/2523) ([jhawthorn](https://github.com/jhawthorn))
- Promotions admin UI fixes [#2400](https://github.com/solidusio/solidus/pull/2400) ([tvdeyen](https://github.com/tvdeyen))
- Do not render complex preference types as form fields [#2394](https://github.com/solidusio/solidus/pull/2394) ([tvdeyen](https://github.com/tvdeyen))
- Re-enable bootstrap tooltips animations [#2334](https://github.com/solidusio/solidus/pull/2334) ([kennyadsl](https://github.com/kennyadsl))
- Store credit admin UI fixes [#2426](https://github.com/solidusio/solidus/pull/2426) ([tvdeyen](https://github.com/tvdeyen))
- Remove bourbon from admin [#2491](https://github.com/solidusio/solidus/pull/2491) ([jhawthorn](https://github.com/jhawthorn))
- Admin order shipments ui cleaning [#2414](https://github.com/solidusio/solidus/pull/2414) ([tvdeyen](https://github.com/tvdeyen))
- Admin line item ui fixes [#2413](https://github.com/solidusio/solidus/pull/2413) ([tvdeyen](https://github.com/tvdeyen))
- Fix select2 above styles [#2412](https://github.com/solidusio/solidus/pull/2412) ([tvdeyen](https://github.com/tvdeyen))
- Admin order payments ui cleanup [#2411](https://github.com/solidusio/solidus/pull/2411) ([tvdeyen](https://github.com/tvdeyen))
- Add data-action classes to admin orders cart templates [#2384](https://github.com/solidusio/solidus/pull/2384) ([kennyadsl](https://github.com/kennyadsl))
- Admin address fixes and extra address validation [#2371](https://github.com/solidusio/solidus/pull/2371) ([jordan-brough](https://github.com/jordan-brough))
- Explicitly define backend/promotions routes [#2332](https://github.com/solidusio/solidus/pull/2332) ([vladstoick](https://github.com/vladstoick))
- Remove bottom border of non-form fieldsets [#2425](https://github.com/solidusio/solidus/pull/2425) ([tvdeyen](https://github.com/tvdeyen))
- Move editing of shipment method and tracking into JS views and templates [#2225](https://github.com/solidusio/solidus/pull/2225) ([jhawthorn](https://github.com/jhawthorn))
- Center "no objects found" messages [#2424](https://github.com/solidusio/solidus/pull/2424) ([tvdeyen](https://github.com/tvdeyen))
- Improve look of missing I18n strings [#2333](https://github.com/solidusio/solidus/pull/2333) ([kennyadsl](https://github.com/kennyadsl))
- Give line-item-select-variant a max-width [#2492](https://github.com/solidusio/solidus/pull/2492) ([jhawthorn](https://github.com/jhawthorn))
- Fix action classes on admin tables [#2336](https://github.com/solidusio/solidus/pull/2336) ([kennyadsl](https://github.com/kennyadsl))
- Remove useless before-highlight class from table lines [#2335](https://github.com/solidusio/solidus/pull/2335) ([kennyadsl](https://github.com/kennyadsl))
- Remove unused methods in stock_transfers_controller [#2294](https://github.com/solidusio/solidus/pull/2294) ([ccarruitero](https://github.com/ccarruitero))
- Fix issue loading select2 locale for es-MX [#2356](https://github.com/solidusio/solidus/pull/2356) [#2365](https://github.com/solidusio/solidus/pull/2365) ([jtapia](https://github.com/jtapia) [dportalesr](https://github.com/dportalesr))
- Remove delimiter on number with currency field [#2428](https://github.com/solidusio/solidus/pull/2428) ([lgiacalone3](https://github.com/lgiacalone3))
- Allow ShipmentsController#remove on ready shipment [#2385](https://github.com/solidusio/solidus/pull/2385) ([alepore](https://github.com/alepore))
- Use single quotes to workaround deface issue [#2361](https://github.com/solidusio/solidus/pull/2361) ([afdev82](https://github.com/afdev82))
- Display country correctly when editing price [#2266](https://github.com/solidusio/solidus/pull/2266) ([jhawthorn](https://github.com/jhawthorn))

## Solidus 2.4.0 (2017-11-07)

### Major changes

- Replace RABL with Jbuilder [#2147](https://github.com/solidusio/solidus/pull/2147) [#2146](https://github.com/solidusio/solidus/pull/2146) ([jhawthorn](https://github.com/jhawthorn))

  We've changed our JSON templating language for both the API and admin from
  [RABL](https://github.com/nesquena/rabl) to [Jbuilder](https://github.com/rails/jbuilder).
  Jbuilder is faster and much more widely used (ships with Rails).

  API responses should be identical, but stores which customized API responses
  using RABL or added their own endpoints which extended Solidus' RABL partials
  will need to be updated.

- Remove rescue\_from StandardError in Api::BaseController [#2139](https://github.com/solidusio/solidus/pull/2139) ([jhawthorn](https://github.com/jhawthorn))

  Previously, exceptions raised in the API were caught (via `rescue_from`) and
  didn't reach the default Rails error handler. This caused many exceptions to
  avoid notice, both in production and in tests.

  This has been removed and exceptions are now reported and handled normally.

- New admin table design [#2159](https://github.com/solidusio/solidus/pull/2159) [#2100](https://github.com/solidusio/solidus/pull/2100) [#2143](https://github.com/solidusio/solidus/pull/2143) [#2123](https://github.com/solidusio/solidus/pull/2123) [#2165](https://github.com/solidusio/solidus/pull/2165) ([Mandily](https://github.com/Mandily), [graygilmore](https://github.com/graygilmore), [tvdeyen](https://github.com/tvdeyen))

  Tables throughout the admin have been redesigned to be simpler and clearer.
  Borders between cells of the same row have been dropped, row striping has been
  removed, and icons are simpler and more clearly attached to their row.

- Introduce Stock::SimpleCoordinator [#2199](https://github.com/solidusio/solidus/pull/2199) ([jhawthorn](https://github.com/jhawthorn))

  The previous stock coordinator had incorrect behaviour when any stock location was low on stock.

  The existing stock coordinator classes, Coordinator, Adjuster, Packer, and
  Prioritizer, have been replaced with the new Stock::SimpleCoordinator. In most
  cases this will coordinate stock identically to the old system, but will
  succeed for several low-stock cases the old Coordinator incorrectly failed on.

  Stores which have customized any of the old Coordinator classes will need to
  either update their customizations or include the [solidus_legacy_stock_system](https://github.com/solidusio-contrib/solidus_legacy_stock_system)
  extension, which provides the old classes.


### Core

- Replace Stock::Coordinator with Stock::SimpleCoordinator [#2199](https://github.com/solidusio/solidus/pull/2199) ([jhawthorn](https://github.com/jhawthorn))
- Wrap Splitter chaining behaviour in new Stock::SplitterChain class [#2189](https://github.com/solidusio/solidus/pull/2189) ([jhawthorn](https://github.com/jhawthorn))
- Remove Postal Code Format Validation (and Twitter CLDR dependency) [#2233](https://github.com/solidusio/solidus/pull/2233) ([mamhoff](https://github.com/mamhoff))
- Switch factories to strings instead of constants [#2230](https://github.com/solidusio/solidus/pull/2230) ([cbrunsdon](https://github.com/cbrunsdon))
- Roll up migrations up to Solidus 1.4 into a single migration [#2229](https://github.com/solidusio/solidus/pull/2229) ([cbrunsdon](https://github.com/cbrunsdon))
- Support non-promotion line-level adjustments [#2188](https://github.com/solidusio/solidus/pull/2188) ([jordan-brough](https://github.com/jordan-brough))
- Fix StoreCredit with multiple currencies [#2183](https://github.com/solidusio/solidus/pull/2183) ([jordan-brough](https://github.com/jordan-brough))
- Add `Spree::Price` to `ProductManagement` role [#2182](https://github.com/solidusio/solidus/pull/2182) ([swcraig](https://github.com/swcraig))
- Remove duplicate error on StoreCredit#authorize failure [#2180](https://github.com/solidusio/solidus/pull/2180) ([jordan-brough](https://github.com/jordan-brough))
- Add `dependent: :destroy` for ShippingMethodZones join model [#2175](https://github.com/solidusio/solidus/pull/2175) ([jordan-brough](https://github.com/jordan-brough))
- Fix method missing error in ReturnAuthorization#amount [#2162](https://github.com/solidusio/solidus/pull/2162) ([luukveenis](https://github.com/luukveenis))
- Use constants instead of translations for `StoreCreditType` names [#2157](https://github.com/solidusio/solidus/pull/2157) ([swcraig](https://github.com/swcraig))
- Enable custom shipping promotions via config.spree.promotions.shipping_actions [#2135](https://github.com/solidusio/solidus/pull/2135) ([jordan-brough](https://github.com/jordan-brough))
- Validate that Refunds have an associated Payment [#2130](https://github.com/solidusio/solidus/pull/2130) ([melissacarbone](https://github.com/melissacarbone))
- Include completed payment amounts when summing totals for store credit [#2129](https://github.com/solidusio/solidus/pull/2129) ([luukveenis](https://github.com/luukveenis))
- Allow dev mode code reloading of configured classes [#2126](https://github.com/solidusio/solidus/pull/2126) ([jhawthorn](https://github.com/jhawthorn))
- Override model_name.human for PaymentMethod [#2107](https://github.com/solidusio/solidus/pull/2107) ([jhawthorn](https://github.com/jhawthorn))
- Fix class/module nesting [#2098](https://github.com/solidusio/solidus/pull/2098) ([cbrunsdon](https://github.com/cbrunsdon))
- Reduce number of SQL statements in countries seeds [#2097](https://github.com/solidusio/solidus/pull/2097) ([jhawthorn](https://github.com/jhawthorn))
- Rename Order#update! to order.recalculate [#2072](https://github.com/solidusio/solidus/pull/2072) ([jhawthorn](https://github.com/jhawthorn))
- Rename Adjustment#update! to Adjustment#recalculate [#2086](https://github.com/solidusio/solidus/pull/2086) ([jhawthorn](https://github.com/jhawthorn))
- Rename Shipment#update! to Shipment#update_state [#2085](https://github.com/solidusio/solidus/pull/2085) ([jhawthorn](https://github.com/jhawthorn))
- Fix shipping method factory for stores with alternate currency [#2084](https://github.com/solidusio/solidus/pull/2084) ([Sinetheta](https://github.com/Sinetheta))

- Added a configurable `Spree::Payment::Cancellation` class [\#2111](https://github.com/solidusio/solidus/pull/2111) ([tvdeyen](https://github.com/tvdeyen))

- Remove `set_current_order` calls in `Spree::Core::ControllerHelpers::Order`
  [\#2185](https://github.com/solidusio/solidus/pull/2185) ([Murph33](https://github.com/murph33))

  Previously a before filter added in
  `core/lib/spree/core/controller_helpers/order.rb` would cause SQL queries to
  be used on almost every request in the frontend. If you do not use Solidus
  Auth you will need to hook into this helper and call `set_current_order` where
  your user signs in. This merges incomplete orders a user has going with their
  current cart. If you do use Solidus Auth you will need to make sure you use a
  current enough version (>= v1.5.0) that includes this explicit call. This
  addresses [\#1116](https://github.com/solidusio/solidus/issues/1116).

- Remove `ffaker` as a runtime dependency in production. It needs to be added to the Gemfile for factories to be used in tests [#2163](https://github.com/solidusio/solidus/pull/2163) [\#2140](https://github.com/solidusio/solidus/pull/2140) ([cbrunsdon](https://github.com/cbrunsdon), [swcraig](https://github.com/swcraig))

- Invalidate existing non store credit payments during checkout [2075](https://github.com/solidusio/solidus/pull/2075) ([tvdeyen](https://github.com/tvdeyen))

- The all configuration objects now use static preferences by default. It's no longer necessary to call `use_static_preferences!`, as that is the new default. For the old behaviour of loading preferences from the DB, call `config.use_legacy_db_preferences!`. [\#2112](https://github.com/solidusio/solidus/pull/2112) ([jhawthorn](https://github.com/jhawthorn))

- Assign and initialize Spree::Config earlier, before rails initializers [\#2178](https://github.com/solidusio/solidus/pull/2178) ([cbrunsdon](https://github.com/cbrunsdon))

### API
- Replace RABL with Jbuilder [#2147](https://github.com/solidusio/solidus/pull/2147) [#2146](https://github.com/solidusio/solidus/pull/2146) ([jhawthorn](https://github.com/jhawthorn))
- Move API pagination into a common partial [#2181](https://github.com/solidusio/solidus/pull/2181) ([jhawthorn](https://github.com/jhawthorn))
- Fix references to nonexistent API attributes [#2153](https://github.com/solidusio/solidus/pull/2153) ([jhawthorn](https://github.com/jhawthorn))
- Remove rescue_from StandardError in Api::BaseController [#2139](https://github.com/solidusio/solidus/pull/2139) ([jhawthorn](https://github.com/jhawthorn))
- Fix error when passing coupon_code to api/checkouts#update [#2136](https://github.com/solidusio/solidus/pull/2136) ([jhawthorn](https://github.com/jhawthorn))
- Improved error handling and performance for moving inventory units between shipments and stock locations [\#2070](https://github.com/solidusio/solidus/pull/2070) ([mamhoff](https://github.com/mamhoff))
- Remove unnecessary Api::Engine.root override [#2128](https://github.com/solidusio/solidus/pull/2128) ([jhawthorn](https://github.com/jhawthorn))

### Admin
- Upgrade to Bootstrap 4.0.0-beta [#2156](https://github.com/solidusio/solidus/pull/2156) ([jhawthorn](https://github.com/jhawthorn))
- Admin Sass Organization [#2133](https://github.com/solidusio/solidus/pull/2133) ([graygilmore](https://github.com/graygilmore))
- Remove Skeleton Grid CSS from the admin and complete its transition to Bootstrap. [\#2127](https://github.com/solidusio/solidus/pull/2127) ([graygilmore](https://github.com/graygilmore))
- Fix issue with user_id not being set on "customer" page [#2176](https://github.com/solidusio/solidus/pull/2176) ([ericsaupe](https://github.com/ericsaupe), [swcraig](https://github.com/swcraig))
- Removed the admin functionality to modify countries and states [\#2118](https://github.com/solidusio/solidus/pull/2118) ([graygilmore](https://github.com/graygilmore)). This functionality, if required, is available through the [solidus_countries_backend](https://github.com/solidusio-contrib/solidus_countries_backend) extension.
- Change table action icons style [#2100](https://github.com/solidusio/solidus/pull/2100) ([tvdeyen](https://github.com/tvdeyen))
- Use number_with_currency widget on new refund page [#2088](https://github.com/solidusio/solidus/pull/2088) ([jhawthorn](https://github.com/jhawthorn))
- Fix admin user order history table [#2226](https://github.com/solidusio/solidus/pull/2226) ([Sinetheta](https://github.com/Sinetheta))
- Replace Admin table styles [#2159](https://github.com/solidusio/solidus/pull/2159) ([Mandily](https://github.com/Mandily), [graygilmore](https://github.com/graygilmore), [tvdeyen](https://github.com/tvdeyen), [jhawthorn](https://github.com/jhawthorn))
- Inherit body colour for labels [#2242](https://github.com/solidusio/solidus/pull/2242) ([jhawthorn](https://github.com/jhawthorn))
- Remove action button background color [#2144](https://github.com/solidusio/solidus/pull/2144) ([tvdeyen](https://github.com/tvdeyen))
- Remove images border in tables [#2143](https://github.com/solidusio/solidus/pull/2143) ([tvdeyen](https://github.com/tvdeyen))
- Pill Component [#2123](https://github.com/solidusio/solidus/pull/2123) ([graygilmore](https://github.com/graygilmore))
- Display a pointer cursor hovering add variant buttons [#2062](https://github.com/solidusio/solidus/pull/2062) ([kennyadsl](https://github.com/kennyadsl))
- Use translated model names in admin payment methods form [#1975](https://github.com/solidusio/solidus/pull/1975) ([tvdeyen](https://github.com/tvdeyen))
- Add missing default_currency field on admin/stores [#2091](https://github.com/solidusio/solidus/pull/2091) ([oeN](https://github.com/oeN))
- UI Fixes for taxons tree [#2148](https://github.com/solidusio/solidus/pull/2148) ([tvdeyen](https://github.com/tvdeyen))
- Make checkout billing address inputs full width [#2171](https://github.com/solidusio/solidus/pull/2171) ([notapatch](https://github.com/notapatch))
- Fixes padding of lists in form fields [#2170](https://github.com/solidusio/solidus/pull/2170) ([tvdeyen](https://github.com/tvdeyen))
- Capitalize event buttons in `OrdersHelper` [#2177](https://github.com/solidusio/solidus/pull/2177) ([swcraig](https://github.com/swcraig))
- Fix backend data-action across multiple files [#2184](https://github.com/solidusio/solidus/pull/2184) ([kennyadsl](https://github.com/kennyadsl))
- New users table layout [#1842](https://github.com/solidusio/solidus/pull/1842) ([tvdeyen](https://github.com/tvdeyen))
- Add headers to shipment method and tracking number [#2169](https://github.com/solidusio/solidus/pull/2169) ([tvdeyen](https://github.com/tvdeyen))
- Fix typo on shipment method edit [#2168](https://github.com/solidusio/solidus/pull/2168) ([jhawthorn](https://github.com/jhawthorn))
- Fix action button hover style [#2167](https://github.com/solidusio/solidus/pull/2167) ([tvdeyen](https://github.com/tvdeyen))
- Show table borders on action columns [#2165](https://github.com/solidusio/solidus/pull/2165) ([jhawthorn](https://github.com/jhawthorn))
- Tweak font styles on admin shipments page [#2164](https://github.com/solidusio/solidus/pull/2164) ([jhawthorn](https://github.com/jhawthorn))
- Use payment.number instead of payment.identifier in admin view [#2222](https://github.com/solidusio/solidus/pull/2222) ([jordan-brough](https://github.com/jordan-brough))
- Exclude Bootstrap buttons from our button styling [#2158](https://github.com/solidusio/solidus/pull/2158) ([graygilmore](https://github.com/graygilmore))
- Move users search form above table [#2094](https://github.com/solidusio/solidus/pull/2094) ([graygilmore](https://github.com/graygilmore))
- Preview Images in a Modal [#2101](https://github.com/solidusio/solidus/pull/2101) ([graygilmore](https://github.com/graygilmore))

### Frontend
- Change product's price color away from link color [#2174](https://github.com/solidusio/solidus/pull/2174) ([notapatch](https://github.com/notapatch))
- Move OrdersHelper from Core to Frontend [#2081](https://github.com/solidusio/solidus/pull/2081) ([dangerdogz](https://github.com/dangerdogz))
- Checkout email input field should use email_field [#2120](https://github.com/solidusio/solidus/pull/2120) ([notapatch](https://github.com/notapatch))

### Removals
- Remove unused Paperclip spec matchers [#2197](https://github.com/solidusio/solidus/pull/2197) ([swcraig](https://github.com/swcraig))
- Remove tax refunds [#2196](https://github.com/solidusio/solidus/pull/2196) ([mamhoff](https://github.com/mamhoff))
- Remove PriceMigrator [#2194](https://github.com/solidusio/solidus/pull/2194) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove task to copy shipped shipments to cartons [#2193](https://github.com/solidusio/solidus/pull/2193) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove upgrade task/spec [#2192](https://github.com/solidusio/solidus/pull/2192) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove unhelpful preload in Stock::Estimator [#2207](https://github.com/solidusio/solidus/pull/2207) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused register call in calculator [#2206](https://github.com/solidusio/solidus/pull/2206) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove autoload on product_filters [#2190](https://github.com/solidusio/solidus/pull/2190) ([cbrunsdon](https://github.com/cbrunsdon))
- Remove identical inheritied methods in `Spree::StoreCredit` [#2200](https://github.com/solidusio/solidus/pull/2200) ([swcraig](https://github.com/swcraig))
- Remove custom responders. They are now available in the `solidus_responders` extension. [#1956](https://github.com/solidusio/solidus/pull/1956) ([omnistegan](https://github.com/omnistegan))
- Remove responders dependency from core [#2090](https://github.com/solidusio/solidus/pull/2090) ([cbrunsdon](https://github.com/cbrunsdon))

### Deprecations

- Deprecate .calculators [#2216](https://github.com/solidusio/solidus/pull/2216) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate pagination in searcher [#2119](https://github.com/solidusio/solidus/pull/2119) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate tasks in core/lib/tasks [#2080](https://github.com/solidusio/solidus/pull/2080) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate Spree::OrderCapturing class [#2076](https://github.com/solidusio/solidus/pull/2076) ([tvdeyen](https://github.com/tvdeyen))
- Deprecated `Spree::PaymentMethod#cancel` [\#2111](https://github.com/solidusio/solidus/pull/2111) ([tvdeyen](https://github.com/tvdeyen))
  Please implement a `try_void` method on your payment method instead that returns a response object if void succeeds or false if not. Solidus will refund the payment then.
- Deprecates several preference fields helpers in favor of preference field partials. [\#2040](https://github.com/solidusio/solidus/pull/2040) ([tvdeyen](https://github.com/tvdeyen))
  Please render `spree/admin/shared/preference_fields/#{preference_type}` instead
- Check if deprecated method_type is overridden [#2093](https://github.com/solidusio/solidus/pull/2093) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate support for alternate Kaminari page_method_name [#2115](https://github.com/solidusio/solidus/pull/2115) ([cbrunsdon](https://github.com/cbrunsdon))
- Deprecate update_params_payment_source method [#2227](https://github.com/solidusio/solidus/pull/2227) ([ccarruitero](https://github.com/ccarruitero))



## Solidus 2.3.0 (2017-07-31)

- Rails 5.1 [\#1895](https://github.com/solidusio/solidus/pull/1895) ([jhawthorn](https://github.com/jhawthorn))

- The default behaviour for selecting the current store has changed. Stores are now only returned if their url matches the current domain exactly (falling back to the default store) [\#2041](https://github.com/solidusio/solidus/pull/2041) [\#1993](https://github.com/solidusio/solidus/pull/1993) ([jhawthorn](https://github.com/jhawthorn), [kennyadsl](https://github.com/kennyadsl))

- Remove dependency on premailer gem [\#2061](https://github.com/solidusio/solidus/pull/2061) ([cbrunsdon](https://github.com/cbrunsdon))

- Order#outstanding_balance now uses reimbursements instead of refunds to calculate the amount that should be paid on an order. [#2002](https://github.com/solidusio/solidus/pull/2002) (many contributors :heart:)

- Renamed bogus payment methods [\#2000](https://github.com/solidusio/solidus/pull/2000) ([tvdeyen](https://github.com/tvdeyen))
  `Spree::Gateway::BogusSimple` and `Spree::Gateway::Bogus` were renamed into `Spree::PaymentMethod::SimpleBogusCreditCard` and `Spree::PaymentMethod::BogusCreditCard`

- Allow refreshing shipping rates for unshipped shipments on completed orders [\#1906](https://github.com/solidusio/solidus/pull/1906) ([mamhoff](https://github.com/mamhoff))
- Remove line_item_options class attribute from Api::LineItemsController [\#1943](https://github.com/solidusio/solidus/pull/1943)
- Allow custom separator between a promotion's `base_code` and `suffix` [\#1951](https://github.com/solidusio/solidus/pull/1951) ([ericgross](https://github.com/ericgross))
- Ignore `adjustment.finalized` on tax adjustments. [\#1936](https://github.com/solidusio/solidus/pull/1936) ([jordan-brough](https://github.com/jordan-brough))
- Transform the relation between TaxRate and TaxCategory to a Many to Many [\#1851](https://github.com/solidusio/solidus/pull/1851) ([vladstoick](https://github.com/vladstoick))

  This fixes issue [\#1836](https://github.com/solidusio/solidus/issues/1836). By allowing a TaxRate to tax multiple categories, stores don't have to create multiple TaxRates with the same value if a zone doesn't have different tax rates for some tax categories.

- Adjustments without a source are now included in `line_item.adjustment_total` [\#1933](https://github.com/solidusio/solidus/pull/1933) ([alexstoick](https://github.com/alexstoick))
- Always update last\_ip\_address on order [\#1658](https://github.com/solidusio/solidus/pull/1658) ([bbuchalter](https://github.com/bbuchalter))
- Don't eager load adjustments in current\_order [\#2069](https://github.com/solidusio/solidus/pull/2069) ([jhawthorn](https://github.com/jhawthorn))
- Avoid running validations in current\_order [\#2068](https://github.com/solidusio/solidus/pull/2068) ([jhawthorn](https://github.com/jhawthorn))
- Fix Paperclip::Errors::NotIdentifiedByImageMagickError on invalid image [\#2064](https://github.com/solidusio/solidus/pull/2064) ([karlentwistle](https://github.com/karlentwistle))
- Fix error message on insufficient inventory. [\#2056](https://github.com/solidusio/solidus/pull/2056) ([husam212](https://github.com/husam212))
- Remove print statements from migrations [\#2048](https://github.com/solidusio/solidus/pull/2048) ([jhawthorn](https://github.com/jhawthorn))
- Make Address.find\_all\_by\_name\_or\_abbr case-insensitive [\#2043](https://github.com/solidusio/solidus/pull/2043) ([jordan-brough](https://github.com/jordan-brough))
- Remove redundant methods on Spree::PaymentMethod::StoreCredit [\#2038](https://github.com/solidusio/solidus/pull/2038) ([skukx](https://github.com/skukx))
- Fix ShippingMethod select for MySQL 5.7 strict [\#2024](https://github.com/solidusio/solidus/pull/2024) ([jhawthorn](https://github.com/jhawthorn))
- Use a subquery to avoid returning duplicate products from Product.available [\#2021](https://github.com/solidusio/solidus/pull/2021) ([jhawthorn](https://github.com/jhawthorn))
- Validate presence of product on a Variant [\#2020](https://github.com/solidusio/solidus/pull/2020) ([jhawthorn](https://github.com/jhawthorn))
- Add some missing data to seeds which was added by migrations [\#1962](https://github.com/solidusio/solidus/pull/1962) ([BravoSimone](https://github.com/BravoSimone))
- Add validity period for Spree::TaxRate [\#1953](https://github.com/solidusio/solidus/pull/1953) ([mtylty](https://github.com/mtylty))
- Remove unnecessary shipping rates callback [\#1905](https://github.com/solidusio/solidus/pull/1905) ([mamhoff](https://github.com/mamhoff))
- Remove fallback first shipping method on shipments [\#1843](https://github.com/solidusio/solidus/pull/1843) ([mamhoff](https://github.com/mamhoff))
- Add a configurable order number generator [\#1820](https://github.com/solidusio/solidus/pull/1820) ([tvdeyen](https://github.com/tvdeyen))
- Assign default user addresses in checkout controller [\#1967](https://github.com/solidusio/solidus/pull/1967) ([kennyadsl](https://github.com/kennyadsl))
- Use user.default_address as a default if bill_address or ship_address is unset [\#1424](https://github.com/solidusio/solidus/pull/1424) ([yeonhoyoon](https://github.com/yeonhoyoon), [peterberkenbosch](https://github.com/peterberkenbosch))
- Add html templates for shipped_email and inventory_cancellation emails [\#1377](https://github.com/solidusio/solidus/pull/1377) ([DanielePalombo](https://github.com/DanielePalombo))
- Don't `@extend` compound selectors in sass. Avoids deprecation warnings in sass 3.4.25 [\#2073](https://github.com/solidusio/solidus/pull/2073) ([jhawthorn](https://github.com/jhawthorn))

### Admin

- Configure admin turbolinks [\#1882](https://github.com/solidusio/solidus/pull/1882) ([mtomov](https://github.com/mtomov))
- Allow users to inline update the variant of an image in admin [\#1580](https://github.com/solidusio/solidus/pull/1580) ([mtomov](https://github.com/mtomov))
- Fix typo on fieldset tags [\#2005](https://github.com/solidusio/solidus/pull/2005) ([oeN](https://github.com/oeN))
- Use more specific selector for select2 [\#1997](https://github.com/solidusio/solidus/pull/1997) ([oeN](https://github.com/oeN))
- Replace select2 with \<select class="custom-select"\> [\#2034](https://github.com/solidusio/solidus/pull/2034) [\#2030](https://github.com/solidusio/solidus/pull/2030) ([jhawthorn](https://github.com/jhawthorn))
- Fix admin SQL issues with DISTINCT products [\#2025](https://github.com/solidusio/solidus/pull/2025) ([jhawthorn](https://github.com/jhawthorn))
- Use `@collection` instead of `@collection.present?` in some admin controllers [\#2046](https://github.com/solidusio/solidus/pull/2046) ([jordan-brough](https://github.com/jordan-brough))
- Admin::ReportsController reusable search params [\#2012](https://github.com/solidusio/solidus/pull/2012) ([oeN](https://github.com/oeN))
- Do not show broken links in admin product view when product is deleted [\#1988](https://github.com/solidusio/solidus/pull/1988) ([laurawadden](https://github.com/laurawadden))
- Allow admin to edit variant option values [\#1944](https://github.com/solidusio/solidus/pull/1944) ([dividedharmony](https://github.com/dividedharmony))
- Do not refresh shipping rates everytime the order is viewed in the admin [\#1798](https://github.com/solidusio/solidus/pull/1798) ([mamhoff](https://github.com/mamhoff))
- Add form guidelines to the style guide [\#1582](https://github.com/solidusio/solidus/pull/1582) ([Mandily](https://github.com/Mandily))
- Improve style guide flash messages UX [\#1964](https://github.com/solidusio/solidus/pull/1964) ([mtylty](https://github.com/mtylty))
- Document tooltips in the style guide [\#1955](https://github.com/solidusio/solidus/pull/1955) ([gus4no](https://github.com/gus4no))
- Fix path for distributed amount fields partial [\#2023](https://github.com/solidusio/solidus/pull/2023) ([graygilmore](https://github.com/graygilmore))
- Use `.all` instead of `.where\(nil\)` in Admin::ResourceController [\#2047](https://github.com/solidusio/solidus/pull/2047) ([jordan-brough](https://github.com/jordan-brough))
- Fix typo on the new promotions form [\#2035](https://github.com/solidusio/solidus/pull/2035) ([swcraig](https://github.com/swcraig))
- Use translated model name in admin payment methods form [\#1975](https://github/com/solidusio/solidus/pull/1975) ([tvdeyen](https://github.com/tvdeyen))


### Deprecations
- Renamed `Spree::Gateway` payment method into `Spree::PaymentMethod::CreditCard` [\#2001](https://github.com/solidusio/solidus/pull/2001) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate `#simple_current_order` [\#1915](https://github.com/solidusio/solidus/pull/1915) ([ericsaupe](https://github.com/ericsaupe))
- Deprecate `PaymentMethod.providers` in favour of `Rails.application.config.spree.payment_methods` [\#1974](https://github.com/solidusio/solidus/pull/1974) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate `Spree::Admin::PaymentMethodsController#load_providers` in favour of `load_payment_methods` [\#1974](https://github.com/solidusio/solidus/pull/1974) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate Shipment\#add\_shipping\_method [\#2018](https://github.com/solidusio/solidus/pull/2018) ([jhawthorn](https://github.com/jhawthorn))
- Re-add deprecated TaxRate\#tax\_category [\#2013](https://github.com/solidusio/solidus/pull/2013) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `Spree::Core::CurrentStore` in favor of `Spree::CurrentStoreSelector`. [\#1993](https://github.com/solidusio/solidus/pull/1993)
- Deprecate `Spree::Order#assign_default_addresses!` in favor of `Order.new.assign_default_user_addresses`. [\#1954](https://github.com/solidusio/solidus/pull/1954) ([kennyadsl](https://github.com/kennyadsl))
- Rename `PaymentMethod#method_type` into `partial_name` [\#1978](https://github.com/solidusio/solidus/pull/1978) ([tvdeyen](https://github.com/tvdeyen))
- Remove ! from assign\_default\_user\_addresses!, deprecating the old method [\#2019](https://github.com/solidusio/solidus/pull/2019) ([jhawthorn](https://github.com/jhawthorn))
- Emit Spree.url JS deprecation warning in all environments [\#2017](https://github.com/solidusio/solidus/pull/2017) ([jhawthorn](https://github.com/jhawthorn))


## Solidus 2.2.1 (2017-05-09)

- Fix migrating CreditCards to WalletPaymentSource [\#1898](https://github.com/solidusio/solidus/pull/1898) ([jhawthorn](https://github.com/jhawthorn))
- Fix setting the wallet's default payment source to the same value [\#1888](https://github.com/solidusio/solidus/pull/1888) ([ahoernecke](https://github.com/ahoernecke))
- Fix assigning nil to `default_wallet_payment_source=` [\#1896](https://github.com/solidusio/solidus/pull/1896) ([jhawthorn](https://github.com/jhawthorn))

## Solidus 2.2.0 (2017-05-01)

### Major Changes

- Spree::Wallet and Non credit card payment sources [\#1707](https://github.com/solidusio/solidus/pull/1707) [\#1773](https://github.com/solidusio/solidus/pull/1773) [\#1765](https://github.com/solidusio/solidus/pull/1765) ([chrisradford](https://github.com/chrisradford), [jordan-brough](https://github.com/jordan-brough), [peterberkenbosch](https://github.com/peterberkenbosch))

  This adds support for payment sources other than `CreditCard`, which can be used to better represent other (potentially reusable) payment sources, like PayPal or Bank accounts. Previously sources like this had to implement all behaviour themselves, or try their best to quack like a credit card.

  This adds a `PaymentSource` base class, which `CreditCard` now inherits, and a `Wallet` service class to help manage users' payment sources. A `WalletPaymentSource` join table is used to tie reusable payment sources to users, replacing the existing behaviour of allowing all credit cards with a stored payment profile.

- Add promotion code batch [\#1524](https://github.com/solidusio/solidus/pull/1524) ([vladstoick](https://github.com/vladstoick))

  Prior to Solidus 1.0, each promotion had at most one code. Though we added the functionality to have many codes on one promotion, the UI for creation and management was lacking.

  In Solidus 2.2 we've added `PromotionCodeBatch`, a model to group a batch of promotion codes. This allows additional promotion codes to be generated after the Promotion's initial creation. Promotion codes are also now generated in a background job.

- Admin UI Changes

  The admin UI was once again a focus in this release. We've made many incremental changes we think all users will appreciate. This includes an upgrade to Bootstrap 4.0.0.alpha6, changes to table styles, and a better select style.

  See the "Admin UI" section below for a full list of changes.


### Core
- `Spree::Order#available_payment_methods` returns an `ActiveRecord::Relation` instead of an array [\#1802](https://github.com/solidusio/solidus/pull/1802) ([luukveenis](https://github.com/luukveenis))
- Product slugs no longer have a minimum length requirement [#1616](https://github.com/solidusio/solidus/pull/1616) ([fschwahn](https://github.com/fschwahn))
- `Spree::Money` now includes `Comparable` and the `<=>` operator for comparisons. [#1682](https://github.com/solidusio/solidus/pull/1682) ([graygilmore ](https://github.com/graygilmore))
- Allow destruction of shipments in the "ready" state. [#1784](https://github.com/solidusio/solidus/pull/1784) ([mamhoff](https://github.com/mamhoff))
- Do not consider pending inventory units cancelable [\#1800](https://github.com/solidusio/solidus/pull/1800) ([mamhoff](https://github.com/mamhoff))
- Rewrite spree.js in plain JS [\#1754](https://github.com/solidusio/solidus/pull/1754) ([jhawthorn](https://github.com/jhawthorn))
- Make sensitive params filtering less eager [\#1755](https://github.com/solidusio/solidus/pull/1755) ([kennyadsl](https://github.com/kennyadsl))
- Use manifest.js to support Sprockets 4 [\#1759](https://github.com/solidusio/solidus/pull/1759) ([jhawthorn](https://github.com/jhawthorn))
- Update paperclip dependency [\#1749](https://github.com/solidusio/solidus/pull/1749) ([brchristian](https://github.com/brchristian))
- Update kaminari dependency to 1.x [\#1734](https://github.com/solidusio/solidus/pull/1734) ([jrochkind](https://github.com/jrochkind))
- Allow twitter\_cldr 4.x [\#1732](https://github.com/solidusio/solidus/pull/1732) ([jrochkind](https://github.com/jrochkind))
- Added LineItem name to unavailable flash [\#1697](https://github.com/solidusio/solidus/pull/1697) ([ericsaupe](https://github.com/ericsaupe))
- Don't treat "unreturned exchanges" specially in checkout state machine flow [\#1690](https://github.com/solidusio/solidus/pull/1690) ([jhawthorn](https://github.com/jhawthorn))
- `set_shipments_cost` is now part of OrderUpdater [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))
- Methods other than `update!`, `update_shipment_state`, `update_payment_state` are now private on OrderUpdater [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))

### Bug Fixes

- `AvailabilityValidator` correctly detects out of stock with multiple shipments from the same stock location. [\#1693](https://github.com/solidusio/solidus/pull/1693) ([jhawthorn](https://github.com/jhawthorn))
- Fix missing close paren in variantAutocomplete [\#1832](https://github.com/solidusio/solidus/pull/1832) ([jhawthorn](https://github.com/jhawthorn))
- Set belongs\_to\_required\_by\_default = false [\#1807](https://github.com/solidusio/solidus/pull/1807) ([jhawthorn](https://github.com/jhawthorn))
- Fix loading transfer shipments [\#1781](https://github.com/solidusio/solidus/pull/1781) ([mamhoff](https://github.com/mamhoff))
- Fix complete order factory to have non-pending inventory units [\#1787](https://github.com/solidusio/solidus/pull/1787) ([mamhoff](https://github.com/mamhoff))
- Fix to cart URL for stores not mounted at root [\#1775](https://github.com/solidusio/solidus/pull/1775) ([funwhilelost](https://github.com/funwhilelost))
- Remove duplicated require in shipment factory [\#1769](https://github.com/solidusio/solidus/pull/1769) ([upinetree](https://github.com/upinetree))
- Fix an issue where updating a user in the admin without specifying roles in would clear the existing roles.[\#1747](https://github.com/solidusio/solidus/pull/1747) ([tvdeyen](https://github.com/tvdeyen))
- Fix the 'Send Mailer' checkbox selection [\#1716](https://github.com/solidusio/solidus/pull/1716) ([jhawthorn](https://github.com/jhawthorn))
- Rearrange AR relation declarations in order.rb in preparation for Rails 5.1 [\#1740](https://github.com/solidusio/solidus/pull/1740) ([jhawthorn](https://github.com/jhawthorn))
- Fix issue where OrderInventory creates superfluous InventoryUnits [\#1751](https://github.com/solidusio/solidus/pull/1751) ([jhawthorn](https://github.com/jhawthorn))
- Fix check for `order.guest\_token` presence [\#1705](https://github.com/solidusio/solidus/pull/1705) ([vfonic](https://github.com/vfonic))
- Fix shipped\_order factory [\#1772](https://github.com/solidusio/solidus/pull/1772) ([tvdeyen](https://github.com/tvdeyen))
- Don't display inactive payment methods on frontend or backend [\#1801](https://github.com/solidusio/solidus/pull/1801) ([luukveenis](https://github.com/luukveenis))
- Don't send email if PromotionCodeBatch email is unset [\#1699](https://github.com/solidusio/solidus/pull/1699) ([jhawthorn](https://github.com/jhawthorn))

### Frontend
- Use `cart_link_path` instead of `cart_link_url` [\#1757](https://github.com/solidusio/solidus/pull/1757) ([bofrede](https://github.com/bofrede))
- Replace cache\_key\_for\_taxons with cache [\#1688](https://github.com/solidusio/solidus/pull/1688) ([jhawthorn](https://github.com/jhawthorn))
- Update code styles for /cart [\#1727](https://github.com/solidusio/solidus/pull/1727) ([vfonic](https://github.com/vfonic))
- Add a frontend views override generator [\#1681](https://github.com/solidusio/solidus/pull/1681) ([tvdeyen](https://github.com/tvdeyen))

### Admin

- Create JS namespaces in centralized file [\#1753](https://github.com/solidusio/solidus/pull/1753) ([jhawthorn](https://github.com/jhawthorn))
- Replace select2-rails with vendored select2 [\#1774](https://github.com/solidusio/solidus/pull/1774) ([jhawthorn](https://github.com/jhawthorn))
- Add JS `Spree.formatMoney` helper for currency formatting [\#1745](https://github.com/solidusio/solidus/pull/1745) ([jhawthorn](https://github.com/jhawthorn))
- Rewrite zones.js.coffee using Backbone.js [\#1766](https://github.com/solidusio/solidus/pull/1766) ([jhawthorn](https://github.com/jhawthorn))
- Add JS `Spree.t` and `Spree.human_attribute_name` for i18n [\#1730](https://github.com/solidusio/solidus/pull/1730) ([jhawthorn](https://github.com/jhawthorn))
- Allow editing multiple Stores [\#1282](https://github.com/solidusio/solidus/pull/1282) ([jhawthorn](https://github.com/jhawthorn))
- Add promotion codes index view [\#1545](https://github.com/solidusio/solidus/pull/1545) ([jhawthorn](https://github.com/jhawthorn))
- Replace deprecated bourbon mixins with unprefixed CSS [\#1706](https://github.com/solidusio/solidus/pull/1706) ([jhawthorn](https://github.com/jhawthorn))
- Ensure helper is specified in CustomerReturnsController [\#1771](https://github.com/solidusio/solidus/pull/1771) ([eric1234](https://github.com/eric1234))
- Ensure helper is specified in VariantsController [\#1714](https://github.com/solidusio/solidus/pull/1714) ([eric1234](https://github.com/eric1234))
- Remove nonexistant form hint from view [\#1698](https://github.com/solidusio/solidus/pull/1698) ([jhawthorn](https://github.com/jhawthorn))
- Promotion search now finds orders which used the specific promotion code, of any code on the promotion. [#1662](https://github.com/solidusio/solidus/pull/1662) ([stewart](https://github.com/stewart))

### Admin UI

- Upgrade to Bootstrap 4.0.0.alpha6 [\#1816](https://github.com/solidusio/solidus/pull/1816) ([jhawthorn](https://github.com/jhawthorn))
- New admin table layout [\#1786](https://github.com/solidusio/solidus/pull/1786) [\#1828](https://github.com/solidusio/solidus/pull/1828) [\#1829](https://github.com/solidusio/solidus/pull/1829) ([tvdeyen](https://github.com/tvdeyen))
- Add number with currency selector widget [\#1793](https://github.com/solidusio/solidus/pull/1793) [\#1813](https://github.com/solidusio/solidus/pull/1813) ([jhawthorn](https://github.com/jhawthorn))
- Replace select2 styling [\#1797](https://github.com/solidusio/solidus/pull/1797) ([jhawthorn](https://github.com/jhawthorn))
- Change admin logo height to match breadcrumbs height [\#1822](https://github.com/solidusio/solidus/pull/1822) ([mtomov](https://github.com/mtomov))
- Fit admin logo to available space [\#1758](https://github.com/solidusio/solidus/pull/1758) ([brchristian](https://github.com/brchristian))
- Make form/button styles match bootstrap's [\#1809](https://github.com/solidusio/solidus/pull/1809) ([jhawthorn](https://github.com/jhawthorn))
- Fix datepicker style [\#1827](https://github.com/solidusio/solidus/pull/1827) ([kennyadsl](https://github.com/kennyadsl))
- Use bootstrap input-group for date range [\#1817](https://github.com/solidusio/solidus/pull/1817) ([jhawthorn](https://github.com/jhawthorn))
- Improve page titles in admin [\#1795](https://github.com/solidusio/solidus/pull/1795) ([jhawthorn](https://github.com/jhawthorn))
- Use an icon as missing image placeholder [\#1760](https://github.com/solidusio/solidus/pull/1760) ([jhawthorn](https://github.com/jhawthorn)) [\#1764](https://github.com/solidusio/solidus/pull/1764) ([jhawthorn](https://github.com/jhawthorn))
- Convert admin orders table into full width layout [\#1782](https://github.com/solidusio/solidus/pull/1782) ([tvdeyen](https://github.com/tvdeyen))
- Raise `font-size` [\#1777](https://github.com/solidusio/solidus/pull/1777) ([tvdeyen](https://github.com/tvdeyen))
- Improve promotions creation form [\#1509](https://github.com/solidusio/solidus/pull/1509) ([jhawthorn](https://github.com/jhawthorn))
- Remove stock location configuration from admin "cart" page [\#1709](https://github.com/solidusio/solidus/pull/1709) [\#1710](https://github.com/solidusio/solidus/pull/1710) ([jhawthorn](https://github.com/jhawthorn))
- Update admin cart page dynamically [\#1715](https://github.com/solidusio/solidus/pull/1715) ([jhawthorn](https://github.com/jhawthorn))
- Fix duplicated Shipments breadcrumb [\#1717](https://github.com/solidusio/solidus/pull/1717) [\#1746](https://github.com/solidusio/solidus/pull/1746) ([jhawthorn](https://github.com/jhawthorn))
- Don’t set default text highlight colors [\#1738](https://github.com/solidusio/solidus/pull/1738) ([brchristian](https://github.com/brchristian))
- Convert customer details page to backbone [\#1762](https://github.com/solidusio/solidus/pull/1762) ([jhawthorn](https://github.com/jhawthorn))
- Remove inline edit from payments dipslay amount [\#1815](https://github.com/solidusio/solidus/pull/1815) ([tvdeyen](https://github.com/tvdeyen))
- Fix styling of tiered promotions delete icon [\#1810](https://github.com/solidusio/solidus/pull/1810) ([jhawthorn](https://github.com/jhawthorn))
- Remove `webkit-tap-highlight-color` [\#1792](https://github.com/solidusio/solidus/pull/1792) ([brchristian](https://github.com/brchristian))
- Promotion and Shipping calculators can be created or changed without reloading the page. [#1618](https://github.com/solidusio/solidus/pull/1618) ([jhawthorn](https://github.com/jhawthorn))


### Removals

- Extract expedited exchanges to an extension [\#1691](https://github.com/solidusio/solidus/pull/1691) ([jhawthorn](https://github.com/jhawthorn))
- Remove spree\_store\_credits column [\#1741](https://github.com/solidusio/solidus/pull/1741) ([jhawthorn](https://github.com/jhawthorn))
- Remove StockMovements\#new action and view [\#1767](https://github.com/solidusio/solidus/pull/1767) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused variant\_management.js.coffee [\#1768](https://github.com/solidusio/solidus/pull/1768) ([jhawthorn](https://github.com/jhawthorn))
- Remove unused payment Javascript [\#1735](https://github.com/solidusio/solidus/pull/1735) ([jhawthorn](https://github.com/jhawthorn))
- Moved `spree/admin/shared/_translations` partial to `spree/admin/shared/_js_locale_data`.


### Deprecations

- Deprecate `Order#has_step?` in favour of `has_checkout_step?` [#1667](https://github.com/solidusio/solidus/pull/1667) ([mamhoff](https://github.com/mamhoff))
- Deprecate `Order#set_shipments_cost`, which is now done in `Order#update!` [\#1689](https://github.com/solidusio/solidus/pull/1689) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `user.default_credit_card`, `user.payment_sources` for `user.wallet.default_wallet_payment_source` and `user.wallet.wallet_payment_sources`
- Deprecate `CreditCard#default` in favour of `user.wallet.default_wallet_payment_source`
- Deprecate `cache_key_for_taxons` helper favour of `cache [I18n.locale, @taxons]`
- Deprecate admin sass variables in favour of bootstrap alternatives [\#1780](https://github.com/solidusio/solidus/pull/1780) ([tvdeyen](https://github.com/tvdeyen))
- Deprecate Address\#empty? [\#1686](https://github.com/solidusio/solidus/pull/1686) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `fill_in_quantity` capybara helper [#1710](https://github.com/solidusio/solidus/pull/1710) ([jhawthorn](https://github.com/jhawthorn))
- Deprecate `wait_for_ajax` capybara helper [#1668](https://github.com/solidusio/solidus/pull/1668) ([cbrunsdon](https://github.com/cbrunsdon))


## Solidus 2.1.0 (2017-01-17)

*   The OrderUpdater (as used by `order.update!`) now fully updates taxes.

    Previously there were two different ways taxes were calculated: a "full"
    and a "quick" calculation. The full calculation was performed with
    `order.create_tax_charge!` and would determine which tax rates applied and
    add taxes to items. The "quick" calculation was performed as part of an
    order update, and would only update the tax amounts on existing line items
    with taxes.

    Now `order.update!` will perform the full calculation every time.
    `order.create_tax_charge!` is now deprecated and has been made equivalent
    to `order.update!`.

    [#1479](https://github.com/solidusio/solidus/pull/1479)

*   `ItemAdjustments` has been merged into the `OrderUpdater`

    The previous behaviour between these two classes was to iterate over each
    item calculating promotions, taxes, and totals for each before moving on to
    the next item. To better support external tax services, we now calculate
    promotions for all items, followed by taxes for all items, etc.

    [#1466](https://github.com/solidusio/solidus/pull/1466)

*   Make frontend prices depend on `store.cart_tax_country_iso`

    Prices in the frontend now depend on `store.cart_tax_country_iso` instead of `Spree::Config.admin_vat_country_iso`.

    [#1605](https://github.com/solidusio/solidus/pull/1605)

*   Deprecate methods related to Spree::Order#tax_zone

    We're not using `Spree::Order#tax_zone`, `Spree::Zone.default_tax`,
    `Spree::Zone.match`, or `Spree::Zone#contains?` in our code base anymore.
    They will be removed soon. Please use `Spree::Order#tax_address`,
    `Spree::Zone.for_address`, and `Spree::Zone.include?`, respectively,
    instead.

    [#1543](https://github.com/solidusio/solidus/pull/1543)

*   Product Prototypes have been removed from Solidus itself.

    The new `solidus_prototype` extension provides the existing functionality. [#1517](https://github.com/solidusio/solidus/pull/1517)

*   Analytics trackers have been removed from Solidus itself.

    The new `solidus_trackers` extension provides the existing functionality. [#1438](https://github.com/solidusio/solidus/pull/1438)

*   Bootstrap row and column classes have replaced the legacy skeleton classes throughout the admin. [#1484](https://github.com/solidusio/solidus/pull/1484)

*   Remove `currency` from line items.

    It's no longer allowed to have line items with different currencies on the
    same order. This makes storing the currency on line items redundant, since
    it will always be considered the same as the order currency.

    It will raise an exception if a line item with the wrong currency is added.

    This change also deletes the `currency` database field (String)
    from the `line_items` table, since it will not be used anymore.

    [#1507](https://github.com/solidusio/solidus/pull/1507)

*   Add `Spree::Promotion#remove_from` and `Spree::PromotionAction#remove_from`

    This will allow promotions to be removed from orders and allows promotion
    actions to define how to reverse their side effects on an order.

    For now `PromotionAction` provides a default remove_from method, with a
    deprecation warning that subclasses should define their own remove_from
    method.

    [#1451](https://github.com/solidusio/solidus/pull/1451)

*   Remove `is_default` boolean from `Spree::Price` model

    This boolean used to mean "the price to be used". With the new
    pricing architecture introduced in 1.3, it is now redundant and can be
    reduced to an order clause in the currently valid prices scope.

    [#1469](https://github.com/solidusio/solidus/pull/1469)

*   Remove callback `Spree::LineItem.after_create :update_tax_charge`

    Any code that creates `LineItem`s outside the context of OrderContents
    should ensure that it calls `order.update!` after doing so.

    [#1463](https://github.com/solidusio/solidus/pull/1463)

*   Mark `Spree::Tax::ItemAdjuster` as api-private [#1463](https://github.com/solidusio/solidus/pull/1463)

*   Updated Credit Card brand server-side detection regex to support more
    brands and MasterCard's new BIN range. [#1477](https://github.com/solidusio/solidus/pull/1477)

    Note: Most stores will be using client-side detection which was updated in
    Solidus 1.2

*   `CreditCard`'s `verification_value` field is now converted to a string and
    has whitespace removed on assignment instead of before validations.

*   The `lastname` field on `Address` is now optional. [#1369](https://github.com/solidusio/solidus/pull/1369)

*   The admin prices listings page now shows master and variant prices
    seperately. This changes `@prices` to `@master_prices` and `@variant_prices` in prices_controller

    [#1510](https://github.com/solidusio/solidus/pull/1510)

*   Admin javascript assets are now individually `require`d using sprockets
    directives instead of using `require_tree`. This should fix issues where
    JS assets could not be overridden in applications. [#1613](https://github.com/solidusio/solidus/pull/1613)

*   The admin has an improved image upload interface with drag and drop. [#1553](https://github.com/solidusio/solidus/pull/1553)

*   PaymentMethod's `display_on` column has been replaced with `available_to_users` and `available_to_admin`.
    The existing attributes and scopes have been deprecated.

    [#1540](https://github.com/solidusio/solidus/pull/1540)

*   ShippingMethod's `display_on` column has been replaced with `available_to_users`.
    The existing attributes and scopes have been deprecated.

    [#1611](https://github.com/solidusio/solidus/pull/1611)

*   Added experimental Spree::Config.tax_adjuster_class

    To allow easier customization of tax calculation in extensions or
    applications.

    This API is *experimental* and is likely to change in a future version.

    [#1479](https://github.com/solidusio/solidus/pull/1479)

*   Removals

    * Removed deprecated `STYLE_image` helpers from BaseHelper [#1623](https://github.com/solidusio/solidus/pull/1623)

    * Removed deprecated method `Spree::TaxRate.adjust` (not to be confused with
      Spree::TaxRate#adjust) in favor of `Spree::Config.tax_adjuster_class`.

      [#1462](https://github.com/solidusio/solidus/pull/1462)

    * Removed deprecated method `Promotion#expired?` in favor of
      `Promotion#inactive?`

      [#1461](https://github.com/solidusio/solidus/pull/1461)

    * Removed nested attribute helpers `generate_template`, `generate_html`,
      and `remove_nested`. Also removes some javascript bound to selectors
      `.remove`, `a[id*=nested]`.

    * Removed `accept_alert` and `dismiss_alert` from CapybaraExt.
      `accept_alert` is now a capybara builtin (that we were overriding) and
      `dismiss_alert` can be replaced with `dismiss_prompt`.

    * Removed deprecated delegate_belongs_to

## Solidus 2.0.0 (2016-09-26)

*   Upgrade to rails 5.0

## Solidus 1.4.1 (2017-06-08)

*   Fix syntax error in `app/views/spree/admin/reimbursements/edit.html.erb` [#1991](https://github.com/solidusio/solidus/pull/1991) ([acreilly](https://github.com/acreilly))

## Solidus 1.4.0 (2016-09-26)

*   Use in-memory objects in OrderUpdater and related areas.

    Solidus now uses in-memory data for updating orders in and around
    OrderUpdater.  E.g. if an order already has `order.line_items` loaded into
    memory when OrderUpdater is run then it will use that information rather
    than requerying the database for it. This should help performance and makes
    some upcoming refactoring easier.

    Warning:  If you bypass ActiveRecord while making updates to your orders you
    run the risk of generating invalid data.  Example:

        order.line_items.to_a
        order.line_items.update_all(price: ...)
        order.update!

    Will now result in incorrect calculations in OrderUpdater because the line
    items will not be refetched.

    In particular, when creating adjustments, you should always create the
    adjustment using the adjustable relationship.

    Good example:

        line_item.adjustments.create!(source: tax_rate, ...)

    Bad examples:

        tax_rate.adjustments.create!(adjustable: line_item, ...)
        Spree::Adjustment.create!(adjustable: line_item, source: tax_rate, ...)

    We try to detect the latter examples and repair the in-memory objects (with
    a deprecation warning) but you should ensure that your code is keeping the
    adjustable's in-memory associations up to date. Custom promotion actions are
    an area likely to have this issue.

    https://github.com/solidusio/solidus/pull/1356
    https://github.com/solidusio/solidus/pull/1389
    https://github.com/solidusio/solidus/pull/1400
    https://github.com/solidusio/solidus/pull/1401

*   Make some 'wallet' behavior configurable

    NOTE: `Order#persist_user_credit_card` has been renamed to
    `Order#add_payment_sources_to_wallet`. If you are overriding
    `persist_user_credit_card` you need to update your code.

    The following extension points have been added for customizing 'wallet'
    behavior.

    * Spree::Config.add_payment_sources_to_wallet_class
    * Spree::Config.default_payment_builder_class

    https://github.com/solidusio/solidus/pull/1086

*   Backend: UI, Remove icons from buttons and tabs

*   Backend: Deprecate args/options that add icons to buttons

*   Update Rules::Taxon/Product handling of invalid match policies

    Rules::Taxon and Rules::Product now require valid match_policy values.
    Please ensure that all your Taxon and Product Rules have valid match_policy
    values.

*   Fix default value for Spree::Promotion::Rules::Taxon preferred_match_policy.

    Previously this was defaulting to nil, which was sometimes interpreted as
    'none'.

*   Deprecate `Spree::Shipment#address` (column renamed)

    `Spree::Shipment#address` was not actually being used for anything in
    particular, so the association has been deprecated and delegated to
    `Spree::Order#ship_address` instead. The database column has been renamed
    `spree_shipments.deprecated_address_id`.

    https://github.com/solidusio/solidus/pull/1138

*   Coupon code application has been separated from the Continue button on the Payment checkout page

    * JavaScript for it has been moved from address.js into its own `spree/frontend/checkout/coupon-code`
    * Numerous small nuisances have been fixed [#1090](https://github.com/solidusio/solidus/pull/1090)

*   Allow filtering orders by store when multiple stores are present. [#1149](https://github.com/solidusio/solidus/pull/1140)

*   Remove unused `user_id` column from PromotionRule. [#1259](https://github.com/solidusio/solidus/pull/1259)

*   Removed "Clear cache" button from the admin [#1275](https://github.com/solidusio/solidus/pull/1275)

*   Adjustments and totals are no longer updated when saving a Shipment or LineItem.

    Previously adjustments and total columns were updated after saving a Shipment or LineItem.
    This was unnecessary since it didn't update the order totals, and running
    order.update! would recalculate the adjustments and totals again.

## Solidus 1.3.0 (2016-06-22)

*   Order now requires a `store_id` in validations

    All orders created since Spree v2.4 should have a store assigned. A
    migration exists to assign all orders without a store to the default store.

    If you are seeing spec failures related to this, you may have to add
    `let!(:store) { create(:store) }` to some test cases.

*   Deprecate `Spree::TaxRate.adjust`, remove `Spree::TaxRate.match`

    The functionality of `Spree::TaxRate.adjust` is now contained in the new
    `Spree::Tax::OrderAdjuster` class.

    Wherever you called `Spree::TaxRate.adjust(items, order_tax_zone)`, instead call
    `Spree::Tax::OrderAdjuster.new(order).adjust!`.

    `Spree::TaxRate.match` was an implementation detail of `Spree::TaxRate.adjust`. It has been
    removed, and its functionality is now contained in the private method
    `Spree::Tax::TaxHelpers#applicable_rates(order)`.

*   Allow more options than `current_currency` to select prices

    Previously, availability of products/variants, caching and pricing was dependent
    only on a `current_currency` string. This has been changed to a `current_pricing_options`
    object. For now, this object (`Spree::Variant::PricingOptions`) only holds the
    currency. It is used for caching instead of the deprecated `current_currency` helper.

    Additionally, your pricing can be customized using a `VariantPriceSelector` object, a default
    implementation of which can be found in `Spree::Variant::PriceSelector`. It is responsible for
    finding the right price for variant, be it for front-end display or for adding it to the
    cart. You can set it through the new `Spree::Config.variant_price_selector_class` setting. This
    class also knows which `PricingOptions` class it cooperates with.

    #### Deprecated methods:

    * `current_currency` helper
    * `Spree::Variant#categorise_variants_from_option`
    * `Spree::Variant#variants_and_option_values` (Use `Spree::Variant#variants_and_option_values#for` instead)
    * `Spree::Core::Search::Base#current_currency`
    * `Spree::Core::Search::Base#current_currency=`

    #### Extracted Functionality:

    There was a strange way of setting prices for line items depending on additional attributes
    being present on the line item (`gift_wrap: true`, for example). It also needed
    `Spree::Variant` to be patched with methods like `Spree::Variant#gift_wrap_price_modifier_in`
    and is generally deemed a non-preferred way of modifying pricing.
    This functionality has now been moved into a [Gem of its own](https://github.com/solidusio-contrib/solidus_price_modifier)
    to ease the transition to the new `Variant::PriceSelector` system.

*   Respect `Spree::Store#default_currency`

    Previously, the `current_currency` helper in both the `core` and `api` gems
    would always return the globally configured default currency rather than the
    current store's one. With Solidus 1.3, we respect that setting without having
    to install the `spree_multi_domain` extension.

*   Persist tax estimations on shipping rates

    Previously, shipping rate taxes were calculated on the fly every time
    a shipping rate would be displayed. Now, shipping rate taxes are stored
    on a dedicated table to look up.

    There is a new model Spree::ShippingRateTax where the taxes are stored,
    and a new Spree::Tax::ShippingRateTaxer that builds those taxes from within
    Spree::Stock::Estimator.

    The shipping rate taxer class can be exchanged for a custom estimator class
    using the new Spree::Appconfiguration.shipping_rate_taxer_class preference.

    https://github.com/solidusio/solidus/pull/904

    In order to convert your historical shipping rate taxation data, please run
    `rake solidus:upgrade:one_point_three` - this will create persisted taxation notes
    for historical shipping rates. Be aware though that these taxation notes are
    estimations and should not be used for accounting purposes.

    https://github.com/solidusio/solidus/pull/1068

*   Deprecate setting a line item's currency by hand

    Previously, a line item's currency could be set directly, and differently from the line item's
    order's currency. This would result in an error. It still does, but is also now explicitly
    deprecated. In the future, we might delete the line item's `currency` column and just delegate
    to the line item's order.

*   Taxes for carts now configurable via the `Spree::Store` object

    In VAT countries, carts (orders without addresses) have to be shown with
    adjustments for the country whose taxes the cart's prices supposedly include.
    This might differ from `Spree::Store` to `Spree::Store`. We're introducting
    the `cart_tax_country_iso` setting on Spree::Store for this purpose.

    Previously the setting for what country any prices include
    Spree::Zone.default_tax. That, however, would *also* implicitly tag all
    prices in Spree as including the taxes from that zone. Introducing the cart
    tax setting on Spree::Store relieves that boolean of some of its
    responsibilities.

    https://github.com/solidusio/solidus/pull/933

*   Make Spree::Product#prices association return all prices

    Previously, only non-master variant prices would have been returned here.
    Now, we get all the prices, including those from the master variant.

    https://github.com/solidusio/solidus/pull/969

*   Changes to Spree::Stock::Estimator

    * The package passed to Spree::Stock::Estimator#shipping_rates must have its
      shipment assigned and that shipment must have its order assigned. This
      is needed for some upcoming tax work in to calculate taxes correctly.
    * Spree::Stock::Estimator.new no longer accepts an order argument. The order
      will be fetched from the shipment.

    https://github.com/solidusio/solidus/pull/965

*   Removed Spree::Stock::Coordinator#packages from the public interface.

    This will allow us to refactor more easily.
    https://github.com/solidusio/solidus/pull/950

*   Removed `pre_tax_amount` column from line item and shipment tables

    This column was previously used as a caching column in the process of
    calculating VATs. Its value should have been (but wasn't) always the same as
    `discounted_amount - included_tax_total`. It's been replaced with a method
    that does just that. [#941](https://github.com/solidusio/solidus/pull/941)

*   Renamed return item `pre_tax_amount` column to `amount`

    The naming and functioning of this column was inconsistent with how
    shipments and line items work: In those models, the base from which we
    calculate everything is the `amount`. The ReturnItem now works just like
    a line item.

    Usability-wise, this change entails that for VAT countries, when creating
    a refund for an order including VAT, you now have to enter the amount
    you want to refund including VAT. This is what a backend user working
    with prices including tax would expect.

    For a non-VAT store, nothing changes except for the form field name, which
    now says `Amount` instead of `Pre-tax-amount`. You might want to adjust the
    i18n translation here, depending on your circumstances.
    [#706](https://github.com/solidusio/solidus/pull/706)

*   Removed Spree::BaseHelper#gem_available? and Spree::BaseHelper#current_spree_page?

    Both these methods were untested and not appropriate code to be in core. If you need these
    methods please pull them into your app. [#710](https://github.com/solidusio/solidus/pull/710).

*   Fixed a bug where toggling 'show only complete order' on/off was not showing
    all orders. [#749](https://github.com/solidusio/solidus/pull/749)

*   ffaker has been updated to version 2.x

    This version changes the namespace from Faker:: to FFaker::

*   versioncake has been updated to version 3.x

    This version uses a rack middleware to determine the version, uses a
    different header name, and has some configuration changes.

    You probably need to add [this](https://github.com/solidusio/solidus/commit/076f56f#diff-fd13b465e9d1fded7e03629bde800c9eR64)
    to your controller specs.

    More information is available in the [VersionCake README](https://github.com/bwillis/versioncake)

*   Bootstrap 4.0.0-alpha.2 is included into the admin.

*   Pagination now uses an admin-specific kaminari theme, which uses the
    bootstrap4 styles. If you have a custom admin page with pagination you can
    use this style with the following.

        <%= paginate @collection, theme: "solidus_admin" %>

*   Settings configuration menu has been replaced with groups of tabs at the top

    * Settings pages were grouped into related partials as outlined in [#634](https://github.com/solidusio/solidus/issues/634)
    * Partials are rendered on pages owned by the partials as tabs as a top bar
    * Admin-nav has a sub-menu for the settings now

*   Lists of classes in configuration (`config.spree.calculators`, `spree.spree.calculators`, etc.) are
    now stored internally as strings and constantized when accessed. This allows these classes to be
    reloaded in development mode and loaded later in the boot process.
    [#1203](https://github.com/solidusio/solidus/pull/1203)

## Solidus 1.2.0 (2016-01-26)

*   Admin menu has been moved from top of the page to the left side.

    * Submenu items are accessible from any page. See [the wiki](https://github.com/solidusio/solidus/wiki/Upgrading-Admin-Navigation-to-1.2)
       for more information and instructions on upgrading.
    * [Solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise)
      should be updated to '~> 1.3' to support the new menu.
    * Added optional styles to the admin area to advance [admin rebrand](https://github.com/solidusio/solidus/issues/520).
      To use the new colors, add `@import 'spree/backend/themes/blue_steel/globals/_variables_override';`
      to your `spree/backend/globals/variables_override`.

*   Removed deface requirement from core

    Projects and extensions which rely on deface will need to add it explicitly
    to their dependencies.

*   `testing_support/capybara_ext.rb` no longer changes capybara's matching
    mode to `:prefer_exact`, and instead uses capybara's default, `:smart`.

    You can restore the old behaviour (not recommended) by adding
    `Capybara.match = :prefer_exact` to your `spec_helper.rb`.

    More information can be found in [capybara's README](https://github.com/jnicklas/capybara#matching)

*   Fixed a bug where sorting in the admin would not save positions correctly.
    [#632](https://github.com/solidusio/solidus/pull/632)

*   Included (VAT-style) taxes, will be considered applicable if they are
    inside the default tax zone, rather than just when they are the defaut tax
    zone. [#657](https://github.com/solidusio/solidus/pull/657)

*   Update jQuery.payment to v1.3.2 (from 1.0) [#608](https://github.com/solidusio/solidus/pull/608)

*   Removed Order::CurrencyUpdater. [#635](https://github.com/solidusio/solidus/pull/635)

*   Removed `Product#set_master_variant_defaults`, which was unnecessary since master is build with `is_master` already `true`.

*   Improved performance of stock packaging [#550](https://github.com/solidusio/solidus/pull/550) [#565](https://github.com/solidusio/solidus/pull/565) [#574](https://github.com/solidusio/solidus/pull/574)

*   Replaced admin taxon management interface [#569](https://github.com/solidusio/solidus/pull/569)

*   Fix logic around raising InsufficientStock when creating shipments. [#566](https://github.com/solidusio/solidus/pull/566)

    Previously, `InsufficientStock` was raised if any StockLocations were fully
    out of inventory. This was incorrect because it was possible other stock
    locations could have fulfilled the inventory. This was also incorrect because
    the stock location could have some, but insufficient inventory, and not raise
    the exception (an incomplete package would be returned). Now the coordinator
    checks that the package is complete and raises `InsufficientStock` if it is
    incomplete for any reason.

*   Removed `Spree::Zone.global` [#627](https://github.com/solidusio/solidus/pull/627)
    Use the "GlobalZone" factory instead: `FactoryGirl.create(:global_zone)`

## Solidus 1.1.0 (2015-11-25)

*   Address is immutable (Address#readonly? is always true)

    This allows us to minimize cloning addresses, while still ensuring historical
    data is preserved.

*   UserAddressBook module added to manage a user's multiple addresses

*   GET /admin/search/users searches all of a user's addresses, not
    just current bill and ship addresss

*   Adjustment state column has been replaced with a finalized boolean column.
    This includes a migration replacing the column, which may cause some
    downtime for large stores.

*   Handlebars templates in the admin are now stored in assets and precompiled
    with the rest of the admin js.

*   Removed `map_nested_attributes_keys` from the Api::BaseController. This
    method was only used in one place and was oblivious of strong_params.

*   Change all mails deliveries to `#deliver_later`. Emails will now be sent in
    the background if you configure active\_job to do so. See [the rails guides](http://guides.rubyonrails.org/active_job_basics.html#job-execution)
    for more information.

*   Cartons deliveries now send one email per-order, instead of one per-carton.
    This allows setting `@order` and `@store` correctly for the template. For
    most stores, which don't combine multiple orders into a carton, this will
    behave the same.

*   Some HABTM associations have been converted to HMT associations.
    Referential integrity has also been added as well.
    Specifically:

    * Prototype <=> Taxon
    * ShippingMethod <=> Zone
    * Product <=> PromotionRule

## Solidus 1.0.1 (2015-08-19)

See https://github.com/solidusio/solidus/releases/tag/v1.0.1

## Solidus 1.0.0 (2015-08-11)

See https://github.com/solidusio/solidus/releases/tag/v1.0.0
