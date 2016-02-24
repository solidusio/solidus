require 'spec_helper'

class DummyShippingCalculator < Spree::ShippingCalculator
end

describe Spree::ShippingMethod, type: :model do
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

  describe ".available_in_stock_location" do
    let!(:stock_location) { create :stock_location }
    let!(:other_stock_location) { create :stock_location }

    subject { described_class.available_in_stock_location(stock_location) }

    context "when available_to_all" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: true) }

      it "returns the shipping_method" do
        is_expected.to eq [shipping_method]
      end
    end

    context "when in stock location" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: false, stock_locations: [stock_location]) }

      it "returns the shipping_method" do
        is_expected.to eq [shipping_method]
      end
    end

    context "when available_to_all and in stock location" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: true, stock_locations: [stock_location]) }

      it "returns the shipping_method" do
        is_expected.to eq [shipping_method]
      end
    end

    context "when in no stock locations" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: false) }

      it "returns no results" do
        is_expected.to be_empty
      end
    end

    context "when in another stock location" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: false, stock_locations: [other_stock_location]) }

      it "returns no results" do
        is_expected.to be_empty
      end
    end

    context "when available_to_all and in another stock location" do
      let!(:shipping_method) { create(:shipping_method, available_to_all: true, stock_locations: [other_stock_location]) }

      it "returns the shipping_method" do
        is_expected.to eq [shipping_method]
      end
    end

    context "when multiple shipping methods match" do
      let!(:shipping_method1) { create(:shipping_method, available_to_all: true, stock_locations: [other_stock_location]) }
      let!(:shipping_method2) { create(:shipping_method, available_to_all: false, stock_locations: [stock_location]) }
      let!(:shipping_method3) { create(:shipping_method, available_to_all: false, stock_locations: [other_stock_location]) }

      it "returns both matching shipping_methods" do
        is_expected.to match_array([shipping_method1, shipping_method2])
      end
    end
  end

  describe ".available_for_address" do
    let!(:included_country) { create(:country, iso: "US") }
    let!(:excluded_country) { create(:country, iso: "CA") }
    let!(:included_zone) { create(:zone, countries: [included_country]) }
    let!(:excluded_zone) { create(:zone, countries: [excluded_country]) }
    let!(:shipping_method) { create(:shipping_method, zones: [included_zone]) }

    let(:matches) { described_class.available_for_address(address) }
    subject { matches }

    context "address included in zone" do
      let!(:address) { create(:address, country_iso_code: 'US') }

      it { is_expected.to include(shipping_method) }
    end

    context "address included other zone" do
      let!(:address) { create(:address, country_iso_code: 'CA') }
      it { is_expected.to_not include(shipping_method) }
    end
  end
end
