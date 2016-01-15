# encoding: utf-8

require 'spec_helper'

module Spree
  describe ProductsHelper, type: :helper do
    include ProductsHelper

    let(:product) { create(:product) }
    let(:currency) { 'USD' }

    before do
      allow(helper).to receive(:current_currency) { currency }
    end

    context "#product_description" do
      # Regression test for https://github.com/spree/spree/issues/1607
      it "renders a product description without excessive paragraph breaks" do
        product.description = %Q{
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
        product.description = %Q{
THIS IS THE BEST PRODUCT EVER!

"IT CHANGED MY LIFE" - Sue, MD}

        description = product_description(product)
        expect(description.strip).to eq(%Q{<p>\nTHIS IS THE BEST PRODUCT EVER!</p>"IT CHANGED MY LIFE" - Sue, MD})
      end

      it "renders a product description without any formatting based on configuration" do
        initialDescription = %Q{
            <p>hello world</p>

            <p>tihs is completely awesome and it works</p>

            <p>why so many spaces in the code. and why some more formatting afterwards?</p>
        }

        product.description = initialDescription

        Spree::Config[:show_raw_product_description] = true
        description = product_description(product)
        expect(description).to eq(initialDescription)
      end

    end

    context '#line_item_description_text' do
      subject { line_item_description_text description }
      context 'variant has a blank description' do
        let(:description) { nil }
        it { is_expected.to eq(Spree.t(:product_has_no_description)) }
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
        allow(helper).to receive(:params) { {page: 10} }
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
          allow(@products).to receive(:count) { 1234567 }
          allow(@products).to receive(:maximum).with(:updated_at) { nil }
          allow(Date).to receive(:today) { today }
        end

        it { is_expected.to eq('en/USD/spree/products/all-10-20131211-1234567') }
      end
    end

    # Regression test for https://github.com/spree/spree/issues/2518 and https://github.com/spree/spree/issues/2323
    it "truncates HTML correctly in product description" do
      product = double(description: "<strong>" + ("a" * 95) + "</strong> This content is invisible.")
      expected = "<strong>" + ("a" * 95) + "</strong>..."
      expect(truncated_product_description(product)).to eq(expected)
    end
  end
end
