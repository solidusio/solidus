require 'spec_helper'

RSpec.describe "solidus_i18n" do
  describe 'defined locales' do
    subject do
      I18n.available_locales.select do |locale|
        I18n.t('spree.i18n.this_file_language', locale: locale, fallback: false, default: nil)
      end
    end

    it "contains the added locales" do
      # Add to this list when adding/removing locales
      expect(subject).to match_array %i[
        en
        zh-CN
        cs
        zh-TW
        it
        nl
        da
        tr
        id
        ro
        pt-BR
        ja
        es
        fr
        de
        ru
        uk
        ko
        pt
        et
        sk
        pl
        nb
        fa
        fi
        en-NZ
        en-IN
        en-AU
        bg
        en-GB
        de-CH
        es-MX
        es-CL
        th
        ca
        vi
        sv
        es-EC
        lv
        sl-SI
      ]
    end

    it "has a unique description for each locale" do
      descriptions = subject.map do |locale|
        I18n.t('spree.i18n.this_file_language', locale: locale)
      end

      expect(descriptions.uniq).to eq(descriptions)
    end
  end
end
