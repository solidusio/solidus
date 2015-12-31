FactoryGirl.define do
  factory :line_item, class: Spree::LineItem do
    quantity 1
    price { BigDecimal.new('10.00') }
    pre_tax_amount { price }
    order
    transient do
      product nil
    end
    variant do
      (product || create(:product)).master
    end
  end
end
