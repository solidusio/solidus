# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ConditionTaxon do
  it { is_expected.to belong_to(:taxon) }
  it { is_expected.to belong_to(:condition) }
end
