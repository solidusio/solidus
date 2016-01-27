require "spec_helper"

module Spree::Promotion::Actions
  RSpec.describe CreateQuantityAdjustments do
    let(:action) { CreateQuantityAdjustments.create!(calculator: calculator, promotion: promotion) }

    let(:order) { FactoryGirl.create :order }
    let(:promotion) { FactoryGirl.create :promotion }

    describe "#compute_amount" do
      subject { action.compute_amount(line_item) }

      let!(:item_a) { FactoryGirl.create :line_item, order: order, quantity: quantity, price: 10 }

      context "with a flat rate adjustment" do
        let(:calculator) { FactoryGirl.create :flat_rate_calculator, preferred_amount: 5 }

        context "with a quantity group of 2" do
          let(:line_item) { item_a }
          before { action.preferred_group_size = 2 }
          context "and an item with a quantity of 0" do
            let(:quantity) { 0 }
            it { is_expected.to eq 0 }
          end
          context "and an item with a quantity of 1" do
            let(:quantity) { 1 }
            it { is_expected.to eq 0 }
          end
          context "and an item with a quantity of 2" do
            let(:quantity) { 2 }
            it { is_expected.to eq(-10) }
          end
          context "and an item with a quantity of 3" do
            let(:quantity) { 3 }
            it { is_expected.to eq(-10) }
          end
          context "and an item with a quantity of 4" do
            let(:quantity) { 4 }
            it { is_expected.to eq(-20) }
          end
        end

        context "with a quantity group of 3" do
          let(:quantity) { 2 }
          let!(:item_b) { FactoryGirl.create :line_item, order: order, quantity: 1 }
          let!(:item_c) { FactoryGirl.create :line_item, order: order, quantity: 1 }
          before { action.preferred_group_size = 3 }
          context "and 2x item A, 1x item B and 1x item C" do
            before { action.perform({ order: order, promotion: promotion }) }
            describe "the adjustment for the first item" do
              let(:line_item) { item_a }
              it { is_expected.to eq(-10) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { item_b }
              it { is_expected.to eq(-5) }
            end
            describe "the adjustment for the third item" do
              let(:line_item) { item_c }
              it { is_expected.to eq 0 }
            end
          end
        end

        context "with multiple orders using the same action" do
          let(:quantity) { 2 }
          let(:line_item) { item_a }
          before do
            action.preferred_group_size = 2
            other_order = FactoryGirl.create :order
            FactoryGirl.create :line_item, order: other_order, quantity: 3
            action.perform({ order: other_order, promotion: promotion })
          end
          it { is_expected.to eq(-10) }
        end
      end

      context "with a percentage based adjustment" do
        let(:calculator) { FactoryGirl.create :percent_on_item_calculator, preferred_percent: 10 }

        context "with a quantity group of 3" do
          before do
            action.preferred_group_size = 3
            action.perform({ order: order, promotion: promotion })
          end
          context "and 2x item A and 1x item B" do
            let(:quantity) { 2 }
            let!(:item_b) { FactoryGirl.create :line_item, order: order, quantity: 1, price: 10 }
            describe "the adjustment for the first item" do
              let(:line_item) { item_a }
              it { is_expected.to eq(-2) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { item_b }
              it { is_expected.to eq(-1) }
            end
          end

          context "and the items cost different amounts" do
            let(:quantity) { 3 }
            let!(:item_b) { FactoryGirl.create :line_item, order: order, quantity: 1, price: 20 }
            describe "the adjustment for the first item" do
              let(:line_item) { item_a }
              it { is_expected.to eq(-3) }
            end
            describe "the adjustment for the second item" do
              let(:line_item) { item_b }
              it { is_expected.to eq 0 }
            end
          end
        end
      end
    end
  end
end
