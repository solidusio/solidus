require 'spec_helper'

describe Spree::PriceMigrator do
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

  let!(:book) { book_product.master }
  let!(:download) { download_product.master }
  let!(:sweater) { sweater_product.master }

  let(:books_category) { create :tax_category, name: "Books" }
  let(:normal_category) { create :tax_category, name: "Normal" }
  let(:digital_category) { create :tax_category, name: "Digital Goods" }

  let(:books_shipping_category) { create :shipping_category, name: "Book Shipping" }
  let(:normal_shipping_category) { create :shipping_category, name: "Normal Shipping" }
  let(:digital_shipping_category) { create :shipping_category, name: "Digital Premium Download" }

  let(:line_item) { order.line_items.first }
  let(:shipment) { order.shipments.first }
  let(:shipping_rate) { shipment.shipping_rates.first }

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
        name: "German reduced VAT",
        included_in_price: true,
        amount: 0.07,
        tax_category: books_category,
        zone: eu_zone
      )
    end
    let!(:german_normal_vat) do
      create(
        :tax_rate,
        name: "German VAT",
        included_in_price: true,
        amount: 0.19,
        tax_category: normal_category,
        zone: eu_zone
      )
    end
    let!(:german_digital_vat) do
      create(
        :tax_rate,
        name: "German VAT",
        included_in_price: true,
        amount: 0.19,
        tax_category: digital_category,
        zone: germany_zone
      )
    end
    let!(:romanian_digital_vat) do
      create(
        :tax_rate,
        name: "Romanian VAT",
        included_in_price: true,
        amount: 0.24,
        tax_category: digital_category,
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
      Spree::PriceMigrator.migrate_default_vat_prices
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(18.69)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(25.21)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(8.40)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(18.69)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(18.69)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(25.21)
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
          expect(line_item.discounted_amount - line_item.included_tax_total).to eq(8.40)
        end
      end
    end
  end
end
