require 'spree/testing_support/factories/line_item_factory'
require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/tax_category_factory'
require 'spree/testing_support/factories/tax_rate_factory'
require 'spree/testing_support/factories/zone_factory'

FactoryGirl.define do
  factory :adjustment, class: Spree::Adjustment do
    order
    adjustable { order }
    amount 100.0
    label 'Shipping'
    association(:source, factory: :tax_rate)
    eligible true

    after(:build) do |adjustment|
      adjustments = adjustment.adjustable.adjustments
      if adjustments.loaded? && !adjustments.include?(adjustment)
        adjustments.proxy_association.add_to_target(adjustment)
      end
    end

    factory :tax_adjustment, class: Spree::Adjustment do
      order { adjustable.order }
      association(:adjustable, factory: :line_item)
      amount 10.0
      label 'VAT 5%'

      after(:create) do |adjustment|
        # Set correct tax category, so that adjustment amount is not 0
        if adjustment.adjustable.is_a?(Spree::LineItem)
          adjustment.source.tax_category = adjustment.adjustable.tax_category
          adjustment.source.save
          adjustment.update!
        end
      end
    end
  end
end
