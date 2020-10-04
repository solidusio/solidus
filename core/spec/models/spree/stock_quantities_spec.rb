# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::StockQuantities, type: :model do
  let(:variant1) { mock_model(Spree::Variant) }
  let(:variant2) { mock_model(Spree::Variant) }

  subject do
    described_class.new(quantities)
  end

  describe "#each" do
    def expect_each
      expect { |item| subject.each(&item) }
    end

    context "with no items" do
      let(:quantities) { {} }

      it "doesn't yield" do
        expect_each.not_to yield_control
      end
    end

    context "with one item" do
      let(:quantities) { { variant1 => 2 } }

      it "yields values" do
        expect_each.to yield_with_args([variant1, 2])
      end
    end

    context "with two items" do
      let(:quantities) { { variant1 => 2, variant2 => 3 } }

      it "yields values" do
        expect_each.to yield_successive_args([variant1, 2], [variant2, 3])
      end
    end
  end

  describe "#variants" do
    context "with one item" do
      let(:quantities) { { variant1 => 2 } }

      it "returns variant" do
        expect(subject.variants).to eq [variant1]
      end
    end

    context "with two items" do
      let(:quantities) { { variant1 => 2, variant2 => 3 } }

      it "returns both variants" do
        expect(subject.variants).to eq [variant1, variant2]
      end
    end
  end

  describe "#empty?" do
    context "no variants" do
      let(:quantities) { {} }
      it { is_expected.to be_empty }
    end

    context "only quantity 0" do
      let(:quantities) { { variant1 => 0 } }
      it { is_expected.to be_empty }
    end

    context "positive quantity" do
      let(:quantities) { { variant1 => 1 } }
      it { is_expected.not_to be_empty }
    end

    context "one variant positive one zero" do
      let(:quantities) { { variant1 => 1, variant2 => 0 } }
      it { is_expected.not_to be_empty }
    end

    context "negative quantity" do
      # empty? doesn't make a whole lot of sense in this case, but returning
      # false is probably more accurate.
      let(:quantities) { { variant1 => -1 } }
      it { is_expected.not_to be_empty }
    end
  end

  describe "==" do
    subject do
      described_class.new(quantity1) == described_class.new(quantity2)
    end

    context "when both empty" do
      let(:quantity1) { {} }
      let(:quantity2) { {} }
      it { is_expected.to be true }
    end

    context "when both equal" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant1 => 1 } }
      it { is_expected.to be true }
    end

    context "with different order" do
      let(:quantity1) { { variant1 => 1, variant2 => 2 } }
      let(:quantity2) { { variant2 => 2, variant1 => 1 } }
      it { is_expected.to be true }
    end

    context "with different variant" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant2 => 1 } }
      it { is_expected.to be false }
    end

    context "with different quantities" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant1 => 2 } }
      it { is_expected.to be false }
    end

    context "nil != 0" do
      let(:quantity1) { { variant1 => 0 } }
      let(:quantity2) { {} }
      it { is_expected.to be false }
    end
  end

  describe "+" do
    subject do
      described_class.new(quantity1) + described_class.new(quantity2)
    end

    context "same variant" do
      let(:quantity1) { { variant1 => 20 } }
      let(:quantity2) { { variant1 => 22 } }

      it { is_expected.to eq described_class.new({ variant1 => 42 }) }
    end

    context "different variants" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant2 => 2 } }

      it { is_expected.to eq described_class.new({ variant1 => 1, variant2 => 2 }) }
    end

    context "0 quantities" do
      let(:quantity1) { { variant1 => 0 } }
      let(:quantity2) { { variant2 => 1 } }

      it { is_expected.to eq described_class.new({ variant1 => 0, variant2 => 1 }) }
    end

    context "empty quantity" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new({ variant1 => 1 }) }
    end
  end

  describe "-" do
    subject do
      described_class.new(quantity1) - described_class.new(quantity2)
    end

    context "same variant" do
      let(:quantity1) { { variant1 => 22 } }
      let(:quantity2) { { variant1 => 20 } }

      it { is_expected.to eq described_class.new({ variant1 => 2 }) }
    end

    context "different variants" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant2 => 2 } }

      it { is_expected.to eq described_class.new({ variant1 => 1, variant2 => -2 }) }
    end

    context "0 quantity" do
      let(:quantity1) { { variant1 => 0 } }
      let(:quantity2) { { variant1 => 1 } }

      it { is_expected.to eq described_class.new({ variant1 => -1 }) }
    end

    context "empty quantity RHS" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new({ variant1 => 1 }) }
    end

    context "empty quantity LHS" do
      let(:quantity1) { {} }
      let(:quantity2) { { variant1 => 1 } }

      it { is_expected.to eq described_class.new({ variant1 => -1 }) }
    end
  end

  # Common subset
  describe "&" do
    subject do
      described_class.new(quantity1) & described_class.new(quantity2)
    end

    context "same variant" do
      let(:quantity1) { { variant1 => 20 } }
      let(:quantity2) { { variant1 => 22 } }

      it { is_expected.to eq described_class.new({ variant1 => 20 }) }
    end

    context "multiple variants" do
      let(:quantity1) { { variant1 => 10, variant2 => 20 } }
      let(:quantity2) { { variant1 => 12, variant2 => 14 } }

      it { is_expected.to eq described_class.new({ variant1 => 10, variant2 => 14 }) }
    end

    context "different variants" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { { variant2 => 2 } }

      it { is_expected.to be_empty }
      it { is_expected.to eq described_class.new({}) }
    end

    context "0 quantities" do
      let(:quantity1) { { variant1 => 0 } }
      let(:quantity2) { { variant1 => 1 } }

      it { is_expected.to eq described_class.new({ variant1 => 0 }) }
    end

    context "empty quantity" do
      let(:quantity1) { { variant1 => 1 } }
      let(:quantity2) { {} }

      it { is_expected.to eq described_class.new({}) }
    end
  end
end
