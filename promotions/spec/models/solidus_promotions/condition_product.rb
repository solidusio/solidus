# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ConditionProduct do
  it { is_expected.to belong_to(:product) }
  it { is_expected.to belong_to(:condition) }
end
