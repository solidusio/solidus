# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ConditionProduct do
  it { is_expected.to belong_to(:product).optional }
  it { is_expected.to belong_to(:condition).optional }
end
