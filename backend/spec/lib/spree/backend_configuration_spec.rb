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
        expect(stock_menu_item.match_path).to eq(%r{/(stock_items)})
      end
    end

    describe 'menu tab for settings' do
      let(:menu_item) { subject.find { |item| item.label == :settings } }
      let(:view) { double("view") }

      describe '#render_in?' do
        it 'is shown if any of its submenus are present' do
          allow(view).to receive(:can?).and_return(true, false)

          expect(menu_item.render_in?(view)).to eq(true)
        end

        it 'is not shown if none of its submenus are present' do
          expect(view).to receive(:can?).exactly(13).times.and_return(false)

          expect(menu_item.render_in?(view)).to eq(false)
        end
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

  describe '#theme_path' do
    it 'returns the default theme path' do
      subject.themes = { foo: 'foo-theme-path' }
      subject.theme = :foo

      expect(subject.theme_path).to eq('foo-theme-path')
    end

    it 'returns the default theme path when the theme is a string' do
      subject.themes = { foo: 'foo-theme-path' }
      subject.theme = 'foo'

      expect(subject.theme_path).to eq('foo-theme-path')
    end

    it 'returns the fallback theme path when the default theme is missing' do
      subject.themes = { foo: 'foo-theme-path', classic: 'classic-theme-path' }
      subject.theme = :bar

      expect{ subject.theme_path }.to raise_error(KeyError)
    end

    it 'gives priority to the user defined theme' do
      subject.themes = { foo: 'foo-theme-path', user: 'user-theme-path' }
      subject.theme = :foo

      expect(subject.theme_path(:user)).to eq('user-theme-path')
    end

    it 'raises an error if the user theme is missing' do
      subject.themes = { foo: 'foo-theme-path', classic: 'classic-theme-path' }
      subject.theme = :foo

      expect{ subject.theme_path(:bar) }.to raise_error(KeyError)
    end
  end

  describe "deprecated behavior" do
    describe "loading *_TABS constants" do
      it "warns about the deprecation" do
        expect(Spree::Deprecation).to receive(:warn).with(a_string_matching(/Spree::BackendConfiguration::\*_TABS is deprecated\./))

        described_class::ORDER_TABS
      end
    end
  end
end
