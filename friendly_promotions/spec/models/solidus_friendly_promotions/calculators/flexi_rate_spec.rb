# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusFriendlyPromotions::Calculators::FlexiRate, type: :model do
  let(:calculator) do
    described_class.new(
      preferred_first_item: first_item,
      preferred_additional_item: additional_item,
      preferred_max_items: max_items
    )
  end
  let(:line_item) do
    mock_model(
      Spree::LineItem, quantity: quantity
    )
  end
  let(:first_item) { 0 }
  let(:additional_item) { 0 }
  let(:max_items) { 0 }

  let(:line_item) do
    mock_model(
      Spree::LineItem, quantity: quantity
    )
  end

  it_behaves_like "a calculator with a description"

  context "compute" do
    subject { calculator.compute(line_item) }

    context "with all amounts 0" do
      context "with quantity 0" do
        let(:quantity) { 0 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 1" do
        let(:quantity) { 1 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 2" do
        let(:quantity) { 2 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 10" do
        let(:quantity) { 10 }

        it { is_expected.to eq 0 }
      end
    end

    context "when first_item has a value" do
      let(:first_item) { 1.23 }

      context "with quantity 0" do
        let(:quantity) { 0 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 1" do
        let(:quantity) { 1 }

        it { is_expected.to eq 1.23 }
      end

      context "with quantity 2" do
        let(:quantity) { 2 }

        it { is_expected.to eq 1.23 }
      end

      context "with quantity 10" do
        let(:quantity) { 10 }

        it { is_expected.to eq 1.23 }
      end
    end

    context "when additional_items has a value" do
      let(:additional_item) { 1.23 }

      context "with quantity 0" do
        let(:quantity) { 0 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 1" do
        let(:quantity) { 1 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 2" do
        let(:quantity) { 2 }

        it { is_expected.to eq 1.23 }
      end

      context "with quantity 10" do
        let(:quantity) { 10 }

        it { is_expected.to eq 11.07 }
      end
    end

    context "when first_item and additional_items has a value" do
      let(:first_item) { 1.13 }
      let(:additional_item) { 2.11 }

      context "with quantity 0" do
        let(:quantity) { 0 }

        it { is_expected.to eq 0 }
      end

      context "with quantity 1" do
        let(:quantity) { 1 }

        it { is_expected.to eq 1.13 }
      end

      context "with quantity 2" do
        let(:quantity) { 2 }

        it { is_expected.to eq 3.24 }
      end

      context "with quantity 10" do
        let(:quantity) { 10 }

        it { is_expected.to eq 20.12 }
      end

      context "with max_items 5" do
        let(:max_items) { 5 }

        context "with quantity 0" do
          let(:quantity) { 0 }

          it { is_expected.to eq 0 }
        end

        context "with quantity 1" do
          let(:quantity) { 1 }

          it { is_expected.to eq 1.13 }
        end

        context "with quantity 2" do
          let(:quantity) { 2 }

          it { is_expected.to eq 3.24 }
        end

        context "with quantity 5" do
          let(:quantity) { 5 }

          it { is_expected.to eq 9.57 }
        end

        context "with quantity 10" do
          let(:quantity) { 10 }

          it { is_expected.to eq 9.57 }
        end
      end
    end
  end

  it "allows creation of new object with all the attributes" do
    attributes = { preferred_first_item: 1, preferred_additional_item: 1, preferred_max_items: 1 }
    calculator = described_class.new(attributes)
    expect(calculator).to have_attributes(attributes)
  end
end
