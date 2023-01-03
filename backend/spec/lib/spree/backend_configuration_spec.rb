# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::BackendConfiguration do
  describe '#menu_items' do
    subject do
      described_class.new.menu_items
    end

    describe 'menu tab for stock items' do
      let(:stock_menu_item) do
        subject.detect { |item| item.label == :stock }
      end

      # Regression for https://github.com/solidusio/solidus/issues/2950
      it 'has match_path set to /stock_items' do
        expect(stock_menu_item.match_path).to eq('/stock_items')
      end
    end

    describe 'menu tab for settings' do
      let(:menu_item) { subject.find { |item| item.label == :settings } }
      let(:view) { double("view") }

      it 'is shown if any of its submenus are present' do
        allow(view).to receive(:can?).and_return(true, false)

        result = view.instance_exec(&menu_item.condition)

        expect(result).to eq(true)
      end

      it 'is not shown if none of its submenus are present' do
        expect(view).to receive(:can?).exactly(12).times.and_return(false)

        result = view.instance_exec(&menu_item.condition)

        expect(result).to eq(false)
      end
    end
  end

  describe '#frontend_product_path' do
    let(:configuration) { described_class.new }
    let(:spree_routes) { double('spree_routes') }
    let(:template_context) { double('template_context', spree: spree_routes) }
    let(:product) { instance_double('Spree::Product', id: 1) }

    subject(:frontend_product_path) do
      configuration.frontend_product_path.call(template_context, product)
    end

    context 'by default' do
      context 'when there is no product path route' do
        before do
          expect(:spree_routes).to_not respond_to(:product_path)
        end

        it { is_expected.to be_nil }
      end

      context 'when there is a product path route' do
        let(:expected_path) { "/products/#{product.id}" }

        let(:spree_routes_class) do
          Class.new do
            def product_path(product)
              "/products/#{product.id}"
            end
          end
        end

        let(:spree_routes) { spree_routes_class.new }

        it 'returns the product path' do
          expect(frontend_product_path).to eq("/products/#{product.id}")
        end
      end
    end
  end
end

