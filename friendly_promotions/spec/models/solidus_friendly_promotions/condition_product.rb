# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::ConditionProduct do
  it { is_expected.to belong_to(:product).optional }
  it { is_expected.to belong_to(:condition).optional }
end
