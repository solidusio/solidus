# Solidus Legacy Promotions

A Rails Engine that contains the classic Spree/Solidus promotion system, extracted from the other Solidus gems.

## Installation

If your Gemfile contains the line `gem "solidus"`, this gem is automatically installed. If you require the individual parts of the Solidus suite, you need to add this gem to your Gemfile:

```rb
gem "solidus_legacy_promotions"
```

This gem is slated for deprecation, as its name implies. We're working on integrating a new implementation for promotions and shipping it later this year.

## Architecture overview

Solidus Legacy Promotions ships with a powerful rule-based promotions system that allows you to grant flexible
discounts to your customers in many different scenarios. You can apply discounts to the entire
order, to a single line item or a set of line items, or to the shipping fees.

In order to achieve this level of flexibility, the promotions system is composed of four concepts:

* **Promotion handlers** are responsible for activating a promotion at the right step of the
  customer experience.
* **Promotion rules** are responsible for checking whether an order is eligible for a promotion.
* **Promotion actions** are responsible for defining the discount(s) to be applied to eligible
  orders.
* **Adjustments** are responsible for storing discount information. Promotion adjustments are
  recalculated every time the order is updated, to check if their eligibility persists when the
  state of the order changes. It is possible to
  [customize how this recalculation behaves][how-to-use-a-custom-promotion-adjuster].

> [!NOTE]
> Adjustments go beyond promotions and apply to other concepts that modify the order amount.
> Taxes are another good example.

Let's take the example of the following promotion:

> Apply free shipping on any orders whose total is $100 USD or greater.

Here's the flow Solidus follows to apply such a promotion:

1. When the customer enters their shipping information,
   the [`Shipping`](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion\_handler/shipping.rb)
   promotion handler activates the promotion on the order.
2. When activated, the promotion will perform
   some [basic eligibility checks](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion.rb#L149) (
   e.g. usage limit, validity dates) and
   then [ensure the defined promotion rules are met.](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion.rb#L149)
3. When called,
   the [`ItemTotal`](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion/rules/item\_total.rb)
   promotion rule will ensure the order's total is $100 USD or greater.
4. Since the order is eligible for the promotion,
   the [`FreeShipping`](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion/actions/free\_shipping.rb)
   action is applied to the order's shipment. The action creates an adjustment that cancels the cost
   of the shipment.
5. The customer gets free shipping!

This is the architecture at a glance. As you can see, Solidus already ships with some useful
handlers, rules, and actions out of the box.

However, you're not limited to using the stock functionality. In fact, the promotions system shows
its full potential when you use it to implement your own logic. In the rest of the guide, we'll use
the promotions system to implement the following requirements:

> We want to uphold a partnership with a new payment platform by offering a 50% shipping discount
> when customers pay with it during the checkout.

In order to do this, we'll have to implement our own handler, rule, and action. Let's get to work!

## Implementing a new handler

There's nothing special about promotion handlers: technically, they're just plain old Ruby objects
that are created and called in the right places during the checkout flow.

There is no unified API for promotion handlers, but we can take inspiration from
the [existing ones](https://github.com/solidusio/solidus/tree/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion\_handler)
and use a similar format:

```ruby title="app/models/amazing_store/promotion_handler/payment.rb"
# frozen_string_literal: true

module AmazingStore
  module PromotionHandler
    class Payment
      RULES_TYPE = 'AmazingStore::Promotion::Rules::Payment'

      attr_reader :order

      def initialize(order)
        @order = order
      end

      def activate
        promotions.each do |promotion|
          promotion.activate(order: order) if promotion.eligible?(order)
        end
      end

      private

      def promotions
        ::Spree::Promotion.
          active.
          joins(:promotion_rules).
          where('promotion_rules.type' => RULES_TYPE)
      end
    end
  end
end
```

Our promotion handler selects a subset of promotions with a specific rule type that we haven't yet
created. Then, it activates the eligible ones, i.e., those who obey its rules.

Remember that promotion handlers simply apply active promotions to the current order at the correct
stage of the order workflow. While other handlers might pick up our promotions, they won't be able
to activate it if they run before the payment step. With the new handler, we want to ensure that
promotions can be activated after a payment method has been selected for the order.

Let's call our handler as a callback after the checkout flow has transitioned from the  `:payment`
state (see
the [section on how to customize state machines](state-machines.mdx#customizing-core-behavior)):

```ruby title="app/overrides/amazing_store/load_payment_promotion_handler.rb"
# frozen_string_literal: true

module AmazingStore
  module LoadPaymentPromotionHandler
    def self.prepended(base)
      base.state_machine.after_transition(from: :payment) do |order|
        AmazingStore::PromotionHandler::Payment.new(order).activate
      end
    end

    ::Spree::Order.prepend(self)
  end
end
```

## Implementing a new rule

Now that we have our handler, let's move on and implement the promotion rule that checks whether the
customer is using the promoted payment method.

We'll allow store admins to edit which payment method carries the discount. The best way to do that
is to create a preference for the promotion rule itself:

```ruby title="app/models/amazing_store/promotion/rules/payment.rb"
# frozen_string_literal: true

module AmazingStore
  module Promotion
    module Rules
      class Payment < ::Spree::PromotionRule
        DEFAULT_PREFERRED_PAYMENT_TYPE = 'AmazingStore::AmazingPaymentPlatform'

        ALLOWED_PAYMENT_TYPES = [
          DEFAULT_PREFERRED_PAYMENT_TYPE,
          'Spree::PaymentMethod::Check',
          'Spree::PaymentMethod::CreditCard'
        ].freeze

        preference :payment_type, :string, default: DEFAULT_PREFERRED_PAYMENT_TYPE

        validates :preferred_payment_type, inclusion: {
          in: ALLOWED_PAYMENT_TYPES,
          allow_blank: true
        }, on: :update

        def applicable?(promotable)
          promotable.is_a?(::Spree::Order)
        end

        def eligible?(order, _options = {})
          order.payments.any? do |payment|
            payment.payment_method.type == preferred_payment_type
          end
        end
      end
    end
  end
end
```

> [!CAUTION]
> You may have noticed that we allow the payment type to be blank on creation. This is because
> promotion rules are initially created without any of their preferences, so that the correct form can
> be presented to the admin when configuring the rule. If we enforced the presence of a payment type
> since the very beginning, Solidus wouldn't be able to create the promotion rule and admins would get
> an error.

Now that we have the implementation of our promotion rule, we also need to give admins a nice UI
where they can manage the rule and enter the promoted payment type. We just need to create the right
partial, where we'll have a local variable `promotion_rule` available to access the current
promotion rule instance:

```markup title="app/views/spree/admin/promotions/rules/_payment.html.erb"
<div class="row">
  <div class="col-6">
    <div class="field">
      <%= promotion_rule.class.human_attribute_name(:payment_type) %>
    </div>
  </div>
  <div class="col-6">
    <div class="field">
      <%= select_tag "#{param_prefix}[preferred_payment_type]", options_for_select(promotion_rule.class::ALLOWED_PAYMENT_TYPES, promotion_rule.preferred_payment_type), class: 'fullwidth' %>
    </div>
  </div>
</div>
```

The last step is to register our new promotion rule in an initializer:

```ruby title="config/initializers/promotions.rb"
# ...
Rails.application.config.spree.promotions.rules << 'AmazingStore::Promotion::Rules::Payment'
```

When you create a new promotion in the backend, we should now see the _Payment_ promotion rule. For
a better experience, we can associate a description so that it's rendered along its form:

```yaml title="config/locales/en.yml"
en:
  # ...
  activerecord:
    attributes:
      amazing_store/promotion/rules/payment:
        description: Must use the specified payment method
```

## Implementing a new action

Finally, let's implement the promotion action that will grant customers a 50% shipping discount. In
order to do that, we can take inspiration from the
existing [`FreeShipping`](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion/actions/free\_shipping.rb)
action:

```ruby title="app/models/amazing_store/promotion/actions/half_shipping.rb"
# frozen_string_literal: true

module AmazingStore
  module Promotion
    module Actions
      class HalfShipping < ::Spree::PromotionAction
        # The `perform` method is called when an action is applied to an order or line
        # item. The payload contains a lot of useful context:
        # https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion.rb#L129
        def perform(payload = {})
          order = payload[:order]
          promotion_code = payload[:promotion_code]

          results = order.shipments.map do |shipment|
            # If the shipment has already been discounted by this promotion action,
            # we skip it.
            next false if shipment.adjustments.where(source: self).exists?

            # If not, we create an adjustment to apply a 50% discount on the shipment.
            shipment.adjustments.create!(
              order: shipment.order,
              amount: compute_amount(shipment),
              source: self,
              promotion_code: promotion_code,
              label: promotion.name,
            )

            # We return true here to mark that the shipment has been discounted.
            true
          end

          # `perform` needs to return true if any adjustments have been applied by
          # the promotion action. Otherwise, it should return false.
          results.any? { |result| result == true }
        end

        def compute_amount(shipment)
          shipment.cost * -0.5
        end

        # The `remove_from` method should undo any actions done by `perform`. It is
        # used when an order becomes ineligible for a given promotion and the promotion
        # needs to be removed.
        def remove_from(order)
          order.shipments.each do |shipment|
            shipment.adjustments.each do |adjustment|
              if adjustment.source == self
                # Here, we simply remove any adjustments on the order's shipments
                # created by this promotion action.
                shipment.adjustments.destroy!(adjustment)
              end
            end
          end
        end
      end
    end
  end
end
```

As you can see, there's quite a bit going on here, but hopefully, the comments help you with the
flow of the action and the purpose of the methods we implemented.

Just like rules, promotion actions can also have preferences and allow admin to define them via the
UI. However, in this case, we don't need any of that. Still, Solidus will expect a partial for the
action, so we should create an empty ERB file.

```erb title="app/views/spree/admin/promotions/actions/_half_shipping.html.erb"
<!-- Intentionally empty -->
```

> [!TIP]
> You can look at
? the [`CreateQuantityAdjustments`](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/core/app/models/spree/promotion/actions/create\_quantity\_adjustments.rb)
> action and
> the [corresponding view](https://github.com/solidusio/solidus/blob/64b6b6eaf902337983c487cf10dfada8dbfc5160/backend/app/views/spree/admin/promotions/actions/\_create\_quantity\_adjustments.html.erb)
for an example of actions with preferences.

Finally, we need to register our action by adding the following to an initializer:

```ruby title="config/initializers/promotions.rb"
# ...
Rails.application.config.spree.promotions.actions << 'AmazingStore::Promotion::Actions::HalfShipping'
```

Like before, let's add a human-friendly description:

```yaml title="config/locales/en.yml"
en:
  # ...
  activerecord:
    attributes:
      amazing_store/promotion/actions/half_shipping:
        description: Applies 50% discount in shipping
```

Restart the server and you should now see your new promotion action!

Let's try it out!

First of all, go to the _Promotions_ section on the backend and click _New Promotion_. In this case,
it makes sense to check the _Apply to all orders_ option, as our promotion doesn't need a code. Once
the promotion has been created, add the _Payment_ rule and the _Half shipping_ action.

You can now go to the frontend and see how the shipment price is dropped by 50% if you select the
configured payment method.
