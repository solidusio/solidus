# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::FlexiRate, type: :model do
  let(:calculator) do
    described_class.new(
      preferred_first_item: first_item,
      preferred_additional_item: additional_item,
      preferred_max_items: max_items
    )
  end

  let(:first_item) { 0 }
  let(:additional_item) { 0 }
  let(:max_items) { 0 }

  it_behaves_like "a calculator with a description"

  context "compute_line_item" do
    let(:line_item) do
      mock_model(
        Spree::LineItem, quantity: quantity
      )
    end

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

  context "compute_price" do
    let(:variant) { mock_model(Spree::Variant) }
    let(:price) { mock_model(Spree::Price, amount: 12, variant: variant, currency: "USD") }
    let(:order) { mock_model(Spree::Order, line_items: [line_item]) }
    let(:line_item_quantity) { 0 }
    let(:line_item) do
      mock_model(
        Spree::LineItem,
        quantity: line_item_quantity,
        variant: variant
      )
    end

    subject { calculator.compute(price, { order: order, quantity: quantity }) }

    context "with no order given" do
      let(:order) { nil }

      context "when first_item and additional_item have values" do
        let(:first_item) { 1.13 }
        let(:additional_item) { 2.11 }

        context "with quantity 2" do
          let(:quantity) { 2 }

          it { is_expected.to eq(1.62) }
        end
      end
    end

    context "if nothing is in the cart" do
      let(:line_item_quantity) { 0 }

      context "when first_item and additional_items have values" do
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

          it { is_expected.to eq 1.62 }
        end

        context "with quantity 10" do
          let(:quantity) { 3 }

          it { is_expected.to eq 1.78 }
        end

        context "with quantity 10" do
          let(:quantity) { 10 }

          it { is_expected.to eq 2.01 }
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

            it { is_expected.to eq 1.62 }
          end

          context "with quantity 5" do
            let(:quantity) { 5 }

            it { is_expected.to eq 1.91 }
          end

          context "with quantity 10" do
            let(:quantity) { 10 }

            it { is_expected.to eq 0.96 }
          end
        end
      end
    end

    context "with items already in the cart" do
      let(:line_item_quantity) { 2 }

      context "when first_item and additional_items have values" do
        let(:first_item) { 1.13 }
        let(:additional_item) { 2.11 }

        context "with quantity 0" do
          let(:quantity) { 0 }

          it { is_expected.to eq 0 }
        end

        context "with quantity 1" do
          let(:quantity) { 1 }

          it { is_expected.to eq 2.11 }
        end

        context "with quantity 2" do
          let(:quantity) { 2 }

          it { is_expected.to eq 2.11 }
        end

        context "with quantity 10" do
          let(:quantity) { 3 }

          it { is_expected.to eq 2.11 }
        end

        context "with quantity 10" do
          let(:quantity) { 10 }

          it { is_expected.to eq 2.11 }
        end

        context "with max_items 5" do
          let(:max_items) { 5 }

          context "with quantity 0" do
            let(:quantity) { 0 }

            it { is_expected.to eq 0 }
          end

          context "with quantity 1" do
            let(:quantity) { 1 }

            it { is_expected.to eq 2.11 }
          end

          context "with quantity 2" do
            let(:quantity) { 2 }

            it { is_expected.to eq 2.11 }
          end

          context "with quantity 5" do
            let(:quantity) { 5 }

            it { is_expected.to eq 1.27 }
          end

          context "with quantity 10" do
            let(:quantity) { 10 }

            it { is_expected.to eq 0.63 }
          end
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
