# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::PromotionRulesStore do
  it { is_expected.to belong_to(:store).optional }
  it { is_expected.to belong_to(:promotion_rule).optional }
end
