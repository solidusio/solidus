# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::ProductsPromotionRule do
  it { is_expected.to belong_to(:product).optional }
  it { is_expected.to belong_to(:promotion_rule).optional }
end
