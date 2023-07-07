# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusFriendlyPromotions::PromotionRulesTaxon do
  it { is_expected.to belong_to(:taxon).optional }
  it { is_expected.to belong_to(:promotion_rule).optional }
end
