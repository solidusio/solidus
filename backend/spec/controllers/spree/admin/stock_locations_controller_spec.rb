# frozen_string_literal: true

require 'spec_helper'

module Spree
  module Admin
    describe StockLocationsController, type: :controller do
      stub_authorization!

      # Regression for https://github.com/spree/spree/issues/4272
      context "with no countries present" do
        it "cannot create a new stock location" do
          get :new
          expect(flash[:error]).to eq(I18n.t('spree.stock_locations_need_a_default_country'))
          expect(response).to redirect_to(spree.admin_stock_locations_path)
        end
      end

      context "with a default country other than the US present" do
        let(:country) { create :country, iso: "BR" }

        before do
          stub_spree_preferences(default_country_iso: country.iso)
        end

        it "can create a new stock location" do
          get :new
          expect(response).to be_successful
        end
      end

      context "with a country with the ISO code of 'US' existing" do
        before do
          FactoryBot.create(:country, iso: 'US')
        end

        it "can create a new stock location" do
          get :new
          expect(response).to be_successful
        end
      end
    end
  end
end
