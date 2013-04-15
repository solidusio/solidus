require 'spec_helper'

describe "Frontend locale selector" do
  context "changes locale", js: true do
    let(:locale) { Spree::Config.supported_locales.last }
    let(:language) { I18n.t("this_file_language", locale: locale) }

    it "updates localization sitewide" do
      visit spree.root_path

      within "#locale-select" do
        select language, from: "locale"
      end

      visit spree.root_path
      I18n.locale.to_s.should == locale
    end
  end
end
