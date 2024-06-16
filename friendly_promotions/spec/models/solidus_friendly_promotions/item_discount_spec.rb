# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::ItemDiscount do
  it { is_expected.to respond_to(:item) }
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:amount) }
  it { is_expected.to respond_to(:label) }
end
