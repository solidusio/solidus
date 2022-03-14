# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::LineItemDiscount do
  subject(:line_item_discount) { build(:line_item_discount) }

  it { is_expected.to respond_to(:line_item) }
  it { is_expected.to respond_to(:promotion_action) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:label) }
end
