# encoding: utf-8

require 'spec_helper'

describe "Translation" do
  def translation
    I18n.t("activerecord.attributes.spree/address.zipcode")
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

  # Chilean spanish is chosen
  context 'when current locale is Chilean Spanish' do
    it 'translation is available' do
      I18n.locale = :'es-CL'
      translation.should == 'Código Postal'
    end
  end
end
