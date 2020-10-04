# frozen_string_literal: true

require 'rails_helper'

module Spree
  RSpec.describe ProductsHelper, type: :helper do
    include ProductsHelper

    let(:product) { create(:product, price: product_price) }
    let(:product_price) { 10 }
    let(:variant) { create(:variant, product: product, price: variant_price) }
    let(:currency) { 'USD' }
    let(:pricing_options) do
      Spree::Config.pricing_options_class.new(currency: currency)
    end

    before do
      without_partial_double_verification do
        allow(helper).to receive(:current_pricing_options) { pricing_options }
      end
    end

    context "#variant_price_diff" do
      let(:variant_price) { 10 }

      subject { helper.variant_price(variant) }

      context "when variant is same as master" do
        it { is_expected.to be_nil }
      end

      context "when currency is default" do
        context "when variant is more than master" do
          let(:variant_price) { 15 }

          it { is_expected.to eq("(Add: <span class=\"money-currency-symbol\">$</span><span class=\"money-whole\">5</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span>)") }
          # Regression test for https://github.com/spree/spree/issues/2737
          it { is_expected.to be_html_safe }
        end

        context "when variant is less than master" do
          let(:product_price) { 15 }

          it { is_expected.to eq("(Subtract: <span class=\"money-currency-symbol\">$</span><span class=\"money-whole\">5</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span>)") }
        end
      end

      context "when currency is JPY" do
        let(:variant_price) { 100 }
        let(:product_price) { 100 }
        let(:currency) { 'JPY' }

        before do
          variant
          product.prices.update_all(currency: currency)
        end

        context "when variant is more than master" do
          let(:variant_price) { 150 }

          it { is_expected.to eq("(Add: <span class=\"money-currency-symbol\">&#x00A5;</span><span class=\"money-whole\">50</span>)") }
        end

        context "when variant is less than master" do
          let(:product_price) { 150 }

          it { is_expected.to eq("(Subtract: <span class=\"money-currency-symbol\">&#x00A5;</span><span class=\"money-whole\">50</span>)") }
        end
      end
    end

    context "#variant_price_full" do
      let!(:variant_2) { create(:variant, product: product, price: variant_2_price) }
      let(:variant_2_price) { 20 }
      let(:variant_price) { 15 }

      before do
        stub_spree_preferences(show_variant_full_price: true)
        variant
      end

      context "when currency is default" do
        it "should return the variant price if the price is different than master" do
          expect(helper.variant_price(variant)).to eq("<span class=\"money-currency-symbol\">$</span><span class=\"money-whole\">15</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span>")
          expect(helper.variant_price(variant_2)).to eq("<span class=\"money-currency-symbol\">$</span><span class=\"money-whole\">20</span><span class=\"money-decimal-mark\">.</span><span class=\"money-decimal\">00</span>")
        end
      end

      context "when currency is JPY" do
        let(:currency) { 'JPY' }
        let(:product_price) { 100 }
        let(:variant_price) { 150 }

        before do
          variant
          product.prices.update_all(currency: currency)
        end

        it "should return the variant price if the price is different than master" do
          expect(helper.variant_price(variant)).to eq("<span class=\"money-currency-symbol\">&#x00A5;</span><span class=\"money-whole\">150</span>")
        end
      end

      context "when all variant prices are equal" do
        let(:product_price) { 10 }
        let(:variant_price) { 10 }
        let(:variant_2_price) { 10 }

        it "should be nil" do
          expect(helper.variant_price(variant)).to be_nil
          expect(helper.variant_price(variant_2)).to be_nil
        end
      end
    end

    context "#product_description" do
      # Regression test for https://github.com/spree/spree/issues/1607
      it "renders a product description without excessive paragraph breaks" do
        product.description = %{
<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus a ligula leo. Proin eu arcu at ipsum dapibus ullamcorper. Pellentesque egestas orci nec magna condimentum luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Ut ac ante et mauris bibendum ultricies non sed massa. Fusce facilisis dui eget lacus scelerisque eget aliquam urna ultricies. Duis et rhoncus quam. Praesent tellus nisi, ultrices sed iaculis quis, euismod interdum ipsum.</p>
<ul>
<li>Lorem ipsum dolor sit amet</li>
<li>Lorem ipsum dolor sit amet</li>
</ul>
        }
        description = product_description(product)
        expect(description.strip).to eq(product.description.strip)
      end

      it "renders a product description with automatic paragraph breaks" do
        product.description = %{
THIS IS THE BEST PRODUCT EVER!

"IT CHANGED MY LIFE" - Sue, MD}

        description = product_description(product)
        expect(description.strip).to eq(%{<p>\nTHIS IS THE BEST PRODUCT EVER!</p>"IT CHANGED MY LIFE" - Sue, MD})
      end

      it "renders a product description without any formatting based on configuration" do
        description = %{
            <p>hello world</p>

            <p>tihs is completely awesome and it works</p>

            <p>why so many spaces in the code. and why some more formatting afterwards?</p>
        }

        product.description = description

        stub_spree_preferences(show_raw_product_description: true)
        description = product_description(product)
        expect(description).to eq(description)
      end
    end

    context '#line_item_description_text' do
      subject { line_item_description_text description }
      context 'variant has a blank description' do
        let(:description) { nil }
        it { is_expected.to eq(I18n.t('spree.product_has_no_description')) }
      end
      context 'variant has a description' do
        let(:description) { 'test_desc' }
        it { is_expected.to eq(description) }
      end
      context 'description has nonbreaking spaces' do
        let(:description) { 'test&nbsp;desc' }
        it { is_expected.to eq('test desc') }
      end
    end

    context '#cache_key_for_products' do
      subject { helper.cache_key_for_products }
      before(:each) do
        @products = double('products collection')
        allow(helper).to receive(:params) { { page: 10 } }
      end

      context 'when there is a maximum updated date' do
        let(:updated_at) { Date.new(2011, 12, 13) }
        before :each do
          allow(@products).to receive(:count) { 5 }
          allow(@products).to receive(:maximum).with(:updated_at) { updated_at }
        end

        it { is_expected.to eq('en/USD/spree/products/all-10-20111213-5') }
      end

      context 'when there is no considered maximum updated date' do
        let(:today) { Date.new(2013, 12, 11) }
        before :each do
          allow(@products).to receive(:count) { 1_234_567 }
          allow(@products).to receive(:maximum).with(:updated_at) { nil }
          allow(Date).to receive(:today) { today }
        end

        it { is_expected.to eq('en/USD/spree/products/all-10-20131211-1234567') }
      end
    end
  end
end
