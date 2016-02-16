require 'spec_helper'

class DummyShippingCalculator < Spree::ShippingCalculator
end

describe Spree::ShippingMethod, type: :model do
  let(:shipping_method){ create(:shipping_method) }

  # Regression test for https://github.com/spree/spree/issues/4492
  context "#shipments" do
    let!(:shipping_method) { create(:shipping_method) }
    let!(:shipment) do
      shipment = create(:shipment)
      shipment.shipping_rates.create!(shipping_method: shipping_method)
      shipment
    end

    it "can gather all the related shipments" do
      expect(shipping_method.shipments).to include(shipment)
    end
  end

  context "validations" do
    before { subject.valid? }

    it "validates presence of name" do
      expect(subject.error_on(:name).size).to eq(1)
    end

    context "shipping category" do
      it "validates presence of at least one" do
        expect(subject.error_on(:base).size).to eq(1)
      end

      context "one associated" do
        before { subject.shipping_categories.push create(:shipping_category) }
        it { expect(subject.error_on(:base).size).to eq(0) }
      end
    end
  end

  context 'factory' do
    it "should set calculable correctly" do
      expect(shipping_method.calculator.calculable).to eq(shipping_method)
    end
  end

  context "generating tracking URLs" do
    context "shipping method has a tracking URL mask on file" do
      let(:tracking_url) { "https://track-o-matic.com/:tracking" }
      before { allow(subject).to receive(:tracking_url) { tracking_url } }

      context 'tracking number has spaces' do
        let(:tracking_numbers) { ["1234 5678 9012 3456", "a bcdef"] }
        let(:expectations) { %w[https://track-o-matic.com/1234%205678%209012%203456 https://track-o-matic.com/a%20bcdef] }

        it "should return a single URL with '%20' in lieu of spaces" do
          tracking_numbers.each_with_index do |num, i|
            expect(subject.build_tracking_url(num)).to eq(expectations[i])
          end
        end
      end
    end
  end

  # Regression test for https://github.com/spree/spree/issues/4320
  context "soft deletion" do
    let(:shipping_method) { create(:shipping_method) }
    it "soft-deletes when destroy is called" do
      shipping_method.destroy
      expect(shipping_method.deleted_at).not_to be_blank
    end
  end

  describe ".with_all_shipping_category_ids" do
    let(:category1) { create(:shipping_category) }
    let(:category2) { create(:shipping_category) }

    def matching(categories)
      described_class.with_all_shipping_category_ids(categories.map(&:id))
    end

    context "with one associated shipping category" do
      let!(:shipping_method) { create(:shipping_method, shipping_categories: [category1]) }

      it "should match the associated category" do
        expect(matching([category1])).to eq [shipping_method]
      end

      it "should not match the other category" do
        expect(matching([category2])).to be_empty
      end

      it "should not match both categories" do
        expect(matching([category1, category2])).to be_empty
      end

      context "with additional joins" do
        before do
          shipping_method.zones << create(:zone)
        end
        it "should not match both categories" do
          result =
            described_class.
            joins(:zones).
            with_all_shipping_category_ids([category1.id, category2.id])
          expect(result).to be_empty
        end
      end
    end

    context "with two associated shipping categories" do
      let!(:shipping_method) { create(:shipping_method, shipping_categories: [category1, category2]) }

      it "should match the associated category" do
        expect(matching([category1])).to eq [shipping_method]
      end

      it "should match both categories" do
        expect(matching([category1, category2])).to eq [shipping_method]
      end
    end

    context "with several shipping methods" do
      let!(:shipping_method1) { create(:shipping_method, shipping_categories: [category1]) }
      let!(:shipping_method2) { create(:shipping_method, shipping_categories: [category1, category2]) }
      let!(:shipping_method3) { create(:shipping_method, shipping_categories: [category2]) }

      it "matches correctly" do
        expect(matching([category1])).to match_array [shipping_method1, shipping_method2]
      end
    end
  end
end
