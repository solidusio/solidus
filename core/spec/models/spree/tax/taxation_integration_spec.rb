# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Taxation system integration tests" do
  let(:order) { create :order, ship_address: shipping_address, state: "delivery" }
  let(:book_product) do
    create :product,
           price: 20,
           name: "Book",
           tax_category: books_category,
           shipping_category: books_shipping_category
  end
  let(:download_product) do
    create :product,
           price: 10,
           name: "Download",
           tax_category: digital_category,
           shipping_category: digital_shipping_category
  end
  let(:sweater_product) do
    create :product,
           price: 30,
           name: "Download",
           tax_category: normal_category,
           shipping_category: normal_shipping_category
  end
  let(:fruit_product) do
    create :product,
      price: 5,
      name: "Food",
      tax_category: fruit_category,
      shipping_category: normal_shipping_category
  end

  let(:book) { book_product.master }
  let(:download) { download_product.master }
  let(:sweater) { sweater_product.master }
  let(:fruit) { fruit_product.master }

  let(:books_category) { create :tax_category, name: "Books" }
  let(:normal_category) { create :tax_category, name: "Normal" }
  let(:digital_category) { create :tax_category, name: "Digital Goods" }
  let(:fruit_category) { create :tax_category, name: "Fruit Product" }
  let(:milk_category) { create :tax_category, name: "Milk Product" }

  let(:books_shipping_category) { create :shipping_category, name: "Book Shipping" }
  let(:normal_shipping_category) { create :shipping_category, name: "Normal Shipping" }
  let(:digital_shipping_category) { create :shipping_category, name: "Digital Premium Download" }

  let(:line_item) { order.line_items.first }
  let(:shipment) { order.shipments.first }
  let(:shipping_rate) { shipment.shipping_rates.first }

  context 'selling from germany' do
    let(:germany) { create :country, iso: "DE" }
    let!(:germany_zone) { create :zone, countries: [germany] }
    let(:romania) { create(:country, iso: "RO") }
    let(:romania_zone) { create(:zone, countries: [romania] ) }
    let(:eu_zone) { create(:zone, countries: [romania, germany]) }
    let(:world_zone) { create(:zone, :with_country) }

    let!(:german_book_vat) do
      create(
        :tax_rate,
        name: "German reduced VAT",
        included_in_price: true,
        amount: 0.07,
        tax_categories: [books_category],
        zone: eu_zone
      )
    end
    let!(:german_normal_vat) do
      create(
        :tax_rate,
        name: "German VAT",
        included_in_price: true,
        amount: 0.19,
        tax_categories: [normal_category],
        zone: eu_zone
      )
    end
    let!(:german_digital_vat) do
      create(
        :tax_rate,
        name: "German VAT",
        included_in_price: true,
        amount: 0.19,
        tax_categories: [digital_category],
        zone: germany_zone
      )
    end
    let!(:german_food_vat) do
      create(
        :tax_rate,
        name: "German Food VAT",
        included_in_price: true,
        amount: 0.09,
        tax_categories: [fruit_category, milk_category],
        zone: germany_zone
      )
    end
    let!(:romanian_digital_vat) do
      create(
        :tax_rate,
        name: "Romanian VAT",
        included_in_price: true,
        amount: 0.24,
        tax_categories: [digital_category],
        zone: romania_zone
      )
    end
    let!(:book_shipping_method) do
      create :shipping_method,
             cost: 8.00,
             shipping_categories: [books_shipping_category],
             tax_category: books_category,
             zones: [eu_zone, world_zone]
    end

    let!(:sweater_shipping_method) do
      create :shipping_method,
             cost: 16.00,
             shipping_categories: [normal_shipping_category],
             tax_category: normal_category,
             zones: [eu_zone, world_zone]
    end

    let!(:premium_download_shipping_method) do
      create :shipping_method,
             cost: 2.00,
             shipping_categories: [digital_shipping_category],
             tax_category: digital_category,
             zones: [eu_zone, world_zone]
    end

    before do
      stub_spree_preferences(admin_vat_country_iso: "DE")
      order.contents.add(variant)
    end

    context 'to germany' do
      let(:shipping_address) { create :address, country_iso_code: "DE" }

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

      context 'an order with a book and a shipment' do
        let(:variant) { book }

        before { 2.times { order.next! } }

        it 'has a shipment for 8.00 dollars' do
          expect(shipment.amount).to eq(8.00)
        end

        it 'has a shipment with 0.52 included tax' do
          expect(shipment.included_tax_total).to eq(0.52)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$8.00 (incl. $0.52 German reduced VAT)")
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

      context 'an order with a sweater and a shipment' do
        let(:variant) { sweater }

        before { 2.times { order.next! } }

        it 'has a shipment for 16.00 dollars' do
          expect(shipment.amount).to eq(16.00)
        end

        it 'has a shipment with 2.55 included tax' do
          expect(shipment.included_tax_total).to eq(2.55)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$16.00 (incl. $2.55 German VAT)")
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

      context 'an order with a download and a shipment' do
        let(:variant) { download }

        before { 2.times { order.next! } }

        it 'has a shipment for 4.00 dollars' do
          expect(shipment.amount).to eq(2.00)
        end

        it 'has a shipment with 0.64 included tax' do
          expect(shipment.included_tax_total).to eq(0.32)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$2.00 (incl. $0.32 German VAT)")
        end
      end

      context 'an order containg a fruit' do
        let(:variant) { fruit }

        it 'still has the original price' do
          expect(line_item.price).to eq(5)
        end

        it 'has one tax adjustment' do
          expect(line_item.adjustments.tax.count).to eq(1)
        end

        it 'has 0.45 of included tax' do
          expect(line_item.included_tax_total).to eq(0.41)
        end
      end
    end

    context 'to romania' do
      let(:shipping_address) { create :address, country_iso_code: "RO" }

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
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(18.69)
        end
      end

      context 'an order with a book and a shipment' do
        let(:variant) { book }

        before { 2.times { order.next! } }

        it 'has a shipment for 8.00 dollars' do
          expect(shipment.amount).to eq(8.00)
        end

        it 'has a shipment with 0.52 included tax' do
          expect(shipment.included_tax_total).to eq(0.52)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$8.00 (incl. $0.52 German reduced VAT)")
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
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(25.21)
        end
      end

      context 'an order with a sweater and a shipment' do
        let(:variant) { sweater }

        before { 2.times { order.next! } }

        it 'has a shipment for 16.00 dollars' do
          expect(shipment.amount).to eq(16.00)
        end

        it 'has a shipment with 2.55 included tax' do
          expect(shipment.included_tax_total).to eq(2.55)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$16.00 (incl. $2.55 German VAT)")
        end
      end

      context 'an order with a download' do
        let(:variant) { download }

        it 'still has an adjusted price for romania' do
          expect(line_item.price).to eq(10.42)
        end

        it 'has one tax adjustment' do
          expect(line_item.adjustments.tax.count).to eq(1)
        end

        it 'has 2.02 of included tax' do
          expect(line_item.included_tax_total).to eq(2.02)
        end

        it 'has a constant amount pre tax' do
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(8.40)
        end
      end

      context 'an order with a download and a shipment' do
        let(:variant) { download }

        before { 2.times { order.next! } }

        it 'it has a shipment with worth 2.00' do
          expect(shipment.amount).to eq(2.00)
        end

        it 'has a shipment with 0.40 included tax' do
          expect(shipment.included_tax_total).to eq(0.39)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$2.00 (incl. $0.39 Romanian VAT)")
        end
      end
    end
    # Technically, this can't be the case yet as the order won't pass the shipment stage,
    # but the taxation code shouldn't implicitly depend on the shipping code.
    context 'to an address that does not have a zone associated' do
      let(:shipping_address) { create :address, country_iso_code: "IT" }

      context 'an order with a book' do
        let(:variant) { book }

        it 'should sell at the net price' do
          expect(line_item.price).to eq(18.69)
        end

        it 'is adjusted to the net price' do
          expect(line_item.total).to eq(18.69)
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

        it 'has a constant amount pre tax' do
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(18.69)
        end
      end
    end

    # International delivery, no tax applies whatsoever
    context 'to anywhere else in the world' do
      let(:shipping_address) { create :address, country: world_zone.countries.first }

      context 'an order with a book' do
        let(:variant) { book }

        it 'should sell at the net price' do
          expect(line_item.price).to eq(18.69)
        end

        it 'is adjusted to the net price' do
          expect(line_item.total).to eq(18.69)
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

        it 'has a constant amount pre tax' do
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(18.69)
        end

        context 'an order with a book and a shipment' do
          let(:variant) { book }

          before { 2.times { order.next! } }

          it 'it has a shipment that costs $8.00' do
            expect(shipment.amount).to eq(8.00)
          end

          it 'has a shipment with no included tax' do
            expect(shipment.included_tax_total).to eq(0)
          end

          it 'has a shipping rate that correctly reflects the shipment' do
            expect(shipping_rate.display_price).to eq("$8.00")
          end
        end
      end

      context 'an order with a sweater' do
        let(:variant) { sweater }

        it 'should sell at the net price' do
          expect(line_item.price).to eq(25.21)
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

        it 'has a constant amount pre tax' do
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(25.21)
        end

        context 'an order with a sweater and a shipment' do
          let(:variant) { sweater }

          before { 2.times { order.next! } }

          it 'it has a shipment costing $16.00' do
            expect(shipment.amount).to eq(16.00)
          end

          it 'has a shipment with no included tax' do
            expect(shipment.included_tax_total).to eq(0)
          end

          it 'has a shipping rate that correctly reflects the shipment' do
            expect(shipping_rate.display_price).to eq("$16.00")
          end
        end
      end

      context 'an order with a download' do
        let(:variant) { download }

        it 'should sell at the net price' do
          expect(line_item.price).to eq(8.40)
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

        it 'has a constant amount pre tax' do
          expect(line_item.total_before_tax - line_item.included_tax_total).to eq(8.40)
        end
      end

      context 'an order with a download and a shipment' do
        let(:variant) { download }

        before { 2.times { order.next! } }

        it 'it has a shipment costing 2.00' do
          expect(shipment.amount).to eq(2.00)
        end

        it 'has a shipment with no included tax' do
          expect(shipment.included_tax_total).to eq(0)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$2.00")
        end
      end
    end
  end

  # Choosing New York here because in the US, states matter
  context 'selling from new york' do
    let(:new_york) { create(:state, state_code: "NY") }
    let(:united_states) { new_york.country }
    let(:new_york_zone) { create(:zone, states: [new_york]) }
    let(:united_states_zone) { create(:zone, countries: [united_states]) }
    # Creating two rates for books here to
    # mimick the existing specs
    let!(:new_york_books_tax) do
      create(
        :tax_rate,
        name: "New York Sales Tax",
        tax_categories: [books_category],
        zone: new_york_zone,
        included_in_price: false,
        amount: 0.05
      )
    end

    let!(:federal_books_tax) do
      create(
        :tax_rate,
        name: "Federal Sales Tax",
        tax_categories: [books_category],
        zone: united_states_zone,
        included_in_price: false,
        amount: 0.10
      )
    end

    let!(:federal_digital_tax) do
      create(
        :tax_rate,
        name: "Federal Sales Tax",
        tax_categories: [digital_category],
        zone: united_states_zone,
        included_in_price: false,
        amount: 0.20
      )
    end

    let!(:book_shipping_method) do
      create :shipping_method,
             cost: 8.00,
             shipping_categories: [books_shipping_category],
             tax_category: books_category,
             zones: [united_states_zone]
    end

    let!(:sweater_shipping_method) do
      create :shipping_method,
             cost: 16.00,
             shipping_categories: [normal_shipping_category],
             tax_category: normal_category,
             zones: [united_states_zone]
    end

    let!(:premium_download_shipping_method) do
      create :shipping_method,
             cost: 2.00,
             shipping_categories: [digital_shipping_category],
             tax_category: digital_category,
             zones: [united_states_zone]
    end

    before do
      order.contents.add(variant)
    end

    context 'to new york' do
      let(:shipping_address) { create :address, state_code: "NY" }

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

        it "should delete adjustments for open order when taxrate is soft-deleted" do
          new_york_books_tax.discard
          federal_books_tax.discard
          expect(line_item.adjustments.count).to eq(0)
        end

        it "should not delete adjustments for complete order when taxrate is soft-deleted" do
          order.update_column :completed_at, Time.now
          new_york_books_tax.discard
          federal_books_tax.discard
          expect(line_item.adjustments.count).to eq(2)
        end

        context 'when tax address is later cleared' do
          before do
            order.ship_address = nil
            order.recalculate
          end

          it 'removes all tax adjustments' do
            aggregate_failures do
              expect(line_item.adjustments.tax.count).to eq(0)
              expect(line_item).to have_attributes(
                price: 20,
                total: 20,
                included_tax_total: 0,
                additional_tax_total: 0
              )
            end
          end
        end
      end

      context 'an order with a book and a shipment' do
        let(:variant) { book }

        before { 2.times { order.next! } }

        it 'it has a shipment with a price of 8.00' do
          expect(shipment.amount).to eq(8.00)
        end

        it 'has a shipment with no included tax' do
          expect(shipment.included_tax_total).to eq(0)
        end

        it 'has a shipment with additional tax of 1.20' do
          expect(shipment.additional_tax_total).to eq(1.20)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to include("$8.00")
          expect(shipping_rate.display_price).to include("+ $0.80 Federal Sales Tax")
          expect(shipping_rate.display_price).to include("+ $0.40 New York Sales Tax")
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

      context 'an order with a sweater and a shipment' do
        let(:variant) { sweater }

        before { 2.times { order.next! } }

        it 'it has a shipment with a price of 16.00' do
          expect(shipment.amount).to eq(16.00)
        end

        it 'has a shipment with no included tax' do
          expect(shipment.included_tax_total).to eq(0)
        end

        it 'has a shipment with no additional tax' do
          expect(shipment.additional_tax_total).to eq(0)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$16.00")
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

      context 'an order with a download and a shipment' do
        let(:variant) { download }

        before { 2.times { order.next! } }

        it 'it has a shipment with a price of 2.00' do
          expect(shipment.amount).to eq(2.00)
        end

        it 'has a shipment with no included tax' do
          expect(shipment.included_tax_total).to eq(0)
        end

        it 'has a shipment with additional tax of 0.40' do
          expect(shipment.additional_tax_total).to eq(0.40)
        end

        it 'has a shipping rate that correctly reflects the shipment' do
          expect(shipping_rate.display_price).to eq("$2.00 (+ $0.40 Federal Sales Tax)")
        end
      end
    end

    context 'when no tax zone is given' do
      let(:shipping_address) { nil }

      context 'and we buy a book' do
        let(:variant) { book }

        it 'does not create adjustments' do
          expect(line_item.adjustments.count).to eq(0)
        end
      end
    end
  end
end
