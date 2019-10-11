# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Solidus::TestingSupport::Preferences do
  describe 'resetting the app configuration' do
    around do |example|
      with_unfrozen_spree_preference_store do
        Solidus::Deprecation.silence do
          example.run
        end
      end
    end

    before do
      reset_spree_preferences
      @original_spree_mails_from = Solidus::Config.mails_from
      @original_spree_searcher_class = Solidus::Config.searcher_class
      class MySearcherClass; end
      include Solidus::TestingSupport::Preferences
      Solidus::Config.mails_from = "hello@myserver.com"
      Solidus::Config.searcher_class = MySearcherClass
    end

    it 'resets normal preferences' do
      expect(Solidus::Config.mails_from).to eq("hello@myserver.com")
      reset_spree_preferences
      expect(Solidus::Config.mails_from).to eq(@original_spree_mails_from)
    end

    it 'resets cached configuration instance variables' do
      expect(Solidus::Config.searcher_class).to eq(MySearcherClass)
      reset_spree_preferences
      expect(Solidus::Config.searcher_class).to eq(@original_spree_searcher_class)
    end
  end

  describe '#stub_spree_preferences' do
    it 'stubs method calls but does not affect actual stored Solidus::Config settings' do
      stub_spree_preferences(currency: 'FOO')
      expect(Solidus::Config.currency).to eq 'FOO'
      expect(Solidus::Config.preference_store[:currency]).to eq 'USD'
    end
  end

  describe '#with_unfrozen_spree_preference_store' do
    it 'changes the original settings, but returns them to original values at exit' do
      with_unfrozen_spree_preference_store do
        Solidus::Config.mails_from = 'override@example.com'
        expect(Solidus::Config.mails_from).to eq 'override@example.com'
        expect(Solidus::Config.preference_store[:mails_from]).to eq 'override@example.com'
      end

      # both the original frozen store and the unfrozen store are unaffected by changes above:
      expect(Solidus::Config.mails_from).to eq 'store@example.com'
      with_unfrozen_spree_preference_store do
        expect(Solidus::Config.mails_from).to eq 'store@example.com'
      end
    end
  end
end
