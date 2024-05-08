# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::ConditionUser do
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:condition).optional }
end
