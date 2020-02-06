## Solidus 2.11.0 (master, unreleased)

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
