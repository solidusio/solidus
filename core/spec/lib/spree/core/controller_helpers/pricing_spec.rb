# frozen_string_literal: true

require 'rails_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Pricing
end

RSpec.describe Spree::Core::ControllerHelpers::Pricing, type: :controller do
  controller(FakesController) {}

  before do
    allow(controller).to receive(:current_store).and_return(store)
  end

  describe '#current_currency' do
    subject { controller.current_currency }

    context "when store default_currency is nil" do
      let(:store) { nil }
      it { Spree::Deprecation.silence { is_expected.to eq('USD') } }
    end

    context "when the current store default_currency empty" do
      let(:store) { FactoryBot.create :store, default_currency: '' }

      it { Spree::Deprecation.silence { is_expected.to eq('USD') } }
    end

    context "when the current store default_currency is a currency" do
      let(:store) { FactoryBot.create :store, default_currency: 'EUR' }

      it { Spree::Deprecation.silence { is_expected.to eq('EUR') } }
    end
  end

  describe '#current_pricing_options' do
    subject { controller.current_pricing_options }

    let(:store) { FactoryBot.create(:store, default_currency: nil) }

    it { is_expected.to be_a(Spree::Config.pricing_options_class) }

    context "currency" do
      subject { controller.current_pricing_options.currency }

      context "when store default_currency is nil" do
        let(:store) { nil }
        it { is_expected.to eq('USD') }
      end

      context "when the current store default_currency empty" do
        let(:store) { FactoryBot.create :store, default_currency: '' }

        it { is_expected.to eq('USD') }
      end

      context "when the current store default_currency is a currency" do
        let(:store) { FactoryBot.create :store, default_currency: 'EUR' }

        it { is_expected.to eq('EUR') }
      end
    end

    context "country_iso" do
      subject { controller.current_pricing_options.country_iso }

      let(:store) { FactoryBot.create(:store, cart_tax_country_iso: cart_tax_country_iso) }

      context "when the store has a cart tax country set" do
        let(:cart_tax_country_iso) { "DE" }
        it { is_expected.to eq("DE") }
      end

      context "when the store has no cart tax country set" do
        let(:cart_tax_country_iso) { nil }
        it { is_expected.to be_nil }
      end
    end

    context "from context" do
      subject { controller.current_pricing_options }

      let(:store) { FactoryBot.create :store, default_currency: 'USD' }

      context "when the whole context is passed" do
        it "receives the right object " do
          expect(Spree::Config.pricing_options_class).to receive(:from_context).with(controller)
          is_expected.to be_nil
        end
      end
    end
  end
end
