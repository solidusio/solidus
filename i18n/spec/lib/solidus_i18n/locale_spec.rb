require 'spec_helper'

RSpec.describe SolidusI18n::Locale do
  describe '.all' do
    subject { SolidusI18n::Locale.all }

    it "Contains all available Solidus locales" do
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
  end
end
