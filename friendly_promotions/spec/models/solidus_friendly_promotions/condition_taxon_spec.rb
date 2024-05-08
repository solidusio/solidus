# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::ConditionTaxon do
  it { is_expected.to belong_to(:taxon).optional }
  it { is_expected.to belong_to(:condition).optional }
end
