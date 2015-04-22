require 'spec_helper'

RSpec.describe Spree::PromotionCode do
  context 'callbacks' do
    subject { promotion_code.save }

    describe '#downcase_value' do
      let(:promotion) { create(:promotion, code: 'NewCoDe') }
      let(:promotion_code) { promotion.codes.first }

      it 'downcases the value before saving' do
        subject
        expect(promotion_code.value).to eq('newcode')
      end
    end
  end

  describe "#usage_limit_exceeded?" do
    subject { code.usage_limit_exceeded?(promotable) }

    shared_examples "it should" do
      context "when there is a usage limit" do
        context "and the limit is not exceeded" do
          let(:usage_limit) { 10 }
          it { is_expected.to be_falsy }
        end
        context "and the limit is exceeded" do
          let(:usage_limit) { 1 }
          context "on a different order" do
            before do
              FactoryGirl.create(
                :completed_order_with_promotion,
                promotion: promotion
              )
            end
            it { is_expected.to be_truthy }
          end
          context "on the same order" do
            it { is_expected.to be_falsy }
          end
        end
      end
      context "when there is no usage limit" do
        let(:usage_limit) { nil }
        it { is_expected.to be_falsy }
      end
    end

    let(:code) { promotion.codes.first }

    context "with an order-level adjustment" do
      let(:promotion) do
        FactoryGirl.create(
          :promotion,
          :with_order_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      let(:promotable) do
        FactoryGirl.create(
          :completed_order_with_promotion,
          promotion: promotion
        )
      end
      it_behaves_like "it should"
    end

    context "with an item-level adjustment" do
      let(:promotion) do
        FactoryGirl.create(
          :promotion,
          :with_line_item_adjustment,
          code: "discount",
          per_code_usage_limit: usage_limit
        )
      end
      let(:promotable) { order.line_items.first }
      before do
        promotion.actions.first.perform({
          order: order,
          promotion: promotion,
          promotion_code: code
        })
      end
      context "when there are multiple line items" do
        let(:order) { FactoryGirl.create(:order_with_line_items, line_items_count: 2) }
        it_behaves_like "it should"
      end
      context "when there is a single line item" do
        let(:order) { FactoryGirl.create(:order_with_line_items) }
        it_behaves_like "it should"
      end
    end
  end

  describe "#usage_count" do
    let(:promotion) do
      FactoryGirl.create(
        :promotion,
        :with_order_adjustment,
        code: "discount"
      )
    end
    let(:code) { promotion.codes.first }

    subject { code.usage_count }

    context "when the code is applied to a non-complete order" do
      let(:order) { FactoryGirl.create(:order_with_line_items) }
      before { promotion.activate(order: order, promotion_code: code) }
      it { is_expected.to eq 0 }
    end
    context "when the code is applied to a complete order" do
      let!(:order) do
        FactoryGirl.create(
          :completed_order_with_promotion,
          promotion: promotion
        )
      end
      context "and the promo is eligible" do
        it { is_expected.to eq 1 }
      end
      context "and the promo is ineligible" do
        before { order.adjustments.promotion.update_all(eligible: false) }
        it { is_expected.to eq 0 }
      end
    end
  end
end
