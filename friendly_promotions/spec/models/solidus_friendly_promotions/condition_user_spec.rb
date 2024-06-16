# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::ConditionUser do
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:condition).optional }
end
