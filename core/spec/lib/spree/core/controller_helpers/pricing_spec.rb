require 'spec_helper'

class FakesController < ApplicationController
  include Spree::Core::ControllerHelpers::Pricing
end

describe Spree::Core::ControllerHelpers::Pricing, type: :controller do
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
      let(:store) { FactoryGirl.create :store, default_currency: '' }

      it { Spree::Deprecation.silence { is_expected.to eq('USD') } }
    end

    context "when the current store default_currency is a currency" do
      let(:store) { FactoryGirl.create :store, default_currency: 'EUR' }

      it { Spree::Deprecation.silence { is_expected.to eq('EUR') } }
    end
  end

  describe '#current_pricing_options' do
    subject { controller.current_pricing_options }

    let(:store) { FactoryGirl.create(:store, default_currency: nil) }

    it { is_expected.to be_a(Spree::Config.pricing_options_class) }

    context "currency" do
      subject { controller.current_pricing_options.currency }

      context "when store default_currency is nil" do
        let(:store) { nil }
        it { is_expected.to eq('USD') }
      end

      context "when the current store default_currency empty" do
        let(:store) { FactoryGirl.create :store, default_currency: '' }

        it { is_expected.to eq('USD') }
      end

      context "when the current store default_currency is a currency" do
        let(:store) { FactoryGirl.create :store, default_currency: 'EUR' }

        it { is_expected.to eq('EUR') }
      end
    end
  end
end
