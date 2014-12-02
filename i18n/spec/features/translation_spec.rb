# encoding: utf-8

RSpec.describe "Translation" do
  def translation
    I18n.t("activerecord.attributes.spree/address.zipcode")
  end

  context "when current locale is en" do
    it "translation is available" do
      I18n.locale = :en
      expect(translation).to eq "Zip Code"
    end
  end

  # German is chosen as an example of language whose translations are found in a file.
  context "when current locale is German" do
    it "translation is available" do
      I18n.locale = :de
      expect(translation).to eq "PLZ"
    end
  end

  # Chilean spanish is chosen
  context 'when current locale is Chilean Spanish' do
    it 'translation is available' do
      I18n.locale = :'es-CL'
      expect(translation).to eq 'Código Postal'
    end
  end
end
