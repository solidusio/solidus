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
  end

  factory :tax_adjustment, class: Spree::Adjustment do
    order { adjustable.order }
    association(:adjustable, factory: :line_item)
    amount 10.0
    label 'VAT 5%'
    association(:source, factory: :tax_rate)
    eligible true

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
