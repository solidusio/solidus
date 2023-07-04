# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::ProductsRule do
  it { is_expected.to belong_to(:product) }
  it { is_expected.to belong_to(:rule) }
end
