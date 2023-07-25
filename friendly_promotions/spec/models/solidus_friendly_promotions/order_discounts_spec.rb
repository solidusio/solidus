# frozen_string_literal: true

RSpec.describe SolidusFriendlyPromotions::OrderDiscounts do
  it { is_expected.to respond_to :order_id }
  it { is_expected.to respond_to :line_item_discounts }
  it { is_expected.to respond_to :shipment_discounts }
  it { is_expected.to respond_to :shipping_rate_discounts }
end
