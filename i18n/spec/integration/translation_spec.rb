# encoding: utf-8

require 'spec_helper'

describe "Translation" do

  let(:app) do
    SpreeI18n::Spec::FakeApp
  end
  
  let(:translation) do
    SpreeI18n::Spec::FakeApp.run lambda { I18n.t("activerecord.attributes.spree/address.zipcode") }
  end

  context "when current locale is en" do
    it "translation is available" do
      I18n.locale = :en
      translation.should == "Zip Code"
    end
  end

  # German is chosen as an example of language whose translations are found in a file.
  context "when current locale is German" do
    it "translation is available" do
      I18n.locale = :de
      translation.should == "PLZ"
    end
  end

  # Japanese is chosen as an example of language whose translations are splitted into
  # several files in a separated directory.
  context "when default locale is Japanese" do
    it "translation is available" do
      I18n.locale = :ja
      translation.should == "郵便番号"
    end
  end
  
  context "when current locale is Japanese, but it is not included in available_locales" do
    let(:translation) do
      SpreeI18n::Spec::FakeApp.run lambda { I18n.t("activerecord.attributes.spree/address.zipcode") } do |config|
        config.i18n.available_locales = [ :de, :en, :fr ]
      end
    end

    it "translation is not available" do
      I18n.locale = :ja
      translation.should == "translation missing: ja.activerecord.attributes.spree/address.zipcode"
    end
  end
end
