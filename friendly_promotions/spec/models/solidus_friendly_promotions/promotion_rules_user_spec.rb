# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::PromotionRulesUser do
  it { is_expected.to belong_to(:user).optional }
  it { is_expected.to belong_to(:promotion_rule).optional }
end
