# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusFriendlyPromotions::Benefits::AdjustLineItem do
  subject(:action) { described_class.new }

  describe "name" do
    subject(:name) { action.model_name.human }

    it { is_expected.to eq("Discount matching line items") }
  end

  describe ".to_partial_path" do
    subject { described_class.new.to_partial_path }

    it { is_expected.to eq("solidus_friendly_promotions/admin/benefit_fields/adjust_line_item") }
  end

  describe "#level" do
    subject { described_class.new.level }

    it { is_expected.to eq(:line_item) }
  end
end
