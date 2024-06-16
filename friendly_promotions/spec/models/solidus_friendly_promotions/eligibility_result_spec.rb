# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::EligibilityResult do
  it { is_expected.to respond_to(:item) }
  it { is_expected.to respond_to(:condition) }
  it { is_expected.to respond_to(:success) }
  it { is_expected.to respond_to(:code) }
  it { is_expected.to respond_to(:message) }
end
