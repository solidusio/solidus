# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::Promotion::Rules::Taxon, type: :model do
  let(:taxon)   { create :taxon, name: 'first' }
  let(:taxon2)  { create :taxon, name: 'second' }
  let(:order)   { create :order_with_line_items }
  let(:product) { order.products.first }

  let(:rule) do
    Spree::Promotion::Rules::Taxon.create!(promotion: create(:promotion))
  end

  context '#eligible?(order)' do
    context 'with any match policy' do
      before do
        rule.update!(preferred_match_policy: 'any')
      end

      it 'is eligible if order does have any prefered taxon' do
        product.taxons << taxon
        rule.taxons << taxon
        expect(rule).to be_eligible(order)
      end

      context 'when order contains items from different taxons' do
        before do
          product.taxons << taxon
          rule.taxons << taxon
        end

        it 'should act on a product within the eligible taxon' do
          expect(rule).to be_actionable(order.line_items.last)
        end

        it 'should not act on a product in another taxon' do
          order.line_items << create(:line_item, product: create(:product, taxons: [taxon2]))
          expect(rule).not_to be_actionable(order.line_items.last)
        end
      end

      context "when order does not have any prefered taxon" do
        before { rule.taxons << taxon2 }
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "You need to add a product from an applicable category before applying this coupon code."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code]).
            to eq :no_matching_taxons
        end
      end

      context 'when a product has a taxon child of a taxon rule' do
        before do
          taxon.children << taxon2
          product.taxons << taxon2
          rule.taxons << taxon
        end

        it{ expect(rule).to be_eligible(order) }
      end
    end

    context 'with all match policy' do
      before do
        rule.update!(preferred_match_policy: 'all')
      end

      it 'is eligible order has all prefered taxons' do
        product.taxons << taxon2
        order.products.last.taxons << taxon

        rule.taxons = [taxon, taxon2]

        expect(rule).to be_eligible(order)
      end

      context "when order does not have all prefered taxons" do
        before { rule.taxons << taxon }
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "You need to add a product from all applicable categories before applying this coupon code."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code]).
            to eq :missing_taxon
        end
      end

      context 'when a product has a taxon child of a taxon rule' do
        let(:taxon3) { create :taxon }

        before do
          taxon.children << taxon2
          taxon.save!
          taxon.reload

          product.taxons = [taxon2, taxon3]
          rule.taxons = [taxon, taxon3]
        end

        it { expect(rule).to be_eligible(order) }
      end
    end

    context 'with none match policy' do
      before do
        rule.preferred_match_policy = 'none'
      end

      context "none of the order's products are in listed taxon" do
        before { rule.taxons << taxon2 }
        it { expect(rule).to be_eligible(order) }
      end

      context "one of the order's products is in a listed taxon" do
        before do
          order.products.first.taxons << taxon
          rule.taxons << taxon
        end
        it "should not be eligible" do
          expect(rule).not_to be_eligible(order)
        end
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "Your cart contains a product from an excluded category that prevents this coupon code from being applied."
        end
        it "sets an error code" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.details[:base].first[:error_code]).
            to eq :has_excluded_taxon
        end
      end
    end

    context 'with an invalid match policy' do
      before do
        order.products.first.taxons << taxon
        rule.taxons << taxon
        rule.preferred_match_policy = 'invalid'
        rule.save!(validate: false)
      end

      it 'logs a warning and uses "any" policy' do
        expect(Spree::Deprecation).to(
          receive(:warn).
          with(/has unexpected match policy "invalid"/)
        )

        expect(
          rule.eligible?(order)
        ).to be_truthy
      end
    end
  end

  describe '#actionable?' do
    let(:line_item) { order.line_items.first! }
    let(:order) { create :order_with_line_items }
    let(:taxon) { create :taxon, name: 'first' }

    context 'with an invalid match policy' do
      before do
        rule.preferred_match_policy = 'invalid'
        rule.save!(validate: false)
        line_item.product.taxons << taxon
        rule.taxons << taxon
      end

      it 'logs a warning and uses "any" policy' do
        expect(Spree::Deprecation).to(
          receive(:warn).
          with(/has unexpected match policy "invalid"/)
        )

        expect(
          rule.actionable?(line_item)
        ).to be_truthy
      end
    end

    context 'when a product has a taxon of a taxon rule' do
      before do
        product.taxons << taxon
        rule.taxons << taxon
        rule.save!
      end

      it 'is actionable' do
        expect(rule).to be_actionable(line_item)
      end
    end

    context 'when a product has a taxon child of a taxon rule' do
      before do
        taxon.children << taxon2
        product.taxons << taxon2
        rule.taxons << taxon
        rule.save!
      end

      it 'is actionable' do
        expect(rule).to be_actionable(line_item)
      end
    end

    context 'when a product does not have taxon or child taxon of a taxon rule' do
      before do
        product.taxons << taxon2
        rule.taxons << taxon
        rule.save!
      end

      it 'is not actionable' do
        expect(rule).not_to be_actionable(line_item)
      end
    end
  end
end
