require 'spec_helper'

describe Spree::TaxRate, type: :model do
  context ".for_zone" do
    subject(:rates_for_zone) { Spree::TaxRate.for_zone(zone) }

    context "when zone is nil" do
      let(:zone) { nil }

      it "should return an empty array" do
        expect(subject).to eq([])
      end
    end

    context "when no rate zones match the tax zone" do
      let(:rate_zone) { create(:zone, :with_country) }
      let!(:rate) { create :tax_rate, zone: rate_zone }

      context "when there is no default tax zone" do
        context "and the zone has no shared members with the rate zone" do
          let(:zone) { create(:zone, :with_country) }

          it "should return an empty array" do
            expect(subject).to eq([])
          end
        end

        context "and the zone has shared members with the rate zone" do
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return the rate that matches the rate zone" do
            expect(subject).to eq([rate])
          end
        end

        context "there is many rates that match the zone" do
          let!(:rate2) { create :tax_rate, zone: rate_zone }
          let(:zone) { create(:zone, countries: rate_zone.countries) }

          it "should return all rates that match the rate zone" do
            expect(subject).to match_array([rate, rate2])
          end
        end

        context "when the tax_zone is contained within a rate zone" do
          let(:country1) { create :country }
          let(:country2) { create :country }
          let(:rate_zone) { create(:zone, countries: [country1, country2]) }
          let(:zone) { create(:zone, countries: [country1]) }

          it "should return the rate zone" do
            expect(subject).to eq([rate])
          end
        end
      end

      context "when there is a default tax zone" do
        let(:default_zone) { create(:zone, :with_country, default_tax: true) }
        let(:included_in_price) { false }
        let!(:rate) do
          create(:tax_rate, zone: default_zone, included_in_price: included_in_price)
        end

        context "when the zone is the default zone" do
          let(:zone) { default_zone }

          context "when the tax is not a VAT" do
            it { is_expected.to eq([rate]) }
          end

          context "when the tax is a VAT" do
            let(:included_in_price) { true }

            it { is_expected.to eq([rate]) }
          end
        end

        context "when the zone is outside the default zone" do
          let(:zone) { create(:zone, :with_country) }

          it { is_expected.to be_empty }
        end
      end
    end
  end

  context ".adjust" do
    let(:zone) { stub_model(Spree::Zone) }
    let(:order) { stub_model(Spree::Order, tax_zone: zone) }
    let(:tax_category_1) { stub_model(Spree::TaxCategory) }
    let(:tax_category_2) { stub_model(Spree::TaxCategory) }
    let(:rate_1) { stub_model(Spree::TaxRate, tax_category: tax_category_1) }
    let(:rate_2) { stub_model(Spree::TaxRate, tax_category: tax_category_2) }

    context "with line items" do
      let(:line_item) do
        stub_model(Spree::LineItem,
          price: 10.0,
          quantity: 1,
          tax_category: tax_category_1,
          variant: stub_model(Spree::Variant),
          order: order
        )
      end

      let(:line_items) { [line_item] }

      before do
        allow(Spree::TaxRate).to receive(:for_zone).with(zone).and_return([rate_1, rate_2])
        allow(Spree::TaxRate).to receive(:for_zone).with(Spree::Zone.default_tax).and_return([])
        allow(order).to receive(:line_items).and_return([line_item])
      end

      it "should only apply adjustments for matching rates" do
        expect(rate_1).to receive(:adjust)
        expect(rate_2).not_to receive(:adjust)
        Spree::Tax::OrderAdjuster.new(order).adjust!
      end
    end

    context "with shipments" do
      let(:shipment) do
        stub_model(
          Spree::Shipment,
          cost: 10.0,
          tax_category: tax_category_1,
          order: order
        )
      end

      before do
        allow(Spree::TaxRate).to receive(:for_zone).with(zone).and_return([rate_1, rate_2])
        allow(Spree::TaxRate).to receive(:for_zone).with(Spree::Zone.default_tax).and_return([])
        allow(order).to receive(:shipments).and_return([shipment])
      end

      it "should apply adjustments for matching rates" do
        expect(rate_1).to receive(:adjust)
        expect(rate_2).not_to receive(:adjust)
        Spree::Tax::OrderAdjuster.new(order).adjust!
      end
    end
  end

  # While the above test is nice and fast - let me tell you a story or two here.
  context ".adjust" do
    let(:order) { create :order }
    let(:book_product) { create :product, price: 20, name: "Book", tax_category: books_category }
    let(:download_product) { create :product, price: 10, name: "Download", tax_category: digital_category }
    let(:sweater_product) { create :product, price: 30, name: "Download", tax_category: normal_category }
    let(:book) { book_product.master }
    let(:download) { download_product.master }
    let(:sweater) { sweater_product.master }
    let(:books_category) { create :tax_category, name: "Books" }
    let(:normal_category) { create :tax_category, name: "Normal" }
    let(:digital_category) { create :tax_category, name: "Digital Goods" }

    context 'selling from germany' do
      let(:germany) { create :country, iso: "DE" }
      # The weird default_tax boolean is what makes this context one with default included taxes
      let!(:germany_zone) { create :zone, countries: [germany], default_tax: true }
      let(:romania) { create(:country, iso: "RO") }
      let(:romania_zone) { create(:zone, countries: [romania] ) }
      let(:eu_zone) { create(:zone, countries: [romania, germany]) }
      let(:world_zone) { create(:zone, :with_country) }

      let!(:german_book_vat) do
        create(
          :tax_rate,
          included_in_price: true,
          amount: 0.07,
          tax_category: books_category,
          zone: eu_zone
        )
      end
      let!(:german_normal_vat) do
        create(
          :tax_rate,
          included_in_price: true,
          amount: 0.19,
          tax_category: normal_category,
          zone: eu_zone
        )
      end
      let!(:german_digital_vat) do
        create(
          :tax_rate,
          included_in_price: true,
          amount: 0.19,
          tax_category: digital_category,
          zone: germany_zone
        )
      end
      let!(:romanian_digital_vat) do
        create(
          :tax_rate,
          included_in_price: true,
          amount: 0.24,
          tax_category: digital_category,
          zone: romania_zone
        )
      end

      before do
        allow(order).to receive(:tax_zone) { tax_zone }
        order.contents.add(variant)
        Spree::Tax::OrderAdjuster.new(order).adjust!
      end

      let(:line_item) { order.line_items.first }

      context 'to germany' do
        let(:tax_zone) { germany_zone }

        context 'an order with a book' do
          let(:variant) { book }

          it 'still has the original price' do
            expect(line_item.price).to eq(20)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 1.13 cents of included tax' do
            expect(line_item.included_tax_total).to eq(1.31)
          end
        end

        context 'an order with a sweater' do
          let(:variant) { sweater }

          it 'still has the original price' do
            expect(line_item.price).to eq(30)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 4,78 of included tax' do
            expect(line_item.included_tax_total).to eq(4.79)
          end
        end

        context 'an order with a download' do
          let(:variant) { download }

          it 'still has the original price' do
            expect(line_item.price).to eq(10)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 1.60 of included tax' do
            expect(line_item.included_tax_total).to eq(1.60)
          end
        end
      end

      context 'to romania' do
        let(:tax_zone) { romania_zone }

        context 'an order with a book' do
          let(:variant) { book }

          it 'still has the original price' do
            expect(line_item.price).to eq(20)
          end

          it 'is adjusted to the original price' do
            expect(line_item.total).to eq(20)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 1.13 cents of included tax' do
            expect(line_item.included_tax_total).to eq(1.31)
          end

          it 'has a constant amount pre tax' do
            expect(line_item.pre_tax_amount).to eq(18.69)
          end
        end

        context 'an order with a sweater' do
          let(:variant) { sweater }

          it 'still has the original price' do
            expect(line_item.price).to eq(30)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 4.79 of included tax' do
            expect(line_item.included_tax_total).to eq(4.79)
          end

          it 'has a constant amount pre tax' do
            expect(line_item.pre_tax_amount).to eq(25.21)
          end
        end

        context 'an order with a download' do
          let(:variant) { download }

          it 'still has an adjusted price for romania' do
            pending "waiting for the MOSS refactoring"
            expect(line_item.price).to eq(10.42)
          end

          it 'has one tax adjustment' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has 2.02 of included tax' do
            pending 'waiting for the MOSS refactoring'
            expect(line_item.included_tax_total).to eq(2.02)
          end

          it 'has a constant amount pre tax' do
            pending 'but it changes to 8.06, because Spree thinks both VATs apply'
            expect(line_item.pre_tax_amount).to eq(8.40)
          end
        end
      end

      # International delivery, no tax applies whatsoever
      context 'to anywhere else in the world' do
        let(:tax_zone) { world_zone }

        context 'an order with a book' do
          let(:variant) { book }

          it 'should sell at the net price' do
            pending "Prices have to be adjusted"
            expect(line_item.price).to eq(18.69)
          end

          it 'is adjusted to the net price' do
            expect(line_item.total).to eq(18.69)
          end

          it 'has no tax adjustments' do
            pending "Right now it gets a refund"
            expect(line_item.adjustments.tax.count).to eq(0)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has no additional tax' do
            pending 'but there is a refund, still'
            expect(line_item.additional_tax_total).to eq(0)
          end

          it 'has a constant amount pre tax' do
            expect(line_item.pre_tax_amount).to eq(18.69)
          end
        end

        context 'an order with a sweater' do
          let(:variant) { sweater }

          it 'should sell at the net price' do
            pending 'but prices are not adjusted according to the zone yet'
            expect(line_item.price).to eq(25.21)
          end

          it 'has no tax adjustments' do
            pending 'but it has a refund'
            expect(line_item.adjustments.tax.count).to eq(0)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has no additional tax' do
            pending 'but it has a refund for included taxes wtf'
            expect(line_item.additional_tax_total).to eq(0)
          end

          it 'has a constant amount pre tax' do
            expect(line_item.pre_tax_amount).to eq(25.21)
          end
        end

        context 'an order with a download' do
          let(:variant) { download }

          it 'should sell at the net price' do
            pending 'but prices are not adjusted yet'
            expect(line_item.price).to eq(8.40)
          end

          it 'has no tax adjustments' do
            pending 'but a refund is created'
            expect(line_item.adjustments.tax.count).to eq(0)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has no additional tax' do
            pending 'but an tax refund that disguises as additional tax is created'
            expect(line_item.additional_tax_total).to eq(0)
          end

          it 'has a constant amount pre tax' do
            expect(line_item.pre_tax_amount).to eq(8.40)
          end
        end
      end
    end

    # Choosing New York here because in the US, states matter
    context 'selling from new york' do
      let(:new_york) { create(:state) }
      let(:united_states) { create(:country, states: [new_york]) }
      let(:new_york_zone) { create(:zone, states: [new_york]) }
      let(:unites_states_zone) { create(:zone, countries: [united_states]) }
      # Creating two rates for books here to
      # mimick the existing specs
      let!(:new_york_books_tax) do
        create(
          :tax_rate,
          tax_category: books_category,
          zone: new_york_zone,
          included_in_price: false,
          amount: 0.05
        )
      end

      let!(:federal_books_tax) do
        create(
          :tax_rate,
          tax_category: books_category,
          zone: unites_states_zone,
          included_in_price: false,
          amount: 0.10
        )
      end

      let!(:federal_digital_tax) do
        create(
          :tax_rate,
          tax_category: digital_category,
          zone: unites_states_zone,
          included_in_price: false,
          amount: 0.20
        )
      end

      before do
        allow(order).to receive(:tax_zone) { tax_zone }
        order.contents.add(variant)
        Spree::Tax::OrderAdjuster.new(order).adjust!
      end

      let(:line_item) { order.line_items.first }

      context 'to new york' do
        let(:tax_zone) { new_york_zone }

        # A fictional case for an item with two applicable rates
        context 'an order with a book' do
          let(:variant) { book }

          it 'still has the original price' do
            expect(line_item.price).to eq(20)
          end

          it 'sells for the line items amount plus additional tax' do
            expect(line_item.total).to eq(23)
          end

          it 'has two tax adjustments' do
            expect(line_item.adjustments.tax.count).to eq(2)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has 15% additional tax' do
            expect(line_item.additional_tax_total).to eq(3)
          end

          it "should delete adjustments for open order when taxrate is deleted" do
            new_york_books_tax.destroy!
            federal_books_tax.destroy!
            expect(line_item.adjustments.count).to eq(0)
          end

          it "should not delete adjustments for complete order when taxrate is deleted" do
            order.update_column :completed_at, Time.now
            new_york_books_tax.destroy!
            federal_books_tax.destroy!
            expect(line_item.adjustments.count).to eq(2)
          end
        end

        # This is a fictional case for when no taxes apply at all.
        context 'an order with a sweater' do
          let(:variant) { sweater }

          it 'still has the original price' do
            expect(line_item.price).to eq(30)
          end

          it 'sells for the line items amount plus additional tax' do
            expect(line_item.total).to eq(30)
          end

          it 'has no tax adjustments' do
            expect(line_item.adjustments.tax.count).to eq(0)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has no additional tax' do
            expect(line_item.additional_tax_total).to eq(0)
          end
        end

        # A fictional case with one applicable rate
        context 'an order with a download' do
          let(:variant) { download }

          it 'still has the original price' do
            expect(line_item.price).to eq(10)
          end

          it 'sells for the line items amount plus additional tax' do
            expect(line_item.total).to eq(12)
          end

          it 'has one tax adjustments' do
            expect(line_item.adjustments.tax.count).to eq(1)
          end

          it 'has no included tax' do
            expect(line_item.included_tax_total).to eq(0)
          end

          it 'has 15% additional tax' do
            expect(line_item.additional_tax_total).to eq(2)
          end
        end
      end

      context 'when no tax zone is given' do
        let(:tax_zone) { nil }

        context 'and we buy a book' do
          let(:variant) { book }

          it 'does not create adjustments' do
            expect(line_item.adjustments.count).to eq(0)
          end
        end
      end
    end
  end
end
