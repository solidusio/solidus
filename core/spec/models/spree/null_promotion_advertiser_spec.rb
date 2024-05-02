# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::PromotionAdvertiser, type: :model do
  describe ".for_product" do
    subject { described_class.for_product(product) }
    let(:product) { create(:product) }

    it { is_expected.to eq([]) }
  end
end
