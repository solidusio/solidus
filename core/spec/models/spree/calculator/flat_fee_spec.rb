# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe Spree::Calculator::FlatFee, type: :model do
  let(:tax_rate) { build(:tax_rate, amount: 42) }
  let(:calculator) { described_class.new(calculable: tax_rate) }

  it_behaves_like "a calculator with a description"

  let(:order) { build(:order) }

  describe "#compute" do
    subject { calculator.compute(order) }

    context "when the calculator is active" do
      it { is_expected.to eq 42 }
    end

    context "when the calculator is inactive" do
      let(:tax_rate) { build(:tax_rate, expires_at: 2.days.ago) }
      it { is_expected.to eq 0 }
    end
  end
end
