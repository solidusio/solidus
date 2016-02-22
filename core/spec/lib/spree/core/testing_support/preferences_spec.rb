require 'spec_helper'

RSpec.describe Spree::TestingSupport::Preferences do
  describe 'resetting the app configuration' do
    before do
      @original_spree_mails_from = Spree::Config.mails_from
      @original_spree_searcher_class = Spree::Config.searcher_class
      class MySearcherClass; end
      include Spree::TestingSupport::Preferences
      Spree::Config.mails_from = "hello@myserver.com"
      Spree::Config.searcher_class = MySearcherClass
    end

    it 'resets normal preferences' do
      expect(Spree::Config.mails_from).to eq("hello@myserver.com")
      reset_spree_preferences
      expect(Spree::Config.mails_from).to eq(@original_spree_mails_from)
    end

    it 'resets cached configuration instance variables' do
      expect(Spree::Config.searcher_class).to eq(MySearcherClass)
      reset_spree_preferences
      expect(Spree::Config.searcher_class).to eq(@original_spree_searcher_class)
    end
  end
end
