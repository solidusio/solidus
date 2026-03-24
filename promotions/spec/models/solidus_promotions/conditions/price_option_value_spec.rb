# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Conditions::PriceOptionValue, type: :model do
  it_behaves_like "an option value condition"

  describe "#eligible?(price)" do
    let(:condition) do
      described_class.new(
        preferred_eligible_values: {
          variant.product.id => [
            variant.option_values.pick(:id)
          ]
        }
      )
    end
    subject { condition.eligible?(promotable) }

    let(:variant) { create :variant }
    let(:promotable) { variant.default_price }

    context "when there price's variant has one of the options values" do
      it { is_expected.to be true }
    end

    context "when the price is for a non-applicable product" do
      let(:promotable) { create(:price) }

      it { is_expected.to be false }
    end
  end
end
