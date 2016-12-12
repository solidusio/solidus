require 'spec_helper'
require 'shared_examples/calculator_shared_examples'

describe Spree::Calculator::TieredFlatRate, type: :model do
  let(:calculator) { Spree::Calculator::TieredFlatRate.new }

  it_behaves_like 'a calculator with a description'

  describe "#valid?" do
    subject { calculator.valid? }
    context "when tiers is a hash" do
      context "and the key is not a positive number" do
        before { calculator.preferred_tiers = { "nope" => 20 } }
        it { is_expected.to be false }
      end

      context "and the key is an integer" do
        before { calculator.preferred_tiers = { 20 => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal.new('20') => BigDecimal.new('20') })
        end
      end

      context "and the key is a float" do
        before { calculator.preferred_tiers = { 20.5 => 20.5 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal.new('20.5') => BigDecimal.new('20.5') })
        end
      end

      context "and the key is a string number" do
        before { calculator.preferred_tiers = { "20" => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal.new('20') => BigDecimal.new('20') })
        end
      end

      context "and the key is a numeric string with spaces" do
        before { calculator.preferred_tiers = { "  20 " => 20 } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal.new('20') => BigDecimal.new('20') })
        end
      end

      context "and the key is a string number with decimals" do
        before { calculator.preferred_tiers = { "20.5" => "20.5" } }
        it "converts successfully" do
          is_expected.to be true
          expect(calculator.preferred_tiers).to eq({ BigDecimal.new('20.5') => BigDecimal.new('20.5') })
        end
      end
    end
  end

  describe "#compute" do
    let(:line_item) { mock_model Spree::LineItem, amount: amount }
    before do
      calculator.preferred_base_amount = 10
      calculator.preferred_tiers = {
        100 => 15,
        200 => 20
      }
    end
    subject { calculator.compute(line_item) }
    context "when amount falls within the first tier" do
      let(:amount) { 50 }
      it { is_expected.to eq 10 }
    end
    context "when amount falls within the second tier" do
      let(:amount) { 150 }
      it { is_expected.to eq 15 }
    end
  end
end
