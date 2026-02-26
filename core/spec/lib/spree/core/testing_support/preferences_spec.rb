# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::TestingSupport::Preferences do
  describe "#stub_spree_preferences" do
    it "stubs method calls but does not affect actual stored Spree::Config settings" do
      stub_spree_preferences(currency: "FOO")
      expect(Spree::Config.currency).to eq "FOO"
      expect(Spree::Config.preference_store[:currency]).to eq "USD"
    end
  end

  describe "#with_unfrozen_spree_preference_store" do
    it "changes the original settings, but returns them to original values at exit" do
      with_unfrozen_spree_preference_store do
        Spree::Config.currency = "EUR"
        expect(Spree::Config.currency).to eq "EUR"
        expect(Spree::Config.preference_store[:currency]).to eq "EUR"
      end

      # both the original frozen store and the unfrozen store are unaffected by changes above:
      expect(Spree::Config.currency).to eq "USD"
      with_unfrozen_spree_preference_store do
        expect(Spree::Config.currency).to eq "USD"
      end
    end
  end
end
