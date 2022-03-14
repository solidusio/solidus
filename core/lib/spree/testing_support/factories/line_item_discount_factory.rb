# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/line_item_factory'
end

FactoryBot.define do
  factory :line_item_discount, class: 'Spree::LineItemDiscount' do
    amount { BigDecimal("-2.00") }
    line_item
    promotion_action { Spree::Promotion::Actions::CreateItemAdjustments.new }
    label { "Cheap because promotion" }
  end
end
